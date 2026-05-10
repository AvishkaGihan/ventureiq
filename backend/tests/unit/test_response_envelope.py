"""Unit tests for response envelope helpers."""

from app.schemas.common import error_response, success_response


def test_success_response_format():
    """Ensure success_response returns the standard envelope."""
    payload = {"status": "ok"}
    envelope = success_response(payload, request_id="req-123")

    assert envelope == {"data": payload, "meta": {"request_id": "req-123"}}


def test_error_response_format():
    """Ensure error_response returns the standard error envelope."""
    envelope = error_response(
        code="INPUT_VALIDATION_ERROR",
        message="Invalid input",
        details={"field": "name"},
        request_id="req-456",
        status_code=400,
    )

    assert envelope["error"]["code"] == "INPUT_VALIDATION_ERROR"
    assert envelope["error"]["message"] == "Invalid input"
    assert envelope["error"]["details"] == {"field": "name"}
    assert envelope["meta"]["request_id"] == "req-456"
