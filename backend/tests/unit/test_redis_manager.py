"""Unit tests for RedisManager."""

import asyncio
from unittest.mock import AsyncMock, patch

import pytest

from app.db.redis import RedisManager


def test_redis_manager_requires_connect_for_properties():
    """Ensure accessing redis connections before connect raises an assertion."""
    manager = RedisManager("redis://localhost:6379")

    with pytest.raises(AssertionError):
        _ = manager.streaming

    with pytest.raises(AssertionError):
        _ = manager.cache

    with pytest.raises(AssertionError):
        _ = manager.rate_limit


def test_redis_manager_connects_and_exposes_connections():
    """Ensure connect initializes all logical database connections."""
    manager = RedisManager("redis://localhost:6379")
    streaming = AsyncMock()
    cache = AsyncMock()
    rate_limit = AsyncMock()

    with patch("app.db.redis.aioredis.from_url", side_effect=[streaming, cache, rate_limit]) as from_url:
        asyncio.run(manager.connect())

    from_url.assert_any_call("redis://localhost:6379/0", decode_responses=True)
    from_url.assert_any_call("redis://localhost:6379/1", decode_responses=True)
    from_url.assert_any_call("redis://localhost:6379/2", decode_responses=True)

    assert manager.streaming is streaming
    assert manager.cache is cache
    assert manager.rate_limit is rate_limit


def test_redis_manager_close_calls_aclose():
    """Ensure close calls aclose on all configured connections."""
    manager = RedisManager("redis://localhost:6379")
    manager._streaming = AsyncMock()
    manager._cache = AsyncMock()
    manager._rate_limit = AsyncMock()

    asyncio.run(manager.close())

    manager._streaming.aclose.assert_awaited_once()
    manager._cache.aclose.assert_awaited_once()
    manager._rate_limit.aclose.assert_awaited_once()


def test_redis_manager_health_check_handles_failures():
    """Ensure health_check reports False when a ping fails."""
    manager = RedisManager("redis://localhost:6379")
    streaming = AsyncMock()
    streaming.ping = AsyncMock(return_value=True)
    cache = AsyncMock()
    cache.ping = AsyncMock(side_effect=RuntimeError("boom"))
    rate_limit = AsyncMock()
    rate_limit.ping = AsyncMock(return_value=True)

    manager._streaming = streaming
    manager._cache = cache
    manager._rate_limit = rate_limit

    results = asyncio.run(manager.health_check())

    assert results == {"streaming": True, "cache": False, "rate_limit": True}
