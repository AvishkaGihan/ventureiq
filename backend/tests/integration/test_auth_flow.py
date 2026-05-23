"""Integration tests for auth endpoints."""

from __future__ import annotations

from unittest.mock import AsyncMock

from fastapi import Depends
from fastapi.testclient import TestClient

from app.api.v1.endpoints import auth as auth_endpoints
from app.core.dependencies import get_current_user, get_db, get_redis_cache
from app.core.logging import request_id_ctx
from app.main import create_app
from app.schemas.auth import TokenResponseSchema
from app.schemas.common import success_response


def _build_client() -> TestClient:
    app = create_app()

    async def override_get_db():
        yield AsyncMock()

    def override_get_redis_cache():
        return AsyncMock()

    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[get_redis_cache] = override_get_redis_cache

    return TestClient(app)


def test_exchange_endpoint_returns_envelope(monkeypatch):
    token_response = TokenResponseSchema(
        access_token="access",
        refresh_token="refresh",
        token_type="bearer",
        expires_in=3600,
    )
    monkeypatch.setattr(auth_endpoints, "exchange_token", AsyncMock(return_value=token_response))

    with _build_client() as client:
        response = client.post("/api/v1/auth/exchange", json={"firebase_token": "token"})

    assert response.status_code == 200
    payload = response.json()
    assert payload["data"]["access_token"] == "access"
    assert payload["data"]["refresh_token"] == "refresh"
    assert payload["meta"]["request_id"]


def test_refresh_endpoint_returns_envelope(monkeypatch):
    token_response = TokenResponseSchema(
        access_token="new-access",
        refresh_token="new-refresh",
        token_type="bearer",
        expires_in=3600,
    )
    monkeypatch.setattr(auth_endpoints, "refresh_tokens", AsyncMock(return_value=token_response))

    with _build_client() as client:
        response = client.post("/api/v1/auth/refresh", json={"refresh_token": "token"})

    assert response.status_code == 200
    payload = response.json()
    assert payload["data"]["access_token"] == "new-access"
    assert payload["data"]["refresh_token"] == "new-refresh"
    assert payload["meta"]["request_id"]


def test_protected_endpoint_requires_auth():
    app = create_app()

    async def override_get_db():
        yield AsyncMock()

    app.dependency_overrides[get_db] = override_get_db

    @app.get("/api/v1/protected")
    async def protected_route(user=Depends(get_current_user)):  # noqa: B008
        return success_response(data={"ok": True}, request_id=request_id_ctx.get("unknown"))

    with TestClient(app) as client:
        response = client.get("/api/v1/protected")

    assert response.status_code == 401
    payload = response.json()
    assert payload["error"]["code"] == "AUTH_REQUIRED"
