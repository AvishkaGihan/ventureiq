# Story 3.2: Plausibility Check via LLM

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user submitting a business idea,
I want my idea checked for basic plausibility before the full analysis runs,
so that I can refine vague or nonsensical submissions and get better results.

## Acceptance Criteria

1. **AC1 — LLM Plausibility Assessment**
   Given a valid idea exists with `status: "pending"` in the database
   When `POST /api/v1/ideas/{idea_id}/plausibility` is called
   Then `PlausibilityService` sends the sanitized `idea_text` (plus optional fields `target_audience`, `industry`, `monetization_model`, `region`) to the LLM via the `LLMProvider` abstraction
   And returns a structured plausibility assessment

2. **AC2 — Three Verdicts**
   The plausibility check returns exactly one of:
   - `pass` — idea is coherent, specific, and analyzable → proceed to full analysis
   - `refine` — idea has potential but needs improvement → include actionable guidance
   - `reject` — idea is nonsensical, harmful, or not a business idea → include reason

3. **AC3 — Refinement Guidance (FR4)**
   Given the verdict is `refine`
   Then the response includes 2-4 specific, actionable suggestions (e.g., "Consider specifying your target customer segment")
   And suggestions are user-friendly and encouraging, not rejective

4. **AC4 — Rejection Reason**
   Given the verdict is `reject`
   Then the response includes a clear, constructive reason without exposing internal details
   And encourages the user to try again with a refined idea

5. **AC5 — Lightweight LLM Config**
   The plausibility check uses `LLMConfig(temperature=0.3, max_output_tokens=512)` to minimize cost
   And uses `generate()` (not `stream()`) since this is a quick check

6. **AC6 — Redis Cache (NFR22)**
   Results are cached in Redis db1 keyed by `plausibility:{sha256(normalized_idea_text)}`
   And cache TTL is 7 days (aligns with agent output cache TTL per architecture)
   And cache hits return the cached result without calling the LLM
   And cache reduces redundant LLM calls by ≥20% (NFR22)

7. **AC7 — Dedicated Endpoint**
   `POST /api/v1/ideas/{idea_id}/plausibility` returns the plausibility result
   And uses the standard response envelope via `success_response()`
   And requires authentication via `get_current_user()`
   And validates the idea belongs to the requesting user (ownership check)

8. **AC8 — Status Update**
   On `pass` verdict → idea `status` updated to `plausibility_passed`
   On `refine` or `reject` verdict → idea `status` updated to `plausibility_failed`
   And status update is persisted to PostgreSQL via async session

9. **AC9 — Unit Tests**
   Unit tests verify all three plausibility outcomes (`pass`, `refine`, `reject`)
   And verify cache hit/miss behavior
   And verify LLM failure graceful degradation
   And verify ownership validation (user can only check their own ideas)
   And mock all LLM calls (no real API calls in tests)

## Tasks / Subtasks

- [ ] Task 1: Create PlausibilityResponse schema (AC: #2, #3, #4, #7)
  - [ ] Add `PlausibilityResponse` Pydantic model to `app/schemas/idea.py`
  - [ ] Fields: `verdict` (Literal["pass","refine","reject"]), `guidance` (list[str]|None), `reason` (str|None), `confidence` (float)
  - [ ] Add `PlausibilityCheckResponse` wrapping `IdeaResponse` + `PlausibilityResponse`

- [ ] Task 2: Create PlausibilityService (AC: #1, #2, #3, #4, #5, #6)
  - [ ] Create `app/services/plausibility_service.py`
  - [ ] Constructor accepts `LLMProvider` and `aioredis.Redis` (cache)
  - [ ] `async def check(self, idea_text: str, target_audience: str|None, industry: str|None, monetization_model: str|None, region: str|None) -> PlausibilityResponse`
  - [ ] Build structured prompt (system + user message separation)
  - [ ] Call `llm.generate(prompt, LLMConfig(temperature=0.3, max_output_tokens=512))`
  - [ ] Parse JSON response into `PlausibilityResponse` with validation
  - [ ] Cache check before LLM call; cache write after successful LLM call
  - [ ] Handle `ProviderUnavailableError` gracefully

- [ ] Task 3: Create plausibility prompt (AC: #1, #3, #4)
  - [ ] Create prompt as a constant/template in `plausibility_service.py` (or dedicated prompt file)
  - [ ] System message: evaluator role, structured JSON output requirement
  - [ ] User message: idea text + optional context fields
  - [ ] Tone: helpful and encouraging, not gatekeeping (per UX spec)
  - [ ] Criteria: coherence, specificity, analyzability, non-trivial

- [ ] Task 4: Add plausibility endpoint (AC: #7, #8)
  - [ ] Add `POST /{idea_id}/plausibility` to `app/api/v1/endpoints/ideas.py`
  - [ ] Look up idea by ID, verify ownership (user_id == current_user.id)
  - [ ] Raise `IdeaNotFoundError` if idea doesn't exist or wrong user
  - [ ] Call `PlausibilityService.check()` with idea fields
  - [ ] Update idea `status` based on verdict
  - [ ] Return response via `success_response()`

- [ ] Task 5: Write unit tests (AC: #9)
  - [ ] Create `backend/tests/unit/test_plausibility_service.py`
  - [ ] Test `pass` verdict with mocked LLM response
  - [ ] Test `refine` verdict with mocked LLM response
  - [ ] Test `reject` verdict with mocked LLM response
  - [ ] Test cache hit returns cached result (no LLM call)
  - [ ] Test cache miss calls LLM and writes cache
  - [ ] Test `ProviderUnavailableError` handling

- [ ] Task 6: Write integration tests (AC: #7, #8, #9)
  - [ ] Create `backend/tests/integration/test_plausibility_endpoint.py`
  - [ ] Test full endpoint flow: auth → lookup idea → plausibility check → status update → response envelope
  - [ ] Test idea not found → 404
  - [ ] Test wrong user ownership → 404 (don't leak existence)
  - [ ] Test idea already checked (non-pending status) — decide behavior
  - [ ] Follow existing `test_ideas_endpoint.py` patterns (FakeIdeaSession, _build_client)

## Dev Notes

### Architecture Patterns & Constraints

**LLM Provider Usage:**
- Use `get_llm_provider()` from `app/providers/factory.py` → returns `LLMFailoverManager`
- Call `llm.generate(prompt, config)` — returns raw string. **NOT** `stream()`
- `LLMConfig(temperature=0.3, max_output_tokens=512)` for low-cost plausibility
- Failover (Gemini → OpenRouter) is transparent — handled by `LLMFailoverManager`
- If both providers fail, `ProviderUnavailableError` is raised automatically

**LLM Response Parsing:**
- The LLM returns a raw string. The prompt must request JSON output
- Parse the response using `json.loads()` then validate with `PlausibilityResponse.model_validate()`
- If parsing fails, treat as a service error — do NOT return raw LLM text to client
- Consider wrapping parse failures gracefully (e.g., default to `reject` with generic message)

**Redis Cache Pattern:**
```python
import hashlib, json

cache_key = f"plausibility:{hashlib.sha256(normalized_text.encode()).hexdigest()}"
cached = await self._cache.get(cache_key)
if cached:
    return PlausibilityResponse.model_validate_json(cached)

# ... call LLM, parse result ...

await self._cache.set(cache_key, result.model_dump_json(), ex=604800)  # 7 days
```

**Normalization for cache key:** Strip whitespace, lowercase, remove punctuation before hashing. Include optional fields in the hash if they affect the assessment.

**Endpoint Pattern (from Story 3-1):**
```python
@router.post("/{idea_id}/plausibility")
async def check_plausibility(
    idea_id: uuid.UUID,
    current_user: UserModel = Depends(get_current_user),
    session: AsyncSession = Depends(get_db),
    request: Request,  # for get_redis_cache
) -> dict:
```

**Ownership Validation:**
```python
result = await session.execute(
    select(IdeaModel).where(IdeaModel.id == idea_id, IdeaModel.user_id == current_user.id)
)
idea = result.scalar_one_or_none()
if idea is None:
    raise IdeaNotFoundError()
```
Use compound WHERE clause (id + user_id) so unauthorized access returns 404 (don't leak existence).

**Status Update Pattern:**
```python
idea.status = "plausibility_passed" if response.verdict == "pass" else "plausibility_failed"
await session.commit()
await session.refresh(idea)
```
Note: `status` column is `String(20)` — both `plausibility_passed` (19 chars) and `plausibility_failed` (19 chars) fit.

### Prompt Design Guidelines

**Tone (from UX spec):**
- "Plausibility checks should feel helpful — 'Here's how I'll analyze your idea' — not rejective"
- "Never blocking, always helpful"
- For `refine`: specific actionable guidance (not generic "be more specific")
- For `reject`: constructive and encouraging to try again

**Evaluation Criteria (from architecture):**
1. **Coherence** — Is the idea understandable and internally consistent?
2. **Specificity** — Is it specific enough to analyze (not just "make money")?
3. **Analyzability** — Can meaningful market/competitive analysis be performed?
4. **Non-trivial** — Is this a real business idea (not a joke, test, or gibberish)?

**Prompt Structure:**
- System message: Define evaluator role, specify JSON output format, set evaluation criteria
- User message: Idea text + optional context (target audience, industry, etc.)
- Separate system/user messages to prevent prompt injection (defense-in-depth)

### Existing Code to Reuse — DO NOT RECREATE

| Component | File | What it provides |
|---|---|---|
| `LLMProvider` ABC | `app/providers/llm/base.py` | `generate(prompt, config)` interface |
| `LLMConfig` | `app/providers/llm/base.py` | Per-request config (temperature, max_output_tokens) |
| `LLMFailoverManager` | `app/providers/llm/failover.py` | Auto failover Gemini → OpenRouter |
| `get_llm_provider()` | `app/providers/factory.py` | Factory returning configured failover manager |
| `IdeaModel` | `app/models/idea.py` | ORM model with `status` field to update |
| `IdeaResponse` | `app/schemas/idea.py` | Existing response schema (extend, don't replace) |
| `IdeaNotFoundError` | `app/core/exceptions.py:59-64` | 404 for missing/unauthorized idea |
| `ProviderUnavailableError` | `app/core/exceptions.py:91-96` | 503 for LLM failures (auto-raised by failover) |
| `get_current_user()` | `app/core/dependencies.py:62-88` | JWT auth dependency |
| `get_db()` | `app/core/dependencies.py:19-22` | Async DB session dependency |
| `get_redis_cache()` | `app/core/dependencies.py:52-54` | Redis db1 cache connection |
| `success_response()` | `app/schemas/common.py:38-40` | Response envelope helper |
| `get_logger()` | `app/core/logging.py:49-51` | Structured JSON logger |
| `request_id_ctx` | `app/core/logging.py:11` | ContextVar for request ID |
| `SanitizationService` | `app/services/sanitization_service.py` | Input already sanitized in 3-1 |

### Project Structure Notes

**New files:**
```
backend/app/services/plausibility_service.py                [NEW]
backend/tests/unit/test_plausibility_service.py             [NEW]
backend/tests/integration/test_plausibility_endpoint.py     [NEW]
```

**Modified files:**
```
backend/app/schemas/idea.py                                 [MODIFY] — add PlausibilityResponse
backend/app/api/v1/endpoints/ideas.py                       [MODIFY] — add POST /{id}/plausibility
```

**NOT modified (reuse as-is):**
```
backend/app/providers/llm/base.py                           [REFERENCE ONLY]
backend/app/providers/llm/failover.py                       [REFERENCE ONLY]
backend/app/providers/factory.py                            [REFERENCE ONLY]
backend/app/core/exceptions.py                              [REFERENCE ONLY]
backend/app/core/dependencies.py                            [REFERENCE ONLY]
backend/app/models/idea.py                                  [REFERENCE ONLY]
```

### Anti-Patterns — DO NOT DO

1. ❌ **NO `HTTPException`** — use `VentureIQError` subclasses (`IdeaNotFoundError`, `ProviderUnavailableError`)
2. ❌ **NO `print()`** — use `get_logger(__name__)` with structured `extra_data`
3. ❌ **NO raw dicts for responses** — use Pydantic schemas + `success_response()`
4. ❌ **NO raw LLM output to client** — always parse/validate through Pydantic schema first
5. ❌ **NO sync DB queries** — all SQLAlchemy operations use `async_session` with `await`
6. ❌ **NO logging raw user input** — log `idea_id`, `verdict`, `request_id` only (PII protection)
7. ❌ **NO `validator` decorator** — use `field_validator` (Pydantic v2)
8. ❌ **NO inner `Config` class** — use `model_config = ConfigDict(...)`
9. ❌ **NO hardcoded API keys or model names** — use Settings
10. ❌ **NO new top-level directories** — follow existing structure exactly
11. ❌ **NO modifying existing middleware or exception classes** — reuse what exists
12. ❌ **NO inline multi-line prompts in service logic** — use constants or dedicated prompt structure

### Testing Standards

**Framework:** `pytest` + `pytest-asyncio`
**HTTP Client:** `httpx.AsyncClient` with `ASGITransport` (NOT `TestClient`)

**Mock pattern for LLM:**
```python
from unittest.mock import AsyncMock

mock_llm = AsyncMock()
mock_llm.generate.return_value = json.dumps({
    "verdict": "pass",
    "guidance": None,
    "reason": None,
    "confidence": 0.92
})
```

**Mock pattern for Redis cache:**
```python
mock_redis = AsyncMock()
mock_redis.get.return_value = None  # cache miss
mock_redis.set.return_value = True
```

**Follow existing test patterns from `test_ideas_endpoint.py`:**
- `FakeIdeaSession` for mock DB session
- `_build_client()` async helper
- `app.dependency_overrides` for injection
- `monkeypatch.setattr()` for rate limit mocking
- All tests: `@pytest.mark.asyncio async def test_*()`

**Edge cases to test:**
- Very short idea text (single word)
- Very long idea text (max 5000 chars)
- Non-English idea text
- Idea with prompt injection attempt in text
- Idea that already has non-pending status
- LLM returns malformed JSON
- LLM returns unexpected verdict value
- Redis connection failure during cache read/write

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Epic-3, Story 3.2 (L560-578)]
- [Source: _bmad-output/planning-artifacts/prd.md#FR4 — Plausibility assessment requirement]
- [Source: _bmad-output/planning-artifacts/prd.md#L249 — Early stopping on failed plausibility]
- [Source: _bmad-output/planning-artifacts/prd.md#L256 — Lightweight model routing for plausibility]
- [Source: _bmad-output/planning-artifacts/architecture.md#L943-945 — Plausibility data flow]
- [Source: _bmad-output/planning-artifacts/architecture.md#L266-267 — Cache TTL decisions]
- [Source: _bmad-output/planning-artifacts/architecture.md#L462-488 — Response envelope]
- [Source: _bmad-output/planning-artifacts/architecture.md#L277 — Prompt injection defense]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#L212 — Helpful not rejective tone]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#L1505 — Inline info nudge pattern]
- [Source: _bmad-output/implementation-artifacts/3-1-idea-submission-endpoint-input-sanitization-backend.md — Predecessor patterns]
- [Source: _bmad-output/implementation-artifacts/epic-2-retro-2026-06-07.md — Provider abstraction, test fixtures]
- [Source: _bmad-output/implementation-artifacts/deferred-work.md — FakeIdeaSession pattern]

### Previous Story Intelligence (3-1)

**Patterns established in 3-1 that MUST be followed:**
- Service classes accept dependencies via constructor injection
- Endpoint functions create/inject services using FastAPI `Depends`
- All responses use `success_response(data=..., request_id=request_id_ctx.get("unknown"))`
- Custom exceptions raised (never raw HTTPException) → caught by global handler in `main.py`
- Structured logging with `extra={"extra_data": {...}}` pattern
- `noqa: B008` comments on `Depends()` parameters

**Key learnings from 3-1 code review:**
- Optional field sanitization: check `if field else None` before sanitizing
- `SanitizationService` is stateless — new instance per request is fine
- `request_id_ctx.get("unknown")` for request ID in responses

**Code review findings resolved in 3-1 (avoid repeating):**
- SQL injection regex false positives → word-boundary matching
- Unicode normalization handling
- Null byte detection

### Downstream Impact

**Story 3-3 (Flutter Idea Input Screen) will consume this endpoint:**
- On `pass` → screen transitions to War Room
- On `refine` → inline info card (Intelligence Blue `#3B82F6` left border) shows guidance below input
- On `reject` → error card (Error Red left border) shows reason
- The API response must contain enough data for all three UI states

**Story 4-1 (LangGraph Agent Pipeline) will consume ideas with `status: plausibility_passed`:**
- Only `plausibility_passed` ideas proceed to full analysis
- This makes the status update in AC8 critical for the downstream pipeline

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List
