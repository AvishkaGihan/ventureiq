"""Authentication request and response schemas."""

from __future__ import annotations

import uuid

from pydantic import BaseModel, ConfigDict, Field


class TokenExchangeRequestSchema(BaseModel):
    """Request payload for exchanging a Firebase token."""

    firebase_token: str = Field(..., min_length=1)


class TokenRefreshRequestSchema(BaseModel):
    """Request payload for refreshing a backend token."""

    refresh_token: str = Field(..., min_length=1)


class TokenResponseSchema(BaseModel):
    """Response payload for access/refresh token pairs."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class UserResponseSchema(BaseModel):
    """Response payload for user details."""

    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

    id: uuid.UUID
    email: str | None = None
    display_name: str | None = None
    tier: str
    auth_method: str = Field(..., alias="auth_provider")
