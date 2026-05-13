"""Health check endpoint."""

import asyncio
import logging
from typing import Any

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_db, get_redis_manager
from app.core.logging import request_id_ctx
from app.db.redis import RedisManager
from app.schemas.common import success_response

router = APIRouter()
logger = logging.getLogger(__name__)


async def check_db_health(session: AsyncSession) -> bool:
    """Return True when the database responds to a simple query."""
    try:
        # Add 2.0 second timeout to prevent infinite hang
        result = await asyncio.wait_for(session.execute(text("SELECT 1")), timeout=2.0)
        return result.scalar() == 1
    except TimeoutError:
        logger.error("Database health check timed out")
        return False
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
        return False


@router.get("/health")
async def health_check(
    session: AsyncSession = Depends(get_db),  # noqa: B008
    redis_manager: RedisManager = Depends(get_redis_manager),  # noqa: B008
) -> dict[str, Any]:
    """Health check endpoint.

    Returns the service health status in the standard envelope format.
    """
    database_ok = await check_db_health(session)
    redis_status = await redis_manager.health_check()
    return success_response(
        data={
            "status": "healthy",
            "version": "0.1.0",
            "services": {
                "database": database_ok,
                "redis": redis_status,
            },
        },
        request_id=request_id_ctx.get("unknown"),
    )
