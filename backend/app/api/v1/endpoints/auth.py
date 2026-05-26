"""Authentication endpoints."""

from __future__ import annotations

from typing import Any

import redis.asyncio as aioredis
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_db, get_redis_cache
from app.core.logging import request_id_ctx
from app.schemas.auth import TokenExchangeRequestSchema, TokenRefreshRequestSchema, UpgradeRequestSchema
from app.schemas.common import success_response
from app.services.auth_service import exchange_token, refresh_tokens, upgrade_account

router = APIRouter()


@router.post("/exchange")
async def exchange_auth_token(
    payload: TokenExchangeRequestSchema,
    session: AsyncSession = Depends(get_db),  # noqa: B008
) -> dict[str, Any]:
    """Exchange Firebase token for backend JWTs."""
    token_response = await exchange_token(payload.firebase_token, session)
    return success_response(
        data=token_response.model_dump(),
        request_id=request_id_ctx.get("unknown"),
    )


@router.post("/refresh")
async def refresh_auth_token(
    payload: TokenRefreshRequestSchema,
    session: AsyncSession = Depends(get_db),  # noqa: B008
    redis: aioredis.Redis = Depends(get_redis_cache),  # noqa: B008
) -> dict[str, Any]:
    """Rotate refresh token and issue new JWTs."""
    token_response = await refresh_tokens(payload.refresh_token, session, redis)
    return success_response(
        data=token_response.model_dump(),
        request_id=request_id_ctx.get("unknown"),
    )


@router.post("/upgrade")
async def upgrade_auth_account(
    payload: UpgradeRequestSchema,
    session: AsyncSession = Depends(get_db),  # noqa: B008
) -> dict[str, Any]:
    """Upgrade an anonymous account to Google-authenticated.

    Validates the user was previously anonymous, updates profile fields,
    and issues new JWTs with `auth_method: "google"`.
    """
    token_response = await upgrade_account(payload.firebase_token, session)
    return success_response(
        data=token_response.model_dump(),
        request_id=request_id_ctx.get("unknown"),
    )
