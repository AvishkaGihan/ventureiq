# Story 2.1: Firebase Authentication & JWT Exchange (Backend)

Status: done

## Story

As a **developer**,
I want Firebase authentication integrated with the backend JWT exchange pattern,
so that the backend can verify Firebase ID tokens and issue its own JWTs with custom claims for all subsequent API authorization.

## Acceptance Criteria (BDD)

1. **Given** the backend infrastructure from Epic 1  
   **When** the auth system is implemented  
   **Then** `app/core/security.py` implements Firebase ID token verification using Firebase Admin SDK

2. **And** `app/core/security.py` implements backend JWT generation with custom claims (`user_id`, `tier`, `auth_method`)

3. **And** `app/api/v1/endpoints/auth.py` provides `POST /api/v1/auth/exchange` that accepts a Firebase ID token and returns a backend JWT + refresh token pair

4. **And** `app/api/v1/endpoints/auth.py` provides `POST /api/v1/auth/refresh` that accepts a refresh token and returns a new JWT + rotated refresh token (NFR16)

5. **And** JWT access tokens expire after a configurable period (default: 1 hour, setting: `JWT_ACCESS_TOKEN_EXPIRE_MINUTES=60`)

6. **And** refresh token rotation is enforced — each refresh token is single-use (NFR16)

7. **And** `app/core/dependencies.py` provides `get_current_user()` dependency that extracts and validates JWT from `Authorization: Bearer` header

8. **And** unauthenticated requests to protected endpoints return `401` with error code `AUTH_REQUIRED`

9. **And** unit tests verify token exchange, refresh rotation, and expired token rejection

## Tasks / Subtasks

- [x] Task 1: Add Firebase Admin SDK + PyJWT dependencies (AC: #1, #2)
  - [x] 1.1 Add `firebase-admin>=7.4.0` and `PyJWT[crypto]>=2.12.1` to `backend/pyproject.toml` dependencies
  - [x] 1.2 Run `uv sync` to install and verify lock file
  - [x] 1.3 Add `pytest-asyncio>=0.25.0` to dev dependencies (needed for async test fixtures)
  - [x] 1.4 Update `FIREBASE_SERVICE_ACCOUNT_PATH` in Settings (see Config section below)
- [x] Task 2: Create `app/core/security.py` — Firebase + JWT (AC: #1, #2)
  - [x] 2.1 Initialize Firebase Admin SDK with service account credentials
  - [x] 2.2 Implement `verify_firebase_token(token: str) -> dict` — verify Firebase ID token, return decoded claims
  - [x] 2.3 Implement `create_access_token(data: dict) -> str` — JWT with `sub`, `tier`, `auth_method`, `jti`, `iat`, `exp`
  - [x] 2.4 Implement `create_refresh_token(user_id: str) -> str` — JWT with `sub`, `jti`, `type=refresh`, longer expiry
  - [x] 2.5 Implement `verify_jwt(token: str) -> dict` — decode and validate backend JWT
  - [x] 2.6 Handle `JWT_SECRET_KEY` via `settings.JWT_SECRET_KEY.get_secret_value()`
- [x] Task 3: Create `app/models/user.py` — UserModel (AC: #1, #3)
  - [x] 3.1 Define `UserModel` with SQLAlchemy mapped columns extending `Base`
  - [x] 3.2 Add Alembic migration for `users` table
- [x] Task 4: Create `app/schemas/auth.py` — Pydantic schemas (AC: #3, #4)
  - [x] 4.1 `TokenExchangeRequestSchema` — `{ firebase_token: str }`
  - [x] 4.2 `TokenRefreshRequestSchema` — `{ refresh_token: str }`
  - [x] 4.3 `TokenResponseSchema` — `{ access_token, refresh_token, token_type, expires_in }`
  - [x] 4.4 `UserResponseSchema` — `{ id, email, display_name, tier, auth_method }`
- [x] Task 5: Create `app/services/auth_service.py` — Business logic (AC: #3, #4, #6)
  - [x] 5.1 `exchange_token(firebase_token, db)` — verify Firebase token → find/create user → issue JWT pair
  - [x] 5.2 `refresh_tokens(refresh_token, db)` — verify refresh → rotate → issue new pair
  - [x] 5.3 Store refresh token JTI in Redis db2 for single-use enforcement
  - [x] 5.4 `get_or_create_user(firebase_claims, db)` — upsert user by `firebase_uid`
- [x] Task 6: Create `app/api/v1/endpoints/auth.py` — Routes (AC: #3, #4)
  - [x] 6.1 `POST /auth/exchange` endpoint with `TokenExchangeRequestSchema` → `TokenResponseSchema`
  - [x] 6.2 `POST /auth/refresh` endpoint with `TokenRefreshRequestSchema` → `TokenResponseSchema`
  - [x] 6.3 Register auth router in `app/api/v1/router.py`
- [x] Task 7: Add `get_current_user()` dependency (AC: #7, #8)
  - [x] 7.1 Add `OAuth2PasswordBearer` scheme or custom header extraction to `app/core/dependencies.py`
  - [x] 7.2 Implement `get_current_user(token, db) -> UserModel` dependency
  - [x] 7.3 Raise `AuthRequiredError` if no token, `AuthInvalidTokenError` if invalid/expired
- [x] Task 8: Firebase initialization in app lifespan (AC: #1)
  - [x] 8.1 Initialize Firebase Admin SDK in `main.py` lifespan (startup)
  - [x] 8.2 Handle missing credentials gracefully with structured logging
- [x] Task 9: Update config and environment (AC: #5)
  - [x] 9.1 Add `FIREBASE_SERVICE_ACCOUNT_PATH` to Settings
  - [x] 9.2 Update `.env.example` with new Firebase/JWT variables
- [x] Task 10: Write tests (AC: #9)
  - [x] 10.1 `tests/unit/test_security.py` — JWT creation, verification, expiry, invalid tokens
  - [x] 10.2 `tests/unit/test_auth_service.py` — exchange flow, refresh rotation, user creation
  - [x] 10.3 `tests/integration/test_auth_flow.py` — full endpoint tests via TestClient
  - [x] 10.4 Mock Firebase Admin SDK in all tests (never call real Firebase)
  - [x] 10.5 Run `ruff check app tests` — 0 issues
  - [x] 10.6 Run `pytest` — all pass

### Review Findings

- [x] [Review][Patch] Non-atomic check-then-set race condition in refresh token rotation [backend/app/services/auth_service.py:115]
- [x] [Review][Patch] Stale used-refresh tokens tracked in ephemeral Rate Limiting Redis instance (db=2) instead of Persistent Cache (db=1) [backend/app/core/dependencies.py:55]
- [x] [Review][Patch] High Risk of DB Truncation Crashing Auth with Google/OAuth photo_url [backend/app/models/user.py:19]
- [x] [Review][Patch] Backend JWT payload maps user ID to standard claim "sub" instead of custom "user_id" [backend/app/core/security.py:48]
- [x] [Review][Patch] Unsafe dictionary access / Type checking gaps in Firebase claims parsing [backend/app/services/auth_service.py:31]
- [x] [Review][Patch] Incorrect OpenAPI / Swagger OAuth2 Interactive Auth Flow Documentation [backend/app/core/dependencies.py:25]
- [x] [Review][Patch] Firebase Token Verification Omits Revocation Check [backend/app/core/security.py:38]
- [x] [Review][Patch] Missing JWT Settings configuration documentation in .env.example [.env.example:27]
- [x] [Review][Patch] Negative or Zero Token Expiration boundaries in settings can cause issues [backend/app/core/config.py:42]
- [x] [Review][Patch] Silent Failures on Firebase SDK Initialization [backend/app/main.py:41]
- [x] [Review][Defer] Weak Token Theft Response Policy [backend/app/services/auth_service.py:115] — deferred, pre-existing
- [x] [Review][Defer] Hardcoded String subscription Tiers [backend/app/models/user.py:21] — deferred, pre-existing
- [x] [Review][Defer] Premature DB Commits in Low-Level Helpers [backend/app/services/auth_service.py:43] — deferred, pre-existing
- [x] [Review][Defer] No Validation of User Status in get_current_user [backend/app/core/dependencies.py:60] — deferred, pre-existing

## Dev Notes

### Critical Architecture Compliance

**ENDPOINT NAME IS `/auth/exchange` — NOT `/auth/token`!** The architecture and epics specify `POST /api/v1/auth/exchange` for Firebase token exchange. Do NOT use `/auth/token` or `/auth/login`.

**JWT Algorithm**: The current config uses `HS256` with `JWT_SECRET_KEY` (symmetric). The architecture doc mentions RS256 in some sections but the implemented config in [config.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/app/core/config.py) uses `HS256`. **Follow the existing config** — use `HS256` with `JWT_SECRET_KEY` (SecretStr). The access token default expiry is 60 minutes per config, not 15 or 30 minutes.

**Response Envelope**: ALL responses MUST use the existing envelope format from [common.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/app/schemas/common.py):

- Success: `{ "data": { ... }, "meta": { "request_id": "uuid" } }`
- Error: `{ "error": { "code": "...", "message": "...", "details": { ... } }, "meta": { "request_id": "uuid" } }`

Use `success_response(data=..., request_id=request_id_ctx.get("unknown"))` helper.

**Exception Hierarchy**: Auth exceptions ALREADY EXIST in [exceptions.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/app/core/exceptions.py):

- `AuthRequiredError` (401, `AUTH_REQUIRED`) — no token provided
- `AuthInvalidTokenError` (401, `AUTH_INVALID_TOKEN`) — invalid/expired JWT
- `AuthProviderTokenInvalidError` (401, `AUTH_PROVIDER_TOKEN_INVALID`) — Firebase token invalid

**DO NOT** create new exception classes for auth. Reuse these existing ones. They are already handled by the global `VentureIQError` exception handler in [main.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/app/main.py#L76-L86).

### Existing Codebase Patterns — MUST Follow

**App Factory**: [main.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/app/main.py) uses `create_app() -> FastAPI` with lifespan context manager. Firebase SDK init goes in the lifespan `startup` block.

**Config Pattern**: [config.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/app/core/config.py) uses `pydantic-settings BaseSettings` with `SettingsConfigDict`. Existing JWT/Firebase fields:

```python
FIREBASE_PROJECT_ID: str = Field(default="")
JWT_SECRET_KEY: SecretStr = Field(default="")
JWT_ALGORITHM: str = Field(default="HS256")
JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=60)
JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = Field(default=7)
```

Add `FIREBASE_SERVICE_ACCOUNT_PATH: str = Field(default="")` for service account JSON file path.

**SecretStr Access**: ALWAYS call `.get_secret_value()` when passing `SecretStr` fields to external libraries. Example: `settings.JWT_SECRET_KEY.get_secret_value()`.

**Dependencies Pattern**: [dependencies.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/app/core/dependencies.py) provides `get_db()`, `get_redis_*()`. Add `get_current_user()` in the SAME file — it's the architecture-specified location.

**Router Registration**: [router.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/app/api/v1/router.py) aggregates all v1 routers:

```python
from app.api.v1.endpoints.auth import router as auth_router
api_v1_router.include_router(auth_router, prefix="/auth", tags=["auth"])
```

**DB Base Model**: [base.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/app/db/base.py) provides `Base` with `TimestampMixin` (id UUID PK, created_at, updated_at). `UserModel` extends `Base`.

**Test Pattern**: [conftest.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/tests/conftest.py) uses `TestClient(app)` (synchronous), `AsyncMock` for DB sessions, `dependency_overrides` for injection. Follow this exact pattern.

**Logging**: Use Python stdlib `logging.getLogger(__name__)` — NOT structlog/loguru. Request ID via `request_id_ctx.get("unknown")`.

### UserModel Schema

Table name: `users` (plural, snake_case per convention)

```python
class UserModel(Base):
    __tablename__ = "users"

    # id, created_at, updated_at inherited from Base/TimestampMixin
    firebase_uid: Mapped[str] = mapped_column(String(128), unique=True, nullable=False, index=True)
    email: Mapped[str | None] = mapped_column(String(255), nullable=True)
    display_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    photo_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    auth_provider: Mapped[str] = mapped_column(String(20), nullable=False)  # "anonymous" | "google"
    tier: Mapped[str] = mapped_column(String(20), nullable=False, default="free")  # "free" | "pro" | "enterprise"
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
```

Index naming: `ix_users_firebase_uid` (auto-created by `index=True`).

### Refresh Token Rotation (NFR16)

Single-use refresh tokens. On each refresh:

1. Verify refresh JWT, extract `jti`
2. Check Redis db2 key `refresh_token:{jti}` — if exists, token was already used → reject (401)
3. Mark old JTI as used: `SET refresh_token:{jti} "used" EX {refresh_expiry_seconds}`
4. Issue new access + refresh token pair with new JTIs
5. Return new pair to client

Use `get_redis_rate_limit(request)` dependency from [dependencies.py](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/backend/app/core/dependencies.py#L48-L50) for Redis db2 access.

### JWT Claims Structure

**Access Token Claims:**

```json
{
  "sub": "<user_id_uuid_string>",
  "tier": "free|pro|enterprise",
  "auth_method": "anonymous|google",
  "jti": "<unique_token_id>",
  "type": "access",
  "iat": 1234567890,
  "exp": 1234571490
}
```

**Refresh Token Claims:**

```json
{
  "sub": "<user_id_uuid_string>",
  "jti": "<unique_token_id>",
  "type": "refresh",
  "iat": 1234567890,
  "exp": 1235172690
}
```

### Firebase Admin SDK Setup

**Latest Version**: `firebase-admin>=7.4.0` (v7.4.0 released April 2026)

- Requires Python 3.10+ (v7.0.0 dropped Python 3.7/3.8, deprecated 3.9)
- Removed dependency on `google-api-python-client` in v7.0.0

**Initialization Pattern:**

```python
import firebase_admin
from firebase_admin import credentials, auth as firebase_auth

def init_firebase(settings: Settings) -> None:
    """Initialize Firebase Admin SDK."""
    if firebase_admin._apps:
        return  # Already initialized
    if settings.FIREBASE_SERVICE_ACCOUNT_PATH:
        cred = credentials.Certificate(settings.FIREBASE_SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
    elif settings.FIREBASE_PROJECT_ID:
        # Use Application Default Credentials (GCP environment)
        firebase_admin.initialize_app(options={"projectId": settings.FIREBASE_PROJECT_ID})
    else:
        logger.warning("No Firebase credentials configured — auth endpoints will fail")
```

**Token Verification:**

```python
decoded = firebase_auth.verify_id_token(firebase_token)
# Returns: { "uid": "...", "email": "...", "name": "...", "picture": "...", "firebase": { "sign_in_provider": "..." } }
```

### PyJWT Notes

**Latest Version**: `PyJWT[crypto]>=2.12.1` (v2.12.1 released March 2026)

**Critical**: Always explicitly pass `algorithm="HS256"` to both `jwt.encode()` and `jwt.decode()`. PyJWT 2.12.x is stricter about algorithm defaults. Example:

```python
jwt.encode(payload, secret, algorithm="HS256")
jwt.decode(token, secret, algorithms=["HS256"])
```

**RSA key minimum**: If ever switching to RS256, keys must be ≥2048 bits. CVE-2026-32597 added strict `crit` header validation — no impact for standard HS256 usage.

### Anti-Patterns to Avoid

1. **DO NOT** raise `HTTPException` directly — always raise custom `VentureIQError` subclasses
2. **DO NOT** use `print()` — use `logging.getLogger(__name__)`
3. **DO NOT** use raw dicts for API responses — use Pydantic schemas + `success_response()` helper
4. **DO NOT** hardcode secrets — use `Settings` fields with `SecretStr`
5. **DO NOT** create a separate `auth_middleware.py` — auth is a FastAPI `Depends()` via `get_current_user()`
6. **DO NOT** store tokens in PostgreSQL — use Redis db2 for refresh token JTI tracking
7. **DO NOT** use `aioredis` package — use `redis.asyncio` (already installed)
8. **DO NOT** call Firebase in tests — always mock `firebase_admin.auth.verify_id_token`
9. **DO NOT** modify existing exception classes — they are already correct
10. **DO NOT** use `@app.on_event("startup")` — use lifespan context manager

### Project Structure Notes

Files to CREATE (new):

```
backend/app/core/security.py          # JWT + Firebase verification functions
backend/app/models/user.py            # UserModel SQLAlchemy
backend/app/schemas/auth.py           # Token exchange/response Pydantic schemas
backend/app/services/auth_service.py  # Auth business logic
backend/app/api/v1/endpoints/auth.py  # Auth API endpoints
backend/tests/unit/test_security.py   # Security module tests
backend/tests/unit/test_auth_service.py  # Auth service tests
backend/tests/integration/test_auth_flow.py  # Full auth flow tests
backend/migrations/versions/xxxx_add_users_table.py  # Alembic migration
```

Files to MODIFY (existing):

```
backend/app/core/config.py            # Add FIREBASE_SERVICE_ACCOUNT_PATH
backend/app/core/dependencies.py      # Add get_current_user()
backend/app/api/v1/router.py          # Register auth router
backend/app/main.py                   # Firebase SDK init in lifespan
backend/app/models/__init__.py        # Export UserModel
backend/pyproject.toml                # Add firebase-admin, PyJWT deps
backend/.env.example → root .env.example  # Add new env vars
```

Files to NOT touch:

```
backend/app/core/exceptions.py        # Already has auth exceptions
backend/app/core/middleware.py         # No auth middleware needed
backend/app/core/logging.py           # No changes needed
backend/app/schemas/common.py         # Already has envelope utilities
backend/app/db/base.py                # No changes (UserModel imports Base)
backend/app/db/redis.py               # No changes (use existing RedisManager)
```

### Downstream Dependencies

Story 2.2 (Flutter auth) will consume:

- `POST /api/v1/auth/exchange` — sends Firebase ID token, receives backend JWT pair
- `POST /api/v1/auth/refresh` — sends refresh token, receives new JWT pair

Story 2.3 (Account upgrade) will need `POST /api/v1/auth/upgrade` — **NOT part of this story**. Do NOT implement the upgrade endpoint.

Story 2.4 (Rate limiting) will use `get_current_user()` dependency to identify user tier.

### Previous Story Learnings (Epic 1)

1. **SecretStr pitfall**: Always `.get_secret_value()` before passing to libraries (learned in Story 1.4)
2. **Async timeout**: Add explicit timeouts for external calls (learned in Story 1.3)
3. **Settings cache**: Use `get_settings.cache_clear()` in test fixtures (learned in Story 1.3)
4. **Ruff compliance**: Run `ruff check app tests` after every file — target zero issues (line-length=120, py313)
5. **Dependency overrides**: Use `app.dependency_overrides[dep] = mock_dep` pattern in tests (established in conftest.py)
6. **Async wrapping**: If Firebase Admin SDK has blocking calls, wrap in `asyncio.to_thread()` (learned in Story 1.4 with ddgs)

### References

- [Source: _bmad-output/planning-artifacts/epics.md — Epic 2 §2.1, Lines 454-472]
- [Source: _bmad-output/planning-artifacts/architecture.md — §JWT Architecture (L275-276), §Auth Flow (L586-596), §Auth Endpoints (L660), §Schemas (L718)]
- [Source: _bmad-output/planning-artifacts/architecture.md — §File Structure (L697-765), §API Response Envelope (L462-488), §Error Codes (L286)]
- [Source: _bmad-output/planning-artifacts/architecture.md — §Data Modeling (L264), §DB Naming (L343-354)]
- [Source: _bmad-output/planning-artifacts/prd.md — FR36-39, NFR16, NFR17, NFR41]
- [Source: backend/app/core/config.py — Existing JWT/Firebase settings]
- [Source: backend/app/core/exceptions.py — Existing auth exception classes]
- [Source: backend/app/core/dependencies.py — Pattern for get_current_user()]
- [Source: backend/app/main.py — Lifespan pattern for Firebase init]
- [Source: _bmad-output/implementation-artifacts/epic-1-retro-2026-05-20.md — Action items for Epic 2]

## Dev Agent Record

### Agent Model Used

GPT-5.2-Codex

### Implementation Plan

- Add Firebase/JWT security helpers, auth service, and endpoints for exchange/refresh.
- Persist users with a new SQLAlchemy model + migration and wire get_current_user dependency.
- Extend config/env and cover auth flows with unit + integration tests.

### Debug Log References

- `uv sync`
- `uv run ruff check app tests`
- `pytest` (runTests)

### Completion Notes List

- Added Firebase Admin SDK initialization and JWT helpers with access/refresh token creation and verification.
- Implemented auth service and endpoints for exchange/refresh with Redis-backed refresh rotation.
- Added UserModel + migration and JWT-based `get_current_user` dependency.
- Added unit and integration tests for security, service logic, and endpoint envelopes.

### File List

- .env.example
- backend/app/api/v1/endpoints/auth.py
- backend/app/api/v1/router.py
- backend/app/core/config.py
- backend/app/core/dependencies.py
- backend/app/core/security.py
- backend/app/main.py
- backend/app/models/**init**.py
- backend/app/models/user.py
- backend/app/schemas/auth.py
- backend/app/services/auth_service.py
- backend/migrations/versions/b3a5c2e1b9af_add_users_table.py
- backend/pyproject.toml
- backend/tests/integration/test_auth_flow.py
- backend/tests/unit/test_auth_service.py
- backend/tests/unit/test_security.py

### Change Log

- 2026-05-20: Implemented Firebase auth exchange/refresh, user persistence, JWT dependency, and tests.
