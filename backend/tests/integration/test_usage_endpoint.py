"""Integration tests for GET /usage/me."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime

from fastapi.testclient import TestClient

from app.core.dependencies import get_current_user, get_redis_rate_limit
from app.main import create_app
from app.models.user import UserModel


class FakeRedis:
    """Redis double for usage endpoint tests."""

    def __init__(self, count: int) -> None:
        self.count = count

    async def zremrangebyscore(self, key: str, minimum: int | str, maximum: int) -> int:
        return 0

    async def zcard(self, key: str) -> int:
        return self.count

    async def expire(self, key: str, ttl: int) -> bool:
        return True


def _build_client(user: UserModel, redis: FakeRedis) -> TestClient:
    app = create_app()

    async def override_current_user() -> UserModel:
        return user

    def override_redis() -> FakeRedis:
        return redis

    app.dependency_overrides[get_current_user] = override_current_user
    app.dependency_overrides[get_redis_rate_limit] = override_redis
    return TestClient(app)


def _user(tier: str) -> UserModel:
    return UserModel(
        id=uuid.uuid4(),
        firebase_uid=f"firebase-{tier}",
        auth_provider="google",
        tier=tier,
    )


def test_usage_endpoint_returns_free_tier_usage(monkeypatch) -> None:
    monkeypatch.setattr("app.services.rate_limit_service.datetime", _FixedDateTime)

    with _build_client(_user("free"), FakeRedis(count=2)) as client:
        response = client.get("/api/v1/usage/me")

    payload = response.json()
    assert response.status_code == 200
    assert payload["data"] == {
        "reports_used": 2,
        "reports_limit": 3,
        "tier": "free",
        "reset_at": "2026-07-01T00:00:00Z",
        "limit_reached": False,
    }
    assert payload["meta"]["request_id"]


def test_usage_endpoint_returns_pro_unlimited(monkeypatch) -> None:
    monkeypatch.setattr("app.services.rate_limit_service.datetime", _FixedDateTime)

    with _build_client(_user("pro"), FakeRedis(count=3)) as client:
        response = client.get("/api/v1/usage/me")

    payload = response.json()
    assert response.status_code == 200
    assert payload["data"]["reports_limit"] == 0
    assert payload["data"]["limit_reached"] is False


class _FixedDateTime(datetime):
    @classmethod
    def now(cls, tz=None):  # noqa: ANN001
        return datetime(2026, 6, 5, tzinfo=UTC)
