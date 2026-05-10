"""Application middleware definitions."""

import uuid

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.responses import Response
from starlette.types import ASGIApp

from app.core.logging import get_logger, request_id_ctx


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
