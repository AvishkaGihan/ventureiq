"""FastAPI dependency helpers for data stores."""

from collections.abc import AsyncGenerator

import redis.asyncio as aioredis
from fastapi import Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.base import AsyncSessionLocal
from app.db.redis import RedisManager


async def get_db() -> AsyncGenerator[AsyncSession]:
    """Yield an async database session."""
    async with AsyncSessionLocal() as session:
        yield session


def get_redis_manager(request: Request) -> RedisManager:
    """Return the Redis manager from application state."""
    return request.app.state.redis_manager


def get_redis(request: Request, db: int = 1) -> aioredis.Redis:
    """Return a Redis connection for the selected logical database."""
    redis_manager = get_redis_manager(request)

    if db == 0:
        return redis_manager.streaming
    if db == 1:
        return redis_manager.cache
    if db == 2:
        return redis_manager.rate_limit

    raise ValueError(f"Unsupported redis db: {db}")


def get_redis_streaming(request: Request) -> aioredis.Redis:
    """Return the Redis connection for streaming state (db0)."""
    return get_redis(request, db=0)


def get_redis_cache(request: Request) -> aioredis.Redis:
    """Return the Redis connection for cache (db1)."""
    return get_redis(request, db=1)


def get_redis_rate_limit(request: Request) -> aioredis.Redis:
    """Return the Redis connection for rate limiting (db2)."""
    return get_redis(request, db=2)
