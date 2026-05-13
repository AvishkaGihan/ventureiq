# Story 1.3: Database & Cache Foundation (PostgreSQL, Redis, Alembic)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want PostgreSQL and Redis connections established with migration infrastructure,
So that data persistence and caching are available for all features.

## Acceptance Criteria

1. **Given** the backend core from Story 1.2 **When** database infrastructure is implemented **Then** `app/db/base.py` creates async SQLAlchemy engine and `AsyncSessionLocal` session factory connected to PostgreSQL
2. **And** `app/db/redis.py` implements `RedisManager` with three logical databases: db0 (streaming state), db1 (cache), db2 (rate limiting)
3. **And** Alembic is initialized with `alembic.ini` and `migrations/env.py` configured for async SQLAlchemy
4. **And** A base SQLAlchemy model (`Base`) is defined with standard fields (`id` UUID PK, `created_at`, `updated_at`)
5. **And** `app/core/dependencies.py` provides FastAPI `Depends` functions: `get_db()` yielding async sessions and `get_redis()` yielding Redis connections
6. **And** Docker Compose services (PostgreSQL, Redis) start correctly and the backend connects on startup
7. **And** `alembic revision --autogenerate` produces valid initial migration
8. **And** `alembic upgrade head` applies migrations successfully
9. **And** Integration tests verify database health check and Redis connectivity

## Tasks / Subtasks

- [x] Task 1: SQLAlchemy Async Engine & Session Factory — `app/db/base.py` (AC: #1, #4)
    - [x] 1.1: Create `async_engine` using `create_async_engine` from `sqlalchemy.ext.asyncio` with `DATABASE_URL` from Settings
    - [x] 1.2: Create `AsyncSessionLocal` using `async_sessionmaker` bound to the engine
    - [x] 1.3: Define `Base` using `DeclarativeBase` with mixin providing `id` (UUID PK, server-default `gen_random_uuid()`), `created_at` (UTC timestamp, server-default `now()`), `updated_at` (UTC timestamp, server-default `now()`, onupdate `now()`)
    - [x] 1.4: Write unit tests verifying Base model has expected columns and types

- [x] Task 2: RedisManager — `app/db/redis.py` (AC: #2)
    - [x] 2.1: Create `RedisManager` class that initializes three `redis.asyncio.Redis` connections: db0, db1, db2
    - [x] 2.2: Expose `streaming` (db0), `cache` (db1), `rate_limit` (db2) as typed properties
    - [x] 2.3: Implement `connect()` and `close()` async lifecycle methods
    - [x] 2.4: Implement `health_check()` that pings all three connections
    - [x] 2.5: Write unit tests with mocked Redis connections verifying property access and lifecycle

- [x] Task 3: FastAPI Dependencies — `app/core/dependencies.py` (AC: #5)
    - [x] 3.1: Create `get_db()` async generator that yields `AsyncSession` from `AsyncSessionLocal` and closes on cleanup
    - [x] 3.2: Create `get_redis(db: int = 1)` that returns the appropriate `RedisManager` connection
    - [x] 3.3: Write unit tests verifying session yield/cleanup and Redis connection routing

- [x] Task 4: Alembic Initialization (AC: #3, #7, #8)
    - [x] 4.1: Run `alembic init -t async migrations` inside `backend/` to scaffold async migration template
    - [x] 4.2: Configure `alembic.ini` — set `sqlalchemy.url` placeholder (overridden in `env.py`)
    - [x] 4.3: Configure `migrations/env.py` — import `Base.metadata`, use `create_async_engine`, configure `target_metadata`
    - [x] 4.4: Verify `alembic revision --autogenerate -m "initial"` produces a valid migration (empty since no models yet)
    - [x] 4.5: Verify `alembic upgrade head` applies without error

- [x] Task 5: Lifespan Integration — `app/main.py` modifications (AC: #6)
    - [x] 5.1: Import and initialize `async_engine` and `RedisManager` in lifespan startup
    - [x] 5.2: Dispose engine and close Redis connections in lifespan shutdown
    - [x] 5.3: Store `RedisManager` instance in `app.state` for dependency access
    - [x] 5.4: Update health endpoint to include database and Redis connectivity checks
    - [x] 5.5: Write integration tests verifying startup/shutdown lifecycle and health check responses

- [x] Task 6: Add Dependencies to `pyproject.toml`
    - [x] 6.1: Add `sqlalchemy[asyncio]>=2.0.49` to project dependencies
    - [x] 6.2: Add `asyncpg>=0.30.0` to project dependencies (PostgreSQL async driver)
    - [x] 6.3: Add `alembic>=1.18.4` to project dependencies
    - [x] 6.4: Add `redis>=7.4.0` to project dependencies
    - [x] 6.5: Run `uv sync` to lock dependencies

- [x] Task 7: Ensure All Tests Pass
    - [x] 7.1: All unit tests run without requiring live DB or Redis (mock where needed)
    - [x] 7.2: `ruff check` passes cleanly
    - [x] 7.3: All existing Story 1.2 tests still pass (no regressions)

## Dev Notes

### Architecture Compliance

This story builds the **data infrastructure layer** — PostgreSQL via async SQLAlchemy, Redis via redis-py async, and Alembic migrations. Every subsequent backend story that touches persistence, caching, or rate limiting depends on these foundations.

**Files to create/modify:**

| File                                | Action | Purpose                                                    |
| :---------------------------------- | :----- | :--------------------------------------------------------- |
| `app/db/base.py`                    | CREATE | Async SQLAlchemy engine, session factory, declarative Base |
| `app/db/redis.py`                   | CREATE | RedisManager with db0/db1/db2 logical databases            |
| `app/core/dependencies.py`          | CREATE | FastAPI `Depends` for `get_db()` and `get_redis()`         |
| `app/main.py`                       | MODIFY | Lifespan startup/shutdown for engine + Redis               |
| `app/api/v1/endpoints/health.py`    | MODIFY | Add DB/Redis health checks                                 |
| `backend/alembic.ini`               | CREATE | Alembic configuration                                      |
| `backend/migrations/env.py`         | CREATE | Alembic async env configuration                            |
| `backend/migrations/script.py.mako` | CREATE | Alembic migration template                                 |
| `backend/migrations/versions/`      | CREATE | Migration versions directory                               |
| `backend/pyproject.toml`            | MODIFY | Add sqlalchemy, asyncpg, alembic, redis deps               |
| `tests/unit/test_db_base.py`        | CREATE | SQLAlchemy Base model tests                                |
| `tests/unit/test_redis_manager.py`  | CREATE | RedisManager tests                                         |
| `tests/unit/test_dependencies.py`   | CREATE | Dependencies tests                                         |
| `tests/unit/test_health.py`         | MODIFY | Update for new health check fields                         |

[Source: architecture.md#Structure Patterns, architecture.md#Project Structure]

### Technical Requirements

**SQLAlchemy Async Engine (`app/db/base.py`):**

Use `sqlalchemy.ext.asyncio` for all async database access. The engine must use the `DATABASE_URL` from `Settings` (already defined with default `postgresql+asyncpg://ventureiq:ventureiq@localhost:5432/ventureiq`).

```python
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy import text
import uuid
from datetime import datetime, timezone

from app.core.config import get_settings

settings = get_settings()
async_engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.APP_DEBUG,
    pool_pre_ping=True,
)

AsyncSessionLocal = async_sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
)
```

**CRITICAL:** Use `async_sessionmaker` (NOT the deprecated `sessionmaker` with `class_=AsyncSession`). SQLAlchemy 2.0+ uses `async_sessionmaker` directly.

[Source: architecture.md#ORM/Database, architecture.md#Core Architectural Decisions]

**Declarative Base with Standard Fields:**

Architecture specifies all models share `id` (UUID PK), `created_at`, `updated_at`. Define this as a mixin on the `Base` class.

```python
class Base(DeclarativeBase):
    """Base class for all SQLAlchemy models."""
    pass

class TimestampMixin:
    """Mixin providing standard timestamp fields."""
    id: Mapped[uuid.UUID] = mapped_column(
        primary_key=True,
        default=uuid.uuid4,
        server_default=text("gen_random_uuid()"),
    )
    created_at: Mapped[datetime] = mapped_column(
        default=lambda: datetime.now(timezone.utc),
        server_default=text("now()"),
    )
    updated_at: Mapped[datetime] = mapped_column(
        default=lambda: datetime.now(timezone.utc),
        server_default=text("now()"),
        onupdate=lambda: datetime.now(timezone.utc),
    )
```

**Database naming conventions:** Tables are `snake_case`, **plural**. Columns are `snake_case`, **singular**. Primary key is always `id`. Foreign keys follow `{referenced_table_singular}_id` pattern. Indexes: `ix_{table}_{column(s)}`. Timestamps always `_at` suffix, UTC, timezone-aware.

[Source: architecture.md#Naming Patterns — Database Naming Conventions]

**SQLAlchemy model naming:** All model classes follow `{Entity}Model` pattern (e.g., `UserModel`, `ReportModel`). This is NOT needed in this story yet (no entity models created), but the Base pattern must support it.

[Source: architecture.md#Code Naming Conventions]

**RedisManager (`app/db/redis.py`):**

Architecture mandates three logical databases for isolation:
- **db0**: Streaming state (WebSocket event buffer, 5-minute TTL)
- **db1**: Cache (search results 24h TTL, agent outputs 7-day TTL)
- **db2**: Rate limiting (sliding window, 30-day TTL)

```python
import redis.asyncio as aioredis
from app.core.config import get_settings

class RedisManager:
    """Manages Redis connections across logical databases."""
    
    def __init__(self, redis_url: str):
        self._url = redis_url
        self._streaming: aioredis.Redis | None = None  # db0
        self._cache: aioredis.Redis | None = None      # db1
        self._rate_limit: aioredis.Redis | None = None  # db2

    async def connect(self) -> None:
        self._streaming = aioredis.from_url(f"{self._url}/0", decode_responses=True)
        self._cache = aioredis.from_url(f"{self._url}/1", decode_responses=True)
        self._rate_limit = aioredis.from_url(f"{self._url}/2", decode_responses=True)

    async def close(self) -> None:
        for conn in (self._streaming, self._cache, self._rate_limit):
            if conn:
                await conn.aclose()

    @property
    def streaming(self) -> aioredis.Redis:
        assert self._streaming is not None, "RedisManager.connect() not called"
        return self._streaming

    @property
    def cache(self) -> aioredis.Redis:
        assert self._cache is not None, "RedisManager.connect() not called"
        return self._cache

    @property
    def rate_limit(self) -> aioredis.Redis:
        assert self._rate_limit is not None, "RedisManager.connect() not called"
        return self._rate_limit

    async def health_check(self) -> dict[str, bool]:
        results = {}
        for name, conn in [("streaming", self._streaming), ("cache", self._cache), ("rate_limit", self._rate_limit)]:
            try:
                results[name] = bool(conn and await conn.ping())
            except Exception:
                results[name] = False
        return results
```

**CRITICAL:** Use `redis.asyncio` (import as `aioredis`). The `redis` package (>=5.x) includes native async support — do NOT install a separate `aioredis` package. Use `aclose()` (not `close()`) for proper async cleanup. Use `from_url()` to parse connection strings.

[Source: architecture.md#Redis architecture, architecture.md#Data Architecture]

**FastAPI Dependencies (`app/core/dependencies.py`):**

```python
from collections.abc import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import AsyncSessionLocal

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Yield an async database session."""
    async with AsyncSessionLocal() as session:
        yield session
```

For Redis, the `RedisManager` instance is stored in `app.state` during lifespan startup. The dependency retrieves it from the request's app state:

```python
from fastapi import Request
import redis.asyncio as aioredis

def get_redis_manager(request: Request) -> "RedisManager":
    return request.app.state.redis_manager

def get_redis_streaming(request: Request) -> aioredis.Redis:
    return request.app.state.redis_manager.streaming

def get_redis_cache(request: Request) -> aioredis.Redis:
    return request.app.state.redis_manager.cache

def get_redis_rate_limit(request: Request) -> aioredis.Redis:
    return request.app.state.redis_manager.rate_limit
```

[Source: architecture.md#Structure Patterns — `core/dependencies.py`]

**Alembic Async Configuration:**

Initialize with `alembic init -t async migrations` to get the async template. Then:

1. **`alembic.ini`** — Set `script_location = migrations`. The `sqlalchemy.url` in `alembic.ini` is a placeholder; the actual URL is loaded from Settings in `env.py`.

2. **`migrations/env.py`** — Must:
   - Import `Base.metadata` from `app.db.base`
   - Import `Settings` to get `DATABASE_URL`
   - Use `create_async_engine` for the migration engine
   - Set `target_metadata = Base.metadata`
   - Use `run_async_migrations()` pattern from the async template

**CRITICAL:** The `alembic.ini` file goes in `backend/` (NOT `backend/app/`). The `migrations/` directory goes in `backend/` (NOT `backend/app/`). Alembic commands run from `backend/` working directory.

[Source: architecture.md#Project Structure — `backend/alembic.ini`, `backend/migrations/`]

**Lifespan Integration (`app/main.py`):**

Extend the existing lifespan to:
1. **Startup**: Create engine (already implicit from import), connect RedisManager, store in `app.state`
2. **Shutdown**: Close RedisManager, dispose async engine

```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    # ... existing settings loading and logging ...
    
    # Database engine is created at module level in db/base.py
    # Redis connection
    from app.db.redis import RedisManager
    from app.db.base import async_engine
    
    redis_manager = RedisManager(settings.REDIS_URL)
    await redis_manager.connect()
    app.state.redis_manager = redis_manager
    
    yield
    
    # Shutdown
    await redis_manager.close()
    await async_engine.dispose()
```

**Health Endpoint Enhancement:**

Update `GET /api/v1/health` to include DB and Redis status. The health endpoint should attempt a simple query and Redis ping:

```python
# In health endpoint
async def check_db_health(session: AsyncSession) -> bool:
    result = await session.execute(text("SELECT 1"))
    return result.scalar() == 1

# Health response includes:
{
    "data": {
        "status": "healthy",
        "version": "0.1.0",
        "services": {
            "database": true,
            "redis": { "streaming": true, "cache": true, "rate_limit": true }
        }
    },
    "meta": { "request_id": "..." }
}
```

**IMPORTANT:** The health endpoint should NOT require authentication. It should degrade gracefully — if DB is unreachable, report `"database": false` but still return 200 (service is running, dependency is down). Use a separate `/ready` endpoint later if needed for Kubernetes-style readiness checks.

### Previous Story Intelligence (Story 1.2)

**Patterns established to follow:**
- App factory pattern: `create_app() -> FastAPI` in `app/main.py` — extend lifespan, don't restructure
- Lifespan uses `try/except ValidationError` for settings — keep this pattern
- `app.state.settings` already stored — add `app.state.redis_manager` similarly
- `request_id_ctx` context var for logging — reuse in any new logging
- Test client fixture in `tests/conftest.py` using `TestClient(app)` — extend with DB/Redis fixtures
- `ruff check` enforces `I001` (import sorting), `UP046` (type params) — keep code compliant
- Docstrings on all modules, classes, and functions
- Type hints on all function signatures

**Code patterns from Story 1.2:**
- Response envelope: `success_response(data, request_id)` and `error_response(...)` — reuse for health endpoint updates
- `get_settings()` uses `@lru_cache` singleton — access it for `DATABASE_URL` and `REDIS_URL`
- Ruff config: `line-length=120`, `target-version="py313"`, selected rules: `["E", "F", "I", "UP", "B", "SIM"]`

**Review feedback from Story 1.2 (deferred items potentially relevant):**
- SecretStr downstream access — when using `DATABASE_URL` (a plain `str` field), no issue. If later adding secrets, use `.get_secret_value()`
- Settings cache collision in concurrent tests — when writing tests that modify settings, clear `get_settings.cache_clear()` in fixtures

**Files from Story 1.2 to MODIFY carefully:**
- `app/main.py` (95 lines) — extend lifespan with DB + Redis lifecycle
- `app/api/v1/endpoints/health.py` — add DB/Redis health checks
- `tests/conftest.py` — add mock DB session and Redis fixtures
- `tests/unit/test_health.py` — update for new health response shape

### Dependencies

**New dependencies to add:**
- `sqlalchemy[asyncio]>=2.0.49` — Async SQLAlchemy ORM (latest stable: 2.0.49)
- `asyncpg>=0.30.0` — PostgreSQL async driver for SQLAlchemy
- `alembic>=1.18.4` — Database migration framework (latest stable: 1.18.4)
- `redis>=7.4.0` — Redis client with native async support (latest stable: 7.4.0)

**Already available:**
- `fastapi[standard]>=0.136.1` — web framework
- `pydantic-settings>=2.14.0` — config (provides `DATABASE_URL`, `REDIS_URL`)
- `uvicorn[standard]>=0.46.0` — ASGI server
- `pytest>=9.0.3` — testing
- `httpx>=0.28.1` — test client
- `ruff>=0.15.12` — linting

**Dev dependencies to consider adding:**
- `pytest-asyncio` — for async test functions (if integration tests need live DB)

**DO NOT add:**
- ❌ `aioredis` — deprecated; `redis>=5.0` includes native async support in `redis.asyncio`
- ❌ `databases` — we use SQLAlchemy directly
- ❌ `tortoise-orm` — we use SQLAlchemy
- ❌ `motor` — MongoDB driver, not relevant

### Testing Requirements

**Test framework:** `pytest` (already in dev deps)
**Test client:** `httpx` via `TestClient` (already in dev deps)
**Async testing:** May need `pytest-asyncio` for unit-testing async functions directly. If possible, keep tests synchronous using `TestClient` for endpoint tests.

**Required test files:**

| Test File                          | Tests                                                                                                            |
| :--------------------------------- | :--------------------------------------------------------------------------------------------------------------- |
| `tests/unit/test_db_base.py`       | Base model has `id`, `created_at`, `updated_at` columns; engine creation with settings                           |
| `tests/unit/test_redis_manager.py` | RedisManager creates 3 connections; properties return correct db; health_check behavior; connect/close lifecycle |
| `tests/unit/test_dependencies.py`  | `get_db()` yields session and closes; Redis dependency retrieves from app state                                  |
| `tests/unit/test_health.py`        | UPDATE — health response includes `services` with `database` and `redis` status                                  |

**CRITICAL testing pattern:** Unit tests must NOT require a live PostgreSQL or Redis instance. Use mocks/patches for database engine and Redis connections. The TestClient from httpx can test endpoints without a real DB if the dependencies are overridden.

**Test patterns from Story 1.2:**
```python
def test_example(client):
    """Descriptive docstring."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
```

For mocking DB sessions in tests:
```python
from unittest.mock import AsyncMock, MagicMock, patch

# Override get_db dependency in tests
async def mock_get_db():
    session = AsyncMock(spec=AsyncSession)
    yield session
```

[Source: architecture.md#Test Organization]

### Anti-Patterns to AVOID

- ❌ Do NOT use synchronous SQLAlchemy engine (`create_engine`) — must use `create_async_engine`
- ❌ Do NOT use `sessionmaker` with `class_=AsyncSession` — use `async_sessionmaker` directly (SQLAlchemy 2.0+ pattern)
- ❌ Do NOT install `aioredis` package — the `redis` package includes `redis.asyncio` natively
- ❌ Do NOT use `redis.close()` — use `redis.aclose()` for async cleanup
- ❌ Do NOT hardcode database URLs — always read from `Settings`
- ❌ Do NOT put `alembic.ini` inside `app/` — it goes in `backend/` root
- ❌ Do NOT put `migrations/` inside `app/` — it goes in `backend/` root
- ❌ Do NOT create entity models (User, Report, Idea, etc.) — those are future stories
- ❌ Do NOT implement `app/core/security.py` — that's Story 2.1
- ❌ Do NOT implement `get_current_user()` dependency — that's Story 2.1
- ❌ Do NOT implement ChromaDB connections — that's a later story
- ❌ Do NOT add rate limiting middleware — that's Story 2.4
- ❌ Do NOT use `print()` — use structured logger
- ❌ Do NOT expose raw database errors to API responses — use the error envelope

### Scope Boundaries

**IN SCOPE:**
- `app/db/base.py` — Async engine, session factory, declarative Base with TimestampMixin
- `app/db/redis.py` — RedisManager with db0/db1/db2
- `app/core/dependencies.py` — `get_db()` and `get_redis_*()` FastAPI dependencies
- `backend/alembic.ini` — Alembic configuration
- `backend/migrations/env.py` — Async Alembic env
- `app/main.py` — Lifespan startup/shutdown for DB + Redis
- Health endpoint update for DB/Redis connectivity
- Unit tests for all new code
- New dependencies in `pyproject.toml`

**OUT OF SCOPE:**
- **NO** entity models (User, Report, Idea, etc.) — those come in Epic 2-3 stories
- **NO** `app/core/security.py` — Story 2.1
- **NO** `get_current_user()` — Story 2.1
- **NO** `app/db/chromadb.py` — later story
- **NO** rate limiting middleware — Story 2.4
- **NO** cache service (`app/services/cache_service.py`) — later story
- **NO** streaming service — Story 4.2
- **NO** actual data migration content — just the Alembic scaffold

### Project Structure Notes

- `app/db/` directory already exists with `__init__.py` — add `base.py` and `redis.py`
- `app/core/` directory exists — add `dependencies.py`
- `tests/unit/` directory exists — add new test files
- `backend/migrations/` will be created by `alembic init`
- `backend/alembic.ini` will be created by `alembic init`
- Follow naming: `snake_case.py` for files, `PascalCase` for classes, `snake_case` for functions

### References

- [Source: architecture.md#ORM/Database] — SQLAlchemy (async) + Alembic
- [Source: architecture.md#Data Architecture] — Redis logical databases (db0/db1/db2), data modeling approach
- [Source: architecture.md#Naming Patterns] — Database naming conventions, code naming conventions
- [Source: architecture.md#Structure Patterns] — `db/base.py`, `db/redis.py`, `core/dependencies.py`
- [Source: architecture.md#Project Structure] — `backend/alembic.ini`, `backend/migrations/`
- [Source: architecture.md#Architectural Boundaries] — Backend ↔ PostgreSQL (`AsyncSession`), Backend ↔ Redis (`RedisManager`)
- [Source: architecture.md#Retry & Resilience Patterns] — Database operations: retry on connection error only, 2 retries, 500ms fixed
- [Source: architecture.md#Enforcement Guidelines] — Rules 1, 2, 6, 8, 9
- [Source: epics.md#Story 1.3] — Acceptance criteria
- [Source: epics.md#Epic 1 Overview] — Walking Skeleton objectives

## Dev Agent Record

### Agent Model Used

GPT-5.2-Codex

### Debug Log References

- `uv sync`
- `python -m pytest`
- `python -m ruff check .`
- `python -m alembic revision --autogenerate -m "initial"`
- `python -m alembic upgrade head`

### Completion Notes List

- Added async SQLAlchemy base, engine, and session factory with timestamp mixin and tests.
- Implemented RedisManager, FastAPI dependencies, and health checks with DB/Redis service status.
- Configured Alembic async environment and generated initial migration; upgrade applied.
- Updated fixtures, added unit tests, synced dependencies, and validated with pytest + ruff.

### File List

- _bmad-output/implementation-artifacts/1-3-database-cache-foundation-postgresql-redis-alembic.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- backend/alembic.ini
- backend/app/api/v1/endpoints/health.py
- backend/app/core/dependencies.py
- backend/app/db/base.py
- backend/app/db/redis.py
- backend/app/main.py
- backend/migrations/env.py
- backend/migrations/script.py.mako
- backend/migrations/versions/4541671124ae_initial.py
- backend/pyproject.toml
- backend/tests/conftest.py
- backend/tests/unit/test_db_base.py
- backend/tests/unit/test_dependencies.py
- backend/tests/unit/test_health.py
- backend/tests/unit/test_redis_manager.py
- backend/uv.lock

### Change Log

- 2026-05-13: Added async SQLAlchemy + Redis foundation, Alembic async migrations, health checks, tests, and dependency updates.

### Review Findings
- [x] [Review][Patch] Missing error handling on Redis connection startup [`backend/app/main.py`]
- [x] [Review][Patch] Incomplete error handling in DB health check [`backend/app/api/v1/endpoints/health.py`]
- [x] [Review][Patch] Infinite hang potential on database health check [`backend/app/api/v1/endpoints/health.py`]
- [x] [Review][Patch] Polluting global app state with test mocks [`backend/tests/conftest.py`]
- [x] [Review][Patch] Global monkey-patching in base fixtures [`backend/tests/conftest.py`]
- [x] [Review][Patch] Test environment leakage into production lifespan code [`backend/app/main.py`]
- [x] [Review][Patch] Incomplete mock implementation for Redis [`backend/tests/conftest.py`]
- [x] [Review][Patch] Interrupted application shutdown on close failure [`backend/app/main.py`]
- [x] [Review][Patch] Asymmetric connection handling during test shutdowns [`backend/app/main.py`]
