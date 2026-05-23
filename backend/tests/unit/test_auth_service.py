"""Unit tests for authentication service logic."""

from __future__ import annotations

import uuid
from unittest.mock import AsyncMock, MagicMock

import pytest

from app.core.config import get_settings
from app.core.exceptions import AuthInvalidTokenError
from app.services import auth_service


def _set_auth_env(monkeypatch: pytest.MonkeyPatch, access_minutes: int = 60, refresh_days: int = 7) -> None:
    monkeypatch.setenv("JWT_SECRET_KEY", "test-secret")
    monkeypatch.setenv("JWT_ALGORITHM", "HS256")
    monkeypatch.setenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", str(access_minutes))
    monkeypatch.setenv("JWT_REFRESH_TOKEN_EXPIRE_DAYS", str(refresh_days))
    get_settings.cache_clear()


@pytest.mark.asyncio
async def test_exchange_token_returns_token_pair(monkeypatch: pytest.MonkeyPatch) -> None:
    _set_auth_env(monkeypatch)

    user = MagicMock()
    user.id = uuid.uuid4()
    user.tier = "free"
    user.auth_provider = "google"

    async def fake_verify(token: str) -> dict[str, str]:
        return {"uid": "firebase-uid"}

    async def fake_get_or_create(claims: dict[str, str], db: AsyncMock) -> MagicMock:
        return user

    monkeypatch.setattr(auth_service, "verify_firebase_token", fake_verify)
    monkeypatch.setattr(auth_service, "get_or_create_user", fake_get_or_create)
    monkeypatch.setattr(auth_service, "create_access_token", lambda data: "access-token")
    monkeypatch.setattr(auth_service, "create_refresh_token", lambda user_id: "refresh-token")

    response = await auth_service.exchange_token("firebase-token", AsyncMock())

    assert response.access_token == "access-token"
    assert response.refresh_token == "refresh-token"
    assert response.token_type == "bearer"
    assert response.expires_in == 3600


@pytest.mark.asyncio
async def test_refresh_tokens_rotates_and_marks_used(monkeypatch: pytest.MonkeyPatch) -> None:
    _set_auth_env(monkeypatch)

    user_id = uuid.uuid4()
    payload = {"sub": str(user_id), "jti": "old-jti", "type": "refresh"}
    monkeypatch.setattr(auth_service, "verify_jwt", lambda token: payload)
    monkeypatch.setattr(auth_service, "create_access_token", lambda data: "new-access")
    monkeypatch.setattr(auth_service, "create_refresh_token", lambda user_id: "new-refresh")

    redis = AsyncMock()
    redis.set = AsyncMock(return_value=True)

    session = AsyncMock()
    result = MagicMock()
    user = MagicMock()
    user.id = user_id
    user.tier = "free"
    user.auth_provider = "google"
    result.scalar_one_or_none.return_value = user
    session.execute = AsyncMock(return_value=result)

    response = await auth_service.refresh_tokens("refresh-token", session, redis)

    assert response.access_token == "new-access"
    assert response.refresh_token == "new-refresh"
    redis.set.assert_awaited_with("refresh_token:old-jti", "used", ex=7 * 24 * 60 * 60, nx=True)


@pytest.mark.asyncio
async def test_refresh_tokens_rejects_reuse(monkeypatch: pytest.MonkeyPatch) -> None:
    _set_auth_env(monkeypatch)

    payload = {"sub": str(uuid.uuid4()), "jti": "old-jti", "type": "refresh"}
    monkeypatch.setattr(auth_service, "verify_jwt", lambda token: payload)

    redis = AsyncMock()
    redis.set = AsyncMock(return_value=False)

    session = AsyncMock()

    with pytest.raises(AuthInvalidTokenError):
        await auth_service.refresh_tokens("refresh-token", session, redis)
