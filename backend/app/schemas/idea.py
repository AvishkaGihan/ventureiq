"""Idea request and response schemas."""

from __future__ import annotations

import uuid
from datetime import datetime
from typing import Literal, Self

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


class IdeaCreateRequest(BaseModel):
    """Request payload for creating a business idea."""

    model_config = ConfigDict(str_strip_whitespace=True)

    idea_text: str = Field(..., max_length=5000)
    target_audience: str | None = Field(default=None, max_length=255)
    industry: str | None = Field(default=None, max_length=255)
    monetization_model: str | None = Field(default=None, max_length=255)
    region: str | None = Field(default=None, max_length=100)

    @field_validator("idea_text", mode="before")
    @classmethod
    def strip_idea_text(cls, value: str) -> str:
        """Strip surrounding whitespace before length validation."""
        if isinstance(value, str):
            return value.strip()
        return value


class IdeaResponse(BaseModel):
    """Response payload for a persisted idea."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: uuid.UUID
    idea_text: str
    target_audience: str | None = None
    industry: str | None = None
    monetization_model: str | None = None
    region: str | None = None
    status: str
    created_at: datetime


class PlausibilityResponse(BaseModel):
    """Structured assessment for an idea plausibility check."""

    verdict: Literal["pass", "refine", "reject"]
    guidance: list[str] | None = None
    reason: str | None = None
    confidence: float = Field(ge=0.0, le=1.0, allow_inf_nan=False)

    @model_validator(mode="after")
    def validate_verdict_payload(self) -> Self:
        """Ensure verdict-specific payloads match the API contract."""
        if self.verdict == "pass" and (self.guidance is not None or self.reason is not None):
            raise ValueError("Pass verdicts must not contain guidance or reasons")
        if self.verdict == "refine" and (self.guidance is None or not 2 <= len(self.guidance) <= 4):
            raise ValueError("Refine verdicts require 2-4 guidance suggestions")
        if self.verdict == "reject" and not self.reason:
            raise ValueError("Reject verdicts require a reason")
        return self


class PlausibilityCheckResponse(BaseModel):
    """Response payload for an idea and its plausibility assessment."""

    idea: IdeaResponse
    plausibility: PlausibilityResponse
