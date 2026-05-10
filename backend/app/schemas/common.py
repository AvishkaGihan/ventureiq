"""Shared response envelope schemas and helpers."""

from typing import Any

from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel, ConfigDict, Field


class MetaSchema(BaseModel):
    """Metadata for API responses."""

    model_config = ConfigDict(extra="ignore")
    request_id: str = Field(..., min_length=1)


class SuccessResponse[T](BaseModel):
    """Standard success response envelope."""

    data: T
    meta: MetaSchema


class ErrorDetail(BaseModel):
    """Error details for API responses."""

    code: str
    message: str
    details: dict[str, Any] | None = None


class ErrorResponse(BaseModel):
    """Standard error response envelope."""

    error: ErrorDetail
    meta: MetaSchema


def success_response(data: Any, request_id: str) -> dict[str, Any]:
    """Return a standard success envelope."""
    return jsonable_encoder(SuccessResponse(data=data, meta=MetaSchema(request_id=request_id)))


def error_response(
    code: str,
    message: str,
    details: dict[str, Any] | None,
    request_id: str,
    status_code: int,
) -> dict[str, Any]:
    """Return a standard error envelope."""
    return jsonable_encoder(ErrorResponse(
        error=ErrorDetail(code=code, message=message, details=details),
        meta=MetaSchema(request_id=request_id),
    ))
