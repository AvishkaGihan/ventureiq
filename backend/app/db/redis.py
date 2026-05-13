"""Redis connection manager for logical databases."""

import redis.asyncio as aioredis


class RedisManager:
    """Manage Redis connections across logical databases."""

    def __init__(self, redis_url: str) -> None:
        self._url = redis_url
        self._streaming: aioredis.Redis | None = None
        self._cache: aioredis.Redis | None = None
        self._rate_limit: aioredis.Redis | None = None

    async def connect(self) -> None:
        """Initialize Redis connections for streaming, cache, and rate limiting."""
        self._streaming = aioredis.from_url(f"{self._url}/0", decode_responses=True)
        self._cache = aioredis.from_url(f"{self._url}/1", decode_responses=True)
        self._rate_limit = aioredis.from_url(f"{self._url}/2", decode_responses=True)

    async def close(self) -> None:
        """Close all Redis connections."""
        for conn in (self._streaming, self._cache, self._rate_limit):
            if conn is not None:
                await conn.aclose()

    @property
    def streaming(self) -> aioredis.Redis:
        """Return the Redis connection for streaming state (db0)."""
        assert self._streaming is not None, "RedisManager.connect() not called"
        return self._streaming

    @property
    def cache(self) -> aioredis.Redis:
        """Return the Redis connection for cache (db1)."""
        assert self._cache is not None, "RedisManager.connect() not called"
        return self._cache

    @property
    def rate_limit(self) -> aioredis.Redis:
        """Return the Redis connection for rate limiting (db2)."""
        assert self._rate_limit is not None, "RedisManager.connect() not called"
        return self._rate_limit

    async def health_check(self) -> dict[str, bool]:
        """Ping all connections and return their availability."""
        results: dict[str, bool] = {}
        for name, conn in (
            ("streaming", self._streaming),
            ("cache", self._cache),
            ("rate_limit", self._rate_limit),
        ):
            try:
                results[name] = bool(conn and await conn.ping())
            except Exception:
                results[name] = False
        return results
