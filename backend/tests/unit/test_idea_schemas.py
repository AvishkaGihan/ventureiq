"""Tests for idea request and response schemas."""

import uuid
from datetime import UTC, datetime

import pytest
from pydantic import ValidationError

from app.models.idea import IdeaModel
from app.schemas.idea import IdeaCreateRequest, IdeaResponse


def test_idea_create_request_strips_idea_text() -> None:
    """Idea text is normalized by trimming outer whitespace."""
    request = IdeaCreateRequest(idea_text="  subscription analytics for gyms  ")

    assert request.idea_text == "subscription analytics for gyms"



def test_idea_create_request_rejects_over_max_length() -> None:
    """Idea text is capped to the configured maximum payload size."""
    with pytest.raises(ValidationError):
        IdeaCreateRequest(idea_text="a" * 5001)


def test_idea_create_request_optional_context_fields_accept_none() -> None:
    """Context fields are optional for low-friction idea submission."""
    request = IdeaCreateRequest(
        idea_text="A scheduling tool for specialist clinics",
        target_audience=None,
        industry=None,
        monetization_model=None,
        region=None,
    )

    assert request.target_audience is None
    assert request.industry is None
    assert request.monetization_model is None
    assert request.region is None


def test_idea_response_supports_orm_conversion() -> None:
    """IdeaResponse can be built from a SQLAlchemy model instance."""
    idea_id = uuid.uuid4()
    user_id = uuid.uuid4()
    created_at = datetime(2026, 6, 7, tzinfo=UTC)
    idea = IdeaModel(
        id=idea_id,
        user_id=user_id,
        idea_text="A supply-chain forecast product for small retailers",
        status="pending",
        created_at=created_at,
    )

    response = IdeaResponse.model_validate(idea)

    assert response.id == idea_id
    assert response.user_id == user_id
    assert response.idea_text == idea.idea_text
    assert response.status == "pending"
    assert response.created_at == created_at
