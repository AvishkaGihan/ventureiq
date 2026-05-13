"""Pytest configuration and shared fixtures."""

from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.core.dependencies import get_db, get_redis_manager
from app.main import create_app


@pytest.fixture(autouse=True)
def clear_settings_cache(monkeypatch):
    """Clear cached settings between tests."""
    monkeypatch.setenv("APP_ENV", "test")
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


@pytest.fixture
def client():
    """Create a test client for the FastAPI application."""
    app = create_app()

    async def override_get_db():
        session = AsyncMock()
        result = MagicMock()
        result.scalar.return_value = 1
        session.execute = AsyncMock(return_value=result)
        yield session

    class DummyRedisManager:
        def __init__(self):
            self.streaming = AsyncMock()
            self.cache = AsyncMock()
            self.rate_limit = AsyncMock()
            
        async def health_check(self) -> dict[str, bool]:
            return {"streaming": True, "cache": True, "rate_limit": True}

    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[get_redis_manager] = lambda: DummyRedisManager()

    with TestClient(app) as test_client:
        yield test_client
        
    app.dependency_overrides.clear()
