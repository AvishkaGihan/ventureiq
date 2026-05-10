"""Structured JSON logging utilities."""

import json
import logging
from contextvars import ContextVar
from datetime import UTC, datetime
from typing import Any

from app.core.config import Settings

request_id_ctx: ContextVar[str] = ContextVar("request_id", default="")


class JsonFormatter(logging.Formatter):
    """Format log records as JSON."""

    def format(self, record: logging.LogRecord) -> str:
        log_data: dict[str, Any] = {
            "timestamp": datetime.now(UTC).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "request_id": request_id_ctx.get(""),
            "module": record.module,
            "function": record.funcName,
        }

        extra_data = getattr(record, "extra_data", None)
        if isinstance(extra_data, dict):
            log_data.update(extra_data)

        return json.dumps(log_data, default=str)


def configure_logging(settings: Settings) -> None:
    """Configure root logger for structured JSON output."""
    logger = logging.getLogger()
    level_name = settings.LOG_LEVEL.upper()
    logger.setLevel(getattr(logging, level_name, logging.INFO))

    logger.handlers.clear()

    handler = logging.StreamHandler()
    handler.setFormatter(JsonFormatter())

    logger.handlers = [handler]
    logger.propagate = False


def get_logger(name: str) -> logging.Logger:
    """Return a configured logger instance."""
    return logging.getLogger(name)
