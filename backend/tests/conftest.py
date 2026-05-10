"""Pytest configuration and shared fixtures."""

import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.main import create_app


@pytest.fixture(autouse=True)
def clear_settings_cache():
    """Clear cached settings between tests."""
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


@pytest.fixture
def client():
    """Create a test client for the FastAPI application."""
    app = create_app()
    with TestClient(app) as test_client:
        yield test_client
