"""Integration tests for POST /auth/upgrade endpoint."""

from __future__ import annotations

from unittest.mock import AsyncMock

from fastapi.testclient import TestClient

from app.api.v1.endpoints import auth as auth_endpoints
from app.core.dependencies import get_db
from app.core.exceptions import AuthInvalidTokenError, AuthUpgradeConflictError
from app.main import create_app
from app.schemas.auth import TokenResponseSchema


def _build_client() -> TestClient:
    app = create_app()

    async def override_get_db():
        yield AsyncMock()

    app.dependency_overrides[get_db] = override_get_db
    return TestClient(app)


def test_upgrade_endpoint_returns_envelope(monkeypatch):
    """Test successful upgrade returns standard envelope with token pair."""
    token_response = TokenResponseSchema(
        access_token="upgrade-access",
        refresh_token="upgrade-refresh",
        token_type="bearer",
        expires_in=3600,
    )
    monkeypatch.setattr(auth_endpoints, "upgrade_account", AsyncMock(return_value=token_response))

    with _build_client() as client:
        response = client.post("/api/v1/auth/upgrade", json={"firebase_token": "firebase-token"})

    assert response.status_code == 200
    payload = response.json()
    assert payload["data"]["access_token"] == "upgrade-access"
    assert payload["data"]["refresh_token"] == "upgrade-refresh"
    assert payload["data"]["token_type"] == "bearer"
    assert payload["meta"]["request_id"]


def test_upgrade_endpoint_conflict_error(monkeypatch):
    """Test upgrade returns 409 when user is already authenticated."""
    monkeypatch.setattr(
        auth_endpoints,
        "upgrade_account",
        AsyncMock(side_effect=AuthUpgradeConflictError("User is already authenticated")),
    )

    with _build_client() as client:
        response = client.post("/api/v1/auth/upgrade", json={"firebase_token": "firebase-token"})

    assert response.status_code == 409
    payload = response.json()
    assert payload["error"]["code"] == "AUTH_UPGRADE_CONFLICT"


def test_upgrade_endpoint_user_not_found(monkeypatch):
    """Test upgrade returns 401 when user not found."""
    monkeypatch.setattr(
        auth_endpoints,
        "upgrade_account",
        AsyncMock(side_effect=AuthInvalidTokenError("User not found for upgrade")),
    )

    with _build_client() as client:
        response = client.post("/api/v1/auth/upgrade", json={"firebase_token": "firebase-token"})

    assert response.status_code == 401
    payload = response.json()
    assert payload["error"]["code"] == "AUTH_INVALID_TOKEN"


def test_upgrade_endpoint_validates_empty_token():
    """Test upgrade rejects empty firebase_token field."""
    with _build_client() as client:
        response = client.post("/api/v1/auth/upgrade", json={"firebase_token": ""})

    assert response.status_code == 400
