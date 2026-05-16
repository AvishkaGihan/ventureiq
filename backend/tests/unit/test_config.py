"""Unit tests for configuration settings."""

import pytest
from pydantic import ValidationError

from app.core.config import Settings


def test_settings_defaults(monkeypatch):
    """Ensure default values load when env vars are not set."""
    monkeypatch.delenv("APP_ENV", raising=False)
    monkeypatch.delenv("APP_DEBUG", raising=False)
    monkeypatch.delenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", raising=False)
    monkeypatch.delenv("JWT_REFRESH_TOKEN_EXPIRE_DAYS", raising=False)

    settings = Settings()

    assert settings.APP_ENV == "development"
    assert settings.APP_DEBUG is True
    assert settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES == 60
    assert settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS == 7
    assert settings.LLM_PRIMARY_PROVIDER == "gemini"
    assert settings.LLM_FALLBACK_PROVIDER == "openrouter"
    assert settings.SEARCH_PRIMARY_PROVIDER == "duckduckgo"
    assert settings.OPENROUTER_MODEL == "google/gemini-2.5-flash"
    assert settings.is_development is True


def test_settings_env_overrides(monkeypatch):
    """Ensure environment variables override defaults."""
    monkeypatch.setenv("DATABASE_URL", "postgresql+asyncpg://override")
    monkeypatch.setenv("APP_DEBUG", "false")
    monkeypatch.setenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "120")

    settings = Settings()

    assert settings.DATABASE_URL == "postgresql+asyncpg://override"
    assert settings.APP_DEBUG is False
    assert settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES == 120


def test_settings_type_validation():
    """Ensure invalid types raise validation errors."""
    with pytest.raises(ValidationError):
        Settings(JWT_ACCESS_TOKEN_EXPIRE_MINUTES="not-an-int")
