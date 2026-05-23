"""FastAPI dependency helpers for data stores."""

import uuid
from collections.abc import AsyncGenerator

import redis.asyncio as aioredis
from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import AuthInvalidTokenError, AuthRequiredError
from app.core.security import verify_jwt
from app.db.base import AsyncSessionLocal
from app.db.redis import RedisManager
from app.models.user import UserModel


async def get_db() -> AsyncGenerator[AsyncSession]:
    """Yield an async database session."""
    async with AsyncSessionLocal() as session:
        yield session


oauth2_scheme = HTTPBearer(auto_error=False)


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


async def get_current_user(
    token: HTTPAuthorizationCredentials | None = Depends(oauth2_scheme),  # noqa: B008
    session: AsyncSession = Depends(get_db),  # noqa: B008
) -> UserModel:
    """Return the current authenticated user or raise auth errors."""
    if not token or not token.credentials:
        raise AuthRequiredError()

    claims = verify_jwt(token.credentials)
    if claims.get("type") != "access":
        raise AuthInvalidTokenError()

    user_id = claims.get("sub")
    if not user_id:
        raise AuthInvalidTokenError()

    try:
        user_uuid = uuid.UUID(str(user_id))
    except ValueError as exc:
        raise AuthInvalidTokenError() from exc

    result = await session.execute(select(UserModel).where(UserModel.id == user_uuid))
    user = result.scalar_one_or_none()
    if user is None:
        raise AuthInvalidTokenError()

    return user
