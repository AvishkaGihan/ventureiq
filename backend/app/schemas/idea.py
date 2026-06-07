"""Idea request and response schemas."""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator


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
