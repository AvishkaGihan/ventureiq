"""Integration tests for POST /api/v1/ideas/{idea_id}/plausibility."""

from __future__ import annotations

import json
import uuid
from datetime import UTC, datetime
from typing import Any
from unittest.mock import AsyncMock

import pytest
from httpx import ASGITransport, AsyncClient

from app.core.dependencies import get_current_user, get_db, get_redis_cache
from app.main import create_app
from app.models.idea import IdeaModel
from app.models.user import UserModel
from app.providers.factory import get_llm_provider


class FakeResult:
    """SQLAlchemy result double for scalar idea lookups."""

    def __init__(self, idea: IdeaModel | None) -> None:
        self._idea = idea

    def scalar_one_or_none(self) -> IdeaModel | None:
        return self._idea


class FakeIdeaLookupSession:
    """Async session double for plausibility endpoint idea lookups."""

    def __init__(self, idea: IdeaModel | None) -> None:
        self.idea = idea
        self.committed = False
        self.refreshed = False

    async def execute(self, _statement: Any) -> FakeResult:
        return FakeResult(self.idea)

    async def commit(self) -> None:
        self.committed = True

    async def refresh(self, model: IdeaModel) -> None:
        self.refreshed = True
        model.updated_at = datetime(2026, 6, 7, tzinfo=UTC)


class FakeRedisManager:
    """Redis manager double for middleware access."""

    def __init__(self, cache: AsyncMock) -> None:
        self.streaming = AsyncMock()
        self.cache = cache
        self.rate_limit = AsyncMock()


def _user(user_id: uuid.UUID | None = None) -> UserModel:
    return UserModel(
        id=user_id or uuid.uuid4(),
        firebase_uid="firebase-user",
        auth_provider="google",
        tier="free",
    )


def _idea(user_id: uuid.UUID, status: str = "pending") -> IdeaModel:
    return IdeaModel(
        id=uuid.uuid4(),
        user_id=user_id,
        idea_text="A scheduling assistant for specialist clinics",
        target_audience="clinic owners",
        industry="healthcare",
        monetization_model="monthly SaaS",
        region="US",
        status=status,
        created_at=datetime(2026, 6, 7, tzinfo=UTC),
        updated_at=datetime(2026, 6, 7, tzinfo=UTC),
    )


async def _build_client(
    user: UserModel,
    session: FakeIdeaLookupSession,
    llm: AsyncMock,
    cache: AsyncMock,
) -> tuple[AsyncClient, Any]:
    app = create_app()
    app.state.redis_manager = FakeRedisManager(cache)

    async def override_current_user() -> UserModel:
        return user

    async def override_get_db():
        yield session

    def override_get_llm_provider() -> AsyncMock:
        return llm

    def override_get_redis_cache() -> AsyncMock:
        return cache

    app.dependency_overrides[get_current_user] = override_current_user
    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[get_llm_provider] = override_get_llm_provider
    app.dependency_overrides[get_redis_cache] = override_get_redis_cache

    transport = ASGITransport(app=app)
    return AsyncClient(transport=transport, base_url="http://testserver"), app


@pytest.mark.asyncio
async def test_plausibility_endpoint_updates_status_and_returns_envelope() -> None:
    user = _user()
    idea = _idea(user.id)
    session = FakeIdeaLookupSession(idea)
    llm = AsyncMock()
    llm.generate.return_value = json.dumps({
        "verdict": "pass",
        "guidance": None,
        "reason": None,
        "confidence": 0.93,
    })
    cache = AsyncMock()
    cache.get.return_value = None
    client, _app = await _build_client(user=user, session=session, llm=llm, cache=cache)

    async with client:
        response = await client.post(f"/api/v1/ideas/{idea.id}/plausibility")

    payload = response.json()
    assert response.status_code == 200
    assert payload["data"]["idea"]["id"] == str(idea.id)
    assert payload["data"]["idea"]["status"] == "plausibility_passed"
    assert payload["data"]["plausibility"]["verdict"] == "pass"
    assert payload["meta"]["request_id"]
    assert idea.status == "plausibility_passed"
    assert session.committed is True
    assert session.refreshed is True
    llm.generate.assert_awaited_once()


@pytest.mark.asyncio
async def test_plausibility_endpoint_returns_404_for_missing_or_wrong_user() -> None:
    user = _user()
    session = FakeIdeaLookupSession(None)
    llm = AsyncMock()
    cache = AsyncMock()
    cache.get.return_value = None
    client, _app = await _build_client(user=user, session=session, llm=llm, cache=cache)

    async with client:
        response = await client.post(f"/api/v1/ideas/{uuid.uuid4()}/plausibility")

    payload = response.json()
    assert response.status_code == 404
    assert payload["error"]["code"] == "IDEA_NOT_FOUND"
    assert session.committed is False
    llm.generate.assert_not_awaited()


@pytest.mark.asyncio
async def test_plausibility_endpoint_returns_404_for_wrong_user_without_leaking_existence() -> None:
    user = _user()
    other_users_idea_id = uuid.uuid4()
    session = FakeIdeaLookupSession(None)
    llm = AsyncMock()
    cache = AsyncMock()
    cache.get.return_value = None
    client, _app = await _build_client(user=user, session=session, llm=llm, cache=cache)

    async with client:
        response = await client.post(f"/api/v1/ideas/{other_users_idea_id}/plausibility")

    payload = response.json()
    assert response.status_code == 404
    assert payload["error"]["code"] == "IDEA_NOT_FOUND"
    assert session.committed is False
    llm.generate.assert_not_awaited()


@pytest.mark.asyncio
async def test_plausibility_endpoint_marks_refine_verdict_as_failed() -> None:
    user = _user()
    idea = _idea(user.id)
    session = FakeIdeaLookupSession(idea)
    llm = AsyncMock()
    llm.generate.return_value = json.dumps({
        "verdict": "refine",
        "guidance": ["Clarify the customer segment", "Describe the first paid use case"],
        "reason": None,
        "confidence": 0.67,
    })
    cache = AsyncMock()
    cache.get.return_value = None
    client, _app = await _build_client(user=user, session=session, llm=llm, cache=cache)

    async with client:
        response = await client.post(f"/api/v1/ideas/{idea.id}/plausibility")

    payload = response.json()
    assert response.status_code == 200
    assert payload["data"]["idea"]["status"] == "plausibility_failed"
    assert payload["data"]["plausibility"]["verdict"] == "refine"
    assert payload["data"]["plausibility"]["guidance"] == [
        "Clarify the customer segment",
        "Describe the first paid use case",
    ]
    assert idea.status == "plausibility_failed"
    assert session.committed is True


@pytest.mark.asyncio
async def test_plausibility_endpoint_rejects_already_checked_idea() -> None:
    user = _user()
    idea = _idea(user.id, status="plausibility_passed")
    session = FakeIdeaLookupSession(idea)
    llm = AsyncMock()
    cache = AsyncMock()
    cache.get.return_value = None
    client, _app = await _build_client(user=user, session=session, llm=llm, cache=cache)

    async with client:
        response = await client.post(f"/api/v1/ideas/{idea.id}/plausibility")

    payload = response.json()
    assert response.status_code == 400
    assert payload["error"]["code"] == "INPUT_VALIDATION_ERROR"
    assert session.committed is False
    llm.generate.assert_not_awaited()
