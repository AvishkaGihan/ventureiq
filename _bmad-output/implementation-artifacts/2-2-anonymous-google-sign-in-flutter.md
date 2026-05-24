# Story 2.2: Anonymous & Google Sign-In (Flutter)

Status: done

## Story

As a **user**,
I want to use VentureIQ immediately without signing in, or sign in with my Google account,
so that I can start validating ideas instantly and optionally persist my data across devices.

## Acceptance Criteria (BDD)

**Given** the Flutter app shell from Epic 1
**When** authentication flows are implemented

1. **Then** `features/auth/data/auth_repository.dart` implements Firebase Anonymous sign-in and Google Sign-In
2. **And** `features/auth/data/auth_remote_data_source.dart` handles the backend JWT exchange (`POST /api/v1/auth/exchange`) after Firebase auth
3. **And** `features/auth/presentation/auth_notifier.dart` (Riverpod `AsyncNotifier`) manages auth state: `unauthenticated`, `anonymous`, `authenticated`
4. **And** on first app launch, Firebase Anonymous sign-in triggers automatically and the backend JWT is obtained transparently
5. **And** users can tap "Sign in with Google" from the Profile tab to upgrade to Google auth (FR36)
6. **And** the Dio interceptor in `core/networking/dio_client.dart` automatically attaches the JWT `Authorization: Bearer` header to all API requests
7. **And** the Dio interceptor automatically attempts token refresh on `401` responses using the stored refresh token
8. **And** auth tokens are stored securely using `flutter_secure_storage`
9. **And** anonymous users can use the app to generate and view reports on-device (FR37)
10. **And** widget tests verify auth state transitions and Google sign-in flow

## Tasks / Subtasks

- [x] Task 1: Add Firebase & Auth dependencies to `pubspec.yaml` (AC: #1, #2, #8)
  - [x] 1.1 Add `firebase_core: ^4.9.0`, `firebase_auth: ^6.5.1` to dependencies
  - [x] 1.2 Add `google_sign_in: ^7.2.0` to dependencies
  - [x] 1.3 Add `flutter_secure_storage: ^10.2.0` to dependencies
  - [x] 1.4 Add `freezed_annotation`, `json_annotation` to dependencies
  - [x] 1.5 Add `freezed`, `json_serializable`, `build_runner` to dev_dependencies
  - [x] 1.6 Run `flutter pub get` to resolve

- [x] Task 2: Initialize Firebase in `main.dart` (AC: #4)
  - [x] 2.1 Add `WidgetsFlutterBinding.ensureInitialized()` before `runApp`
  - [x] 2.2 Add `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` before `runApp`
  - [x] 2.3 Run `flutterfire configure` to generate `firebase_options.dart` (or create manually from Firebase Console config)
  - [x] 2.4 Initialize `GoogleSignIn.instance` (v7.x singleton pattern)

- [x] Task 3: Create auth data layer (AC: #1, #2)
  - [x] 3.1 Create `features/auth/data/auth_remote_data_source.dart` — calls `POST /api/v1/auth/exchange` and `POST /api/v1/auth/refresh` via DioClient
  - [x] 3.2 Create `features/auth/domain/auth_entity.dart` — freezed `AuthUser` entity with `id`, `email`, `displayName`, `tier`, `authMethod`, `isAnonymous`
  - [x] 3.3 Create `features/auth/domain/auth_state.dart` — freezed `AuthState` sealed class: `unauthenticated`, `anonymous(AuthUser)`, `authenticated(AuthUser)`
  - [x] 3.4 Create `features/auth/data/auth_repository.dart` — implements `signInAnonymously()`, `signInWithGoogle()`, `signOut()`, `exchangeToken()`, `refreshToken()`

- [x] Task 4: Create secure token storage (AC: #8)
  - [x] 4.1 Create `features/auth/data/token_storage.dart` — wraps `FlutterSecureStorage` for `accessToken`, `refreshToken` read/write/delete
  - [x] 4.2 Use `AndroidOptions()` default (RSA OAEP + AES-GCM) — NOT deprecated `encryptedSharedPreferences`
  - [x] 4.3 Use `IOSOptions(accessibility: KeychainAccessibility.first_unlock)` for iOS

- [x] Task 5: Create auth presentation layer (AC: #3, #4, #5)
  - [x] 5.1 Create `features/auth/presentation/auth_notifier.dart` — Riverpod `AsyncNotifier<AuthState>` managing `unauthenticated → anonymous → authenticated` transitions
  - [x] 5.2 Create `features/auth/presentation/auth_providers.dart` — `authNotifierProvider`, `authRepositoryProvider`, `tokenStorageProvider`, `authRemoteDataSourceProvider`
  - [x] 5.3 `build()` method: check secure storage for cached tokens → validate → set initial state
  - [x] 5.4 `signInAnonymously()`: Firebase anonymous auth → exchange token with backend → store JWT pair → transition to `anonymous` state
  - [x] 5.5 `signInWithGoogle()`: GoogleSignIn.instance.authenticate() → Firebase signInWithCredential → exchange token → store JWT pair → transition to `authenticated` state
  - [x] 5.6 `signOut()`: clear tokens, sign out Firebase, transition to `unauthenticated`

- [x] Task 6: Extend Dio interceptor for JWT auth (AC: #6, #7)
  - [x] 6.1 Create `core/networking/auth_interceptor.dart` — Dio `Interceptor` subclass
  - [x] 6.2 `onRequest`: read access token from `TokenStorage` → attach `Authorization: Bearer {token}` header
  - [x] 6.3 `onError` (401 handling): attempt token refresh via `POST /api/v1/auth/refresh` → store new tokens → retry original request with `handler.resolve()`
  - [x] 6.4 On refresh failure: clear tokens → signal auth state to `unauthenticated` → reject with `handler.next()`
  - [x] 6.5 Add `AuthInterceptor` to DioClient interceptor chain (after JSON interceptor, before logging)
  - [x] 6.6 Add `authRefresh` endpoint to `ApiEndpoints`: `'$basePath/auth/refresh'`

- [x] Task 7: Integrate auth state with router (AC: #4, #9)
  - [x] 7.1 Update `routerProvider` to depend on `authNotifierProvider` for state-aware redirects
  - [x] 7.2 On `unauthenticated` state: trigger auto-anonymous sign-in (first launch flow)
  - [x] 7.3 Add `/auth` route to GoRouter (for future explicit auth screen if needed)
  - [x] 7.4 Current Profile tab placeholder should show "Sign in with Google" button for anonymous users

- [x] Task 8: Write widget and unit tests (AC: #10)
  - [x] 8.1 `test/features/auth/data/auth_repository_test.dart` — mock FirebaseAuth + GoogleSignIn, verify anonymous/Google flows
  - [x] 8.2 `test/features/auth/data/auth_remote_data_source_test.dart` — mock Dio, verify exchange/refresh API calls
  - [x] 8.3 `test/features/auth/presentation/auth_notifier_test.dart` — verify state transitions: unauthenticated → anonymous → authenticated
  - [x] 8.4 `test/core/networking/auth_interceptor_test.dart` — verify header attachment, 401 refresh, refresh failure
  - [x] 8.5 Mock Firebase Auth — NEVER call real Firebase in tests
  - [x] 8.6 Run `dart analyze` — zero issues
  - [x] 8.7 Run `flutter test` — all pass

## Dev Notes

### Critical Architecture Compliance

**Feature Structure — `data/domain/presentation` Triad**: Every feature MUST follow this pattern. No exceptions. Auth files go in `mobile/lib/features/auth/`.

**State Management — Riverpod AsyncNotifier**: Use `AsyncNotifier<AuthState>` pattern with `AsyncValue<T>` (loading/data/error). Provider naming: `authNotifierProvider`, `authRepositoryProvider`. Notifier class: `AuthNotifier extends AsyncNotifier<AuthState>`.

**Data Models — freezed**: ALL Dart data classes MUST use `freezed` + `json_serializable`. Never manually implement `==`, `hashCode`, `copyWith`. Run `dart run build_runner build --delete-conflicting-outputs` after creating/modifying freezed classes.

**google_sign_in v7.x BREAKING CHANGES**: Version 7.0.0+ introduced critical changes:
- **Singleton pattern**: Use `GoogleSignIn.instance` — NOT `GoogleSignIn()` constructor
- **Mandatory initialization**: Call `await GoogleSignIn.instance.initialize()` at startup
- **Method rename**: `authenticate()` replaces `signIn()`
- **DO NOT** use old `GoogleSignIn().signIn()` pattern — it will NOT work

**flutter_secure_storage v10.x BREAKING CHANGES**: Version 10.0.0+ changes:
- `encryptedSharedPreferences` is **DEPRECATED** — do NOT use it
- Default ciphers: RSA OAEP (key) + AES-GCM (storage) — use new defaults
- Minimum Android SDK: **23** (Android 6.0+)
- `ResetOnError` defaults to `true` (unrecoverable key errors auto-reset)
- Minimum iOS: **12**, minimum macOS: **10.14**

**Firebase Auth v6.5.1**: Latest stable (Firebase BoM v4.14.0). Use `FirebaseAuth.instance.signInAnonymously()` and `signInWithCredential(credential)`.

### Backend API Contract — MUST Match Exactly

**Token Exchange — `POST /api/v1/auth/exchange`**:
```json
// Request
{ "firebase_token": "<firebase_id_token>" }

// Success Response (wrapped in envelope)
{
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "token_type": "bearer",
    "expires_in": 3600
  },
  "meta": { "request_id": "uuid" }
}

// Error Response
{
  "error": { "code": "AUTH_PROVIDER_TOKEN_INVALID", "message": "...", "details": {...} },
  "meta": { "request_id": "uuid" }
}
```

**Token Refresh — `POST /api/v1/auth/refresh`**:
```json
// Request
{ "refresh_token": "<backend_refresh_token>" }

// Response — same envelope as exchange
```

**Error Codes**: `AUTH_REQUIRED` (no token), `AUTH_INVALID_TOKEN` (expired/invalid JWT), `AUTH_PROVIDER_TOKEN_INVALID` (Firebase token invalid).

Use the existing `ApiResponseParser.parse()` from `core/networking/api_response.dart` to unwrap envelopes.

### Existing Codebase — MUST Reuse

**DioClient** ([dio_client.dart](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/mobile/lib/core/networking/dio_client.dart)): Singleton with interceptor chain. Add `AuthInterceptor` to `_init()` method. Do NOT create a separate Dio instance for auth.

**ApiEndpoints** ([api_endpoints.dart](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/mobile/lib/core/networking/api_endpoints.dart)): Already has `authExchange`. Add `authRefresh = '$basePath/auth/refresh'`.

**ApiResponseParser** ([api_response.dart](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/mobile/lib/core/networking/api_response.dart)): Use `ApiResponseParser.parse<T>(json, fromJson)` for all API responses. Throws `ApiError` on error envelope.

**GoRouter** ([app_router.dart](file:///c:/Users/avish/OneDrive/Documents/Projects/ventureiq/mobile/lib/app_router.dart)): Uses `routerProvider` (Riverpod). Currently starts at `/home`. The `routerProvider` must be updated to depend on auth state. The Profile tab placeholder needs a Google Sign-In button.

**Design Tokens**: Use `AppColors`, `AppTypography`, `AppSpacing` from `core/theme/`. Dark premium theme. Electric Violet `#6C5CE7` for primary CTAs. `surface-000` (#09090B) for backgrounds. 48dp minimum touch targets.

**Error Handling**: Use `ErrorCard` widget from `core/widgets/error_card.dart` for error states. Always show: what happened + what to do next.

**Dart Analysis**: Strict rules in `analysis_options.yaml`. `prefer_single_quotes`, `require_trailing_commas`, `prefer_const_constructors`. Excludes `*.g.dart`, `*.freezed.dart`.

### Auth Flow — Step by Step

```
App Launch
  ├─→ Check flutter_secure_storage for cached access_token
  │     ├─→ Token found & valid → Set state: anonymous or authenticated (based on claims)
  │     ├─→ Token found & expired → Attempt refresh via POST /api/v1/auth/refresh
  │     │     ├─→ Refresh success → Store new tokens → Set auth state
  │     │     └─→ Refresh failure → Clear tokens → signInAnonymously()
  │     └─→ No token → signInAnonymously()
  │
  └─→ signInAnonymously()
        ├─→ FirebaseAuth.instance.signInAnonymously()
        ├─→ Get Firebase ID token: user.getIdToken()
        ├─→ POST /api/v1/auth/exchange { firebase_token: idToken }
        ├─→ Store { access_token, refresh_token } in flutter_secure_storage
        └─→ Set state: AuthState.anonymous(AuthUser(...))

Google Sign-In (from Profile tab)
  ├─→ GoogleSignIn.instance.authenticate()
  ├─→ Get GoogleSignInAuthentication (accessToken, idToken)
  ├─→ GoogleAuthProvider.credential(accessToken, idToken)
  ├─→ FirebaseAuth.instance.signInWithCredential(credential)
  ├─→ Get Firebase ID token: user.getIdToken()
  ├─→ POST /api/v1/auth/exchange { firebase_token: idToken }
  ├─→ Store new { access_token, refresh_token }
  └─→ Set state: AuthState.authenticated(AuthUser(...))
```

### Dio AuthInterceptor — Token Refresh Logic

```
onRequest(options, handler)
  ├─→ Read access_token from TokenStorage
  ├─→ If token exists → options.headers['Authorization'] = 'Bearer $token'
  └─→ handler.next(options)

onError(error, handler)
  ├─→ If error.response?.statusCode != 401 → handler.next(error)
  ├─→ If already retrying (flag) → handler.next(error) (prevent infinite loop)
  ├─→ Read refresh_token from TokenStorage
  ├─→ POST /api/v1/auth/refresh { refresh_token }
  │     ├─→ Success → Store new tokens → Retry original request → handler.resolve(response)
  │     └─→ Failure → Clear tokens → Signal unauthenticated → handler.next(error)
  └─→ Set retry flag to prevent re-entrance
```

**CRITICAL**: The refresh call must use a SEPARATE Dio instance (or raw HTTP) that does NOT have the AuthInterceptor to avoid infinite recursion.

### Forward Compatibility — Design for Stories 2.3 and 2.4

**Story 2.3 (Account Upgrade)**: The auth_repository must support `linkWithCredential` for upgrading anonymous → authenticated. Design `AuthNotifier` so the `anonymous → authenticated` transition preserves state cleanly. TokenStorage must support overwriting tokens during upgrade.

**Story 2.4 (Rate Limiting)**: The JWT `access_token` contains `tier` claim. `AuthUser` entity must expose `tier`. The `AuthNotifier` must make tier accessible to UI consumers (for `usage_indicator.dart` widget in Profile tab).

**Story 15.1 (Splash Screen)**: "Get Started" button will trigger anonymous auth. The `signInAnonymously()` method must be callable from outside the notifier init.

**Story 15.2 (Profile Screen)**: Shows "Anonymous User" or Google details + "Sign in with Google" CTA for anonymous users. The minimal Profile tab update in this story sets the foundation.

### Anti-Patterns to Avoid

1. **DO NOT** use `GoogleSignIn()` constructor — v7.x uses `GoogleSignIn.instance` singleton
2. **DO NOT** use `signIn()` method — v7.x renamed it to `authenticate()`
3. **DO NOT** use `encryptedSharedPreferences` in flutter_secure_storage — it's deprecated in v10.x
4. **DO NOT** create a new Dio instance for API calls — reuse `DioClient.instance`
5. **DO NOT** use the AuthInterceptor's Dio instance for refresh calls — creates infinite loop
6. **DO NOT** manually implement `==`/`hashCode`/`copyWith` — use freezed
7. **DO NOT** use double quotes in Dart — `prefer_single_quotes` lint rule enforced
8. **DO NOT** forget trailing commas — `require_trailing_commas` lint rule enforced
9. **DO NOT** use `print()` — use `debugPrint()` in debug mode only
10. **DO NOT** call real Firebase in tests — always mock `FirebaseAuth.instance`
11. **DO NOT** store tokens in Hive — use `flutter_secure_storage` for sensitive data (Hive is for report cache only)
12. **DO NOT** skip `const` constructors — `prefer_const_constructors` is enforced
13. **DO NOT** create global mutable state — use feature-scoped Riverpod providers
14. **DO NOT** use `setState` or `ChangeNotifier` — use Riverpod `AsyncNotifier` pattern exclusively

### Project Structure Notes

Files to CREATE:
```
mobile/lib/features/auth/
├── data/
│   ├── auth_repository.dart           # Firebase + backend auth implementation
│   ├── auth_remote_data_source.dart    # Backend API calls (exchange, refresh)
│   └── token_storage.dart             # flutter_secure_storage wrapper
├── domain/
│   ├── auth_entity.dart               # freezed AuthUser entity
│   └── auth_state.dart                # freezed AuthState sealed class
└── presentation/
    ├── auth_notifier.dart             # Riverpod AsyncNotifier<AuthState>
    └── auth_providers.dart            # All auth-related providers

mobile/lib/core/networking/
└── auth_interceptor.dart              # Dio interceptor for JWT + refresh

mobile/test/features/auth/
├── data/
│   ├── auth_repository_test.dart
│   └── auth_remote_data_source_test.dart
└── presentation/
    └── auth_notifier_test.dart

mobile/test/core/networking/
└── auth_interceptor_test.dart
```

Files to MODIFY:
```
mobile/pubspec.yaml                    # Add firebase_core, firebase_auth, google_sign_in, flutter_secure_storage, freezed deps
mobile/lib/main.dart                   # Firebase.initializeApp + GoogleSignIn.instance.initialize
mobile/lib/core/networking/dio_client.dart     # Add AuthInterceptor to chain
mobile/lib/core/networking/api_endpoints.dart  # Add authRefresh endpoint
mobile/lib/app_router.dart             # Auth-state-aware redirects
```

Files to NOT touch:
```
mobile/lib/core/theme/*                # No theme changes needed
mobile/lib/core/widgets/*              # Reuse existing widgets as-is
mobile/lib/core/constants/enums.dart   # No new enums for auth
mobile/lib/core/networking/api_response.dart  # Already has correct envelope parser
mobile/lib/core/utils/responsive.dart  # No changes needed
mobile/analysis_options.yaml           # Already excludes *.g.dart, *.freezed.dart
```

### Previous Story Learnings (Story 2.1)

1. **Endpoint is `/auth/exchange` — NOT `/auth/token`**: The backend uses `POST /api/v1/auth/exchange`. The Flutter client MUST match.
2. **JWT uses `sub` claim for user ID**: The backend JWT puts user_id in the `sub` claim (standard JWT claim), not a custom `user_id` claim.
3. **Response envelope is mandatory**: ALL backend responses are wrapped in `{ "data": {...}, "meta": {...} }`. Use `ApiResponseParser`.
4. **Refresh token is single-use**: Each refresh token can only be used once. After refresh, the OLD token is invalidated. Store the NEW pair immediately.
5. **Firebase token verification includes revocation check**: The backend calls `verify_id_token(token, check_revoked=True)`. Ensure you send fresh Firebase ID tokens.
6. **Backend JWT expiry**: Access token = 60 minutes (configured in backend `JWT_ACCESS_TOKEN_EXPIRE_MINUTES`), Refresh token = 7 days.
7. **Token type is always "bearer"**: Response includes `token_type: "bearer"`. Use this in the `Authorization` header.

### Epic 1 Retrospective Learnings

1. **Dio error swallowing**: An early Dio interceptor swallowed 4xx error codes (fixed in Story 1.5). Ensure the AuthInterceptor correctly propagates non-401 errors.
2. **Mock cleanup**: Standardize mock patterns to prevent leakage between tests. Use `setUp`/`tearDown` consistently.
3. **Auth State Mock Helper**: Epic 1 retro action item — create a standardized mock utility to simulate authenticated/anonymous states in widget tests. Implement this as a test helper.
4. **Firebase Sandbox**: Firebase console must be configured with iOS/Android client config files before testing real auth flows. Tests MUST mock Firebase.

### Git Intelligence

Most recent commit (8af1d89): Story 2.1 implementation added:
- `backend/app/core/security.py` — JWT + Firebase verification
- `backend/app/services/auth_service.py` — exchange/refresh business logic
- `backend/app/api/v1/endpoints/auth.py` — `/exchange` and `/refresh` routes
- `backend/app/schemas/auth.py` — `TokenExchangeRequestSchema`, `TokenRefreshRequestSchema`, `TokenResponseSchema`
- `backend/app/models/user.py` — `UserModel` with `firebase_uid`, `email`, `display_name`, `tier`, `auth_provider`

The backend is ready and tested. This story implements the Flutter client that consumes these endpoints.

### Latest Technical Information

| Package | Latest Version | Key Notes |
|---|---|---|
| `firebase_core` | ^4.9.0 | Firebase BoM v4.14.0 |
| `firebase_auth` | ^6.5.1 | Requires `firebase_core`, Python 3.10+ on backend |
| `google_sign_in` | ^7.2.0 | **Singleton pattern**, `authenticate()` method |
| `flutter_secure_storage` | ^10.2.0 | RSA OAEP + AES-GCM, min Android SDK 23 |
| `freezed` | latest | Code gen for immutable data classes |
| `json_serializable` | latest | JSON serialization code gen |
| `build_runner` | latest | Code generation runner |

### UX Design Notes

The UX spec does NOT include auth-specific screen designs. Auth is designed as **zero-friction anonymous-first**:
- **Anonymous users get 3 free reports without account creation**
- **No signup walls, no mandatory fields**
- **First action is typing an idea, not creating an account**
- **Auth is deferred until needed (export/share)**

For Story 2.2, implement auth transparently — auto-anonymous on launch, Google sign-in only from Profile tab. Use existing design tokens for any auth UI elements:
- Primary CTA: Electric Violet `#6C5CE7`, 48dp height, 8dp radius
- Button loading: replace label with 20dp `CircularProgressIndicator`
- Error feedback: SnackBar with `surface-100` bg, accent-colored left border, 4s auto-dismiss
- Text: `text-primary` (#F0F1F5) for headings, `text-secondary` (#A1A7BE) for descriptions

### References

- [Source: _bmad-output/planning-artifacts/epics.md — Epic 2 §2.2, Lines 474-493]
- [Source: _bmad-output/planning-artifacts/architecture.md — §Flutter Auth Flow (L586-596), §Feature Structure (L801-811), §Riverpod Patterns (L541-551)]
- [Source: _bmad-output/planning-artifacts/architecture.md — §JWT Architecture (L273-278), §File Naming (L368-381), §Error Handling (L562-574)]
- [Source: _bmad-output/planning-artifacts/architecture.md — §Code Generation (L157-158), §API Response Envelope (L462-488)]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md — §Zero-friction start (L77, L773, L907), §Design Tokens (L346-380)]
- [Source: _bmad-output/planning-artifacts/prd.md — FR36, FR37, FR38, FR39, NFR16, NFR17, NFR41]
- [Source: _bmad-output/implementation-artifacts/2-1-firebase-authentication-jwt-exchange-backend.md — Backend API contract, JWT claims, review findings]
- [Source: _bmad-output/implementation-artifacts/epic-1-retro-2026-05-20.md — Action items: Auth State Mock Helper, Firebase Sandbox]
- [Source: mobile/lib/core/networking/dio_client.dart — Existing DioClient singleton pattern]
- [Source: mobile/lib/core/networking/api_endpoints.dart — Existing authExchange endpoint]
- [Source: mobile/lib/core/networking/api_response.dart — ApiResponseParser envelope handling]
- [Source: mobile/lib/app_router.dart — GoRouter configuration with routerProvider]
- [Source: mobile/pubspec.yaml — Current dependencies (no Firebase yet)]
- [Source: backend/app/schemas/auth.py — TokenResponseSchema fields: access_token, refresh_token, token_type, expires_in]

## Dev Agent Record

### Agent Model Used

Antigravity (Google DeepMind)

### Debug Log References

- Conversation: `a25915b4-4560-4603-91f2-e96134a186ef`
- Transcript: `C:\Users\avish\.gemini\antigravity\brain\a25915b4-4560-4603-91f2-e96134a186ef\.system_generated\logs\transcript.jsonl`

### Completion Notes List

1. **GoogleSignIn v7.x API correction**: `authenticate()` returns non-nullable `GoogleSignInAccount`. The `.authentication` property is a sync getter (not a Future). Only `idToken` is available for auth; `accessToken` requires separate authorization scope request via `authorizationClient`.
2. **firebase_options.dart**: Created as a stub with placeholder values. Must be regenerated via `flutterfire configure --project=<project-id>` before running the app.
3. **AuthInterceptor uses separate plain Dio**: Refresh calls use a plain Dio instance (no interceptors) to prevent infinite recursion on 401.
4. **Auto-anonymous sign-in**: Triggered via `routerProvider` watching `authNotifierProvider` — when state is `unauthenticated`, schedules anonymous sign-in via `Future.microtask()` to avoid build-phase mutations.
5. **Profile tab as auth entry point**: Anonymous users see "Sign in with Google" CTA with Electric Violet button. Authenticated users see name/email and sign-out button.
6. **DioClient injection pattern**: Added `addAuthInterceptor()` method for runtime interceptor injection rather than requiring interceptor at construction time (avoids circular dependency with providers).
7. **Test results**: `dart analyze` — 0 issues. `flutter test` — 227 passed, 0 failures (27 new auth tests + 200 existing).
8. **json_annotation version warning**: `build_runner` emits a warning about json_annotation constraint `^4.9.0` allowing versions before 4.12.0. Non-blocking; code generates correctly.

### File List

**Created:**
- `mobile/lib/features/auth/domain/auth_entity.dart`
- `mobile/lib/features/auth/domain/auth_entity.freezed.dart` (generated)
- `mobile/lib/features/auth/domain/auth_entity.g.dart` (generated)
- `mobile/lib/features/auth/domain/auth_state.dart`
- `mobile/lib/features/auth/domain/auth_state.freezed.dart` (generated)
- `mobile/lib/features/auth/data/token_storage.dart`
- `mobile/lib/features/auth/data/auth_remote_data_source.dart`
- `mobile/lib/features/auth/data/auth_repository.dart`
- `mobile/lib/features/auth/presentation/auth_notifier.dart`
- `mobile/lib/features/auth/presentation/auth_providers.dart`
- `mobile/lib/core/networking/auth_interceptor.dart`
- `mobile/lib/firebase_options.dart` (stub — must regenerate)
- `mobile/test/features/auth/data/auth_remote_data_source_test.dart`
- `mobile/test/features/auth/data/auth_repository_test.dart`
- `mobile/test/features/auth/presentation/auth_notifier_test.dart`
- `mobile/test/core/networking/auth_interceptor_test.dart`

**Modified:**
- `mobile/pubspec.yaml` — added auth dependencies
- `mobile/lib/main.dart` — Firebase/GoogleSignIn init, AuthInterceptor wiring
- `mobile/lib/core/networking/api_endpoints.dart` — added `authRefresh`
- `mobile/lib/core/networking/dio_client.dart` — added `addAuthInterceptor()`
- `mobile/lib/app_router.dart` — auth-state-aware routing, Profile screen with Google Sign-In
- `mobile/test/app_router_test.dart` — updated Profile tab test for auth-dependent screen
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — story status
### Review Findings
- [x] [Review][Decision] Infinite Loop / No True "Signed Out" State — `app_router.dart` triggers `signInAnonymously()` on `unauthenticated`. Signing out forces a sign-in, creating flickers and infinite loops if auth fails.
- [x] [Review][Patch] Android Emulator Networking Broken [`mobile/lib/core/networking/api_endpoints.dart`]
- [x] [Review][Patch] Auth Interceptor Drops Concurrent Requests [`mobile/lib/core/networking/auth_interceptor.dart`]
- [x] [Review][Patch] Auth Interceptor Drops on Transient Network Failure [`mobile/lib/core/networking/auth_interceptor.dart`]
- [x] [Review][Patch] Risky Concurrent Secure Storage Writes [`mobile/lib/features/auth/data/token_storage.dart`]
- [x] [Review][Patch] Google Sign-In Cancellation Crash [`mobile/lib/features/auth/data/auth_repository.dart`]
- [x] [Review][Patch] Google Session Persists on Sign Out [`mobile/lib/features/auth/data/auth_repository.dart`]
- [x] [Review][Patch] Missing implementation of auth state signaling on refresh failure [`mobile/lib/main.dart`]
- [x] [Review][Patch] Missing widget tests for Google sign-in flow [`mobile/test/features/auth/presentation/`]
- [x] [Review][Defer] Race Condition in Backend Token Refresh [`backend/app/services/auth_service.py`] — deferred, pre-existing
- [x] [Review][Defer] Database Concurrency Failure in get_or_create_user [`backend/app/services/auth_service.py`] — deferred, pre-existing
- [x] [Review][Defer] Swallowed Firebase Initialization Errors [`backend/main.py`] — deferred, pre-existing
- [x] [Review][Defer] Swagger UI Auth is Broken [`backend/app/api/v1/endpoints/auth.py`] — deferred, pre-existing
- [x] [Review][Defer] No Server-Side Token Revocation [`backend`] — deferred, pre-existing
- [x] [Review][Defer] Missing Rate Limiting on Token Exchange [`backend/app/api/v1/endpoints/auth.py`] — deferred, pre-existing
- [x] [Review][Defer] Data Loss on Google Sign-In [`mobile/lib/features/auth/data/auth_repository.dart`] — deferred to Story 2.3
