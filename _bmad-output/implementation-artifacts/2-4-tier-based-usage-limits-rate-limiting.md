# Story 2.4: Tier-Based Usage Limits & Rate Limiting

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a platform operator,
I want tier-based usage limits enforced so free users are limited to 3 reports/month while Pro users have unlimited access,
So that the platform can sustainably serve users while incentivizing upgrades.

## Acceptance Criteria

1. `app/services/rate_limit_service.py` tracks report generation count per user per calendar month using Redis db2
2. Free tier: 3 reports/month (FR39); Anonymous tier: 3 reports/month (device fingerprint + IP)
3. Pro tier: unlimited report generation
4. `app/core/middleware.py` includes rate limiting middleware checking usage before report generation endpoints
5. API returns `429` with `RATE_LIMIT_EXCEEDED` error code and `remaining_seconds_until_reset` in details when free user exceeds limit
6. Flutter displays upgrade prompt when rate limit is hit, showing "3/3 reports used this month"
7. `features/auth/presentation/widgets/usage_indicator.dart` shows current usage in Profile tab
8. Redis TTL auto-expires at month end (NFR17)
9. Unit tests verify limit enforcement, month-boundary reset, and tier-based bypass
10. Rate limit headers `X-RateLimit-Remaining` and `X-RateLimit-Reset` included on report generation responses

## Tasks / Subtasks

### Backend

- [ ] Task 1: Rate Limit Service (AC: #1, #2, #3, #8)
  - [ ] 1.1 Create `app/services/rate_limit_service.py` with `RateLimitService` class
  - [ ] 1.2 Implement Redis Sorted Set (ZSET) sliding window via atomic Lua script
  - [ ] 1.3 Key pattern: `rate_limit:reports:{user_id}:{YYYY-MM}` — avoids collision with `refresh_token:{jti}` keys in db2
  - [ ] 1.4 TTL calculated to calendar month end (UTC)
  - [ ] 1.5 Methods: `check_and_increment(user_id, tier) → (allowed: bool, current_count: int, limit: int, reset_at: datetime)`
  - [ ] 1.6 Method: `get_usage(user_id, tier) → (current_count: int, limit: int, reset_at: datetime)` (read-only for usage endpoint)
  - [ ] 1.7 Tier-aware logic: skip check entirely for "pro" tier; enforce limit=3 for "free" and "anonymous"

- [ ] Task 2: Rate Limit Configuration (AC: #2, #3)
  - [ ] 2.1 Add to `app/core/config.py` Settings: `RATE_LIMIT_FREE_TIER_MONTHLY: int = 3`, `RATE_LIMIT_PRO_TIER_MONTHLY: int = 0` (0 = unlimited), `RATE_LIMIT_ANONYMOUS_TIER_MONTHLY: int = 3`
  - [ ] 2.2 Add `RATE_LIMIT_ENABLED: bool = True` toggle for development/testing

- [ ] Task 3: Rate Limiting Middleware (AC: #4, #5, #10)
  - [ ] 3.1 Add `RateLimitMiddleware` class in `app/core/middleware.py` (alongside existing `RequestIDMiddleware`)
  - [ ] 3.2 Middleware applies ONLY to configurable route prefixes (initially `["/api/v1/ideas"]` for report generation — Epic 3 endpoint)
  - [ ] 3.3 Extract user from JWT via `get_current_user()` pattern (not full dependency injection in middleware — decode JWT manually or use a lightweight helper)
  - [ ] 3.4 Call `RateLimitService.check_and_increment()` — if denied, raise `RateLimitExceededError` with `remaining_seconds_until_reset`
  - [ ] 3.5 Add `X-RateLimit-Remaining` and `X-RateLimit-Reset` response headers on ALL responses to rate-limited routes (not just 429s)
  - [ ] 3.6 **Fail-open**: If Redis is unavailable, allow the request with a warning log
  - [ ] 3.7 Register middleware in `app/main.py` `create_app()` — AFTER `RequestIDMiddleware` so request_id is available for logging

- [ ] Task 4: Usage Status Endpoint (AC: #6, #7)
  - [ ] 4.1 Create `app/api/v1/endpoints/usage.py` with `GET /api/v1/usage/me` endpoint
  - [ ] 4.2 Returns: `{ "data": { "reports_used": 2, "reports_limit": 3, "tier": "free", "reset_at": "2026-07-01T00:00:00Z", "limit_reached": false }, "meta": {...} }`
  - [ ] 4.3 Depends on `get_current_user()` and `get_redis_rate_limit()`
  - [ ] 4.4 Register in `app/api/v1/router.py`

- [ ] Task 5: Rate Limit Schemas (AC: #5)
  - [ ] 5.1 Create `app/schemas/usage.py` with `UsageStatusSchema`, `RateLimitExceededDetailSchema`
  - [ ] 5.2 `RateLimitExceededDetailSchema`: `reports_used: int`, `reports_limit: int`, `reset_at: datetime`, `retry_after_seconds: int`
  - [ ] 5.3 Update `RateLimitExceededError` in `exceptions.py` to accept and include `details` dict (verify it exists from Story 1.2 — it does at line 43-48)

- [ ] Task 6: Backend Unit & Integration Tests (AC: #9)
  - [ ] 6.1 `tests/unit/test_rate_limit_service.py` — limit enforcement, month-boundary reset, tier bypass, Redis failure fail-open
  - [ ] 6.2 `tests/unit/test_rate_limit_middleware.py` — middleware applies to correct routes, skips non-rate-limited routes, returns correct headers
  - [ ] 6.3 `tests/integration/test_usage_endpoint.py` — GET /usage/me returns correct counts for different tiers
  - [ ] 6.4 Mock Redis with `DummyRedisManager` pattern from `conftest.py`; test atomic Lua script logic

### Flutter / Mobile

- [ ] Task 7: Usage Data Layer (AC: #6, #7)
  - [ ] 7.1 Add `usageMe` constant to `api_endpoints.dart`: `static const usageMe = '/api/v1/usage/me';`
  - [ ] 7.2 Create `features/auth/data/usage_repository.dart` — calls `GET /usage/me`, returns `UsageStatus` entity
  - [ ] 7.3 Create `features/auth/domain/usage_entity.dart` — freezed `UsageStatus` class: `reportsUsed`, `reportsLimit`, `tier`, `resetAt`, `limitReached`

- [ ] Task 8: Usage State Management (AC: #6, #7)
  - [ ] 8.1 Create `features/auth/presentation/usage_notifier.dart` — Riverpod `AsyncNotifier<UsageStatus>`
  - [ ] 8.2 Create `features/auth/presentation/usage_providers.dart` — `usageNotifierProvider`
  - [ ] 8.3 Auto-refresh usage on app foreground and after report generation

- [ ] Task 9: Usage Indicator Widget (AC: #7)
  - [ ] 9.1 Create `features/auth/presentation/widgets/usage_indicator.dart`
  - [ ] 9.2 Shows: progress bar (e.g., 2/3), "reports used this month" label, tier badge
  - [ ] 9.3 Warning state (Caution Amber `#F59E0B`) when usage ≥ 2 of 3
  - [ ] 9.4 Place in Profile tab (via `app_router.dart` profile screen)
  - [ ] 9.5 Use `AppColors`, `AppTypography`, `AppSpacing` design tokens
  - [ ] 9.6 Pro tier: show "Unlimited" badge instead of counter

- [ ] Task 10: Rate Limit Error Handling & Upgrade Prompt (AC: #6)
  - [ ] 10.1 Handle `429` responses in Dio error handling — do NOT trigger auth refresh (AuthInterceptor must NOT retry 429s)
  - [ ] 10.2 Create `features/auth/presentation/widgets/rate_limit_dialog.dart` — bottom sheet upgrade prompt
  - [ ] 10.3 Shows "3/3 reports used this month", "Upgrade to Pro for unlimited reports", CTA to upgrade (links to Profile/settings for now — IAP deferred post-V1)
  - [ ] 10.4 Uses `ErrorCard` widget from `core/widgets/error_card.dart` for inline errors

- [ ] Task 11: Flutter Widget Tests (AC: #9)
  - [ ] 11.1 `test/features/auth/presentation/widgets/usage_indicator_test.dart` — renders correctly for free/pro/anonymous tiers
  - [ ] 11.2 `test/features/auth/presentation/widgets/rate_limit_dialog_test.dart` — shows correct messaging
  - [ ] 11.3 Mock `usageNotifierProvider` with different states

## Dev Notes

### Architecture Compliance

- **Redis db2 is EXCLUSIVELY for rate limiting** — `get_redis_rate_limit(request)` dependency already exists in `dependencies.py`
- **Key collision warning**: Refresh token JTIs are stored as `refresh_token:{jti}` in db2. Rate limit keys MUST use prefix `rate_limit:reports:{user_id}:{YYYY-MM}` to avoid collision
- **Sliding window algorithm**: Architecture specifies sliding window with 30-day TTL. Use Redis Sorted Sets (ZSET) with Lua script for atomic check-and-increment. Each report generation adds a timestamp entry; ZREMRANGEBYSCORE prunes entries outside the window
- **Middleware stack order in `main.py`**: `RequestIDMiddleware` → `RateLimitMiddleware` → `ErrorHandlerMiddleware` (if exists). Rate limiter needs request_id for structured logging
- **API response envelope**: ALL responses (including 429 errors) MUST use the standard envelope: `{ "error": { "code": "RATE_LIMIT_EXCEEDED", "message": "...", "details": {...} }, "meta": { "request_id": "..." } }`

### Existing Infrastructure to Reuse (DO NOT Recreate)

| Component | File | What Exists |
|---|---|---|
| `RateLimitExceededError` | `app/core/exceptions.py:43-48` | `error_code="RATE_LIMIT_EXCEEDED"`, `status_code=429` — ALREADY EXISTS |
| `get_redis_rate_limit()` | `app/core/dependencies.py` | Returns Redis db2 connection — ALREADY EXISTS |
| `RedisManager.rate_limit` | `app/db/redis.py` | Typed property for db2 — ALREADY EXISTS |
| `UserModel.tier` | `app/models/user.py:23` | `String(20)`, default `"free"` — ALREADY EXISTS |
| `get_current_user()` | `app/core/dependencies.py` | Returns `UserModel` with `.tier` — ALREADY EXISTS |
| JWT `tier` claim | `app/core/security.py:64` | Included in access token payload — ALREADY EXISTS |
| `AuthUser.tier` (Flutter) | `features/auth/domain/auth_entity.dart:17` | `@Default('free') String tier` — ALREADY EXISTS |
| `RequestIDMiddleware` | `app/core/middleware.py` | Existing middleware class — DO NOT MODIFY |
| `success_response()` | `app/schemas/common.py` | Response envelope helper — USE THIS |
| `DummyRedisManager` | `tests/conftest.py` | Test mock for Redis — EXTEND for rate limit tests |
| Error handlers | `app/main.py` | Global `VentureIQError` handler — catches `RateLimitExceededError` automatically |

### Technical Implementation Details

**Redis Lua Script (Atomic Sliding Window):**
```lua
-- KEYS[1] = rate_limit:reports:{user_id}:{YYYY-MM}
-- ARGV[1] = window_start (timestamp ms)
-- ARGV[2] = now (timestamp ms)
-- ARGV[3] = limit (e.g., 3)
-- ARGV[4] = ttl_seconds

-- Remove entries outside window
redis.call('ZREMRANGEBYSCORE', KEYS[1], '-inf', ARGV[1])
-- Count current entries
local count = redis.call('ZCARD', KEYS[1])
if count < tonumber(ARGV[3]) then
  -- Under limit — add this request
  redis.call('ZADD', KEYS[1], ARGV[2], ARGV[2])
  redis.call('EXPIRE', KEYS[1], tonumber(ARGV[4]))
  return {1, count + 1}  -- {allowed, new_count}
else
  return {0, count}  -- {denied, current_count}
end
```

**Month-End TTL Calculation:**
```python
from datetime import datetime, timezone
import calendar

def get_month_end_ttl() -> int:
    now = datetime.now(timezone.utc)
    _, last_day = calendar.monthrange(now.year, now.month)
    month_end = now.replace(day=last_day, hour=23, minute=59, second=59)
    return max(int((month_end - now).total_seconds()), 1)
```

**Middleware Route Matching:**
- Rate limiting applies ONLY to report generation endpoints
- Initially configure for `POST /api/v1/ideas` (Story 3.1 — not yet implemented, but middleware must be ready)
- Auth endpoints (`/auth/*`) are NOT rate-limited by this middleware (separate concern per deferred-work.md)
- Health endpoint (`/health`) is NEVER rate-limited

**Anonymous User Handling:**
- Anonymous users DO get Firebase UIDs + backend JWTs (established in Story 2.2)
- Track by `user_id` from JWT (same as signed-in users)
- Their JWT `auth_method` claim is `"anonymous"` — tier defaults to `"free"`
- Device fingerprint + IP tracking (from PRD) is NOT in the Story 2.4 acceptance criteria — user-ID-based tracking is sufficient since anonymous users have unique IDs

### Anti-Patterns — MUST FOLLOW

**Backend:**
1. ❌ DO NOT raise `HTTPException` directly — use `RateLimitExceededError` (VentureIQError subclass)
2. ❌ DO NOT use `print()` — use `logging.getLogger(__name__)`
3. ❌ DO NOT use raw dicts for responses — use Pydantic schemas + `success_response()`
4. ❌ DO NOT hardcode tier limits — use `Settings` from `config.py`
5. ❌ DO NOT use `aioredis` — use `redis.asyncio` (project standard)
6. ❌ DO NOT use `@app.on_event("startup")` — use lifespan pattern
7. ❌ DO NOT perform read-then-write in Python for Redis counters — use atomic Lua script
8. ❌ DO NOT store rate limit data in PostgreSQL — Redis db2 only
9. ❌ DO NOT modify existing `RequestIDMiddleware` or exception classes
10. ❌ DO NOT call real Redis in tests — mock with `DummyRedisManager` pattern

**Flutter:**
1. ❌ DO NOT use double quotes — `prefer_single_quotes` enforced
2. ❌ DO NOT forget trailing commas — `require_trailing_commas` enforced
3. ❌ DO NOT skip `const` constructors where applicable
4. ❌ DO NOT use `setState`/`ChangeNotifier` — use Riverpod `AsyncNotifier`
5. ❌ DO NOT use `print()` — use `debugPrint()`
6. ❌ DO NOT treat 429 as an auth error — AuthInterceptor must NOT retry 429 responses
7. ❌ DO NOT create non-freezed data classes — use `freezed` + `json_serializable`
8. ❌ DO NOT hardcode colors/spacing — use `AppColors`, `AppTypography`, `AppSpacing` tokens

### Previous Story Learnings (APPLY THESE)

- **SecretStr pitfall**: Always `.get_secret_value()` before passing secrets to libraries
- **Async timeout**: Add explicit timeouts to Redis calls (`asyncio.wait_for` or `redis.asyncio` timeout param)
- **Settings cache**: Use `get_settings.cache_clear()` in test fixtures when overriding config
- **Ruff compliance**: `ruff check app tests` — target zero issues (line-length=120, py313)
- **Dependency overrides**: Use `app.dependency_overrides[dep] = mock_dep` in tests
- **Non-atomic race condition**: Story 2-1 had a check-then-set bug — SOLVED by using Lua scripts for atomic Redis operations
- **Dio error swallowing**: Epic 1 retro found Dio silently swallowed errors — verify 429 propagates to Flutter error handling correctly
- **Widget overflows**: Use `Flexible`/`Expanded` for compact layouts in `usage_indicator.dart`
- **Epic 1 retro action item**: "Scaffold Redis db2 Sliding Window Helper" was explicitly assigned for Story 2-4

### Project Structure Notes

**New files to create:**
```
backend/app/
├── services/rate_limit_service.py          [NEW]
├── schemas/usage.py                         [NEW]
├── api/v1/endpoints/usage.py               [NEW]

backend/tests/
├── unit/test_rate_limit_service.py          [NEW]
├── unit/test_rate_limit_middleware.py       [NEW]
├── integration/test_usage_endpoint.py      [NEW]

mobile/lib/features/auth/
├── data/usage_repository.dart               [NEW]
├── domain/usage_entity.dart                 [NEW]
├── presentation/usage_notifier.dart         [NEW]
├── presentation/usage_providers.dart        [NEW]
├── presentation/widgets/usage_indicator.dart [NEW]
├── presentation/widgets/rate_limit_dialog.dart [NEW]

mobile/test/features/auth/presentation/widgets/
├── usage_indicator_test.dart                [NEW]
├── rate_limit_dialog_test.dart              [NEW]
```

**Files to modify:**
```
backend/app/core/middleware.py               [MODIFY] — Add RateLimitMiddleware
backend/app/core/config.py                   [MODIFY] — Add rate limit settings
backend/app/core/exceptions.py               [MODIFY] — Add details support to RateLimitExceededError (if needed)
backend/app/main.py                          [MODIFY] — Register RateLimitMiddleware
backend/app/api/v1/router.py                 [MODIFY] — Register usage router
mobile/lib/core/networking/api_endpoints.dart [MODIFY] — Add usageMe endpoint
mobile/lib/core/networking/auth_interceptor.dart [MODIFY] — Ensure 429 is NOT retried
mobile/lib/app_router.dart                   [MODIFY] — Add usage_indicator to Profile screen
```

### Downstream Dependencies (Who Uses What 2.4 Builds)

- **Story 3.1** (Epic 3): "Rate limiting middleware (from Story 2.4) is applied — free tier users blocked after 3 reports/month" — the `POST /api/v1/ideas` endpoint will be wrapped by rate limit middleware
- **Story 15.2** (Epic 15): "Profile screen shows reports generated this month with progress bar" — will reuse `usage_indicator.dart` and `usageNotifierProvider`

### Scope Boundaries

- ✅ **IN SCOPE**: Server-side rate limit enforcement, Redis sliding window, usage API, Flutter usage widget, upgrade prompt UI
- ❌ **OUT OF SCOPE**: In-app purchases (deferred post-V1 per FR39), Stripe/payment integration, device fingerprint + IP multi-dimension enforcement (acceptance criteria use user-ID only), rate limiting on auth endpoints (deferred per deferred-work.md)
- ⚠️ **NOTE**: Pro tier upgrade is currently server-side only (manual DB update or admin API). IAP receipt validation is explicitly deferred to post-V1.

### References

- [Source: epics.md#L514-L533 — Story 2.4 definition](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/epics.md#L514-L533)
- [Source: architecture.md#L265-L268 — Redis db2 rate limiting, sliding window](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/architecture.md#L265-L268)
- [Source: architecture.md#L85 — Multi-tier rate limiting](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/architecture.md#L85)
- [Source: architecture.md#L701 — Middleware file](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/architecture.md#L701)
- [Source: architecture.md#L993 — Rate limiting backend + Flutter mapping](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/architecture.md#L993)
- [Source: prd.md#L404-L411 — Rate limiting table (4 tiers)](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/prd.md#L404-L411)
- [Source: prd.md#L426 — RATE_LIMIT_EXCEEDED error code](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/prd.md#L426)
- [Source: prd.md#L616 — FR39 tier-based usage limits](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/prd.md#L616)
- [Source: ux-design-specification.md#L1457-L1461 — Warning state for approaching rate limits](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/ux-design-specification.md#L1457-L1461)
- [Source: 2-1 story — JWT tier claim, get_current_user(), anti-patterns](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/implementation-artifacts/2-1-firebase-authentication-jwt-exchange-backend.md)
- [Source: 2-2 story — AuthUser.tier, AuthInterceptor, Flutter patterns](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/implementation-artifacts/2-2-anonymous-google-sign-in-flutter.md)
- [Source: 2-3 story — Exception adding pattern, endpoint pattern](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/implementation-artifacts/2-3-anonymous-to-authenticated-upgrade-data-retention.md)
- [Source: epic-1-retro — Redis db2 sliding window helper action item](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/implementation-artifacts/epic-1-retro-2026-05-20.md)
- [Source: deferred-work.md — String tiers, missing auth rate limiting](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/implementation-artifacts/deferred-work.md)
- [Source: project-context.md](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/project-context.md)

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List
