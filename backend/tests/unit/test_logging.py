"""Unit tests for structured JSON logging."""

import json

from app.core.config import Settings
from app.core.logging import configure_logging, get_logger, request_id_ctx


def test_json_log_includes_request_id(capsys):
    """Ensure JSON logs include request_id and standard fields."""
    settings = Settings(LOG_LEVEL="INFO")
    configure_logging(settings)

    request_id_ctx.set("test-request-id")

    logger = get_logger("test_logger")
    logger.info("log-message")

    captured = capsys.readouterr()
    output = (captured.err or captured.out).strip()

    assert output, "Expected log output to be captured"

    log_entry = json.loads(output.splitlines()[-1])

    assert log_entry["level"] == "INFO"
    assert log_entry["message"] == "log-message"
    assert log_entry["request_id"] == "test-request-id"
    assert "timestamp" in log_entry
    assert "module" in log_entry
    assert "function" in log_entry
