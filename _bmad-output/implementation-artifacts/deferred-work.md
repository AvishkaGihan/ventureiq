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
