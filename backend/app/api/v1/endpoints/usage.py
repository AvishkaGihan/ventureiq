"""Usage status endpoints."""

from __future__ import annotations

from typing import Any

import redis.asyncio as aioredis
from fastapi import APIRouter, Depends

from app.core.dependencies import get_current_user, get_redis_rate_limit
from app.core.logging import request_id_ctx
from app.models.user import UserModel
from app.schemas.common import success_response
from app.schemas.usage import UsageStatusSchema
from app.services.rate_limit_service import RateLimitService

router = APIRouter()


@router.get("/me")
async def get_my_usage(
    current_user: UserModel = Depends(get_current_user),  # noqa: B008
    redis: aioredis.Redis = Depends(get_redis_rate_limit),  # noqa: B008
) -> dict[str, Any]:
    """Return current report-generation usage for the authenticated user."""
    service = RateLimitService(redis=redis)
    usage = await service.get_usage(user_id=str(current_user.id), tier=current_user.tier)
    data = UsageStatusSchema(
        reports_used=usage.current_count,
        reports_limit=usage.limit,
        tier=current_user.tier,
        reset_at=usage.reset_at,
        limit_reached=usage.limit != 0 and usage.current_count >= usage.limit,
    )
    return success_response(data=data.model_dump(), request_id=request_id_ctx.get("unknown"))
