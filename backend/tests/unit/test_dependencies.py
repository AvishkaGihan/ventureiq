"""Unit tests for FastAPI dependencies."""

import asyncio
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

import pytest

from app.core import dependencies


class DummySession:
    """Async context manager for testing get_db."""

    def __init__(self) -> None:
        self.closed = False

    async def __aenter__(self) -> "DummySession":
        return self

    async def __aexit__(self, exc_type, exc, tb) -> None:
        self.closed = True


def test_get_db_yields_and_closes_session():
    """Ensure get_db yields a session and closes it afterwards."""
    dummy_session = DummySession()

    async def consume_session() -> DummySession:
        async for session in dependencies.get_db():
            return session
        raise AssertionError("Session was not yielded")

    with patch.object(dependencies, "AsyncSessionLocal", return_value=dummy_session):
        session = asyncio.run(consume_session())

    assert session is dummy_session
    assert dummy_session.closed is True


def test_get_redis_routes_connections():
    """Ensure get_redis routes to the correct logical database."""
    streaming = MagicMock()
    cache = MagicMock()
    rate_limit = MagicMock()
    manager = SimpleNamespace(streaming=streaming, cache=cache, rate_limit=rate_limit)
    request = SimpleNamespace(app=SimpleNamespace(state=SimpleNamespace(redis_manager=manager)))

    assert dependencies.get_redis_manager(request) is manager
    assert dependencies.get_redis(request, db=0) is streaming
    assert dependencies.get_redis(request, db=1) is cache
    assert dependencies.get_redis(request, db=2) is rate_limit

    with pytest.raises(ValueError):
        _ = dependencies.get_redis(request, db=3)
