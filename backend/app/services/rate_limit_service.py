"""Redis-backed report generation rate limiting."""

from __future__ import annotations

import logging
import uuid
from collections.abc import Callable
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta

import redis.asyncio as aioredis

from app.core.config import Settings, get_settings

logger = logging.getLogger(__name__)


REPORT_LIMIT_LUA_SCRIPT = """
local count = redis.call('ZCARD', KEYS[1])
if count < tonumber(ARGV[2]) then
  redis.call('ZADD', KEYS[1], ARGV[1], ARGV[4])
  if count == 0 then
    redis.call('EXPIRE', KEYS[1], tonumber(ARGV[3]))
  end
  return {1, count + 1}
else
  return {0, count}
end
"""


@dataclass(frozen=True)
class RateLimitResult:
    """Result of a rate-limit check."""

    allowed: bool
    current_count: int
    limit: int
    reset_at: datetime

    @property
    def remaining(self) -> int:
        """Return reports remaining in the current month."""
        if self.limit == 0:
            return 0
        return max(self.limit - self.current_count, 0)

    @property
    def retry_after_seconds(self) -> int:
        """Return seconds until the monthly limit resets."""
        return max(int((self.reset_at - datetime.now(UTC)).total_seconds()), 0)


class RateLimitService:
    """Enforce monthly report-generation limits with Redis db2."""

    def __init__(
        self,
        redis: aioredis.Redis,
        settings: Settings | None = None,
        now_func: Callable[[], datetime] | None = None,
    ) -> None:
        self.redis = redis
        self.settings = settings or get_settings()
        self._now_func = now_func or (lambda: datetime.now(UTC))

    async def check_and_increment(self, user_id: str, tier: str) -> RateLimitResult:
        """Atomically check and increment report usage for the current month."""
        limit = self._limit_for_tier(tier)
        reset_at = self._month_reset_at()
        if not self.settings.RATE_LIMIT_ENABLED or limit == 0:
            return RateLimitResult(allowed=True, current_count=0, limit=limit, reset_at=reset_at)

        key = self._key(user_id)
        now_ms = int(self._now().timestamp() * 1000)
        ttl_seconds = self._ttl_seconds(reset_at)
        member = f"{now_ms}-{uuid.uuid4().hex[:8]}"

        try:
            allowed, current_count = await self.redis.eval(
                REPORT_LIMIT_LUA_SCRIPT,
                1,
                key,
                now_ms,
                limit,
                ttl_seconds,
                member,
            )
        except Exception:
            logger.warning("Redis rate limit check failed; allowing request", exc_info=True)
            return RateLimitResult(allowed=True, current_count=0, limit=limit, reset_at=reset_at)

        return RateLimitResult(
            allowed=bool(int(allowed)),
            current_count=int(current_count),
            limit=limit,
            reset_at=reset_at,
        )

    async def get_usage(self, user_id: str, tier: str) -> RateLimitResult:
        """Return current usage without incrementing the report count."""
        limit = self._limit_for_tier(tier)
        reset_at = self._month_reset_at()
        if limit == 0:
            return RateLimitResult(allowed=True, current_count=0, limit=limit, reset_at=reset_at)

        key = self._key(user_id)
        current_count = int(await self.redis.zcard(key))

        return RateLimitResult(
            allowed=current_count < limit,
            current_count=current_count,
            limit=limit,
            reset_at=reset_at,
        )

    def _limit_for_tier(self, tier: str) -> int:
        normalized = tier.lower()
        if normalized == "pro":
            return self.settings.RATE_LIMIT_PRO_TIER_MONTHLY
        if normalized == "anonymous":
            return self.settings.RATE_LIMIT_ANONYMOUS_TIER_MONTHLY
        return self.settings.RATE_LIMIT_FREE_TIER_MONTHLY

    def _key(self, user_id: str) -> str:
        now = self._now()
        return f"rate_limit:reports:{user_id}:{now:%Y-%m}"

    def _now(self) -> datetime:
        now = self._now_func()
        return now.astimezone(UTC)

    def _month_start(self) -> datetime:
        now = self._now()
        return now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    def _month_reset_at(self) -> datetime:
        month_start = self._month_start()
        if month_start.month == 12:
            return month_start.replace(year=month_start.year + 1, month=1)
        return month_start.replace(month=month_start.month + 1)

    def _ttl_seconds(self, reset_at: datetime) -> int:
        ttl = reset_at - self._now()
        return max(int(ttl / timedelta(seconds=1)), 1)
