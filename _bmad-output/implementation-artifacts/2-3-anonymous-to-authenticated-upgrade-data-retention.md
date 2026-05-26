# Story 2.3: Anonymous-to-Authenticated Upgrade & Data Retention

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an **anonymous user**,
I want to upgrade to a signed-in Google account and keep all my existing reports and data,
So that I don't lose my work when I decide to create a permanent account.

## Acceptance Criteria (BDD)

**Given** a user is using the app anonymously with existing local data
**When** the user taps "Sign in with Google" and completes Google OAuth

1. **Then** Firebase `linkWithCredential` links the anonymous UID to the Google credential (FR38)
2. **And** `POST /api/v1/auth/upgrade` notifies the backend to migrate any server-side data from the anonymous user ID to the authenticated user ID
3. **And** a new backend JWT is issued with `auth_method: "google"` and updated claims
4. **And** all locally cached reports (Hive) are re-tagged with the authenticated user ID
5. **And** the user sees a success toast: "Account created! Your data has been preserved."
6. **And** if the Google account is already linked to another VentureIQ account, an error is shown: "This Google account is already in use"
7. **And** the upgrade is atomic — if any step fails, the user remains anonymous with their data intact
8. **And** unit tests verify the upgrade flow including error cases

## Tasks / Subtasks

### Backend

- [x] Task 1: Create `POST /api/v1/auth/upgrade` endpoint (AC: #2, #3)
  - [x] 1.1: Add `UpgradeRequestSchema` to `backend/app/schemas/auth.py` — field: `firebase_token: str`
  - [x] 1.2: Add `upgrade_account()` to `backend/app/services/auth_service.py` — verify Firebase token, find existing user by `firebase_uid`, update `auth_provider`→"google", `email`, `display_name`, `photo_url`, issue new JWT pair
  - [x] 1.3: Add `POST /upgrade` route to `backend/app/api/v1/endpoints/auth.py` — uses `success_response()` envelope
  - [x] 1.4: Handle collision: if `linkWithCredential` failed and a different user already maps to same Google account Firebase UID → return structured error with code `AUTH_UPGRADE_CONFLICT`
  - [x] 1.5: Add `AuthUpgradeConflictError` exception to `backend/app/core/exceptions.py` (409 Conflict)

- [x] Task 2: Backend tests for upgrade flow (AC: #8)
  - [x] 2.1: Unit test `upgrade_account()` — happy path: anonymous→google with updated claims
  - [x] 2.2: Unit test `upgrade_account()` — error: Firebase UID not found (new user edge case)
  - [x] 2.3: Unit test `upgrade_account()` — error: user already authenticated (already google)
  - [x] 2.4: Integration test `POST /auth/upgrade` — full round-trip with mocked Firebase

### Flutter

- [x] Task 3: Implement `upgradeToGoogle()` in `AuthRepository` (AC: #1, #7)
  - [x] 3.1: Add `upgradeToGoogle()` method — uses `currentUser!.linkWithCredential()` NOT `signInWithCredential()`
  - [x] 3.2: Handle `FirebaseAuthException` code `credential-already-in-use` → throw typed exception
  - [x] 3.3: Handle `FirebaseAuthException` code `provider-already-linked` → throw typed exception
  - [x] 3.4: On ANY failure after `linkWithCredential` succeeds → attempt compensating `unlink('google.com')` for atomicity

- [x] Task 4: Add `upgradeAccount()` to `AuthRemoteDataSource` (AC: #2)
  - [x] 4.1: Add method calling `POST /api/v1/auth/upgrade` with Firebase ID token
  - [x] 4.2: Add `ApiEndpoints.authUpgrade` constant (value: `/api/v1/auth/upgrade`)

- [x] Task 5: Modify `AuthNotifier` to route upgrade vs. fresh sign-in (AC: #1, #5, #6, #7)
  - [x] 5.1: Modify `signInWithGoogle()` — if current state is `anonymous`, call `upgradeToGoogle()` instead of `signInWithGoogle()`
  - [x] 5.2: On success → transition to `AuthState.authenticated(user)` and show success toast
  - [x] 5.3: On `credential-already-in-use` → show error "This Google account is already in use", remain anonymous
  - [x] 5.4: On any other failure → restore previous anonymous state, show error SnackBar

- [x] Task 6: Hive report re-tagging stub (AC: #4)
  - [x] 6.1: Add `retagLocalReports({required String oldUid, required String newUid})` stub method to `AuthRepository` (Hive is not yet integrated — no-op implementation with TODO for future)
  - [x] 6.2: Call stub from `upgradeToGoogle()` after successful backend token exchange

- [x] Task 7: Flutter tests for upgrade flow (AC: #8)
  - [x] 7.1: Unit test `upgradeToGoogle()` — happy path: `linkWithCredential` + backend upgrade + token storage
  - [x] 7.2: Unit test `upgradeToGoogle()` — error: `credential-already-in-use`
  - [x] 7.3: Unit test `upgradeToGoogle()` — error: `provider-already-linked`
  - [x] 7.4: Unit test `upgradeToGoogle()` — error: backend upgrade fails after `linkWithCredential` succeeds → compensating unlink
  - [x] 7.5: Unit test `AuthNotifier` — `signInWithGoogle` routes to `upgradeToGoogle` when anonymous
  - [x] 7.6: Unit test `AuthNotifier` — `signInWithGoogle` routes to `signInWithGoogle` when unauthenticated (fresh sign-in after sign-out, edge case)

### Review Findings

- [x] [Review][Patch] Minification/Obfuscation Hazard in Exception Type Check [mobile/lib/app_router.dart:592]
- [x] [Review][Patch] Success SnackBar Never Displayed due to Riverpod Wiping State during Loading [mobile/lib/features/auth/presentation/auth_notifier.dart:874-875]
- [x] [Review][Patch] Google Sign-In Cancellation Null Dereference (NoSuchMethodError) [mobile/lib/features/auth/data/auth_repository.dart:743-744]
- [x] [Review][Patch] Incomplete Google Sign-In Cancellation PlatformException Code Check [mobile/lib/features/auth/presentation/auth_notifier.dart:88-90]
- [x] [Review][Patch] Missing Router Handling for ProviderAlreadyLinkedException [mobile/lib/app_router.dart:590-596]
- [x] [Review][Patch] Inconsistent Google Sign-In Button Loading UI [mobile/lib/app_router.dart:227-239]
- [x] [Review][Patch] Missing Email Uniqueness Check on Backend [backend/app/services/auth_service.py:311-319]
- [x] [Review][Patch] Concurrent Race Condition on Backend /upgrade [backend/app/services/auth_service.py:134-141]
- [x] [Review][Patch] Untested and Unmocked Firebase Admin Fallback Path [backend/tests/unit/test_upgrade_account.py]
- [x] [Review][Patch] Unsafe Null-Assertion Operator ! on API Response Data [mobile/lib/features/auth/data/auth_remote_data_source.dart:649]
- [x] [Review][Patch] Fragile Sequential Sign-Out Flow [mobile/lib/features/auth/data/auth_repository.dart:831-842]
- [x] [Review][Patch] Performance Bottleneck: Fallback Fetch on Missing Profile Picture [backend/app/services/auth_service.py:46-52]
- [x] [Review][Defer] Distributed State Inconsistency Dual-Write Hazard [mobile/lib/features/auth/data/auth_repository.dart:763-814] — deferred, pre-existing

## Dev Notes

### Critical: Data Loss Bug Fix (Deferred from Story 2.2)

The current `signInWithGoogle()` in `auth_repository.dart` uses `signInWithCredential()` which creates a **NEW Firebase UID**, orphaning anonymous data. Story 2.3 MUST fix this by routing through `linkWithCredential()` when upgrading from anonymous. This was explicitly deferred from Story 2.2 code review (see [deferred-work.md](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/implementation-artifacts/deferred-work.md#L18)).

### Key Architecture Decision: `linkWithCredential` Preserves UID

When Firebase `linkWithCredential` succeeds, the Firebase UID **stays the same** (the anonymous UID is preserved, the Google credential is simply linked to it). This means:
- The backend `users` table row **does not change its `firebase_uid`**
- The backend just needs to update `auth_provider`, `email`, `display_name`, `photo_url`
- The existing `get_or_create_user()` in `auth_service.py` already handles this update pattern
- The new `/auth/upgrade` endpoint is essentially a re-exchange with explicit validation that it's an anonymous→authenticated upgrade

### Why `/auth/upgrade` Instead of Reusing `/auth/exchange`

The epics explicitly require `POST /api/v1/auth/upgrade`. Reasons:
1. **Explicit intent** — the backend can validate the user was previously anonymous
2. **Audit trail** — upgrade events can be logged distinctly from normal sign-ins
3. **Error handling** — upgrade-specific errors (conflict, already authenticated) have different responses than exchange errors
4. **Future-proofing** — data migration logic (when reports/ideas exist) attaches to this endpoint

### Backend Upgrade Logic

```python
# auth_service.py — upgrade_account() pseudocode:
async def upgrade_account(firebase_token: str, db: AsyncSession) -> TokenResponseSchema:
    claims = await verify_firebase_token(firebase_token)
    firebase_uid = claims["uid"]
    user = await db.execute(select(UserModel).where(UserModel.firebase_uid == firebase_uid))
    user = user.scalar_one_or_none()
    
    if user is None:
        raise AuthInvalidTokenError("User not found for upgrade")
    
    if user.auth_provider != "anonymous":
        raise AuthUpgradeConflictError("User is already authenticated — not an anonymous account")
    
    # Update user fields from Google claims
    user.auth_provider = "google"
    user.email = claims.get("email")
    user.display_name = claims.get("name")
    user.photo_url = claims.get("picture")
    user.last_login_at = datetime.now(UTC)
    await db.commit()
    await db.refresh(user)
    
    # Issue new JWT with updated claims
    access_token = create_access_token({"user_id": str(user.id), "tier": user.tier, "auth_method": "google"})
    refresh_token = create_refresh_token(str(user.id))
    return TokenResponseSchema(...)
```

### Flutter Upgrade Logic

```dart
// auth_repository.dart — upgradeToGoogle() pseudocode:
Future<AuthUser> upgradeToGoogle() async {
  final currentUser = _firebaseAuth.currentUser;
  if (currentUser == null || !currentUser.isAnonymous) {
    throw Exception('Cannot upgrade: no anonymous session');
  }
  
  final googleUser = await _googleSignIn.authenticate();
  final googleAuth = googleUser.authentication;
  final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
  
  try {
    // 1. Link credential to existing anonymous user (UID stays same)
    await currentUser.linkWithCredential(credential);
    
    // 2. Get new Firebase ID token (now has Google provider)
    final idToken = await currentUser.getIdToken(true); // force refresh
    
    // 3. Call backend upgrade endpoint
    final tokenResponse = await _remoteDataSource.upgradeAccount(firebaseToken: idToken!);
    
    // 4. Store new backend tokens
    await _tokenStorage.writeTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );
    
    // 5. Stub: re-tag Hive reports (no-op for now)
    await retagLocalReports(oldUid: currentUser.uid, newUid: currentUser.uid); // UID doesn't change
    
    return AuthUser(
      id: currentUser.uid,
      email: currentUser.email,
      displayName: currentUser.displayName,
      tier: 'free',
      authMethod: 'google',
      isAnonymous: false,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'credential-already-in-use') {
      throw AccountAlreadyInUseException();
    }
    if (e.code == 'provider-already-linked') {
      throw ProviderAlreadyLinkedException();
    }
    rethrow;
  } catch (e) {
    // Compensating action: if linkWithCredential succeeded but backend failed,
    // attempt to unlink the Google provider to restore anonymous state
    try {
      await currentUser.unlink('google.com');
    } catch (_) {
      // Unlink failed — user may be in inconsistent state
      // Log this critical error
    }
    rethrow;
  }
}
```

### GoogleSignIn v7.x Reminder

- Use `GoogleSignIn.instance.authenticate()` (NOT deprecated `signIn()`)
- `.authentication` is a **sync getter** (NOT a Future)
- Only `idToken` is available; `accessToken` requires separate `authorizationClient`
- Singleton pattern: `GoogleSignIn.instance`

[Source: Story 2.2 completion notes, docs/project-context.md]

### Atomicity Strategy

The upgrade flow has a tricky atomicity challenge:

1. **Firebase `linkWithCredential`** → succeeds → Google is now linked
2. **Backend `POST /auth/upgrade`** → if this fails, Google credential is linked to Firebase but backend still shows "anonymous"

**Compensating transaction**: If step 2 fails, attempt `currentUser.unlink('google.com')` to restore the anonymous state. If unlink also fails, log a critical error — manual intervention may be needed.

**Testing**: Mock both success and failure scenarios for the compensating transaction path.

### Existing Anti-Patterns (MUST Follow from Stories 2.1 + 2.2)

**Backend:**
1. DO NOT raise `HTTPException` — use custom `VentureIQError` subclasses
2. DO NOT use `print()` — use `logging.getLogger(__name__)`
3. DO NOT use raw dicts for responses — use Pydantic schemas + `success_response()` helper
4. DO NOT call Firebase in tests — always mock `firebase_admin.auth.verify_id_token`
5. DO NOT create separate auth middleware — use `Depends(get_current_user)` pattern
6. DO NOT use `@app.on_event("startup")` — use lifespan context manager

**Flutter:**
1. ALL data classes use `freezed` + `json_serializable`
2. Feature structure MUST be `data/domain/presentation` triad
3. State management: Riverpod `AsyncNotifier<AuthState>` with `AsyncValue<T>`
4. Use separate plain Dio instance for token refresh calls (prevent interceptor recursion)
5. GoogleSignIn v7.x: `authenticate()` not `signIn()`, `.authentication` is sync
6. DO NOT modify existing exception classes — they are already correct
7. DO NOT use `aioredis` package in backend — use `redis.asyncio` (already installed)

### Deferred Issues from Previous Stories (Context Only — DO NOT Fix)

These deferred items from stories 2.1/2.2 exist but are OUT OF SCOPE for story 2.3. Do not attempt to fix them:
- Weak Token Theft Response Policy
- Hardcoded String subscription Tiers
- Premature DB Commits in Low-Level Helpers
- No Validation of User Status in get_current_user
- Race Condition in Backend Token Refresh
- Database Concurrency Failure in get_or_create_user
- Swagger UI Auth is Broken
- No Server-Side Token Revocation
- Missing Rate Limiting on Token Exchange

### UX Design Notes

No dedicated screen for the upgrade flow. The upgrade is triggered from the **existing Google Sign-In button** in the Profile tab. UX requirements:
- **Success toast**: SnackBar with success accent, text "Account created! Your data has been preserved.", 4s auto-dismiss
- **Error toast**: SnackBar with `surface-100` background, accent-colored left border, 4s auto-dismiss
- **Loading state**: Button label replaced with 20dp `CircularProgressIndicator` while upgrade is in progress
- **No page navigation** — user stays on the current screen after upgrade

[Source: UX Design Specification, Story 2.2 implementation notes]

### Hive Integration Status

Hive is **NOT yet integrated** in the Flutter app. No reports or ideas models exist yet. AC #4 (re-tagging local reports) should be implemented as a **no-op stub** with a clear TODO comment for when Hive/report models are added in later epics (Epic 3+). The method signature and call point should be established now so future stories can fill in the implementation.

### Project Structure Notes

- Alignment with unified project structure: All new files follow existing `data/domain/presentation` triad for Flutter and `api/services/schemas/models` layers for backend
- Backend endpoint mounts at `router` in `auth.py` — no new router file needed
- No new Alembic migration needed — `users` table schema is unchanged (fields are all already present and nullable where needed)
- `ApiEndpoints` constants file in Flutter already exists at `mobile/lib/core/networking/api_endpoints.dart`

### References

- [Source: epics.md — Epic 2, Story 2.3](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/epics.md)
- [Source: architecture.md — Auth Flow §5.8](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/architecture.md)
- [Source: prd.md — FR38, NFR41](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/prd.md)
- [Source: ux-design-specification.md — Auth UX](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/planning-artifacts/ux-design-specification.md)
- [Source: Story 2.1 implementation](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/implementation-artifacts/2-1-firebase-authentication-jwt-exchange-backend.md)
- [Source: Story 2.2 implementation](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/implementation-artifacts/2-2-anonymous-google-sign-in-flutter.md)
- [Source: deferred-work.md — Data Loss on Google Sign-In](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/implementation-artifacts/deferred-work.md)
- [Source: project-context.md](file:///home/rhansana/Documents/avishka-project/ventureiq/ventureiq/_bmad-output/project-context.md)
- [Source: Firebase linkWithCredential docs](https://firebase.google.com/docs/auth/flutter/account-linking)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6 (Thinking)

### Debug Log References

### Completion Notes List

- Story context engine analysis completed — comprehensive developer guide created
- Both research subagents completed exhaustive analysis of epics, architecture, UX, previous stories, and deferred work
- Web research confirmed Firebase `linkWithCredential` patterns and `credential-already-in-use` error handling for 2025/2026
- Git history analyzed: 10 commits showing linear progression through Epic 1 → Epic 2 stories
- Critical deferred bug "Data Loss on Google Sign-In" identified and addressed as primary fix target
- Hive re-tagging identified as stub-only (Hive not yet integrated)
- No Alembic migration needed (existing schema supports upgrade fields)
- Fixed compile-time errors in Flutter tests regarding `FirebaseAuthException` missing `fromCode` and `AsyncValue.valueOrNull`.
- Verified all backend (7) and flutter (5) unit tests pass successfully.
- Completed all frontend routing and logic, including atomicity via compensating Google unlink.

### File List

**Files to CREATE:**
- None (all changes are modifications to existing files)

**Files to MODIFY:**
- `backend/app/api/v1/endpoints/auth.py` — add `POST /upgrade` endpoint
- `backend/app/services/auth_service.py` — add `upgrade_account()` function
- `backend/app/schemas/auth.py` — add `UpgradeRequestSchema`
- `backend/app/core/exceptions.py` — add `AuthUpgradeConflictError`
- `mobile/lib/features/auth/data/auth_repository.dart` — add `upgradeToGoogle()`, `retagLocalReports()` stub
- `mobile/lib/features/auth/data/auth_remote_data_source.dart` — add `upgradeAccount()` method
- `mobile/lib/features/auth/presentation/auth_notifier.dart` — modify `signInWithGoogle()` to route upgrades
- `mobile/lib/core/networking/api_endpoints.dart` — add `authUpgrade` constant

**Test files to CREATE:**
- `backend/tests/unit/test_upgrade_account.py`
- `backend/tests/integration/test_upgrade_flow.py`
- `mobile/test/features/auth/data/auth_repository_upgrade_test.dart`
- `mobile/test/features/auth/presentation/auth_notifier_upgrade_test.dart`
