# Story 1.4: Provider Abstraction Layer (LLM & Search)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want provider-agnostic interfaces for LLM and search integrations,
So that agents can be built against stable abstractions and providers can be swapped without code changes.

## Acceptance Criteria

1. **Given** the backend core from Story 1.2 **When** provider abstractions are implemented **Then** `app/providers/llm/base.py` defines `LLMProvider` ABC with methods: `generate(prompt, config) -> str`, `stream(prompt, config) -> AsyncIterator[str]`, and `get_model_info() -> ModelInfo`
2. **And** `app/providers/llm/gemini.py` implements `GeminiProvider` using Google Gemini 2.5 Flash via `langchain-google-genai`
3. **And** `app/providers/llm/openrouter.py` implements `OpenRouterProvider` as fallback
4. **And** `app/providers/search/base.py` defines `SearchProvider` ABC with method: `search(query, num_results) -> list[SearchResult]`
5. **And** `app/providers/search/duckduckgo.py` implements `DuckDuckGoProvider`
6. **And** Provider selection is configured via Pydantic settings (primary + fallback)
7. **And** LLM provider includes automatic failover: on persistent error or elevated latency from primary, transparently switches to fallback (NFR26)
8. **And** Search provider includes retry with exponential backoff on rate limiting (NFR27)
9. **And** Unit tests verify provider interfaces and mock-based provider swap tests confirm no agent code changes needed (NFR39, NFR40)

## Tasks / Subtasks

- [x] Task 1: LLM Provider ABC — `app/providers/llm/base.py` (AC: #1)
  - [x] 1.1: Define `ModelInfo` Pydantic model with fields: `name`, `provider`, `max_tokens`, `supports_streaming`
  - [x] 1.2: Define `LLMConfig` Pydantic model with fields: `temperature`, `max_output_tokens`, `top_p`, `stop_sequences`
  - [x] 1.3: Define `LLMProvider` ABC with methods: `generate()`, `stream()`, `get_model_info()`
  - [x] 1.4: Write unit tests verifying ABC cannot be instantiated and enforces method signatures

- [x] Task 2: Gemini Provider — `app/providers/llm/gemini.py` (AC: #2)
  - [x] 2.1: Implement `GeminiProvider(LLMProvider)` using `ChatGoogleGenerativeAI` from `langchain-google-genai`
  - [x] 2.2: `generate()` calls `llm.ainvoke()` and returns `str`
  - [x] 2.3: `stream()` calls `llm.astream()` and yields token strings via `AsyncIterator[str]`
  - [x] 2.4: `get_model_info()` returns `ModelInfo` with Gemini 2.5 Flash details
  - [x] 2.5: API key read from `Settings.GEMINI_API_KEY` (SecretStr — use `.get_secret_value()`)
  - [x] 2.6: Write unit tests with mocked `ChatGoogleGenerativeAI`

- [x] Task 3: OpenRouter Provider — `app/providers/llm/openrouter.py` (AC: #3)
  - [x] 3.1: Implement `OpenRouterProvider(LLMProvider)` using `ChatOpenRouter` from `langchain-openrouter`
  - [x] 3.2: `generate()` and `stream()` methods following same contract as GeminiProvider
  - [x] 3.3: API key read from `Settings.OPENROUTER_API_KEY` (SecretStr — use `.get_secret_value()`)
  - [x] 3.4: Default model: a capable fallback model (e.g., `google/gemini-2.5-flash`)
  - [x] 3.5: Write unit tests with mocked `ChatOpenRouter`

- [x] Task 4: Search Provider ABC — `app/providers/search/base.py` (AC: #4)
  - [x] 4.1: Define `SearchResult` Pydantic model with fields: `title`, `url`, `snippet`
  - [x] 4.2: Define `SearchProvider` ABC with method: `search(query, num_results) -> list[SearchResult]`
  - [x] 4.3: Write unit tests verifying ABC enforcement

- [x] Task 5: DuckDuckGo Provider — `app/providers/search/duckduckgo.py` (AC: #5)
  - [x] 5.1: Implement `DuckDuckGoProvider(SearchProvider)` using `DDGS` from the `ddgs` package
  - [x] 5.2: `search()` calls `DDGS().text()` with `max_results` parameter
  - [x] 5.3: Map DuckDuckGo results to `SearchResult` Pydantic model
  - [x] 5.4: Write unit tests with mocked `DDGS`

- [x] Task 6: Provider Settings — `app/core/config.py` (AC: #6)
  - [x] 6.1: Add `LLM_PRIMARY_PROVIDER` (default: `"gemini"`) and `LLM_FALLBACK_PROVIDER` (default: `"openrouter"`) to `Settings`
  - [x] 6.2: Add `SEARCH_PRIMARY_PROVIDER` (default: `"duckduckgo"`) to `Settings`
  - [x] 6.3: Add `OPENROUTER_MODEL` (default: `"google/gemini-2.5-flash"`) to `Settings`
  - [x] 6.4: Write tests for new settings fields

- [x] Task 7: LLM Failover Manager — `app/providers/llm/failover.py` (AC: #7)
  - [x] 7.1: Create `LLMFailoverManager` that wraps primary + fallback `LLMProvider`
  - [x] 7.2: `generate()` tries primary; on persistent error (2 retries, 2s fixed backoff), transparently switches to fallback
  - [x] 7.3: `stream()` follows same failover logic
  - [x] 7.4: Log failover events via structured logger with `request_id`
  - [x] 7.5: Write unit tests verifying failover triggers and transparent switching

- [x] Task 8: Search Retry Logic — `app/providers/search/duckduckgo.py` (AC: #8)
  - [x] 8.1: Add exponential backoff retry on rate limiting (1s fixed, 2 retries) inside `DuckDuckGoProvider.search()`
  - [x] 8.2: On exhausted retries, raise `ProviderRateLimitedError`
  - [x] 8.3: Write unit tests verifying retry behavior and error propagation

- [x] Task 9: Provider Factory — `app/providers/factory.py` (AC: #6, #7)
  - [x] 9.1: Create `get_llm_provider()` factory that reads settings and returns `LLMFailoverManager`
  - [x] 9.2: Create `get_search_provider()` factory that reads settings and returns `SearchProvider`
  - [x] 9.3: Write unit tests for factory construction

- [x] Task 10: Dependencies Update — `pyproject.toml` (AC: all)
  - [x] 10.1: Add `langchain-google-genai>=4.2.0` to project dependencies
  - [x] 10.2: Add `langchain-openrouter>=0.3.0` to project dependencies
  - [x] 10.3: Add `ddgs>=8.0.0` to project dependencies
  - [x] 10.4: Run `uv sync` to lock dependencies

- [x] Task 11: Provider Swap Tests (AC: #9)
  - [x] 11.1: Write mock-based test proving an agent-like consumer can use `LLMProvider` interface with GeminiProvider, then swap to OpenRouterProvider with zero code changes (NFR39)
  - [x] 11.2: Write mock-based test proving SearchProvider interface is provider-agnostic (NFR40)
  - [x] 11.3: Ensure all existing Story 1.2/1.3 tests pass — no regressions
  - [x] 11.4: `ruff check` passes cleanly

### Review Findings

- [x] [Review][Patch] Fix typo in `get_search_provider` (undefined `provider_name` and mislabeled "LLM provider") [backend/app/providers/factory.py:18]
- [x] [Review][Patch] Implement missing `stream` and `get_model_info` in `LLMFailoverManager` [backend/app/providers/llm/failover.py]
- [x] [Review][Patch] Fix stream corruption risk in `LLMFailoverManager.stream` (do not restart stream if chunks were already yielded) [backend/app/providers/llm/failover.py:80]
- [x] [Review][Patch] Fix DuckDuckGo search iteration escaping error mapping (use `list()` conversion inside `to_thread`) [backend/app/providers/search/duckduckgo.py:27]
- [x] [Review][Dismissed] Correct hallucinated model version `google/gemini-2.5-flash` (User confirms 2.5 is intentional)
- [x] [Review][Patch] Update `DuckDuckGoProvider` retry logic to include general exceptions in retry loop [backend/app/providers/search/duckduckgo.py:25]
- [x] [Review][Patch] Add missing imports (`AsyncIterator`, `LLMConfig`, `ModelInfo`, `asyncio`, `ProviderUnavailableError`, `ProviderRateLimitedError`) [Multiple files]
- [x] [Review][Patch] Validate API keys are not empty strings during provider initialization [backend/app/providers/factory.py]
- [x] [Review][Patch] Guard against negative retry counts in `LLMFailoverManager` [backend/app/providers/llm/failover.py]


This story creates the **provider abstraction layer** — the interface that all downstream agent code (Epic 4+) will program against. The abstractions must be stable and complete because every agent, the plausibility check service, and the scoring service all depend on these interfaces.

**Files to create/modify:**

| File                                      | Action | Purpose                                                          |
| :---------------------------------------- | :----- | :--------------------------------------------------------------- |
| `app/providers/llm/base.py`               | CREATE | `LLMProvider` ABC, `ModelInfo`, `LLMConfig` Pydantic models      |
| `app/providers/llm/gemini.py`             | CREATE | `GeminiProvider` — Gemini 2.5 Flash via `langchain-google-genai` |
| `app/providers/llm/openrouter.py`         | CREATE | `OpenRouterProvider` — fallback via `langchain-openrouter`       |
| `app/providers/llm/failover.py`           | CREATE | `LLMFailoverManager` — automatic primary→fallback failover       |
| `app/providers/search/base.py`            | CREATE | `SearchProvider` ABC, `SearchResult` Pydantic model              |
| `app/providers/search/duckduckgo.py`      | CREATE | `DuckDuckGoProvider` — DuckDuckGo search via `ddgs`              |
| `app/providers/factory.py`                | CREATE | `get_llm_provider()`, `get_search_provider()` factories          |
| `app/core/config.py`                      | MODIFY | Add provider selection settings                                  |
| `backend/pyproject.toml`                  | MODIFY | Add langchain-google-genai, langchain-openrouter, ddgs deps      |
| `tests/unit/test_llm_provider_base.py`    | CREATE | LLM ABC tests                                                    |
| `tests/unit/test_gemini_provider.py`      | CREATE | Gemini provider tests                                            |
| `tests/unit/test_openrouter_provider.py`  | CREATE | OpenRouter provider tests                                        |
| `tests/unit/test_llm_failover.py`         | CREATE | Failover manager tests                                           |
| `tests/unit/test_search_provider_base.py` | CREATE | Search ABC tests                                                 |
| `tests/unit/test_duckduckgo_provider.py`  | CREATE | DuckDuckGo provider tests                                        |
| `tests/unit/test_provider_factory.py`     | CREATE | Factory tests                                                    |
| `tests/unit/test_provider_swap.py`        | CREATE | Provider-swap contract tests (NFR39, NFR40)                      |

[Source: architecture.md#Structure Patterns, architecture.md#Project Structure — `app/providers/`]

### Technical Requirements

**LLM Provider ABC (`app/providers/llm/base.py`):**

```python
from abc import ABC, abstractmethod
from collections.abc import AsyncIterator
from pydantic import BaseModel

class ModelInfo(BaseModel):
    """LLM model metadata."""
    name: str           # e.g. "gemini-2.5-flash"
    provider: str       # e.g. "google", "openrouter"
    max_tokens: int     # max output tokens
    supports_streaming: bool

class LLMConfig(BaseModel):
    """Per-request LLM configuration."""
    temperature: float = 0.7
    max_output_tokens: int = 4096
    top_p: float = 0.95
    stop_sequences: list[str] | None = None

class LLMProvider(ABC):
    """Abstract base class for LLM providers."""

    @abstractmethod
    async def generate(self, prompt: str, config: LLMConfig | None = None) -> str:
        """Generate a complete response from the LLM."""
        ...

    @abstractmethod
    async def stream(self, prompt: str, config: LLMConfig | None = None) -> AsyncIterator[str]:
        """Stream response tokens from the LLM."""
        ...

    @abstractmethod
    def get_model_info(self) -> ModelInfo:
        """Return model metadata."""
        ...
```

**CRITICAL:** The `stream()` method must return `AsyncIterator[str]` — not `AsyncGenerator`. Use `async def stream(...) -> AsyncIterator[str]` with `yield` inside. The method signature must use `AsyncIterator` from `collections.abc` for type hints.

[Source: architecture.md#Architectural Boundaries — `Backend ↔ LLM: LLMProvider.stream()`]

**Gemini Provider (`app/providers/llm/gemini.py`):**

Uses `langchain-google-genai` v4.2.x with `ChatGoogleGenerativeAI`:

```python
from langchain_google_genai import ChatGoogleGenerativeAI

class GeminiProvider(LLMProvider):
    def __init__(self, api_key: str, model: str = "gemini-2.5-flash"):
        self._llm = ChatGoogleGenerativeAI(
            model=model,
            google_api_key=api_key,
        )
        self._model = model

    async def generate(self, prompt: str, config: LLMConfig | None = None) -> str:
        cfg = config or LLMConfig()
        self._llm.temperature = cfg.temperature
        self._llm.max_output_tokens = cfg.max_output_tokens
        response = await self._llm.ainvoke(prompt)
        return response.content

    async def stream(self, prompt: str, config: LLMConfig | None = None) -> AsyncIterator[str]:
        cfg = config or LLMConfig()
        self._llm.temperature = cfg.temperature
        self._llm.max_output_tokens = cfg.max_output_tokens
        async for chunk in self._llm.astream(prompt):
            if chunk.content:
                yield chunk.content
```

**CRITICAL:** `api_key` comes from `Settings.GEMINI_API_KEY` which is `SecretStr`. Pass `settings.GEMINI_API_KEY.get_secret_value()` when constructing the provider — never pass the `SecretStr` object directly.

[Source: architecture.md#Core Architectural Decisions — Google Gemini 2.5 Flash as primary LLM, deferred-work.md — SecretStr downstream access]

**OpenRouter Provider (`app/providers/llm/openrouter.py`):**

Uses `langchain-openrouter` (the dedicated first-party integration, NOT `langchain-openai` with base URL override):

```python
from langchain_openrouter import ChatOpenRouter

class OpenRouterProvider(LLMProvider):
    def __init__(self, api_key: str, model: str = "google/gemini-2.5-flash"):
        self._llm = ChatOpenRouter(
            model=model,
            openrouter_api_key=api_key,
        )
        self._model = model
```

**CRITICAL:** Do NOT use `langchain-openai` with `base_url` pointing to OpenRouter — this approach causes issues with structured outputs, reasoning content, and tracing. Use the dedicated `langchain-openrouter` package with `ChatOpenRouter`.

**DuckDuckGo Provider (`app/providers/search/duckduckgo.py`):**

Uses `ddgs` package (formerly `duckduckgo-search`):

```python
from ddgs import DDGS

class DuckDuckGoProvider(SearchProvider):
    async def search(self, query: str, num_results: int = 5) -> list[SearchResult]:
        with DDGS() as ddgs:
            results = ddgs.text(query, max_results=num_results)
            return [
                SearchResult(
                    title=r.get("title", ""),
                    url=r.get("href", ""),
                    snippet=r.get("body", ""),
                )
                for r in results
            ]
```

**CRITICAL:** The `ddgs` package is synchronous. Wrap the blocking call in `asyncio.to_thread()` to avoid blocking the event loop:

```python
import asyncio

async def search(self, query: str, num_results: int = 5) -> list[SearchResult]:
    results = await asyncio.to_thread(self._sync_search, query, num_results)
    return results

def _sync_search(self, query: str, num_results: int) -> list[SearchResult]:
    with DDGS() as ddgs:
        raw = ddgs.text(query, max_results=num_results)
        return [SearchResult(title=r.get("title",""), url=r.get("href",""), snippet=r.get("body","")) for r in raw]
```

**IMPORTANT:** Do NOT install the old `duckduckgo-search` package. The package has been renamed to `ddgs`. Import as `from ddgs import DDGS`.

**LLM Failover Manager (`app/providers/llm/failover.py`):**

Wraps primary + fallback providers with automatic failover per architecture retry/resilience patterns:

```python
class LLMFailoverManager(LLMProvider):
    """Transparent failover between primary and fallback LLM providers."""

    def __init__(self, primary: LLMProvider, fallback: LLMProvider):
        self._primary = primary
        self._fallback = fallback

    async def generate(self, prompt, config=None) -> str:
        # Try primary with 2 retries, 2s fixed backoff
        # On exhausted retries, switch to fallback (log the failover)
        ...

    async def stream(self, prompt, config=None) -> AsyncIterator[str]:
        # Same failover logic for streaming
        ...
```

Failover pattern from architecture: **LLM provider calls → Retry on rate limit (429), failover on persistent error → 2 retries + failover → 2s fixed backoff + provider switch**

[Source: architecture.md#Retry & Resilience Patterns]

**Search Retry Pattern:**

Search provider calls → **Retry on timeout, failover on rate limit → 2 retries + failover → 1s fixed backoff**

Implement retry inside `DuckDuckGoProvider.search()` directly. On exhausted retries, raise `ProviderRateLimitedError` from `app.core.exceptions`.

[Source: architecture.md#Retry & Resilience Patterns]

**Provider Factory (`app/providers/factory.py`):**

```python
def get_llm_provider(settings: Settings) -> LLMProvider:
    """Construct the LLM provider stack based on settings."""
    primary = _build_llm_provider(settings.LLM_PRIMARY_PROVIDER, settings)
    fallback = _build_llm_provider(settings.LLM_FALLBACK_PROVIDER, settings)
    return LLMFailoverManager(primary, fallback)

def get_search_provider(settings: Settings) -> SearchProvider:
    """Construct the search provider based on settings."""
    if settings.SEARCH_PRIMARY_PROVIDER == "duckduckgo":
        return DuckDuckGoProvider()
    raise ValueError(f"Unknown search provider: {settings.SEARCH_PRIMARY_PROVIDER}")
```

### Previous Story Intelligence (Story 1.3)

**Patterns established to follow:**

- App factory pattern in `app/main.py` — extend lifespan if needed, don't restructure
- `app.state.settings` and `app.state.redis_manager` stored in lifespan — follow this pattern for any new stateful services
- `get_settings()` uses `@lru_cache` singleton — reuse for settings access
- `request_id_ctx` context var for structured logging — reuse in provider error logging
- Test client fixture in `tests/conftest.py` — extend with provider mock fixtures if needed
- `ruff check` enforces `I001` (import sorting), `UP046` (type params) — keep code compliant
- Docstrings on all modules, classes, and functions
- Type hints on all function signatures
- Ruff config: `line-length=120`, `target-version="py313"`, selected rules: `["E", "F", "I", "UP", "B", "SIM"]`

**Deferred items from previous stories (potentially relevant):**

- SecretStr downstream access — when using `GEMINI_API_KEY` and `OPENROUTER_API_KEY` (both `SecretStr`), use `.get_secret_value()` to extract the actual string value before passing to third-party constructors
- Settings cache collision in concurrent tests — use `get_settings.cache_clear()` in fixtures (already handled in `conftest.py`)

**Files from previous stories that exist:**

- `app/core/config.py` (54 lines) — MODIFY to add provider settings
- `app/core/exceptions.py` (129 lines) — `ProviderRateLimitedError` and `ProviderUnavailableError` ALREADY EXIST — reuse them
- `app/core/logging.py` (52 lines) — use `get_logger()` for provider logging
- `app/providers/__init__.py` — exists (empty)
- `app/providers/llm/__init__.py` — exists (empty)
- `app/providers/search/__init__.py` — exists (empty)
- `backend/pyproject.toml` (34 lines) — MODIFY to add new deps

### Dependencies

**New dependencies to add:**

- `langchain-google-genai>=4.2.0` — Google Gemini via LangChain (latest stable: 4.2.2)
- `langchain-openrouter>=0.3.0` — OpenRouter first-party LangChain integration
- `ddgs>=8.0.0` — DuckDuckGo search (formerly `duckduckgo-search`)

**Already available:**

- `fastapi[standard]>=0.136.1`
- `pydantic-settings>=2.14.0` (provides `Settings` with `SecretStr`)
- `uvicorn[standard]>=0.46.0`
- `pytest>=9.0.3`
- `httpx>=0.28.1`
- `ruff>=0.15.12`
- `sqlalchemy[asyncio]>=2.0.49`
- `asyncpg>=0.30.0`
- `alembic>=1.18.4`
- `redis>=7.4.0`

**DO NOT add:**

- ❌ `langchain-openai` — do NOT use this for OpenRouter; use `langchain-openrouter` instead
- ❌ `duckduckgo-search` — renamed to `ddgs`; install `ddgs` not the old package
- ❌ `aioredis` — already addressed in Story 1.3
- ❌ `openai` — not needed; OpenRouter access is through `langchain-openrouter`
- ❌ `google-generativeai` — pulled in as a transitive dep by `langchain-google-genai`; do NOT install separately

### Testing Requirements

**Test framework:** `pytest` (already in dev deps)
**Async testing:** Provider methods are async. Use `pytest-asyncio` if testing async methods directly, or test via synchronous wrapper patterns.

**Required test files:**

| Test File                                 | Tests                                                                                                                                                     |
| :---------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tests/unit/test_llm_provider_base.py`    | ABC enforcement; `ModelInfo` and `LLMConfig` model validation                                                                                             |
| `tests/unit/test_gemini_provider.py`      | `generate()` returns string; `stream()` yields strings; `get_model_info()` correct; API key handling                                                      |
| `tests/unit/test_openrouter_provider.py`  | Same pattern as Gemini tests; uses `ChatOpenRouter`                                                                                                       |
| `tests/unit/test_llm_failover.py`         | Primary success → no failover; primary failure → failover to fallback; both fail → raises `ProviderUnavailableError`; retry count correct; backoff timing |
| `tests/unit/test_search_provider_base.py` | ABC enforcement; `SearchResult` model validation                                                                                                          |
| `tests/unit/test_duckduckgo_provider.py`  | `search()` returns `SearchResult` list; retry on rate limit; raises `ProviderRateLimitedError` on exhaustion                                              |
| `tests/unit/test_provider_factory.py`     | Factory returns correct provider types based on settings                                                                                                  |
| `tests/unit/test_provider_swap.py`        | Consumer code works with both LLM providers unchanged; same for search providers (NFR39, NFR40)                                                           |

**CRITICAL testing pattern:** Unit tests must NOT require real API keys or network access. Mock all external calls (`ChatGoogleGenerativeAI`, `ChatOpenRouter`, `DDGS`). Use `unittest.mock.AsyncMock` for async methods and `unittest.mock.MagicMock` for sync methods.

**Test patterns from previous stories:**

```python
from unittest.mock import AsyncMock, MagicMock, patch

# Mock LangChain model
@patch("app.providers.llm.gemini.ChatGoogleGenerativeAI")
def test_gemini_generate(mock_llm_class):
    mock_llm = AsyncMock()
    mock_llm.ainvoke.return_value = MagicMock(content="test response")
    mock_llm_class.return_value = mock_llm
    # ... test generate()
```

### Anti-Patterns to AVOID

- ❌ Do NOT use `langchain-openai` + `base_url` for OpenRouter — causes issues with structured outputs and tracing
- ❌ Do NOT install `duckduckgo-search` — it's been renamed to `ddgs`
- ❌ Do NOT call DuckDuckGo synchronously in an async context — wrap in `asyncio.to_thread()`
- ❌ Do NOT pass `SecretStr` objects to third-party constructors — always call `.get_secret_value()` first
- ❌ Do NOT hardcode API keys — always read from `Settings`
- ❌ Do NOT create agents, prompts, or graph definitions — those are Epic 4
- ❌ Do NOT implement caching — that's a later story (`cache_service.py`)
- ❌ Do NOT implement the streaming service — that's Story 4.2
- ❌ Do NOT implement plausibility check — that's Story 3.2
- ❌ Do NOT add provider dependencies to `app/main.py` lifespan — providers are constructed on-demand via factory, not stored in `app.state`
- ❌ Do NOT use `print()` — use structured logger
- ❌ Do NOT expose raw exception messages from LLM/search providers to API responses

### Scope Boundaries

**IN SCOPE:**

- `app/providers/llm/base.py` — LLMProvider ABC, ModelInfo, LLMConfig
- `app/providers/llm/gemini.py` — GeminiProvider implementation
- `app/providers/llm/openrouter.py` — OpenRouterProvider implementation
- `app/providers/llm/failover.py` — LLMFailoverManager with automatic failover
- `app/providers/search/base.py` — SearchProvider ABC, SearchResult
- `app/providers/search/duckduckgo.py` — DuckDuckGoProvider with retry
- `app/providers/factory.py` — Provider factory functions
- `app/core/config.py` — New provider settings fields
- `backend/pyproject.toml` — New dependencies
- Unit tests for all new code
- Provider-swap contract tests (NFR39, NFR40)

**OUT OF SCOPE:**

- **NO** agents, prompts, or graph definitions — Epic 4
- **NO** `app/services/cache_service.py` — later story
- **NO** `app/services/streaming_service.py` — Story 4.2
- **NO** `app/services/plausibility_service.py` — Story 3.2
- **NO** `app/services/analysis_service.py` — Story 4.1
- **NO** WebSocket streaming — Story 4.2
- **NO** Firebase auth/security — Story 2.1
- **NO** changes to `app/main.py` (providers are on-demand, not lifespan-managed)
- **NO** ChromaDB integration — later story

### Project Structure Notes

- `app/providers/` directory with `__init__.py` already exists from Story 1.1 scaffolding
- `app/providers/llm/__init__.py` already exists (empty)
- `app/providers/search/__init__.py` already exists (empty)
- New files go exclusively within these existing directories plus `app/providers/factory.py`
- Test files go in `backend/tests/unit/` following existing `test_{module}.py` naming pattern
- Follow naming: `snake_case.py` for files, `PascalCase` for classes, `snake_case` for functions
- `ProviderRateLimitedError` and `ProviderUnavailableError` already defined in `app/core/exceptions.py` — reuse them, do NOT duplicate

### References

- [Source: architecture.md#Structure Patterns] — `app/providers/llm/`, `app/providers/search/` directory structure
- [Source: architecture.md#Project Structure] — Complete file listing for providers
- [Source: architecture.md#Architectural Boundaries] — `Backend ↔ LLM: LLMProvider.stream()`, `Backend ↔ Search: SearchProvider.search()`
- [Source: architecture.md#Retry & Resilience Patterns] — LLM: 2 retries + failover, 2s fixed; Search: 2 retries, 1s fixed
- [Source: architecture.md#Core Architectural Decisions] — Gemini 2.5 Flash primary, OpenRouter fallback, DuckDuckGo Search
- [Source: architecture.md#Enforcement Guidelines] — Rules 1, 2, 6, 8, 9
- [Source: epics.md#Story 1.4] — Acceptance criteria
- [Source: epics.md#Epic 1 Overview] — Walking Skeleton objectives, NFR39/NFR40 coverage
- [Source: prd.md] — NFR26 (LLM failover), NFR27 (search retry), NFR39 (LLM abstraction), NFR40 (search abstraction)

## Dev Agent Record

### Agent Model Used

GPT-5.2-Codex

### Implementation Plan

- Implement provider abstractions and concrete providers with async-safe patterns.
- Add failover/retry logic and provider factory wiring.
- Expand settings, dependencies, and unit tests to cover provider contracts.

### Debug Log References

- `uv sync` failed with `langchain-openrouter>=0.3.0` (no matching version); adjusted to `>=0.2.3` and re-ran successfully.
- `pytest` executed: 67 passed.
- `ruff check .` executed: pass.

### Completion Notes List

- Added LLM/search abstractions, concrete providers, failover, and retry logic.
- Implemented provider factory and settings fields for provider selection.
- Added unit tests for providers, failover, factory, and swap contracts.
- Updated dependencies; `langchain-openrouter` minimum version adjusted to `>=0.2.3` due to resolution availability.
- Tests: `python -m pytest`, `python -m ruff check .`.

### File List

- \_bmad-output/implementation-artifacts/1-4-provider-abstraction-layer-llm-search.md
- \_bmad-output/implementation-artifacts/sprint-status.yaml
- backend/app/core/config.py
- backend/app/providers/factory.py
- backend/app/providers/llm/base.py
- backend/app/providers/llm/failover.py
- backend/app/providers/llm/gemini.py
- backend/app/providers/llm/openrouter.py
- backend/app/providers/search/base.py
- backend/app/providers/search/duckduckgo.py
- backend/pyproject.toml
- backend/tests/unit/test_config.py
- backend/tests/unit/test_duckduckgo_provider.py
- backend/tests/unit/test_gemini_provider.py
- backend/tests/unit/test_llm_failover.py
- backend/tests/unit/test_llm_provider_base.py
- backend/tests/unit/test_openrouter_provider.py
- backend/tests/unit/test_provider_factory.py
- backend/tests/unit/test_provider_swap.py
- backend/tests/unit/test_search_provider_base.py

### Change Log

- 2026-05-15: Implemented provider abstractions, LLM/search providers, failover/retry, settings, and tests; updated dependencies and ran pytest.
