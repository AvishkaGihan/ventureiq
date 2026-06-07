---
baseline_commit: a1318d1ffc82fa331b4ab4a901841cbbfd9c57d2
---

# Story 3.1: Idea Submission Endpoint & Input Sanitization (Backend)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want an API endpoint that receives business ideas, sanitizes them against prompt injection, and stores them for analysis,
So that user-submitted ideas are validated and safe before consuming AI resources.

## Acceptance Criteria

1. `app/models/idea.py` defines SQLAlchemy `Idea` model with fields: `id` (UUID), `user_id`, `idea_text`, `target_audience`, `industry`, `monetization_model`, `region`, `status`, `created_at`
2. `app/schemas/idea.py` defines Pydantic request schema `IdeaCreateRequest` (idea_text required, context fields optional) and response schema `IdeaResponse`
3. `app/api/v1/endpoints/ideas.py` provides `POST /api/v1/ideas` that validates, sanitizes, and persists the idea
4. `app/services/sanitization_service.py` implements input sanitization against prompt injection using pattern matching and content filtering (NFR12, FR50)
5. Ideas shorter than 10 characters or flagged as non-business content return `422` with helpful guidance: "Add more detail about your business idea for better results"
6. Alembic migration creates the `ideas` table
7. The endpoint returns the created idea with `status: "pending"` in the standard envelope format
8. Rate limiting middleware (from Story 2.4) is applied — free tier users blocked after 3 reports/month
9. Unit tests verify sanitization against a prompt injection test corpus and input validation edge cases

## Tasks / Subtasks

### Backend

- [x] Task 1: Idea SQLAlchemy Model (AC: #1)
  - [x] 1.1 Create `app/models/idea.py` with `IdeaModel` class extending `Base`
  - [x] 1.2 Fields: `user_id` (UUID FK → `users.id`, indexed), `idea_text` (Text, not null), `target_audience` (String(255), nullable), `industry` (String(255), nullable), `monetization_model` (String(255), nullable), `region` (String(100), nullable), `status` (String(20), not null, default `"pending"`)
  - [x] 1.3 `__tablename__ = "ideas"` (plural, snake_case per convention)
  - [x] 1.4 Register in `app/models/__init__.py`: add `IdeaModel` to imports and `__all__`
  - [x] 1.5 Ensure `user_id` FK references `users.id` using `ForeignKey("users.id")` — the `users` table already exists from Epic 2

- [x] Task 2: Alembic Migration (AC: #6)
  - [x] 2.1 Run `alembic revision --autogenerate -m "create ideas table"` to generate migration
  - [x] 2.2 Review migration: verify UUID PK, FK to `users.id`, index on `user_id` (`ix_ideas_user_id`), all column types correct
  - [x] 2.3 Run `alembic upgrade head` to apply migration
  - [x] 2.4 Verify migration is reversible: `alembic downgrade -1` then `alembic upgrade head`

- [x] Task 3: Idea Pydantic Schemas (AC: #2)
  - [x] 3.1 Create `app/schemas/idea.py`
  - [x] 3.2 `IdeaCreateRequest(BaseModel)`: `idea_text: str` (required, `min_length=10`, `max_length=5000`), `target_audience: str | None = None`, `industry: str | None = None`, `monetization_model: str | None = None`, `region: str | None = None`
  - [x] 3.3 Add `field_validator` on `idea_text`: strip leading/trailing whitespace, reject if stripped length < 10
  - [x] 3.4 `IdeaResponse(BaseModel)`: `id: uuid.UUID`, `user_id: uuid.UUID`, `idea_text: str`, `target_audience: str | None`, `industry: str | None`, `monetization_model: str | None`, `region: str | None`, `status: str`, `created_at: datetime`
  - [x] 3.5 Add `model_config = ConfigDict(from_attributes=True)` on `IdeaResponse` for ORM conversion

- [x] Task 4: Sanitization Service (AC: #4, #5)
  - [x] 4.1 Create `app/services/sanitization_service.py` with `SanitizationService` class
  - [x] 4.2 Method: `sanitize(text: str) → SanitizationResult` — returns `SanitizationResult(is_safe: bool, sanitized_text: str, reason: str | None)`
  - [x] 4.3 Implement defense-in-depth input sanitization:
    - **Pattern matching**: Regex detection for known prompt injection phrases ("ignore all previous instructions", "you are now", "system prompt", "act as", "forget everything", "override", "new instructions", "DAN mode", "developer mode", encoded variants like base64/hex)
    - **Content filtering**: Detect non-business content (detect code injection attempts, script tags, SQL injection patterns)
    - **Unicode normalization**: Normalize Unicode to NFC to prevent homoglyph attacks before pattern matching
    - **Control character stripping**: Remove/replace zero-width characters, invisible unicode characters
  - [x] 4.4 Validation: reject ideas < 10 chars (after stripping) with reason: "Add more detail about your business idea for better results"
  - [x] 4.5 Return `SanitizationResult` dataclass: `is_safe: bool`, `sanitized_text: str`, `reason: str | None`, `flagged_patterns: list[str]`
  - [x] 4.6 Log flagged patterns using structured logger (never log the raw malicious input to prevent log injection — log pattern names only)

- [x] Task 5: Ideas Endpoint (AC: #3, #7, #8)
  - [x] 5.1 Create `app/api/v1/endpoints/ideas.py` with FastAPI `APIRouter`
  - [x] 5.2 `POST /` (mounted at `/api/v1/ideas` in router.py): accepts `IdeaCreateRequest` body
  - [x] 5.3 Dependencies: `current_user: UserModel = Depends(get_current_user)`, `session: AsyncSession = Depends(get_db)`
  - [x] 5.4 Flow: validate input → sanitize via `SanitizationService` → if unsafe, raise `InputValidationError` with sanitization reason → create `IdeaModel` → persist → return `IdeaResponse` in `success_response()` envelope
  - [x] 5.5 Set `idea.status = "pending"` on creation
  - [x] 5.6 Set `idea.user_id = current_user.id` (from JWT-authenticated user)
  - [x] 5.7 Register in `app/api/v1/router.py`: `api_v1_router.include_router(ideas_router, prefix="/ideas", tags=["ideas"])`

- [x] Task 6: Unit & Integration Tests (AC: #9)
  - [x] 6.1 Create `tests/unit/test_sanitization_service.py`:
    - Test known prompt injection patterns are detected (corpus of ~15-20 patterns)
    - Test Unicode normalization catches homoglyph attacks
    - Test control character stripping
    - Test valid business ideas pass sanitization
    - Test boundary: exactly 10 chars passes, 9 chars fails
    - Test whitespace-only input fails
    - Test very long input (5000+ chars) is handled correctly
  - [x] 6.2 Create `tests/unit/test_idea_schemas.py`:
    - Test `IdeaCreateRequest` validation (required fields, min_length, max_length)
    - Test optional fields accept None
    - Test whitespace stripping on idea_text
    - Test `IdeaResponse` from_attributes ORM conversion
  - [x] 6.3 Create `tests/integration/test_ideas_endpoint.py`:
    - Test `POST /api/v1/ideas` creates idea and returns 200 with envelope
    - Test unauthenticated request returns 401 AUTH_REQUIRED
    - Test idea_text < 10 chars returns 422 with guidance message
    - Test prompt injection attempt returns 400 INPUT_VALIDATION_ERROR
    - Test rate-limited user (4th request in month) returns 429 RATE_LIMIT_EXCEEDED
    - Test all optional context fields are persisted correctly
    - Test idea status is "pending" in response
    - Use `httpx.AsyncClient` (not `TestClient`) per project conventions

## Dev Notes

### Architecture Compliance

- **API endpoint pattern**: One router file per resource → `ideas.py` in `endpoints/`
- **Schema naming**: `IdeaCreateRequest` (not `IdeaSubmitSchema` — follow PRD naming but apply project convention `{Entity}{Action}Schema` → PRD says `IdeaSubmitSchema` but architecture convention is `{Entity}{Action}Schema`; use **`IdeaCreateRequest`** since this is a request schema and matches the pattern from `auth.py`)
- **Model naming**: `IdeaModel` (matches `UserModel` convention)
- **Response envelope**: ALL responses via `success_response()` helper from `app/schemas/common.py`
- **Error raising**: Use `InputValidationError` from `app/core/exceptions.py` (already exists at line 51-56) — NEVER raise raw `HTTPException`
- **422 status for validation**: The `InputValidationError` has `status_code=400`. For the < 10 char validation, raise `InputValidationError(message="Add more detail about your business idea for better results")`. NOTE: The AC says 422 but the project's `InputValidationError` uses 400 — **use 400 to match the existing exception pattern** (the error handler maps `InputValidationError` → 400). Do NOT create a new exception class.
- **Rate limiting**: The `RateLimitMiddleware` (from Story 2.4) already targets `POST /api/v1/ideas` in its `route_prefixes` config — this endpoint will be rate-limited automatically. No additional work needed.
- **Database convention**: Table name `ideas` (plural), columns `snake_case`, PK `id` (UUID v4), FK `user_id` → `users.id`, index `ix_ideas_user_id`

### Existing Infrastructure to Reuse (DO NOT Recreate)

| Component | File | What Exists |
|---|---|---|
| `Base` class | `app/db/base.py:50` | Declarative base with `TimestampMixin` (id UUID PK, created_at, updated_at) — INHERIT FROM THIS |
| `UserModel` | `app/models/user.py` | User table with `id`, `tier`, `firebase_uid` — FK TARGET |
| `InputValidationError` | `app/core/exceptions.py:51-56` | `error_code="INPUT_VALIDATION_ERROR"`, `status_code=400` — USE THIS for sanitization failures |
| `get_current_user()` | `app/core/dependencies.py:62-88` | Returns `UserModel` from JWT — USE AS DEPENDENCY |
| `get_db()` | `app/core/dependencies.py:19-22` | Yields `AsyncSession` — USE AS DEPENDENCY |
| `success_response()` | `app/schemas/common.py:38-40` | Response envelope helper — USE FOR ALL RESPONSES |
| `RateLimitMiddleware` | `app/core/middleware.py:40-117` | Already targets `POST /api/v1/ideas` — NO CHANGES NEEDED |
| `api_v1_router` | `app/api/v1/router.py` | Router aggregator — ADD ideas router here |
| `get_logger()` | `app/core/logging.py` | Structured JSON logger — USE FOR ALL LOGGING |
| `request_id_ctx` | `app/core/logging.py` | Context var for request ID — USE IN LOGGING |
| Error handler | `app/main.py` | Global `VentureIQError` handler — catches `InputValidationError` automatically |
| `DummyRedisManager` | `tests/conftest.py` | Test mock for Redis — REUSE IN TESTS |
| Test auth fixtures | `tests/conftest.py` | Authenticated test client fixtures — REUSE |

### Technical Implementation Details

**IdeaModel ForeignKey Setup:**
```python
from sqlalchemy import ForeignKey
from sqlalchemy.dialects.postgresql import UUID as PG_UUID

user_id: Mapped[uuid.UUID] = mapped_column(
    PG_UUID(as_uuid=True),
    ForeignKey("users.id"),
    nullable=False,
    index=True,
)
```

**Sanitization Pattern Corpus (Minimum):**
```python
INJECTION_PATTERNS = [
    r"(?i)ignore\s+(all\s+)?previous\s+instructions",
    r"(?i)forget\s+(all\s+|everything\s+)?(you\s+)?(know|were\s+told)",
    r"(?i)you\s+are\s+now\s+(?:a\s+)?(?:an?\s+)?",
    r"(?i)new\s+(?:system\s+)?instructions?\s*[:：]",
    r"(?i)system\s*(?:prompt|message)\s*[:：]",
    r"(?i)(?:override|bypass|disable)\s+(?:safety|security|filter|guard)",
    r"(?i)act\s+as\s+(?:a\s+)?(?:an?\s+)?",
    r"(?i)(?:DAN|developer)\s+mode",
    r"(?i)jailbreak",
    r"(?i)(?:pretend|imagine)\s+(?:you\s+are|that)",
    r"(?i)do\s+not\s+follow\s+(?:any\s+)?(?:rules|guidelines|instructions)",
    r"(?i)(?:reveal|show|print|output)\s+(?:your\s+)?(?:system\s+)?prompt",
    r"(?i)<\s*(?:script|iframe|img|svg|object|embed)",
    r"(?i)(?:UNION|SELECT|DROP|INSERT|DELETE|UPDATE)\s+",
]
```

**Unicode Normalization:**
```python
import unicodedata

def _normalize_text(text: str) -> str:
    """Normalize Unicode to NFC and strip zero-width characters."""
    normalized = unicodedata.normalize("NFC", text)
    # Strip zero-width characters
    zero_width = "\u200b\u200c\u200d\u200e\u200f\ufeff\u2060\u2061\u2062\u2063"
    for char in zero_width:
        normalized = normalized.replace(char, "")
    return normalized
```

**Endpoint Implementation Pattern (follow existing auth.py style):**
```python
from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user, get_db
from app.core.logging import get_logger, request_id_ctx
from app.models.user import UserModel
from app.schemas.common import success_response

router = APIRouter()
logger = get_logger(__name__)

@router.post("/")
async def create_idea(
    request: Request,
    body: IdeaCreateRequest,
    current_user: UserModel = Depends(get_current_user),
    session: AsyncSession = Depends(get_db),
) -> dict:
    # sanitize → validate → persist → respond
    ...
    return success_response(data=IdeaResponse.model_validate(idea), request_id=request_id_ctx.get("unknown"))
```

### Anti-Patterns — MUST FOLLOW

**Backend:**
1. ❌ DO NOT raise `HTTPException` directly — use `InputValidationError` (VentureIQError subclass)
2. ❌ DO NOT use `print()` — use `get_logger(__name__)` with structured extra data
3. ❌ DO NOT use raw dicts for responses — use Pydantic schemas + `success_response()`
4. ❌ DO NOT log raw user input in sanitization failure logs — log pattern names only (security)
5. ❌ DO NOT use `validator` decorator — use `field_validator` (Pydantic v2)
6. ❌ DO NOT use inner `Config` class — use `model_config = ConfigDict(...)` (Pydantic v2)
7. ❌ DO NOT use `json()` method — use `model_dump()` (Pydantic v2)
8. ❌ DO NOT create synchronous database queries — all SQLAlchemy operations use `async_session` with `await`
9. ❌ DO NOT use `@app.on_event("startup")` — use lifespan pattern (already in main.py)
10. ❌ DO NOT modify existing `RequestIDMiddleware`, `RateLimitMiddleware`, or exception classes
11. ❌ DO NOT create new top-level directories — follow existing project structure exactly
12. ❌ DO NOT use `aioredis` — use `redis.asyncio` if Redis is needed (project standard)

### Previous Story Learnings (APPLY THESE)

**From Epic 2 Stories:**
- **SecretStr pitfall**: Always `.get_secret_value()` before passing secrets to libraries
- **Async timeout**: Add explicit timeouts to Redis calls
- **Settings cache**: Use `get_settings.cache_clear()` in test fixtures when overriding config
- **Ruff compliance**: `ruff check app tests` — target zero issues (line-length=120, py313)
- **Dependency overrides**: Use `app.dependency_overrides[dep] = mock_dep` in integration tests
- **Non-atomic race condition**: Solved by using atomic operations — apply same mindset here
- **Dio error swallowing**: Verify error responses propagate correctly in tests

**From Epic 2 Retrospective Action Items for Epic 3:**
- **Sanitization Rules Catalog** (Amelia): Create a comprehensive prompt injection test corpus — cover this in unit tests
- **Expand Rate Limiter Key Helper** (Charlie): Ensure rate limiter works with user IDs (already implemented in 2.4, verify it works with this endpoint)
- **Standardize Rate Limit Schema** (Charlie): Rate limit responses should align with standard error envelopes (already done in 2.4)

### Git Intelligence

**Recent commits (5 most recent):**
1. `a1318d1` — docs: add Epic 2 retrospective report and update sprint status to mark Epic 2 as complete
2. `a4edd09` — Merge PR: bmad-skills-cleanup-and-customization
3. `4a9ca09` — feat: implement tier-based rate limiting with backend service and mobile UI usage tracking
4. `4c2ca02` — Merge remote-tracking branch 'origin/useage-limits-and-rate-limiting'
5. `9e30b2d` — refactor(bmad): cleanup bmad skills, consolidate workflows, and add customization overrides

**Patterns established**: rate limiting uses Redis ZSET with Lua scripts, middleware-based approach, test fixtures use `DummyRedisManager`, integration tests use `httpx.AsyncClient`.

### Project Structure Notes

**New files to create:**
```
backend/app/
├── models/idea.py                               [NEW]
├── schemas/idea.py                              [NEW]
├── services/sanitization_service.py             [NEW]
├── api/v1/endpoints/ideas.py                    [NEW]

backend/tests/
├── unit/test_sanitization_service.py            [NEW]
├── unit/test_idea_schemas.py                    [NEW]
├── integration/test_ideas_endpoint.py           [NEW]

backend/migrations/versions/
├── xxxx_create_ideas_table.py                   [NEW - auto-generated]
```

**Files to modify:**
```
backend/app/models/__init__.py                   [MODIFY] — Add IdeaModel import and __all__
backend/app/api/v1/router.py                     [MODIFY] — Register ideas router
```

**Files NOT to modify (verify they work as-is):**
```
backend/app/core/middleware.py                   [NO CHANGE] — RateLimitMiddleware already targets /api/v1/ideas
backend/app/core/exceptions.py                   [NO CHANGE] — InputValidationError already exists
backend/app/core/dependencies.py                 [NO CHANGE] — get_current_user, get_db already exist
backend/app/schemas/common.py                    [NO CHANGE] — success_response already exists
```

### Downstream Dependencies (Who Uses What 3.1 Builds)

- **Story 3.2** (Plausibility Check via LLM): Will call `POST /api/v1/ideas/{id}/plausibility` — needs the Idea model and ideas endpoint as foundation
- **Story 3.3** (Idea Input Screen Flutter): Will call `POST /api/v1/ideas` — needs this endpoint to be working
- **Story 4.1** (LangGraph Agent Pipeline): Will consume ideas from the database for analysis
- **All downstream stories** rely on the `ideas` table existing in the database

### Scope Boundaries

- ✅ **IN SCOPE**: Idea model, schemas, sanitization service, POST endpoint, Alembic migration, unit/integration tests
- ❌ **OUT OF SCOPE**: Plausibility check (Story 3.2), Flutter UI (Story 3.3), voice input (Story 3.4), GET/UPDATE/DELETE idea endpoints (future stories), full analysis pipeline trigger
- ⚠️ **NOTE**: This story creates the idea with `status: "pending"`. The plausibility check (Story 3.2) will update it to `plausibility_passed` or `plausibility_failed`. The analysis pipeline (Epic 4) will consume `plausibility_passed` ideas.

### References

- [Source: epics.md#L540-L558 — Story 3.1 definition](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/_bmad-output/planning-artifacts/epics.md#L540-L558)
- [Source: architecture.md#L661 — ideas.py endpoint in structure](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/_bmad-output/planning-artifacts/architecture.md#L661)
- [Source: architecture.md#L719 — idea.py schema in structure](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/_bmad-output/planning-artifacts/architecture.md#L719)
- [Source: architecture.md#L277 — Prompt injection defense-in-depth](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/_bmad-output/planning-artifacts/architecture.md#L277)
- [Source: architecture.md#L462-L470 — API response envelope format](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/_bmad-output/planning-artifacts/architecture.md#L462-L470)
- [Source: architecture.md#L943-L944 — POST /ideas → IdeaService.validate() flow](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/_bmad-output/planning-artifacts/architecture.md#L943-L944)
- [Source: 2-4 story — Rate limit middleware already targets /api/v1/ideas](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/_bmad-output/implementation-artifacts/2-4-tier-based-usage-limits-rate-limiting.md)
- [Source: epic-2-retro — Action items for Epic 3](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/_bmad-output/implementation-artifacts/epic-2-retro-2026-06-07.md#L88-L106)
- [Source: project-context.md — All project rules and conventions](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/_bmad-output/project-context.md)

## Dev Agent Record

### Agent Model Used

GPT-5 Codex

### Debug Log References

- `.\.venv\Scripts\pytest.exe tests\unit\test_idea_model.py` - passed after Task 1 implementation.
- `.\.venv\Scripts\alembic.exe revision --autogenerate -m "create ideas table"` - generated migration; reviewed and corrected unsafe autogen output.
- `.\.venv\Scripts\alembic.exe upgrade head` - applied migration.
- `.\.venv\Scripts\alembic.exe downgrade -1` then `.\.venv\Scripts\alembic.exe upgrade head` - verified reversibility.
- `.\.venv\Scripts\pytest.exe tests\unit\test_idea_schemas.py` - passed after Task 3 implementation.
- `.\.venv\Scripts\pytest.exe tests\unit\test_sanitization_service.py` - passed after Task 4 implementation.
- `.\.venv\Scripts\pytest.exe tests\integration\test_ideas_endpoint.py` - passed after Task 5 implementation.
- `.\.venv\Scripts\pytest.exe tests\unit\test_idea_model.py tests\unit\test_idea_schemas.py tests\unit\test_sanitization_service.py tests\integration\test_ideas_endpoint.py` - 39 passed.
- `.\.venv\Scripts\ruff.exe check app tests migrations` - all checks passed.
- `.\.venv\Scripts\pytest.exe` - 137 passed, 13 existing JWT key-length warnings.

### Completion Notes List

- Implemented `IdeaModel` with UUID user FK, text/context fields, pending status, and model package registration.
- Added and verified Alembic migration `db34530b5f9b_create_ideas_table.py`; corrected autogenerate output so it creates only `ideas` and does not drop `users`.
- Added `IdeaCreateRequest` and `IdeaResponse` with Pydantic v2 validation and ORM conversion support.
- Implemented `SanitizationService` with prompt-injection regex corpus, base64/hex decoded variant detection, HTML/SQL/code payload filtering, Unicode normalization, zero-width stripping, and pattern-only warning logs.
- Added `POST /api/v1/ideas` using authenticated user dependency, async DB session, sanitizer, `InputValidationError`, and standard success envelope.
- Preserved project exception behavior for validation as 400 per Dev Notes, while returning the required short-idea guidance message.
- Added unit and integration coverage for model shape, schema boundaries, sanitization corpus, endpoint persistence/envelope/auth/sanitization/rate-limit behavior.

### File List

- backend/app/api/v1/endpoints/ideas.py
- backend/app/api/v1/router.py
- backend/app/main.py
- backend/app/models/__init__.py
- backend/app/models/idea.py
- backend/app/schemas/idea.py
- backend/app/services/sanitization_service.py
- backend/migrations/versions/db34530b5f9b_create_ideas_table.py
- backend/tests/integration/test_ideas_endpoint.py
- backend/tests/unit/test_idea_model.py
- backend/tests/unit/test_idea_schemas.py
- backend/tests/unit/test_sanitization_service.py

### Change Log

- 2026-06-07: Implemented Story 3.1 backend idea submission endpoint, sanitization, persistence model/migration, and tests. Status set to review.

### Review Findings
- [x] [Review][Decision] Overly broad SQL injection regex introduces false positives — The sql_injection regex blindly blocks SELECT , UPDATE , UNION , etc., which will reject legitimate business ideas containing common words (e.g. "A union for freelance workers").
- [x] [Review][Patch] Optional fields bypass sanitization [backend/app/api/v1/endpoints/ideas.py:60-63]
- [x] [Review][Patch] Modified global exception handler inappropriately couples to endpoint logic [backend/app/main.py:102-118]
- [x] [Review][Patch] Pydantic min_length constraint preempts SanitizationService length check [backend/app/schemas/idea.py:193]
- [x] [Review][Patch] Optional string fields lack whitespace trimming [backend/app/schemas/idea.py:12-15]
- [x] [Review][Patch] Sanitization bypass via URL/HTML encoding [backend/app/services/sanitization_service.py:108-118]
- [x] [Review][Patch] Base64 payload missing padding bypasses detection [backend/app/services/sanitization_service.py:126-128]
- [x] [Review][Patch] Prompt injection bypass via fullwidth/compatibility characters [backend/app/services/sanitization_service.py:102-106]
- [x] [Review][Patch] Unhandled Null Byte (\u0000) causes DB commit failure [backend/app/api/v1/endpoints/ideas.py:66-67]
- [x] [Review][Patch] Naive HTML Filtering ignores dangerous tags [backend/app/services/sanitization_service.py]
- [x] [Review][Patch] Duplicated guidance message [backend/app/main.py & backend/app/services/sanitization_service.py]
- [x] [Review][Defer] Integration tests mock database session [backend/tests/integration/test_ideas_endpoint.py] — deferred, pre-existing
