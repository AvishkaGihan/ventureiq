"""VentureIQ API - FastAPI Application."""

import logging
import sys
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic_core import ValidationError

from app.api.v1.router import api_v1_router
from app.core.config import get_settings
from app.core.exceptions import InternalError, VentureIQError
from app.core.logging import configure_logging, request_id_ctx
from app.core.middleware import RateLimitMiddleware, RequestIDMiddleware
from app.core.security import init_firebase
from app.db.base import async_engine
from app.db.redis import RedisManager
from app.schemas.common import error_response


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan context manager.

    Handles startup and shutdown events.
    Startup: DB connections, cache warmup, etc. (added in later stories)
    Shutdown: Graceful cleanup of resources.
    """
    try:
        settings = get_settings()
    except ValidationError as e:
        logger = logging.getLogger(__name__)
        logger.error(f"Configuration validation failed: {e}")
        sys.exit(1)
        
    configure_logging(settings)
    app.state.settings = settings

    try:
        init_firebase(settings)
    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.critical(f"Failed to initialize Firebase Admin SDK: {e}")
        raise e

    redis_manager = RedisManager(settings.REDIS_URL)
    try:
        await redis_manager.connect()
    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.error(f"Failed to connect to Redis on startup: {e}")
        # We don't exit here so the app can start degraded, or we can choose to sys.exit(1). 
        # The spec implies graceful degradation for health endpoint.
    app.state.redis_manager = redis_manager

    yield

    try:
        await redis_manager.close()
    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.error(f"Error closing Redis connection: {e}")
        
    try:
        await async_engine.dispose()
    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.error(f"Error disposing database engine: {e}")


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title="VentureIQ API",
        description="AI-powered startup idea validation platform",
        version="0.1.0",
        lifespan=lifespan,
    )

    app.add_middleware(RateLimitMiddleware, route_prefixes=get_settings().RATE_LIMIT_ROUTE_PREFIXES)
    app.add_middleware(RequestIDMiddleware)

    @app.exception_handler(VentureIQError)
    async def ventureiq_error_handler(request: Request, exc: VentureIQError) -> JSONResponse:
        request_id = request_id_ctx.get("") or "unknown"
        content = error_response(
            code=exc.error_code,
            message=exc.message,
            details=exc.details,
            request_id=request_id,
            status_code=exc.status_code,
        )
        return JSONResponse(status_code=exc.status_code, content=content)

    @app.exception_handler(RequestValidationError)
    async def validation_error_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
        request_id = request_id_ctx.get("") or "unknown"
        content = error_response(
            code="INPUT_VALIDATION_ERROR",
            message="Input validation error",
            details={"errors": exc.errors()},
            request_id=request_id,
            status_code=400,
        )
        return JSONResponse(status_code=400, content=content)

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        internal_error = InternalError()
        request_id = request_id_ctx.get("") or "unknown"
        content = error_response(
            code=internal_error.error_code,
            message=internal_error.message,
            details=None,
            request_id=request_id,
            status_code=internal_error.status_code,
        )
        return JSONResponse(status_code=internal_error.status_code, content=content)

    app.include_router(api_v1_router, prefix="/api/v1")

    return app


app = create_app()
