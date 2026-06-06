"""Tests for report-generation rate-limit middleware."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime, timedelta

import jwt
from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.core.middleware import RateLimitMiddleware, RequestIDMiddleware
from app.services.rate_limit_service import RateLimitResult


class DummyRedisManager:
    """Redis manager double exposing db2."""

    rate_limit = object()


def _build_app(monkeypatch, result: RateLimitResult | None = None, fail: bool = False) -> FastAPI:
    app = FastAPI()
    app.state.redis_manager = DummyRedisManager()

    async def limited_route() -> dict[str, str]:
        return {"status": "ok"}

    async def health_route() -> dict[str, str]:
        return {"status": "ok"}

    app.add_api_route("/api/v1/ideas", limited_route, methods=["POST"])
    app.add_api_route("/api/v1/health", health_route, methods=["GET"])
    app.add_middleware(RateLimitMiddleware, route_prefixes=["/api/v1/ideas"])
    app.add_middleware(RequestIDMiddleware)

    class FakeRateLimitService:
        def __init__(self, redis, settings):  # noqa: ANN001
            self.redis = redis
            self.settings = settings

        async def check_and_increment(self, user_id: str, tier: str) -> RateLimitResult:
            if fail:
                raise ConnectionError("redis down")
            assert user_id
            assert tier in {"free", "anonymous", "pro"}
            assert result is not None
            return result

    monkeypatch.setattr("app.core.middleware.RateLimitService", FakeRateLimitService)
    return app


def _token(tier: str = "free", auth_method: str = "google") -> str:
    settings = get_settings()
    user_id = uuid.uuid4()
    now = datetime.now(UTC)
    return jwt.encode(
        {
            "sub": str(user_id),
            "user_id": str(user_id),
            "tier": tier,
            "auth_method": auth_method,
            "jti": uuid.uuid4().hex,
            "type": "access",
            "iat": int(now.timestamp()),
            "exp": int((now + timedelta(minutes=5)).timestamp()),
        },
        settings.JWT_SECRET_KEY.get_secret_value(),
        algorithm=settings.JWT_ALGORITHM,
    )


def test_rate_limited_route_adds_remaining_headers(monkeypatch) -> None:
    result = RateLimitResult(
        allowed=True,
        current_count=2,
        limit=3,
        reset_at=datetime(2026, 7, 1, tzinfo=UTC),
    )
    app = _build_app(monkeypatch, result=result)

    with TestClient(app) as client:
        response = client.post("/api/v1/ideas", headers={"Authorization": f"Bearer {_token()}"})

    assert response.status_code == 200
    assert response.headers["X-RateLimit-Remaining"] == "1"
    assert response.headers["X-RateLimit-Reset"] == "2026-07-01T00:00:00Z"


def test_rate_limited_route_returns_429_envelope(monkeypatch) -> None:
    result = RateLimitResult(
        allowed=False,
        current_count=3,
        limit=3,
        reset_at=datetime(2026, 7, 1, tzinfo=UTC),
    )
    app = _build_app(monkeypatch, result=result)

    with TestClient(app) as client:
        response = client.post("/api/v1/ideas", headers={"Authorization": f"Bearer {_token()}"})

    payload = response.json()
    assert response.status_code == 429
    assert payload["error"]["code"] == "RATE_LIMIT_EXCEEDED"
    assert payload["error"]["details"]["reports_used"] == 3
    assert "remaining_seconds_until_reset" in payload["error"]["details"]
    assert response.headers["X-RateLimit-Remaining"] == "0"


def test_middleware_skips_non_report_generation_routes(monkeypatch) -> None:
    app = _build_app(monkeypatch, fail=True)

    with TestClient(app) as client:
        response = client.get("/api/v1/health", headers={"Authorization": f"Bearer {_token()}"})

    assert response.status_code == 200
    assert "X-RateLimit-Remaining" not in response.headers


def test_middleware_fails_open_when_rate_limit_check_errors(monkeypatch) -> None:
    app = _build_app(monkeypatch, fail=True)

    with TestClient(app) as client:
        response = client.post("/api/v1/ideas", headers={"Authorization": f"Bearer {_token()}"})

    assert response.status_code == 200
    assert "X-RateLimit-Remaining" not in response.headers
