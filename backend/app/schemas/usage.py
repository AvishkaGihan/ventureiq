"""Usage and rate-limit schemas."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class UsageStatusSchema(BaseModel):
    """Current report usage for the authenticated user."""

    model_config = ConfigDict(extra="ignore")

    reports_used: int = Field(..., ge=0)
    reports_limit: int = Field(..., ge=0)
    tier: str = Field(..., min_length=1)
    reset_at: datetime
    limit_reached: bool


class RateLimitExceededDetailSchema(BaseModel):
    """Details returned when report generation limit is exceeded."""

    model_config = ConfigDict(extra="ignore")

    reports_used: int = Field(..., ge=0)
    reports_limit: int = Field(..., ge=0)
    reset_at: datetime
    retry_after_seconds: int = Field(..., ge=0)
    remaining_seconds_until_reset: int = Field(..., ge=0)
