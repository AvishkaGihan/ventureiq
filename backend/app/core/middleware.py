"""Application middleware definitions."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime

from fastapi import Request
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.responses import Response
from starlette.types import ASGIApp

from app.core.config import get_settings
from app.core.exceptions import RateLimitExceededError
from app.core.logging import get_logger, request_id_ctx
from app.core.security import verify_jwt
from app.db.redis import RedisManager
from app.schemas.common import error_response
from app.services.rate_limit_service import RateLimitResult, RateLimitService


class RequestIDMiddleware(BaseHTTPMiddleware):
    """Middleware that generates and propagates a request ID."""

    def __init__(self, app: ASGIApp) -> None:
        super().__init__(app)

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        logger = get_logger(__name__)
        request_id = str(uuid.uuid4())
        logger.info("Generated request_id", extra={"extra_data": {"request_id": request_id}})
        request_id_ctx.set(request_id)
        
        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        return response


class RateLimitMiddleware(BaseHTTPMiddleware):
    """Middleware enforcing report-generation usage limits."""

    def __init__(self, app: ASGIApp, route_prefixes: list[str] | None = None) -> None:
        super().__init__(app)
        self.route_prefixes = route_prefixes or ["/api/v1/ideas"]

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        if not self._is_rate_limited_route(request):
            return await call_next(request)

        logger = get_logger(__name__)
        settings = get_settings()
        result: RateLimitResult | None = None

        try:
            authorization = request.headers.get("authorization", "")
            scheme, _, token = authorization.partition(" ")
            if scheme.lower() != "bearer" or not token:
                return await call_next(request)

            claims = verify_jwt(token)
            user_id = str(claims.get("sub") or "")
            if not user_id:
                return await call_next(request)

            tier = self._tier_from_claims(claims)
            redis_manager: RedisManager = request.app.state.redis_manager
            service = RateLimitService(redis=redis_manager.rate_limit, settings=settings)
            result = await service.check_and_increment(user_id=user_id, tier=tier)
        except Exception as e:
            if type(e).__name__ in ("ExpiredSignatureError", "InvalidTokenError", "DecodeError", "PyJWTError"):
                return await call_next(request)
            logger.warning(
                "Rate limiting failed open",
                extra={"extra_data": {"request_id": request_id_ctx.get("unknown")}},
                exc_info=True,
            )
            return await call_next(request)

        if result and not result.allowed:
            from app.schemas.usage import RateLimitExceededDetailSchema
            details_model = RateLimitExceededDetailSchema(
                reports_used=result.current_count,
                reports_limit=result.limit,
                reset_at=result.reset_at,
                retry_after_seconds=result.retry_after_seconds,
                remaining_seconds_until_reset=result.retry_after_seconds,
            )
            error = RateLimitExceededError(details=details_model.model_dump(mode="json"))
            content = error_response(
                code=error.error_code,
                message=error.message,
                details=error.details,
                request_id=request_id_ctx.get("unknown"),
                status_code=error.status_code,
            )
            response = JSONResponse(status_code=error.status_code, content=content)
        else:
            response = await call_next(request)

        if result:
            response.headers["X-RateLimit-Remaining"] = str(result.remaining)
            response.headers["X-RateLimit-Reset"] = self._format_reset(result.reset_at)
        return response

    def _is_rate_limited_route(self, request: Request) -> bool:
        if request.method != "POST":
            return False
        return any(request.url.path.rstrip("/") == prefix.rstrip("/") for prefix in self.route_prefixes)

    def _tier_from_claims(self, claims: dict[str, object]) -> str:
        if claims.get("auth_method") == "anonymous":
            return "anonymous"
        return str(claims.get("tier") or "free")

    def _format_reset(self, reset_at: datetime) -> str:
        return reset_at.astimezone(UTC).isoformat().replace("+00:00", "Z")
