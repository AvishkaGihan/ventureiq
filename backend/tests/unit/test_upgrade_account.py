"""Unit tests for upgrade_account service logic."""

from __future__ import annotations

import uuid
from unittest.mock import AsyncMock, MagicMock

import pytest

from app.core.config import get_settings
from app.core.exceptions import AuthInvalidTokenError, AuthUpgradeConflictError
from app.services import auth_service


def _set_auth_env(monkeypatch: pytest.MonkeyPatch, access_minutes: int = 60, refresh_days: int = 7) -> None:
    monkeypatch.setenv("JWT_SECRET_KEY", "test-secret")
    monkeypatch.setenv("JWT_ALGORITHM", "HS256")
    monkeypatch.setenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", str(access_minutes))
    monkeypatch.setenv("JWT_REFRESH_TOKEN_EXPIRE_DAYS", str(refresh_days))
    get_settings.cache_clear()


def _make_anonymous_user(user_id: uuid.UUID | None = None) -> MagicMock:
    """Create a mock anonymous user."""
    user = MagicMock()
    user.id = user_id or uuid.uuid4()
    user.tier = "free"
    user.auth_provider = "anonymous"
    user.email = None
    user.display_name = None
    user.photo_url = None
    user.firebase_uid = "firebase-uid-123"
    return user


def _make_google_user(user_id: uuid.UUID | None = None) -> MagicMock:
    """Create a mock Google-authenticated user."""
    user = MagicMock()
    user.id = user_id or uuid.uuid4()
    user.tier = "free"
    user.auth_provider = "google"
    user.email = "user@gmail.com"
    user.display_name = "Test User"
    user.photo_url = "https://lh3.googleusercontent.com/photo"
    user.firebase_uid = "firebase-uid-123"
    return user


@pytest.mark.asyncio
async def test_upgrade_account_happy_path(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test upgrade from anonymous → google with updated claims."""
    _set_auth_env(monkeypatch)

    user = _make_anonymous_user()

    firebase_claims = {
        "uid": "firebase-uid-123",
        "email": "upgraded@gmail.com",
        "name": "Upgraded User",
        "picture": "https://lh3.googleusercontent.com/upgraded",
    }

    async def fake_verify(token: str) -> dict:
        return firebase_claims

    monkeypatch.setattr(auth_service, "verify_firebase_token", fake_verify)
    monkeypatch.setattr(auth_service, "create_access_token", lambda data: "upgrade-access-token")
    monkeypatch.setattr(auth_service, "create_refresh_token", lambda user_id: "upgrade-refresh-token")

    session = AsyncMock()
    result = MagicMock()
    result.scalar_one_or_none.side_effect = [user, None]
    session.execute = AsyncMock(return_value=result)

    response = await auth_service.upgrade_account("firebase-token", session)

    assert response.access_token == "upgrade-access-token"
    assert response.refresh_token == "upgrade-refresh-token"
    assert response.token_type == "bearer"
    assert response.expires_in == 3600

    # Verify user fields were updated
    assert user.auth_provider == "google"
    assert user.email == "upgraded@gmail.com"
    assert user.display_name == "Upgraded User"
    assert user.photo_url == "https://lh3.googleusercontent.com/upgraded"
    session.commit.assert_awaited_once()
    session.refresh.assert_awaited_once_with(user)


@pytest.mark.asyncio
async def test_upgrade_account_user_not_found(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test error when Firebase UID maps to no existing user."""
    _set_auth_env(monkeypatch)

    async def fake_verify(token: str) -> dict:
        return {"uid": "nonexistent-uid"}

    monkeypatch.setattr(auth_service, "verify_firebase_token", fake_verify)

    session = AsyncMock()
    result = MagicMock()
    result.scalar_one_or_none.return_value = None
    session.execute = AsyncMock(return_value=result)

    with pytest.raises(AuthInvalidTokenError, match="User not found for upgrade"):
        await auth_service.upgrade_account("firebase-token", session)


@pytest.mark.asyncio
async def test_upgrade_account_already_authenticated(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test error when user is already Google-authenticated."""
    _set_auth_env(monkeypatch)

    user = _make_google_user()

    async def fake_verify(token: str) -> dict:
        return {"uid": "firebase-uid-123"}

    monkeypatch.setattr(auth_service, "verify_firebase_token", fake_verify)

    session = AsyncMock()
    result = MagicMock()
    result.scalar_one_or_none.return_value = user
    session.execute = AsyncMock(return_value=result)

    with pytest.raises(AuthUpgradeConflictError, match="already authenticated"):
        await auth_service.upgrade_account("firebase-token", session)


@pytest.mark.asyncio
async def test_upgrade_account_email_conflict(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test error when Google account email is already in use by another user."""
    _set_auth_env(monkeypatch)

    user = _make_anonymous_user()

    async def fake_verify(token: str) -> dict:
        return {
            "uid": "firebase-uid-123",
            "email": "existing@gmail.com",
            "name": "Test User",
            "picture": "https://lh3.googleusercontent.com/photo",
        }

    monkeypatch.setattr(auth_service, "verify_firebase_token", fake_verify)

    session = AsyncMock()
    # Mock first select (user row to upgrade) -> returns user
    # Mock second select (email duplicate check) -> returns another user row
    another_user = _make_google_user(user_id=uuid.uuid4())
    another_user.firebase_uid = "firebase-uid-another"
    another_user.email = "existing@gmail.com"

    result_user = MagicMock()
    result_user.scalar_one_or_none.side_effect = [user, another_user]
    session.execute = AsyncMock(return_value=result_user)

    with pytest.raises(AuthUpgradeConflictError, match="already linked to another VentureIQ account"):
        await auth_service.upgrade_account("firebase-token", session)


@pytest.mark.asyncio
async def test_upgrade_account_profile_fallback_path(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test fallback to Firebase Admin SDK when name and picture are missing in claims."""
    _set_auth_env(monkeypatch)

    user = _make_anonymous_user()

    async def fake_verify(token: str) -> dict:
        return {
            "uid": "firebase-uid-123",
            "email": "fallback@gmail.com",
            # missing "name" and "picture"
        }

    monkeypatch.setattr(auth_service, "verify_firebase_token", fake_verify)
    monkeypatch.setattr(auth_service, "create_access_token", lambda data: "upgrade-access-token")
    monkeypatch.setattr(auth_service, "create_refresh_token", lambda user_id: "upgrade-refresh-token")

    # Mock fb_auth.get_user
    mock_fb_user = MagicMock()
    mock_fb_user.display_name = "Firebase Admin Name"
    mock_fb_user.photo_url = "https://lh3.firebase.com/photo"
    monkeypatch.setattr(auth_service.fb_auth, "get_user", lambda uid: mock_fb_user)

    session = AsyncMock()
    result = MagicMock()
    # first: user to upgrade, second: email uniqueness check (returns None)
    result.scalar_one_or_none.side_effect = [user, None]
    session.execute = AsyncMock(return_value=result)

    response = await auth_service.upgrade_account("firebase-token", session)

    assert response.access_token == "upgrade-access-token"
    assert user.display_name == "Firebase Admin Name"
    assert user.photo_url == "https://lh3.firebase.com/photo"
