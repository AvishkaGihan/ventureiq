# Story 1.2: Backend Core Infrastructure (Config, Logging, Error Handling)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want the backend core layer established with configuration management, structured logging, and the error handling framework,
So that all subsequent backend features have consistent infrastructure to build upon.

## Acceptance Criteria

1. **Given** the backend project from Story 1.1 **When** the core infrastructure is implemented **Then** `app/core/config.py` implements Pydantic `BaseSettings` loading from `.env` with typed fields for database URLs, Redis URLs, API keys, and feature flags
2. **And** `app/core/logging.py` implements structured JSON logging with `request_id` propagation
3. **And** `app/core/exceptions.py` defines custom exception classes for all 14 enumerated error codes from the PRD (`AUTH_REQUIRED`, `AUTH_INVALID_TOKEN`, `AUTH_PROVIDER_TOKEN_INVALID`, `RATE_LIMIT_EXCEEDED`, `INPUT_VALIDATION_ERROR`, `IDEA_NOT_FOUND`, `REPORT_NOT_FOUND`, `REPORT_NOT_READY`, `PROVIDER_RATE_LIMITED`, `PROVIDER_UNAVAILABLE`, `EXPORT_FAILED`, `SHARE_LINK_FAILED`, `STREAM_NOT_FOUND`, `INTERNAL_ERROR`)
4. **And** `app/core/middleware.py` implements RequestID middleware that generates and propagates UUIDs across all requests
5. **And** `app/main.py` uses FastAPI lifespan context manager for startup/shutdown (already in place from Story 1.1 — enhance with settings loading and logging initialization)
6. **And** the global error handler catches custom exceptions and returns structured error responses in the envelope format: `{ "error": { "code", "message", "details" }, "meta": { "request_id" } }`
7. **And** all success responses follow the envelope format: `{ "data": ..., "meta": { "request_id" } }`
8. **And** unit tests exist for config loading, error handler, and response envelope formatting

## Tasks / Subtasks

- [x] Task 1: Configuration Management — `app/core/config.py` (AC: #1)
  - [x] 1.1: Create `Settings(BaseSettings)` class with `SettingsConfigDict(env_file=".env", extra="ignore")`
  - [x] 1.2: Define typed fields for ALL environment variables from `.env.example`: DATABASE_URL, REDIS_URL, CHROMADB_URL, GEMINI_API_KEY, OPENROUTER_API_KEY, FIREBASE_PROJECT_ID, JWT_SECRET_KEY, JWT_ALGORITHM, JWT_ACCESS_TOKEN_EXPIRE_MINUTES, JWT_REFRESH_TOKEN_EXPIRE_DAYS, APP_ENV, APP_DEBUG, LOG_LEVEL
  - [x] 1.3: Add `@lru_cache` singleton pattern via `get_settings()` function
  - [x] 1.4: Add computed/derived properties where needed (e.g., `is_development` from `APP_ENV`)
  - [x] 1.5: Write unit tests verifying config loads from env vars, defaults work, and type validation catches invalid values

- [x] Task 2: Structured JSON Logging — `app/core/logging.py` (AC: #2)
  - [x] 2.1: Configure Python `logging` module to output structured JSON with fields: `timestamp`, `level`, `message`, `request_id`, `module`, `function`
  - [x] 2.2: Implement `request_id` propagation via `contextvars.ContextVar` so all log entries within a request carry the same request_id
  - [x] 2.3: Create `get_logger(name)` factory function that returns a configured logger
  - [x] 2.4: Write unit tests verifying JSON log output format and request_id propagation

- [x] Task 3: Custom Exception Classes — `app/core/exceptions.py` (AC: #3)
  - [x] 3.1: Create base `VentureIQError` exception class with `error_code`, `message`, `details`, `status_code` attributes
  - [x] 3.2: Define all 14 exception subclasses mapping to PRD error codes, each with correct HTTP status code
  - [x] 3.3: Write unit tests verifying exception attributes and inheritance

- [x] Task 4: Request ID Middleware — `app/core/middleware.py` (AC: #4)
  - [x] 4.1: Implement `RequestIDMiddleware` that generates UUID v4 for each request, stores in `contextvars.ContextVar`, and adds `X-Request-ID` response header
  - [x] 4.2: Set the `request_id` context var so logging picks it up automatically
  - [x] 4.3: Write unit tests verifying request_id generation, header inclusion, and uniqueness

- [x] Task 5: Response Envelope Utilities — `app/schemas/common.py` (AC: #6, #7)
  - [x] 5.1: Create Pydantic response models: `MetaSchema`, `SuccessResponse`, `ErrorDetail`, `ErrorResponse`
  - [x] 5.2: Create helper functions `success_response(data, request_id)` and `error_response(code, message, details, request_id, status_code)` that return properly formatted envelopes
  - [x] 5.3: Write unit tests verifying envelope structure

- [x] Task 6: Global Error Handler — integrated in `app/main.py` (AC: #5, #6)
  - [x] 6.1: Register `@app.exception_handler(VentureIQError)` that returns `JSONResponse` with error envelope and correct status code
  - [x] 6.2: Register `@app.exception_handler(RequestValidationError)` mapping to `INPUT_VALIDATION_ERROR`
  - [x] 6.3: Register catch-all `@app.exception_handler(Exception)` returning `INTERNAL_ERROR` (500) — **never expose stack traces**
  - [x] 6.4: Add middleware to the app (RequestID middleware)
  - [x] 6.5: Initialize logging in lifespan startup
  - [x] 6.6: Refactor health endpoint to use response envelope utilities and get `request_id` from context var
  - [x] 6.7: Write integration tests verifying error responses for custom exceptions, validation errors, and unhandled exceptions

- [x] Task 7: Update Existing Tests (AC: #8)
  - [x] 7.1: Update `tests/conftest.py` with any new fixtures needed (e.g., mock settings)
  - [x] 7.2: Update `test_health.py` to work with new middleware (request_id now comes from middleware, not hardcoded)
  - [x] 7.3: Ensure all tests pass with `pytest` and `ruff check`

## Dev Notes

### Architecture Compliance

This story builds the **backend core infrastructure layer** — config, logging, exceptions, and middleware. Every subsequent backend story depends on these patterns. Get them right here.

**Files to create/modify:**

| File                               | Action | Purpose                                       |
| :--------------------------------- | :----- | :-------------------------------------------- |
| `app/core/config.py`               | CREATE | Pydantic BaseSettings configuration           |
| `app/core/logging.py`              | CREATE | Structured JSON logging with request_id       |
| `app/core/exceptions.py`           | CREATE | All 14 custom exception classes               |
| `app/core/middleware.py`           | CREATE | RequestID middleware                          |
| `app/schemas/common.py`            | CREATE | Response envelope Pydantic models + helpers   |
| `app/main.py`                      | MODIFY | Add middleware, error handlers, lifespan init |
| `app/api/v1/endpoints/health.py`   | MODIFY | Use envelope utilities + context request_id   |
| `tests/conftest.py`                | MODIFY | Add fixtures for settings, request context    |
| `tests/unit/test_health.py`        | MODIFY | Adapt to new middleware-driven request_id     |
| `tests/unit/test_config.py`        | CREATE | Config loading tests                          |
| `tests/unit/test_exceptions.py`    | CREATE | Exception class tests                         |
| `tests/unit/test_middleware.py`    | CREATE | Middleware tests                              |
| `tests/unit/test_error_handler.py` | CREATE | Global error handler tests                    |

[Source: architecture.md#Structure Patterns, architecture.md#Project Structure]

### Technical Requirements

**Pydantic BaseSettings Configuration (`app/core/config.py`):**
- Use `pydantic-settings` package (already in dependencies: `pydantic-settings>=2.14.0`)
- Use `SettingsConfigDict` (NOT legacy `class Config`)
- Use `@lru_cache` via `get_settings()` for singleton pattern
- Set `env_file=".env"`, `extra="ignore"`, `case_sensitive=False`
- All fields MUST be typed — Pydantic validates on instantiation
- Sensitive fields (API keys, JWT secret) should use `SecretStr` type where appropriate for log-safe handling
- Fields must match `.env.example` variable names exactly (case-insensitive by default)

```python
from functools import lru_cache
from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://ventureiq:ventureiq@localhost:5432/ventureiq"
    # ... typed fields for ALL .env.example vars

@lru_cache
def get_settings() -> Settings:
    return Settings()
```

[Source: architecture.md#Config management, architecture.md#Core Architectural Decisions]

**Structured JSON Logging (`app/core/logging.py`):**
- Use Python's built-in `logging` module — do NOT add external logging libraries (structlog, python-json-logger)
- Implement a custom `JsonFormatter` that outputs JSON with: `timestamp` (ISO 8601 UTC), `level`, `message`, `request_id` (from context var), `module`, `function`, `extra` (any additional key-value pairs)
- Use `contextvars.ContextVar` for `request_id` propagation — this is thread-safe for async FastAPI
- Create `get_logger(name: str)` factory that returns a logger with the JSON formatter attached
- Log level configured from `Settings.LOG_LEVEL`

```python
import logging
import json
from contextvars import ContextVar
from datetime import datetime, timezone

request_id_ctx: ContextVar[str] = ContextVar("request_id", default="")

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "request_id": request_id_ctx.get(""),
            "module": record.module,
            "function": record.funcName,
        }
        # Include any extra fields
        if hasattr(record, "extra_data"):
            log_data.update(record.extra_data)
        return json.dumps(log_data)
```

[Source: architecture.md#Process Patterns — Error Handling, architecture.md#Enforcement Guidelines rule 9]

**Error Codes — ALL 14 from PRD:**

| Error Code                    | HTTP Status | Exception Class Name            |
| :---------------------------- | :---------- | :------------------------------ |
| `AUTH_REQUIRED`               | 401         | `AuthRequiredError`             |
| `AUTH_INVALID_TOKEN`          | 401         | `AuthInvalidTokenError`         |
| `AUTH_PROVIDER_TOKEN_INVALID` | 401         | `AuthProviderTokenInvalidError` |
| `RATE_LIMIT_EXCEEDED`         | 429         | `RateLimitExceededError`        |
| `INPUT_VALIDATION_ERROR`      | 400         | `InputValidationError`          |
| `IDEA_NOT_FOUND`              | 404         | `IdeaNotFoundError`             |
| `REPORT_NOT_FOUND`            | 404         | `ReportNotFoundError`           |
| `REPORT_NOT_READY`            | 409         | `ReportNotReadyError`           |
| `PROVIDER_RATE_LIMITED`       | 503         | `ProviderRateLimitedError`      |
| `PROVIDER_UNAVAILABLE`        | 503         | `ProviderUnavailableError`      |
| `EXPORT_FAILED`               | 500         | `ExportFailedError`             |
| `SHARE_LINK_FAILED`           | 500         | `ShareLinkFailedError`          |
| `STREAM_NOT_FOUND`            | 404         | `StreamNotFoundError`           |
| `INTERNAL_ERROR`              | 500         | `InternalError`                 |

[Source: prd.md#Error Codes]

**Exception class pattern:**

```python
class VentureIQError(Exception):
    """Base exception for VentureIQ."""
    error_code: str = "INTERNAL_ERROR"
    status_code: int = 500
    message: str = "An unexpected error occurred"
    
    def __init__(self, message: str | None = None, details: dict | None = None):
        self.message = message or self.__class__.message
        self.details = details
        super().__init__(self.message)

class AuthRequiredError(VentureIQError):
    error_code = "AUTH_REQUIRED"
    status_code = 401
    message = "Authentication is required"
```

[Source: architecture.md#Process Patterns — Error Handling]

**Response Envelope Format — MUST match exactly:**

```json
// Success
{
  "data": { ... },
  "meta": { "request_id": "uuid-v4" }
}

// Error
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": null
  },
  "meta": { "request_id": "uuid-v4" }
}
```

[Source: architecture.md#Format Patterns]

**RequestID Middleware Pattern:**

```python
import uuid
from starlette.middleware.base import BaseHTTPMiddleware
from app.core.logging import request_id_ctx

class RequestIDMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        rid = str(uuid.uuid4())
        request_id_ctx.set(rid)
        request.state.request_id = rid
        response = await call_next(request)
        response.headers["X-Request-ID"] = rid
        return response
```

**Global Error Handler Pattern:**

```python
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from app.core.exceptions import VentureIQError
from app.core.logging import request_id_ctx

@app.exception_handler(VentureIQError)
async def ventureiq_error_handler(request: Request, exc: VentureIQError):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.error_code,
                "message": exc.message,
                "details": exc.details,
            },
            "meta": {"request_id": request_id_ctx.get("")},
        },
    )
```

**CRITICAL:** Use `JSONResponse` directly in exception handlers — do NOT raise `HTTPException` from within handlers.

[Source: architecture.md#Process Patterns — Error Handling]

### Previous Story Intelligence (Story 1.1)

**Patterns established to follow:**
- App factory pattern: `create_app() -> FastAPI` in `app/main.py` — extend, don't replace
- Router aggregation: `app/api/v1/router.py` aggregates endpoint routers — no changes needed here
- Lifespan context manager already in place — add settings load and logging init to startup section
- Test client fixture in `tests/conftest.py` using `TestClient(app)` — extend with new fixtures
- Health endpoint at `GET /api/v1/health` currently generates request_id inline — refactor to use middleware context var

**Files from Story 1.1 to MODIFY carefully:**
- `app/main.py` (38 lines) — add middleware, exception handlers, lifespan init
- `app/api/v1/endpoints/health.py` (25 lines) — remove inline uuid, use envelope helper + context var
- `tests/conftest.py` (14 lines) — add new fixtures
- `tests/unit/test_health.py` (69 lines) — request_id now comes from middleware, not inline

**Review feedback from Story 1.1:**
- Docker compose bind mount issue was resolved by narrowing bind mount — no impact on this story
- Compose defaults pointed at localhost instead of container services — resolved with env overrides in docker-compose.yml

**Code patterns from Story 1.1:**
- Docstrings on all modules and functions
- Type hints on all function signatures
- Ruff-compliant code (line-length=120, py313 target)

### Dependencies

**Already available (from Story 1.1):**
- `fastapi[standard]>=0.136.1` — includes `starlette` (middleware base classes)
- `pydantic-settings>=2.14.0` — BaseSettings
- `uvicorn[standard]>=0.46.0` — ASGI server

**NO new dependencies needed.** All required functionality is available from:
- `pydantic-settings` — `BaseSettings`, `SettingsConfigDict`
- `starlette` (included with FastAPI) — `BaseHTTPMiddleware`
- Python stdlib — `logging`, `json`, `contextvars`, `uuid`, `datetime`

**DO NOT add:**
- ❌ `structlog` — use Python's built-in `logging` with a custom JSON formatter
- ❌ `python-json-logger` — same reason; keep dependencies minimal
- ❌ `loguru` — same reason

### Testing Requirements

**Test framework:** `pytest` (already in dev deps)
**Test client:** `httpx` (already in dev deps) — prefer `TestClient` from FastAPI for sync tests
**Async testing:** Not needed for this story — all tests can be synchronous

**Required test files:**

| Test File                          | Tests                                                                        |
| :--------------------------------- | :--------------------------------------------------------------------------- |
| `tests/unit/test_config.py`        | Config loads from env vars, defaults work, type validation                   |
| `tests/unit/test_exceptions.py`    | All 14 exceptions have correct error_code, status_code, message              |
| `tests/unit/test_middleware.py`    | RequestID generated, unique per request, header present                      |
| `tests/unit/test_error_handler.py` | Custom exception → correct envelope, validation error → 400, unhandled → 500 |
| `tests/unit/test_health.py`        | Update existing tests for middleware-driven request_id                       |

**Test patterns from Story 1.1:**
```python
def test_example(client):
    """Descriptive docstring."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
```

[Source: architecture.md#Test Organization]

### Anti-Patterns to AVOID

- ❌ Do NOT use `@app.on_event("startup")` — use lifespan context manager (already in place)
- ❌ Do NOT add external logging libraries (structlog, loguru, python-json-logger) — use Python stdlib `logging`
- ❌ Do NOT use `print()` statements — use structured logger
- ❌ Do NOT expose stack traces in error responses — always use structured error envelope
- ❌ Do NOT raise `HTTPException` inside exception handlers — return `JSONResponse` directly
- ❌ Do NOT hardcode config values — all config via `Settings` from env vars
- ❌ Do NOT use legacy `class Config` in Pydantic — use `SettingsConfigDict`
- ❌ Do NOT create `app/core/dependencies.py` in this story — that's Story 1.3 (DB/Redis deps)
- ❌ Do NOT implement database connections, Redis, or Alembic — that's Story 1.3
- ❌ Do NOT implement auth/security — that's Story 2.1
- ❌ Do NOT add any new pip/uv dependencies — everything needed is already installed

### Scope Boundaries

**IN SCOPE:**
- `app/core/config.py` — Pydantic BaseSettings
- `app/core/logging.py` — Structured JSON logging with request_id context
- `app/core/exceptions.py` — All 14 custom exception classes
- `app/core/middleware.py` — RequestID middleware
- `app/schemas/common.py` — Response envelope Pydantic models + helpers
- `app/main.py` modifications — middleware registration, error handlers, lifespan enhancements
- Health endpoint refactoring to use new infrastructure
- Comprehensive unit tests for all new code

**OUT OF SCOPE:**
- **NO** `app/core/dependencies.py` (Story 1.3 — FastAPI Depends for DB/Redis)
- **NO** `app/core/security.py` (Story 2.1 — JWT/Firebase auth)
- **NO** database connections, SQLAlchemy, or Alembic (Story 1.3)
- **NO** Redis connections (Story 1.3)
- **NO** rate limiting middleware (Story 2.4 — uses Redis db2)
- **NO** provider abstractions (Story 1.4)
- **NO** new dependencies added to `pyproject.toml`

### Project Structure Notes

- All files must go in the established directory structure from Story 1.1
- `app/core/` directory already exists with `__init__.py`
- `app/schemas/` directory already exists with `__init__.py`
- `tests/unit/` directory already exists with `__init__.py`
- Follow naming conventions: `snake_case.py` for files, `PascalCase` for classes, `snake_case` for functions/variables
- `{Entity}{Action}Schema` naming pattern for Pydantic schemas (e.g., `ErrorResponseSchema` → though for common schemas, shorter names like `ErrorResponse` are acceptable)

### References

- [Source: architecture.md#Config management] — Pydantic BaseSettings + .env + GCP Secret Manager
- [Source: architecture.md#Process Patterns — Error Handling] — Layer-appropriate error handling patterns
- [Source: architecture.md#Format Patterns] — API response envelope format
- [Source: architecture.md#Enforcement Guidelines] — 10 enforcement rules including structured logging
- [Source: architecture.md#Structure Patterns] — Backend project organization
- [Source: architecture.md#Naming Patterns] — Code naming conventions
- [Source: prd.md#Error Codes] — All 14 enumerated error codes with HTTP status codes
- [Source: prd.md#Error Handling] — Structured error response requirements
- [Source: epics.md#Story 1.2] — Story acceptance criteria
- [Source: epics.md#Epic 1 Overview] — Epic context and objectives

## Dev Agent Record

### Agent Model Used

GPT-5.2-Codex

### Implementation Plan

- Implement config, logging, exceptions, and request ID middleware per Dev Notes
- Add response envelope schemas/helpers and wire middleware + handlers into the app lifecycle
- Update health endpoint and tests, then verify lint/test runs

### Debug Log References

- `runTests` on individual files reported "No tests found"; full `runTests` invocation returned summary passed=1 failed=0
- `ruff check app tests` passed after UTC and generic type syntax fixes

### Completion Notes List

- ✅ Task 1: Added typed `Settings` with defaults, SecretStr fields, cached `get_settings`, and config tests
- ✅ Task 2: Added JSON logging formatter, request_id context propagation, logging setup, and log format tests
- ✅ Task 3: Added `VentureIQError` base plus 14 subclasses with status codes/messages and tests
- ✅ Task 4: Added Request ID middleware with X-Request-ID header + context var and tests
- ✅ Task 5: Added response envelope schemas/helpers and tests for success/error envelopes
- ✅ Task 6: Wired middleware and exception handlers in `create_app`, updated health endpoint, and added error handler tests
- ✅ Task 7: Updated test fixtures and health tests; `ruff check app tests` clean; `runTests` summary passed=1 failed=0

### File List

- `backend/app/core/config.py` (new)
- `backend/app/core/logging.py` (new)
- `backend/app/core/exceptions.py` (new)
- `backend/app/core/middleware.py` (new)
- `backend/app/schemas/common.py` (new)
- `backend/app/main.py` (modified)
- `backend/app/api/v1/endpoints/health.py` (modified)
- `backend/tests/conftest.py` (modified)
- `backend/tests/unit/test_health.py` (modified)
- `backend/tests/unit/test_config.py` (new)
- `backend/tests/unit/test_logging.py` (new)
- `backend/tests/unit/test_exceptions.py` (new)
- `backend/tests/unit/test_middleware.py` (new)
- `backend/tests/unit/test_response_envelope.py` (new)
- `backend/tests/unit/test_error_handler.py` (new)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (modified)

### Change Log

- 2026-05-09: Story 1.2 implementation complete — core config/logging/errors/middleware added, envelopes enforced, and tests updated

### Review Findings

- [x] [Review][Decision] Validation error details exposure — `RequestValidationError` handler includes full error list in `details` (`{"errors": exc.errors()}`), exposing internal schema.
- [x] [Review][Patch] Inconsistent request_id fallback [backend/app/api/v1/endpoints/health.py:13]
- [x] [Review][Patch] Request state redundancy [backend/app/core/middleware.py]
- [x] [Review][Patch] Logger reconfiguration without cleanup [backend/app/core/logging.py:42]
- [x] [Review][Patch] No request_id validation as UUID [backend/app/schemas/common.py]
- [x] [Review][Patch] JSON serializable issues in logging [backend/app/core/logging.py:29]
- [x] [Review][Patch] Un-serializable objects in JSONResponse [backend/app/schemas/common.py]
- [x] [Review][Patch] get_settings ValidationError uncaught [backend/app/main.py:30]
- [x] [Review][Patch] Unused parameter in error_response [backend/app/schemas/common.py]
- [x] [Review][Patch] No logging for request_id generation [backend/app/core/middleware.py]
- [x] [Review][Patch] Generic type syntax (Python 3.12+) [backend/app/schemas/common.py]
- [x] [Review][Defer] Missing UTC import version check [various] — deferred, pre-existing
- [x] [Review][Defer] No end-to-end logging test [various] — deferred, pre-existing
- [x] [Review][Defer] Settings cache collision in concurrent tests [backend/tests] — deferred, pre-existing
- [x] [Review][Defer] SecretStr downstream access [backend/app/core/config.py] — deferred, pre-existing
