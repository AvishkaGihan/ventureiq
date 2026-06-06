"""Tests for report-generation rate limiting."""

from __future__ import annotations

from datetime import UTC, datetime

import pytest

from app.core.config import Settings
from app.services.rate_limit_service import RateLimitService


class FakeRedis:
    """Small Redis ZSET double for the rate limit Lua contract."""

    def __init__(self) -> None:
        self.zsets: dict[str, dict[str, float]] = {}
        self.ttls: dict[str, int] = {}
        self.fail_eval = False

    async def eval(
        self,
        script: str,
        numkeys: int,
        key: str,
        now: int,
        limit: int,
        ttl: int,
        member: str,
    ) -> list[int]:
        if self.fail_eval:
            raise ConnectionError("redis unavailable")

        zset = self.zsets.setdefault(key, {})
        
        count = len(zset)
        if count < limit:
            zset[member] = now
            if count == 0:
                self.ttls[key] = ttl
            return [1, count + 1]
        return [0, count]

    async def zremrangebyscore(self, key: str, minimum: int | str, maximum: int) -> int:
        zset = self.zsets.setdefault(key, {})
        removed = 0
        for member, score in list(zset.items()):
            if score <= maximum:
                del zset[member]
                removed += 1
        return removed

    async def zcard(self, key: str) -> int:
        return len(self.zsets.setdefault(key, {}))

    async def expire(self, key: str, ttl: int) -> bool:
        self.ttls[key] = ttl
        return True


@pytest.fixture
def settings() -> Settings:
    """Return rate-limit test settings."""
    return Settings(
        RATE_LIMIT_FREE_TIER_MONTHLY=3,
        RATE_LIMIT_ANONYMOUS_TIER_MONTHLY=3,
        RATE_LIMIT_PRO_TIER_MONTHLY=0,
        RATE_LIMIT_ENABLED=True,
    )


@pytest.mark.asyncio
async def test_free_tier_is_limited_to_three_reports_per_month(settings: Settings) -> None:
    redis = FakeRedis()
    service = RateLimitService(redis=redis, settings=settings, now_func=lambda: datetime(2026, 6, 5, tzinfo=UTC))

    first = await service.check_and_increment("user-1", "free")
    second = await service.check_and_increment("user-1", "free")
    third = await service.check_and_increment("user-1", "free")
    fourth = await service.check_and_increment("user-1", "free")

    assert [first.allowed, second.allowed, third.allowed, fourth.allowed] == [True, True, True, False]
    assert fourth.current_count == 3
    assert fourth.limit == 3
    assert fourth.reset_at == datetime(2026, 7, 1, tzinfo=UTC)
    assert redis.ttls["rate_limit:reports:user-1:2026-06"] > 0


@pytest.mark.asyncio
async def test_calendar_month_boundary_uses_new_key(settings: Settings) -> None:
    redis = FakeRedis()
    june_service = RateLimitService(
        redis=redis,
        settings=settings,
        now_func=lambda: datetime(2026, 6, 30, 23, 59, tzinfo=UTC),
    )
    july_service = RateLimitService(redis=redis, settings=settings, now_func=lambda: datetime(2026, 7, 1, tzinfo=UTC))

    for _ in range(3):
        assert (await june_service.check_and_increment("user-1", "free")).allowed is True

    assert (await june_service.check_and_increment("user-1", "free")).allowed is False
    july_result = await july_service.check_and_increment("user-1", "free")

    assert july_result.allowed is True
    assert july_result.current_count == 1
    assert july_result.reset_at == datetime(2026, 8, 1, tzinfo=UTC)


@pytest.mark.asyncio
async def test_pro_tier_bypasses_redis(settings: Settings) -> None:
    redis = FakeRedis()
    redis.fail_eval = True
    service = RateLimitService(redis=redis, settings=settings, now_func=lambda: datetime(2026, 6, 5, tzinfo=UTC))

    result = await service.check_and_increment("user-1", "pro")

    assert result.allowed is True
    assert result.current_count == 0
    assert result.limit == 0


@pytest.mark.asyncio
async def test_redis_failure_fails_open(settings: Settings) -> None:
    redis = FakeRedis()
    redis.fail_eval = True
    service = RateLimitService(redis=redis, settings=settings, now_func=lambda: datetime(2026, 6, 5, tzinfo=UTC))

    result = await service.check_and_increment("user-1", "free")

    assert result.allowed is True
    assert result.current_count == 0
    assert result.limit == 3


@pytest.mark.asyncio
async def test_get_usage_is_read_only(settings: Settings) -> None:
    redis = FakeRedis()
    service = RateLimitService(redis=redis, settings=settings, now_func=lambda: datetime(2026, 6, 5, tzinfo=UTC))

    await service.check_and_increment("user-1", "anonymous")
    usage = await service.get_usage("user-1", "anonymous")

    assert usage.allowed is True
    assert usage.current_count == 1
    assert usage.limit == 3
