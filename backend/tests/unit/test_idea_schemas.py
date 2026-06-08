"""Tests for idea request and response schemas."""

import uuid
from datetime import UTC, datetime

import pytest
from pydantic import ValidationError

from app.models.idea import IdeaModel
from app.schemas.idea import IdeaCreateRequest, IdeaResponse, PlausibilityCheckResponse, PlausibilityResponse


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


def test_plausibility_response_accepts_expected_verdicts() -> None:
    """Plausibility responses expose the exact frontend contract."""
    response = PlausibilityResponse(
        verdict="refine",
        guidance=["Clarify the customer segment", "Add a likely pricing model"],
        reason=None,
        confidence=0.74,
    )

    assert response.verdict == "refine"
    assert response.guidance == ["Clarify the customer segment", "Add a likely pricing model"]
    assert response.reason is None
    assert response.confidence == 0.74


def test_plausibility_response_rejects_unexpected_verdict() -> None:
    """Only pass/refine/reject are valid plausibility outcomes."""
    with pytest.raises(ValidationError):
        PlausibilityResponse(verdict="maybe", guidance=None, reason=None, confidence=0.5)


def test_plausibility_response_requires_refine_guidance() -> None:
    """Refine verdicts must include the requested number of actionable suggestions."""
    with pytest.raises(ValidationError):
        PlausibilityResponse(verdict="refine", guidance=["Clarify the customer"], reason=None, confidence=0.7)


def test_plausibility_response_requires_reject_reason() -> None:
    """Reject verdicts must include a constructive reason for the user."""
    with pytest.raises(ValidationError):
        PlausibilityResponse(verdict="reject", guidance=None, reason=None, confidence=0.7)


def test_plausibility_check_response_wraps_idea_and_assessment() -> None:
    """Endpoint payload combines the updated idea with the plausibility result."""
    idea = IdeaResponse(
        id=uuid.uuid4(),
        user_id=uuid.uuid4(),
        idea_text="A cash-flow assistant for small clinics",
        status="plausibility_passed",
        created_at=datetime(2026, 6, 7, tzinfo=UTC),
    )
    plausibility = PlausibilityResponse(
        verdict="pass",
        guidance=None,
        reason=None,
        confidence=0.91,
    )

    response = PlausibilityCheckResponse(idea=idea, plausibility=plausibility)

    assert response.idea == idea
    assert response.plausibility == plausibility
