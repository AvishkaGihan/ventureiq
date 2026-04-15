---
project_name: 'ventureiq'
user_name: 'Avishka Gihan'
date: '2026-04-15'
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'testing_rules', 'code_quality', 'workflow_rules', 'critical_rules']
status: 'complete'
rule_count: 95
optimized_for_llm: true
existing_patterns_found: 22
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

### Monorepo Structure
- Root: `ventureiq/` — monorepo with `mobile/` (Flutter) and `backend/` (Python FastAPI)
- Package manager: `uv` (Python), `pub` (Flutter)
- Local dev: `docker-compose.yml` at root (backend + Redis 7.x + PostgreSQL + ChromaDB)

### Flutter Client (mobile/)
- **Flutter SDK 3.41.4** stable — single codebase iOS 15+ / Android 10+
- **Riverpod** (latest stable) — `AsyncNotifier` patterns, compile-time safe
- **GoRouter** (latest stable) — deep linking, state-aware navigation guards
- **Dio** (HTTP) + `web_socket_channel` (WebSocket)
- **Hive** — offline report cache (50-report LRU eviction)
- **fl_chart** — radar chart, dimensional bars
- **freezed + json_serializable** — all data classes (code generation via build_runner)
- **flutter_secure_storage** — auth token storage
- **Material Design 3** — heavily custom-themed dark premium theme

### Python Backend (backend/)
- **Python 3.13** — async-first via FastAPI
- **FastAPI 0.135.3** — WebSocket + REST, auto-generated OpenAPI 3.0
- **LangGraph** (latest stable) — multi-agent graph orchestration
- **SQLAlchemy** (async) + **Alembic** — PostgreSQL access + schema migrations
- **Pydantic v2** — request/response schemas + `BaseSettings` config
- **Ruff** — linter + formatter (replaces flake8/black/isort)
- **pytest + pytest-asyncio + httpx** — async-native testing

### Infrastructure
- **PostgreSQL** — primary persistent store (encrypted at rest)
- **Redis 7.x** — db0 (streaming state), db1 (cache), db2 (rate limiting)
- **ChromaDB** — vector storage for Ask the Board (per-user/report partitioned)
- **Firebase Auth** (Google Sign-In + anonymous) + **FCM** (push notifications)
- **Google Gemini 2.5 Flash** — primary LLM (via `langchain-google-genai`)
- **OpenRouter** — fallback LLM provider
- **DuckDuckGo Search** — primary search (zero-cost, rate-limit risk)
- **Google Cloud Run (2nd gen)** — deployment target
- **GitHub Actions** — CI/CD (backend-ci.yml, mobile-ci.yml, deploy.yml)
- **Docker** — multi-stage production builds

## Critical Implementation Rules

### Language-Specific Rules

#### Python (Backend)
- **Always use `async`/`await`** — FastAPI endpoints, SQLAlchemy queries, Redis operations, and LLM provider calls are all async. Never use synchronous blocking calls
- **Pydantic v2 conventions** — Use `model_validator` not `validator`, `model_serializer` not `json()`, `ConfigDict` not inner `Config` class
- **Type hints required everywhere** — function signatures, return types, variable assignments for non-obvious types. Use `TypedDict` for LangGraph state (not dataclasses)
- **`snake_case` for everything** — functions, variables, module names, API path parameters, query parameters. Constants use `UPPER_SNAKE_CASE`
- **Private members use `_` prefix** — not `__` double underscore (reserve dunder for Python magic methods)
- **Never use `print()`** — always use the structured JSON logger from `app/core/logging.py` with `request_id` context
- **String formatting** — use f-strings, never `%` operator or `.format()`
- **Imports** — standard library → third-party → local, each group separated by blank line. Ruff enforces this

#### Dart (Flutter)
- **`camelCase` for everything** — variables, functions, methods, parameters. `PascalCase` for classes/types/enums
- **All data classes use freezed** — never write manual `==`, `hashCode`, `copyWith`, or `toString`. Run `build_runner` after model changes
- **`@JsonKey(name: 'snake_case')` mappings** — Dart models use `camelCase` properties but must map to `snake_case` API fields
- **Riverpod `AsyncNotifier` pattern** — not `StateNotifier` (deprecated pattern). Always wrap async state in `AsyncValue<T>`
- **Widget composition over inheritance** — never extend `StatelessWidget`/`StatefulWidget` to create "base" widgets. Use composition
- **Const constructors** — use `const` on widget constructors wherever possible for rebuild optimization
- **Named parameters** — prefer named parameters over positional for functions with 2+ parameters
- **Null safety** — never use `!` force unwrap without a preceding null check or assertion. Prefer `?.` and `??` operators

### Framework-Specific Rules

#### FastAPI (Backend)
- **Lifespan context manager** — use `@asynccontextmanager` lifespan in `main.py` for startup/shutdown (DB pool, Redis connections). Never use `@app.on_event` (deprecated)
- **Dependency injection via `Depends`** — `get_db()` yields async sessions, `get_current_user()` extracts JWT. Never instantiate sessions or verify auth manually in endpoints
- **One router file per resource** — `endpoints/reports.py`, `endpoints/ideas.py`, etc. Aggregate in `api/v1/router.py`. Never put multiple resources in one file
- **API versioning** — all routes under `/api/v1/` prefix. Breaking changes require `/api/v2/`
- **Response envelope on ALL endpoints** — Success: `{ "data": ..., "meta": { "request_id": "uuid" } }`. List: add `page`, `page_size`, `total` to meta. Error: `{ "error": { "code", "message", "details" }, "meta": { "request_id" } }`
- **Custom exceptions → global handler** — raise `ReportNotFoundError(report_id)` etc. from `core/exceptions.py`. The global error handler converts to structured envelope. Never return raw `HTTPException` with ad-hoc messages
- **WebSocket endpoints in `websockets/` directory** — separate from REST `endpoints/`. Single bidirectional connection per streaming session

#### LangGraph (Agent Orchestration)
- **State is `TypedDict`** — `class AnalysisState(TypedDict)` in `agents/state.py`. Never use Pydantic models or dataclasses for graph state
- **Nodes return partial dicts** — `return {"scout_output": result}`. Never return full state copies
- **Node naming** — `snake_case` verbs: `run_scout`, `cross_reference`, `synthesize`
- **Edge conditions** — named functions returning literal strings: `def should_cross_ref(state) -> str:`
- **Each agent = one file** — `agents/scout.py`, `agents/rival.py`, etc. Graph definition in `agents/graph.py`
- **Agent errors in state, not exceptions** — return `{"scout_error": AgentError(...)}`. Never raise unhandled exceptions from agent nodes
- **Prompts in dedicated files** — `agents/prompts/scout_prompt.py`. Never inline multi-line prompt strings in agent logic

#### Riverpod (Flutter State Management)
- **Provider naming** — `{feature}{Type}Provider`: `warRoomStateProvider`, `authNotifierProvider`
- **Notifier classes** — `{Feature}Notifier extends AsyncNotifier<{Feature}State>`: `WarRoomNotifier`, `AuthNotifier`
- **State classes** — `{Feature}State` with freezed: `WarRoomState`, `AgentState`. Immutable updates via `copyWith`
- **Feature-scoped providers** — each feature owns its providers in `{feature}_providers.dart`. Never create global mutable state
- **Async data always `AsyncValue<T>`** — loading/data/error states. Use `.when(data:, loading:, error:)` pattern in UI
- **Single WebSocket → dispatcher** — `WarRoomNotifier` owns the connection. Dispatches parsed events to per-agent `AgentStateNotifier` providers

#### GoRouter (Flutter Navigation)
- **Route paths** — `/{kebab-case}`: `/idea-input`, `/war-room`, `/executive-summary`
- **Route names** — `PascalCase`: `IdeaInput`, `WarRoom`, `ExecutiveSummary`
- **Navigation guards** — auth-aware redirects in router configuration. Unauthenticated users redirected to login for protected routes
- **Deep linking** — shared report URLs (`/reports/{id}`) must resolve correctly when app is installed

### Testing Rules

#### Python (pytest)
- **File naming** — `test_{module}.py` mirroring `app/` structure in `backend/tests/`
- **Async tests** — use `@pytest.mark.asyncio` and `async def test_...()` for all async code
- **Test client** — use `httpx.AsyncClient` (not `TestClient`) for async FastAPI endpoint testing
- **Fixtures in `conftest.py`** — shared fixtures (test DB session, mock Redis, authenticated client) at `tests/conftest.py`. Feature-specific fixtures in local `conftest.py`
- **Mock LLM/search providers** — never make real API calls in unit tests. Mock at the provider abstraction boundary (`LLMProvider`, `SearchProvider`)
- **Unit vs integration boundary** — `tests/unit/` for isolated logic (scoring, sanitization, schema validation). `tests/integration/` for multi-component flows (auth pipeline, WebSocket streaming, agent pipeline)
- **Agent tests** — test with mocked LLM responses. Verify structured output schema, token budget enforcement, and error state handling

#### Flutter (flutter_test)
- **File naming** — `{module}_test.dart` mirroring `lib/` structure in `mobile/test/`
- **Widget tests** — use `WidgetTester` with `pumpWidget` and `pumpAndSettle`. Test state transitions, user interactions, and accessibility semantics
- **Golden tests** — golden comparison tests for custom visual components (ViabilityScoreDisplay, WarRoomAgentCard, ConfidenceBadge)
- **Mock providers** — override Riverpod providers in tests using `ProviderScope.overrides`. Never test against real API
- **Screen reader verification** — test `Semantics` tree for critical flows (idea submission, report viewing)

#### General
- **Tests alongside implementation** — every story ships with tests. No "add tests later"
- **Test data factories** — create reusable test data builders, not inline fixtures
- **No test interdependence** — each test must be independently runnable. No shared mutable state between tests

### Code Quality & Style Rules

#### Naming Conventions

**Database (PostgreSQL):**
- Tables: `snake_case` **plural** — `reports`, `user_sessions`, `agent_outputs`
- Columns: `snake_case` **singular** — `user_id`, `created_at`, `viability_score`
- Primary keys: always `id` (UUID v4) — never `report_id` in the PK column
- Foreign keys: `{referenced_table_singular}_id` — `report.user_id` → `users.id`
- Indexes: `ix_{table}_{column}` — `ix_reports_user_id`
- Timestamps: always `_at` suffix, UTC, timezone-aware — `created_at`, `completed_at`
- Enums: `PascalCase` Python class — `AgentRole.SCOUT`, `ReportStatus.COMPLETED`

**API (FastAPI):**
- Endpoints: `/api/v1/{resource}` **plural**, `snake_case` — `/api/v1/reports`, `/api/v1/agent_outputs`
- Route params: `{snake_case}` — `/api/v1/reports/{report_id}`
- Query params: `snake_case` — `?page_size=20&sort_by=created_at`
- Non-CRUD actions: `POST /resource/{id}/{action}` — `POST /api/v1/reports/{report_id}/export`
- WebSocket: `ws://host/api/v1/ws/{resource}` — `ws://host/api/v1/ws/analysis/{idea_id}`

**Code Naming:**
- Pydantic schemas: `{Entity}{Action}Schema` — `ReportResponseSchema`, `IdeaCreateRequest`
- SQLAlchemy models: `{Entity}Model` — `ReportModel`, `UserModel`
- LangGraph state: `{Feature}State` (TypedDict) — `AnalysisState`
- Services: `{domain}_service.py` — `analysis_service.py`, `cache_service.py`

#### Project Structure Rules
- **One file per entity/resource/agent** — never combine multiple entities in one file
- **Backend**: `api/v1/endpoints/` (REST) + `api/v1/websockets/` (WS) + `agents/` (LangGraph) + `core/` (infra) + `models/` (ORM) + `schemas/` (Pydantic) + `services/` (logic) + `providers/` (external)
- **Flutter**: feature-first with `data/domain/presentation` triad per feature — no exceptions
- **Never create new top-level directories** without explicit approval
- **Shared widgets** in `core/widgets/`. Feature-specific widgets in `features/{feature}/presentation/widgets/`

#### Data Format Rules
- Dates in API: ISO 8601 strings, UTC, with timezone — `"2026-04-15T12:34:56.789Z"`
- JSON fields (API): `snake_case` — `"viability_score"`, `"created_at"`
- JSON fields (Dart): `camelCase` with `@JsonKey` for mapping — `viabilityScore` ↔ `"viability_score"`
- Booleans: `true`/`false` — never `1`/`0`
- Nulls: explicit `null`, never omit field — `"details": null` not missing key
- IDs: UUID v4 strings — `"550e8400-e29b-41d4-a716-446655440000"`
- Enums in API: `UPPER_SNAKE_CASE` strings — `"SCOUT"`, `"COMPLETED"`, `"HIGH_RISK"`
- Money/scores: integer or decimal, never string — `78`, `92.5`

#### Documentation
- **No `print()` statements** — structured JSON logging only with `request_id`
- **Docstrings** — public functions/classes in both Python (Google style) and Dart (`///` doc comments)
- **Inline comments** — explain "why", not "what". No noise comments

### Development Workflow Rules

#### Git & Repository
- **Branch naming** — `feat/{epic}-{story}-{short-description}`: `feat/e1-s1-monorepo-scaffold`, `fix/e4-ws-reconnection`
- **Commit messages** — conventional commits: `feat(agents): add scout parallel execution`, `fix(auth): handle refresh token rotation edge case`
- **PR scope** — one story per PR. Never bundle multiple stories unless they are trivially coupled
- **CI must pass** — Ruff (Python) + Dart analyzer (Flutter) + all tests before merge. CI pipelines: `backend-ci.yml`, `mobile-ci.yml`

#### Deployment
- **Environment strategy** — 3-tier: local (Docker Compose), staging (Cloud Run), production (Cloud Run)
- **Config management** — Pydantic `BaseSettings` + `.env` (local) + GCP Secret Manager (production). Never hardcode secrets
- **Docker** — multi-stage builds for production (slim Python base). `docker-compose.yml` for local dev environment
- **Database migrations** — Alembic migration created for every schema change. `alembic revision --autogenerate` + manual review before applying. Never modify existing migrations

#### Implementation Sequence
- Follow the 12-step dependency order defined in architecture:
  1. Monorepo + Docker Compose → 2. FastAPI skeleton → 3. PostgreSQL + SQLAlchemy + Alembic → 4. Firebase Auth + JWT → 5. LangGraph agents → 6. WebSocket streaming + Redis → 7. Flutter app shell + theme → 8. War Room UI + WebSocket client → 9. Report persistence + Evidence Panel → 10. Extended features → 11. CI/CD + Cloud Run → 12. Observability

#### Dependency Awareness
- JWT exchange → requires Firebase Auth setup first
- WebSocket streaming → requires Redis + LangGraph pipeline
- War Room UI → requires WebSocket streaming + agent state model
- Offline caching → requires report data model finalized
- Cloud Run deployment → requires Docker + env config

### Critical Don't-Miss Rules

#### Anti-Patterns to Avoid
- **Never expose stack traces to clients** — all errors go through the global error handler. User-facing messages: "what happened + what to do next" (e.g., "Scout encountered an issue. 4 of 5 agents completed.")
- **Never use bare dicts for API responses** — always use Pydantic schemas for all input/output. No `return {"status": "ok"}`
- **Never hardcode colors, sizes, or spacing in Flutter** — always reference design tokens from `app_colors.dart`, `app_spacing.dart`, `app_typography.dart`
- **Never create synchronous database queries** — all SQLAlchemy operations use `async_session` with `await`
- **Never store API keys in the Flutter client** — all LLM/search credentials are backend-only. Client communicates exclusively with the FastAPI backend
- **Never close WebSocket on agent error** — send in-band error event `{"event_type": "error", "payload": {...}}` and continue. Connection stays open
- **Never skip the response envelope** — even health check returns `{ "data": { "status": "ok" }, "meta": { "request_id": "..." } }`

#### Security Rules
- **Prompt injection defense** — defense-in-depth: input sanitization (boundary) + inter-agent schema validation (LangGraph state) + output filtering (client)
- **JWT on every request** — Dio interceptor attaches `Authorization: Bearer` automatically. WebSocket verifies JWT on handshake
- **Token lifecycle** — access token: configurable expiry (default 1hr). Refresh token: 7-day with single-use rotation. On 401: interceptor attempts refresh → retry → redirect to login on failure
- **PII protection** — no PII in ChromaDB vectors or LLM prompts beyond what user explicitly submits. No user data in logs beyond `user_id` and `request_id`
- **Rate limiting** — enforced at middleware level: anonymous 3/month (device fingerprint + IP), free 3/month (user ID), Pro unlimited. Redis db2 sliding window counters

#### WebSocket Contract
- **Event envelope** — ALL messages: `{ "event_type", "timestamp", "payload" }`
- **Server → Client events (10):** `agent_status`, `agent_token`, `agent_citation`, `cross_reference`, `synthesis_progress`, `score_reveal`, `error`, `analysis_complete`, `search_result`, `heartbeat`, `replay_batch`
- **Client → Server controls (3):** `control_resume`, `control_spotlight`, `control_skip`
- **Heartbeat every 15 seconds** — detect stale connections
- **Event buffer in Redis db0** — 5-minute TTL per session for reconnection replay
- **Reconnection** — client sends `last_event_timestamp`, server replays from buffer as `replay_batch`

#### Error Handling by Layer
| Layer | Pattern | Never Do |
|:--|:--|:--|
| FastAPI endpoints | Raise custom exceptions → global handler | Return raw HTTPException |
| Agent pipeline | Return `AgentError` in state | Raise unhandled exceptions |
| WebSocket | In-band error event | Close connection |
| Flutter UI | `AsyncValue.error` → error widget | Show raw exception text |
| Logging | Structured JSON with `request_id` | Use `print()` |

#### Loading State Patterns
- Screen loading → skeleton shimmer (never blank screen)
- War Room streaming → `AgentStatusIndicator` phase progression
- Button actions → `CircularProgressIndicator` replaces button label
- Pull-to-refresh → Material `RefreshIndicator`

#### Accessibility Non-Negotiables
- All custom widgets include `Semantics` wrappers
- War Room streaming text announced in batched chunks (~2 sentences) via live region
- 48dp minimum touch targets on all interactive elements
- Dynamic text scaling support up to 1.5× without layout breakage
- Reduce Motion: `MediaQuery.disableAnimationsOf(context)` replaces all animations with instant state changes

---

## Usage Guidelines

**For AI Agents:**
- Read this file before implementing any code
- Follow ALL rules exactly as documented
- When in doubt, prefer the more restrictive option
- Reference the architecture document for detailed directory structure and data flow diagrams
- Reference the epics document for story-level acceptance criteria

**For Humans:**
- Keep this file lean and focused on agent needs
- Update when technology stack changes
- Review quarterly for outdated rules
- Remove rules that become obvious over time

_Last Updated: 2026-04-15_
