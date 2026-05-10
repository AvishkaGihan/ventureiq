"""Health check endpoint."""

from typing import Any

from fastapi import APIRouter

from app.core.logging import request_id_ctx
from app.schemas.common import success_response

router = APIRouter()


@router.get("/health")
async def health_check() -> dict[str, Any]:
    """Health check endpoint.

    Returns the service health status in the standard envelope format.
    """
    return success_response(
        data={
            "status": "healthy",
            "version": "0.1.0",
        },
        request_id=request_id_ctx.get("unknown"),
    )
