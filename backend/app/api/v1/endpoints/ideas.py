"""Idea submission endpoints."""

from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user, get_db
from app.core.exceptions import InputValidationError
from app.core.logging import get_logger, request_id_ctx
from app.models.idea import IdeaModel
from app.models.user import UserModel
from app.schemas.common import success_response
from app.schemas.idea import IdeaCreateRequest, IdeaResponse
from app.services.sanitization_service import SanitizationService

router = APIRouter()
logger = get_logger(__name__)


@router.post("")
async def create_idea(
    body: IdeaCreateRequest,
    current_user: UserModel = Depends(get_current_user),  # noqa: B008
    session: AsyncSession = Depends(get_db),  # noqa: B008
) -> dict:
    """Create a sanitized business idea for downstream analysis."""
    sanitizer = SanitizationService()
    result = sanitizer.sanitize(body.idea_text)
    if not result.is_safe:
        raise InputValidationError(
            message=result.reason,
            details={"flagged_patterns": result.flagged_patterns} if result.flagged_patterns else None,
        )

    # Strip null bytes
    if "\x00" in body.idea_text:
        raise InputValidationError(message="Input contains null bytes")

    # Sanitize optional fields
    target_audience = sanitizer.sanitize(body.target_audience).sanitized_text if body.target_audience else None
    industry = sanitizer.sanitize(body.industry).sanitized_text if body.industry else None
    monetization_model = sanitizer.sanitize(body.monetization_model).sanitized_text if body.monetization_model else None
    region = sanitizer.sanitize(body.region).sanitized_text if body.region else None

    idea = IdeaModel(
        user_id=current_user.id,
        idea_text=result.sanitized_text,
        target_audience=target_audience,
        industry=industry,
        monetization_model=monetization_model,
        region=region,
        status="pending",
    )
    session.add(idea)
    await session.commit()
    await session.refresh(idea)

    logger.info(
        "Idea created",
        extra={"extra_data": {"idea_id": str(idea.id), "user_id": str(current_user.id)}},
    )
    return success_response(
        data=IdeaResponse.model_validate(idea),
        request_id=request_id_ctx.get("unknown"),
    )
