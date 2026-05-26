"""Custom exception classes for VentureIQ."""

from typing import Any


class VentureIQError(Exception):
    """Base exception for VentureIQ errors."""

    error_code: str = "INTERNAL_ERROR"
    status_code: int = 500
    message: str = "An unexpected error occurred"

    def __init__(self, message: str | None = None, details: dict[str, Any] | None = None) -> None:
        self.message = message or self.__class__.message
        self.details = details
        super().__init__(self.message)


class AuthRequiredError(VentureIQError):
    """Authentication required."""

    error_code = "AUTH_REQUIRED"
    status_code = 401
    message = "Authentication is required"


class AuthInvalidTokenError(VentureIQError):
    """Invalid or expired authentication token."""

    error_code = "AUTH_INVALID_TOKEN"
    status_code = 401
    message = "Invalid or expired token"


class AuthProviderTokenInvalidError(VentureIQError):
    """Provider token exchange failed."""

    error_code = "AUTH_PROVIDER_TOKEN_INVALID"
    status_code = 401
    message = "Provider token is invalid"


class RateLimitExceededError(VentureIQError):
    """Rate limit exceeded."""

    error_code = "RATE_LIMIT_EXCEEDED"
    status_code = 429
    message = "Rate limit exceeded"


class InputValidationError(VentureIQError):
    """Request input validation failed."""

    error_code = "INPUT_VALIDATION_ERROR"
    status_code = 400
    message = "Input validation error"


class IdeaNotFoundError(VentureIQError):
    """Idea not found."""

    error_code = "IDEA_NOT_FOUND"
    status_code = 404
    message = "Idea not found"


class ReportNotFoundError(VentureIQError):
    """Report not found."""

    error_code = "REPORT_NOT_FOUND"
    status_code = 404
    message = "Report not found"


class ReportNotReadyError(VentureIQError):
    """Report is not ready."""

    error_code = "REPORT_NOT_READY"
    status_code = 409
    message = "Report not ready"


class ProviderRateLimitedError(VentureIQError):
    """Provider rate limited request."""

    error_code = "PROVIDER_RATE_LIMITED"
    status_code = 503
    message = "Provider rate limited"


class ProviderUnavailableError(VentureIQError):
    """Provider unavailable."""

    error_code = "PROVIDER_UNAVAILABLE"
    status_code = 503
    message = "Provider unavailable"


class ExportFailedError(VentureIQError):
    """Export operation failed."""

    error_code = "EXPORT_FAILED"
    status_code = 500
    message = "Export failed"


class ShareLinkFailedError(VentureIQError):
    """Share link creation failed."""

    error_code = "SHARE_LINK_FAILED"
    status_code = 500
    message = "Share link failed"


class StreamNotFoundError(VentureIQError):
    """Streaming resource not found."""

    error_code = "STREAM_NOT_FOUND"
    status_code = 404
    message = "Stream not found"


class InternalError(VentureIQError):
    """Unhandled internal error."""

    error_code = "INTERNAL_ERROR"
    status_code = 500
    message = "Internal server error"


class AuthUpgradeConflictError(VentureIQError):
    """Account upgrade conflict — user is already authenticated or Google account in use."""

    error_code = "AUTH_UPGRADE_CONFLICT"
    status_code = 409
    message = "Account upgrade conflict"
