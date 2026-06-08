## Deferred from: code review (2026-05-18) of 1-5-flutter-app-shell-with-navigation-theme-foundation.md
- [Review][Defer] Missing landscape responsive handling [mobile/lib/core/utils/responsive.dart:88] — deferred, pre-existing
- [Review][Defer] Missing global error interceptor [mobile/lib/core/networking/dio_client.dart] — deferred, pre-existing

## Deferred from: code review (2026-05-22) of 2-1-firebase-authentication-jwt-exchange-backend.md
- [Review][Defer] Weak Token Theft Response Policy [backend/app/services/auth_service.py:115] — deferred, pre-existing
- [Review][Defer] Hardcoded String subscription Tiers [backend/app/models/user.py:21] — deferred, pre-existing
- [Review][Defer] Premature DB Commits in Low-Level Helpers [backend/app/services/auth_service.py:43] — deferred, pre-existing
- [Review][Defer] No Validation of User Status in get_current_user [backend/app/core/dependencies.py:60] — deferred, pre-existing

## Deferred from: code review of 2-2-anonymous-google-sign-in-flutter (2026-05-24)
- Race Condition in Backend Token Refresh [backend/app/services/auth_service.py]
- Database Concurrency Failure in get_or_create_user [backend/app/services/auth_service.py]
- Swallowed Firebase Initialization Errors [backend/main.py]
- Swagger UI Auth is Broken [backend/app/api/v1/endpoints/auth.py]
- No Server-Side Token Revocation [backend]
- Missing Rate Limiting on Token Exchange [backend/app/api/v1/endpoints/auth.py]
## Deferred from: code review (2026-05-18) of 1-5-flutter-app-shell-with-navigation-theme-foundation.md
- [Review][Defer] Missing landscape responsive handling [mobile/lib/core/utils/responsive.dart:88] — deferred, pre-existing
- [Review][Defer] Missing global error interceptor [mobile/lib/core/networking/dio_client.dart] — deferred, pre-existing

## Deferred from: code review (2026-05-22) of 2-1-firebase-authentication-jwt-exchange-backend.md
- [Review][Defer] Weak Token Theft Response Policy [backend/app/services/auth_service.py:115] — deferred, pre-existing
- [Review][Defer] Hardcoded String subscription Tiers [backend/app/models/user.py:21] — deferred, pre-existing
- [Review][Defer] Premature DB Commits in Low-Level Helpers [backend/app/services/auth_service.py:43] — deferred, pre-existing
- [Review][Defer] No Validation of User Status in get_current_user [backend/app/core/dependencies.py:60] — deferred, pre-existing

## Deferred from: code review of 2-2-anonymous-google-sign-in-flutter (2026-05-24)
- Race Condition in Backend Token Refresh [backend/app/services/auth_service.py]
- Database Concurrency Failure in get_or_create_user [backend/app/services/auth_service.py]
- Swallowed Firebase Initialization Errors [backend/main.py]
- Swagger UI Auth is Broken [backend/app/api/v1/endpoints/auth.py]
- No Server-Side Token Revocation [backend]
- Missing Rate Limiting on Token Exchange [backend/app/api/v1/endpoints/auth.py]
- Data Loss on Google Sign-In [mobile/lib/features/auth/data/auth_repository.dart] (Story 2.3 Account Upgrade)

## Deferred from: code review of 2-3-anonymous-to-authenticated-upgrade-data-retention (2026-05-26)
- No Concurrency Protection on Upgrade [backend/app/services/auth_service.py]
- Synchronous Firebase SDK Call in Thread Pool Bottleneck [backend/app/services/auth_service.py]
- Silently Swallowed Google Sign-Out Errors [mobile/lib/features/auth/data/auth_repository.dart]
- Distributed State Inconsistency Dual-Write Hazard [mobile/lib/features/auth/data/auth_repository.dart:763-814]

## Deferred from: code review of 2-4-tier-based-usage-limits-rate-limiting.md (2026-06-05)
- State Desync Between JWT and DB — Middleware uses JWT tier, but /usage/me uses DB tier. If a user upgrades to Pro, the UI will show they have unlimited reports, but the backend will still block their requests until they log out and log back in. (Pro upgrade flow is deferred post-V1, so handling token refresh on upgrade is also deferred)

## Deferred from: code review of 3-1-idea-submission-endpoint-input-sanitization-backend (2026-06-07)
- Integration tests mock database session: test_ideas_endpoint.py uses FakeIdeaSession instead of a real database, failing to test DB constraints. Deferred as it may be a pre-existing test pattern.

## Deferred from: code review of 3-2-plausibility-check-via-llm.md (2026-06-08)
- Synchronous LLM Bottleneck (inline generation ties up workers)
