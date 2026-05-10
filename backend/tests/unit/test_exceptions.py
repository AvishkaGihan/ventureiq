"""Unit tests for custom exception classes."""

import pytest

from app.core.exceptions import (
    AuthInvalidTokenError,
    AuthProviderTokenInvalidError,
    AuthRequiredError,
    ExportFailedError,
    IdeaNotFoundError,
    InputValidationError,
    InternalError,
    ProviderRateLimitedError,
    ProviderUnavailableError,
    RateLimitExceededError,
    ReportNotFoundError,
    ReportNotReadyError,
    ShareLinkFailedError,
    StreamNotFoundError,
)


@pytest.mark.parametrize(
    "exc_class, code, status, message",
    [
        (AuthRequiredError, "AUTH_REQUIRED", 401, "Authentication is required"),
        (AuthInvalidTokenError, "AUTH_INVALID_TOKEN", 401, "Invalid or expired token"),
        (
            AuthProviderTokenInvalidError,
            "AUTH_PROVIDER_TOKEN_INVALID",
            401,
            "Provider token is invalid",
        ),
        (RateLimitExceededError, "RATE_LIMIT_EXCEEDED", 429, "Rate limit exceeded"),
        (InputValidationError, "INPUT_VALIDATION_ERROR", 400, "Input validation error"),
        (IdeaNotFoundError, "IDEA_NOT_FOUND", 404, "Idea not found"),
        (ReportNotFoundError, "REPORT_NOT_FOUND", 404, "Report not found"),
        (ReportNotReadyError, "REPORT_NOT_READY", 409, "Report not ready"),
        (ProviderRateLimitedError, "PROVIDER_RATE_LIMITED", 503, "Provider rate limited"),
        (ProviderUnavailableError, "PROVIDER_UNAVAILABLE", 503, "Provider unavailable"),
        (ExportFailedError, "EXPORT_FAILED", 500, "Export failed"),
        (ShareLinkFailedError, "SHARE_LINK_FAILED", 500, "Share link failed"),
        (StreamNotFoundError, "STREAM_NOT_FOUND", 404, "Stream not found"),
        (InternalError, "INTERNAL_ERROR", 500, "Internal server error"),
    ],
)
def test_exception_attributes(exc_class, code, status, message):
    """Ensure exception classes expose configured attributes."""
    exc = exc_class()

    assert exc.error_code == code
    assert exc.status_code == status
    assert exc.message == message


def test_exception_overrides_message_and_details():
    """Ensure overrides apply to message and details."""
    exc = AuthRequiredError(message="Custom message", details={"reason": "test"})

    assert exc.message == "Custom message"
    assert exc.details == {"reason": "test"}
