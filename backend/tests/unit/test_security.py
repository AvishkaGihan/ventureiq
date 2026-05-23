"""Unit tests for JWT security helpers."""

from __future__ import annotations

import pytest

from app.core.config import get_settings
from app.core.exceptions import AuthInvalidTokenError
from app.core.security import create_access_token, create_refresh_token, init_firebase, verify_jwt


def _set_auth_env(monkeypatch: pytest.MonkeyPatch, access_minutes: int = 60, refresh_days: int = 7) -> None:
    monkeypatch.setenv("JWT_SECRET_KEY", "test-secret")
    monkeypatch.setenv("JWT_ALGORITHM", "HS256")
    monkeypatch.setenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", str(access_minutes))
    monkeypatch.setenv("JWT_REFRESH_TOKEN_EXPIRE_DAYS", str(refresh_days))
    get_settings.cache_clear()


def test_create_and_verify_access_token(monkeypatch: pytest.MonkeyPatch) -> None:
    _set_auth_env(monkeypatch)

    token = create_access_token(
        {
            "user_id": "user-123",
            "tier": "free",
            "auth_method": "google",
        }
    )
    claims = verify_jwt(token)

    assert claims["sub"] == "user-123"
    assert claims["tier"] == "free"
    assert claims["auth_method"] == "google"
    assert claims["type"] == "access"


def test_create_refresh_token(monkeypatch: pytest.MonkeyPatch) -> None:
    _set_auth_env(monkeypatch)

    token = create_refresh_token("user-123")
    claims = verify_jwt(token)

    assert claims["sub"] == "user-123"
    assert claims["type"] == "refresh"


def test_verify_jwt_rejects_expired_token(monkeypatch: pytest.MonkeyPatch) -> None:
    _set_auth_env(monkeypatch)
    settings = get_settings()
    monkeypatch.setattr(settings, "JWT_ACCESS_TOKEN_EXPIRE_MINUTES", -1)

    token = create_access_token(
        {
            "user_id": "user-123",
            "tier": "free",
            "auth_method": "anonymous",
        }
    )

    with pytest.raises(AuthInvalidTokenError):
        verify_jwt(token)


def test_verify_jwt_rejects_invalid_token(monkeypatch: pytest.MonkeyPatch) -> None:
    _set_auth_env(monkeypatch)

    with pytest.raises(AuthInvalidTokenError):
        verify_jwt("not-a-token")


def test_init_firebase_fails_fast(monkeypatch: pytest.MonkeyPatch) -> None:
    _set_auth_env(monkeypatch)
    settings = get_settings()
    monkeypatch.setattr(settings, "FIREBASE_SERVICE_ACCOUNT_PATH", "invalid-path-non-existent.json")
    
    with pytest.raises(FileNotFoundError):
        init_firebase(settings)
