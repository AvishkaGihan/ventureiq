"""Unit tests for global error handlers."""

from fastapi import APIRouter, Query
from fastapi.testclient import TestClient

from app.core.exceptions import AuthRequiredError
from app.main import create_app


def _create_test_client() -> TestClient:
    app = create_app()
    router = APIRouter()

    @router.get("/test/auth-error")
    async def auth_error():
        raise AuthRequiredError()

    @router.get("/test/validation")
    async def validation(limit: int = Query(...)):
        return {"data": limit}

    @router.get("/test/boom")
    async def boom():
        raise RuntimeError("boom")

    app.include_router(router, prefix="/api/v1")
    return TestClient(app, raise_server_exceptions=False)


def test_custom_exception_handler_returns_envelope():
    """Ensure custom exceptions return structured error envelopes."""
    with _create_test_client() as client:
        response = client.get("/api/v1/test/auth-error")

    assert response.status_code == 401
    payload = response.json()

    assert payload["error"]["code"] == "AUTH_REQUIRED"
    assert payload["error"]["message"] == "Authentication is required"
    assert payload["error"]["details"] is None
    assert "request_id" in payload["meta"]


def test_validation_error_handler_returns_envelope():
    """Ensure validation errors map to INPUT_VALIDATION_ERROR."""
    with _create_test_client() as client:
        response = client.get("/api/v1/test/validation?limit=not-an-int")

    assert response.status_code == 400
    payload = response.json()

    assert payload["error"]["code"] == "INPUT_VALIDATION_ERROR"
    assert payload["error"]["details"]
    assert "request_id" in payload["meta"]


def test_unhandled_exception_handler_returns_envelope():
    """Ensure unhandled exceptions return INTERNAL_ERROR."""
    with _create_test_client() as client:
        response = client.get("/api/v1/test/boom")

    assert response.status_code == 500
    payload = response.json()

    assert payload["error"]["code"] == "INTERNAL_ERROR"
    assert payload["error"]["details"] is None
    assert "request_id" in payload["meta"]
