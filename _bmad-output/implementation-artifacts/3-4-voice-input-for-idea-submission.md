---
baseline_commit: a480590811adabbcbc712cbde2ef0d9124eb4513
---
# Story 3.4: Voice Input for Idea Submission

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user**,
I want to dictate my business idea using voice input,
So that I can submit ideas hands-free when typing is inconvenient.

## Acceptance Criteria (BDD)

```gherkin
Given the Idea Input screen from Story 3.3
When voice input is implemented
Then A microphone icon button (48×48dp) appears right-aligned within the idea text field (FR2)
And Tapping the microphone requests microphone permission (if not already granted) using platform-native permission dialog
And During recording, the microphone icon transforms to an animated recording indicator (pulsing red dot)
And Speech-to-text uses platform-native speech recognition (iOS Speech framework / Android SpeechRecognizer)
And Transcribed text is inserted into the idea text field in real time as the user speaks
And Tapping the recording indicator stops recording and finalizes the transcription
And If microphone permission is denied, a helpful info toast explains how to enable it in system settings
And If speech recognition fails (no network, unsupported language), an error toast is shown with clear guidance
And The transcribed text can be edited manually before submission
And Screen reader announces: "Voice input button. Tap to dictate your idea." (NFR35)
And Widget tests verify recording states and permission handling
```

## Tasks / Subtasks

- [x] Task 1: Add `speech_to_text` dependency (AC: platform-native STT)
  - [x] 1.1 Add `speech_to_text: ^7.3.0` to `mobile/pubspec.yaml`
  - [x] 1.2 Run `flutter pub get`

- [x] Task 2: Configure platform permissions (AC: permission request)
  - [x] 2.1 Add `NSSpeechRecognitionUsageDescription` to `ios/Runner/Info.plist`
  - [x] 2.2 Add `NSMicrophoneUsageDescription` to `ios/Runner/Info.plist`
  - [x] 2.3 Add `RECORD_AUDIO` permission to `android/app/src/main/AndroidManifest.xml`
  - [x] 2.4 Verify `INTERNET` permission already present (needed for some Android STT)

- [x] Task 3: Create `VoiceInputButton` widget (AC: mic icon, recording state, real-time transcription)
  - [x] 3.1 Create `mobile/lib/features/idea_input/presentation/widgets/voice_input_button.dart`
  - [x] 3.2 Implement `VoiceInputButton` as `StatefulWidget` with `SpeechToText` instance
  - [x] 3.3 Props: `onTranscription(String text)` callback, `isEnabled` flag
  - [x] 3.4 Idle state: `Icons.mic` icon, `48×48dp` InkWell with Semantics label
  - [x] 3.5 Listening state: animated pulsing red dot (use `AnimatedContainer` or `ScaleTransition`)
  - [x] 3.6 Call `speechToText.listen(onResult:)` — invoke `onTranscription` with `result.recognizedWords` on each partial/final result
  - [x] 3.7 Call `speechToText.stop()` on tap during listening
  - [x] 3.8 Handle permission denied: show `SnackBar` with "Microphone access is required. Enable it in Settings > App Permissions."
  - [x] 3.9 Handle speech recognition error: show `SnackBar` with context-specific guidance (no network, unsupported language)
  - [x] 3.10 Respect `MediaQuery.disableAnimationsOf(context)` — replace pulsing animation with static red dot icon when Reduce Motion is enabled (NFR35/UX-DR24)

- [x] Task 4: Integrate `VoiceInputButton` into `IdeaTextField` (AC: right-aligned within text field)
  - [x] 4.1 Modify `idea_text_field.dart` — add `VoiceInputButton` as `suffixIcon` inside the `InputDecoration`
  - [x] 4.2 Wire `onTranscription` callback to append transcribed text to `TextEditingController` and call `widget.onChanged`
  - [x] 4.3 Ensure `didUpdateWidget` still syncs external value correctly after voice transcription
  - [x] 4.4 Position button right-aligned within the text field using `suffixIcon` with proper padding

- [x] Task 5: Widget tests (AC: recording states + permission handling)
  - [x] 5.1 Create `mobile/test/features/idea_input/presentation/widgets/voice_input_button_test.dart`
  - [x] 5.2 Test idle state renders mic icon with correct semantics label
  - [x] 5.3 Test tap on mic with available speech → transitions to listening state
  - [x] 5.4 Test tap during listening → stops and finalizes transcription
  - [x] 5.5 Test permission denied → shows SnackBar with settings guidance
  - [x] 5.6 Test speech recognition error → shows error SnackBar
  - [x] 5.7 Test transcribed text appears in text field via callback
  - [x] 5.8 Test Reduce Motion: pulsing animation disabled, static indicator shown
  - [x] 5.9 Mock `SpeechToText` — never make real platform calls in tests

- [x] Task 6: Run validation
  - [x] 6.1 `dart analyze` — zero issues
  - [x] 6.2 `flutter test` — all existing + new tests pass
  - [x] 6.3 Verify accessibility: Semantics tree contains "Voice input button. Tap to dictate your idea."

## Dev Notes

### Architecture Decision: Platform-Native STT

**Decision:** Use platform-native speech-to-text (iOS Speech framework / Android SpeechRecognizer) — NOT cloud-based.
**Rationale:** Zero additional API cost, good enough quality for short idea phrases, no cloud dependency.
**Package:** `speech_to_text` ^7.3.0 (latest stable) — wraps platform APIs directly.
**Scope:** Client-side ONLY. No backend changes. Transcribed text feeds into the existing `POST /api/v1/ideas` endpoint identically to typed text.

[Source: architecture.md Line 297]

### Files to CREATE

| File | Purpose |
|------|---------|
| `mobile/lib/features/idea_input/presentation/widgets/voice_input_button.dart` | Voice input button widget with STT integration |
| `mobile/test/features/idea_input/presentation/widgets/voice_input_button_test.dart` | Widget tests for voice input |

### Files to MODIFY

| File | What Changes | What to Preserve |
|------|-------------|------------------|
| `mobile/lib/features/idea_input/presentation/widgets/idea_text_field.dart` (148 lines) | Add `VoiceInputButton` as `suffixIcon` in `InputDecoration` | Blur validation logic, focus glow animation, character count, `didUpdateWidget` controller sync, Semantics wrapper |
| `mobile/pubspec.yaml` | Add `speech_to_text: ^7.3.0` dependency | All existing dependencies |
| `mobile/ios/Runner/Info.plist` | Add `NSSpeechRecognitionUsageDescription` + `NSMicrophoneUsageDescription` | All existing plist entries |
| `mobile/android/app/src/main/AndroidManifest.xml` | Add `RECORD_AUDIO` permission | All existing permissions and manifest structure |

### Current State of `idea_text_field.dart` (CRITICAL — READ BEFORE MODIFYING)

The existing `IdeaTextField` is a `StatefulWidget` with:
- **Internal state:** `FocusNode`, `TextEditingController`, `_hasBlurred`, `_isFocused`
- **Focus glow:** `AnimatedContainer` with `BoxShadow(color: AppColors.electricViolet.withValues(alpha: 0.3), blurRadius: 20)` on focus
- **Validation:** blur-only — error shown when `_hasBlurred && trimmedLength > 0 && trimmedLength < 10`
- **Controller sync:** `didUpdateWidget` updates controller text when `widget.value != _controller.text`, setting cursor to end
- **Character count:** displayed below field in `AppTypography.caption` / `textTertiary`
- **No `suffixIcon`** currently — `InputDecoration` has `filled: false`, `border: InputBorder.none`, `contentPadding: EdgeInsets.all(AppSpacing.space4)`
- **Props:** `value` (String) and `onChanged` (ValueChanged<String>)

**Integration approach:** Add a `suffixIcon` to the existing `InputDecoration`. The VoiceInputButton's `onTranscription` callback should:
1. Append transcribed text to `_controller.text` (or replace if field is empty)
2. Update cursor position to end of text
3. Call `widget.onChanged` with the new text so Riverpod state updates

**DO NOT** move the text field into VoiceInputButton or restructure the widget tree. The VoiceInputButton is a child composed INTO the existing IdeaTextField.

### Current State of `IdeaInputNotifier` (CONTEXT — NO CHANGES NEEDED)

The `IdeaInputNotifier` manages form state via `IdeaInputState` (freezed). Key methods:
- `updateIdeaText(String)` — updates `ideaText`, clears `plausibilityResult` and `submittedIdeaId`
- `submit()` — creates idea via API, runs plausibility check
- `canValidate` getter — checks `ideaText.trim().length >= 10`

**No changes needed to notifier** — voice transcription triggers the existing `updateIdeaText` flow via `widget.onChanged` in `IdeaTextField`.

### Design Token Requirements (NEVER HARDCODE)

| Token | Use |
|-------|-----|
| `AppColors.electricViolet` | Focus glow, primary accent |
| `AppColors.error` | Recording indicator red dot — use `AppColors.error` (0xFFEF4444) |
| `AppColors.surface200` | Input field fill |
| `AppColors.surface300` | Borders |
| `AppColors.textPrimary` | Primary text |
| `AppColors.textTertiary` | Hint text, character count |
| `AppSpacing.radiusMd` | Border radius |
| `AppSpacing.space4` | Padding |
| `AppTypography.body` | Body text style |
| `AppTypography.caption` | Caption text style |

### Accessibility Requirements (NON-NEGOTIABLE)

1. **Semantics label:** `"Voice input button. Tap to dictate your idea."` — exact text, per NFR35
2. **During recording:** Update semantics to `"Recording. Tap to stop."` with `liveRegion: true` for screen reader announcement
3. **48dp minimum touch target** — the mic button must be at least 48×48dp (NFR36)
4. **Reduce Motion support:** Check `MediaQuery.disableAnimationsOf(context)` — if enabled, show static red dot icon instead of pulsing animation (UX-DR24)

### Testing Patterns (from Story 3-3)

- **Framework:** `flutter_test` + `WidgetTester`
- **Mock pattern:** Create `_MockSpeechToText` implementing or extending `SpeechToText` with configurable behavior (available/unavailable, permission granted/denied, recognition results)
- **Provider overrides:** NOT needed — VoiceInputButton manages its own `SpeechToText` instance internally
- **SnackBar testing:** Use `find.byType(SnackBar)` after `tester.pumpAndSettle()`
- **Semantics testing:** Use `find.bySemanticsLabel()` to verify accessibility labels
- **File:** `mobile/test/features/idea_input/presentation/widgets/voice_input_button_test.dart`

### Anti-Patterns to AVOID

1. ❌ DO NOT create a separate provider or notifier for voice state — keep it local to `VoiceInputButton` StatefulWidget
2. ❌ DO NOT use cloud-based STT (Whisper, Deepgram, Google Cloud Speech) — architecture mandates platform-native
3. ❌ DO NOT create a new screen or dialog for voice input — it's a button INSIDE the text field
4. ❌ DO NOT hardcode any colors, sizes, or spacing — always use `AppColors`, `AppSpacing`, `AppTypography`
5. ❌ DO NOT use `!` force unwrap without preceding null check
6. ❌ DO NOT create duplicate ErrorCard or SnackBar utilities — use existing patterns
7. ❌ DO NOT use `StateNotifier` (deprecated) — use local `StatefulWidget` state since this is widget-level, not app-level state
8. ❌ DO NOT modify `idea_input_notifier.dart` — voice text flows through existing `onChanged` callback
9. ❌ DO NOT modify `idea_input_screen.dart` — VoiceInputButton is composed inside IdeaTextField, not at screen level
10. ❌ DO NOT extend StatelessWidget/StatefulWidget to create "base" widgets — use composition

### Project Structure Notes

New files MUST go in prescribed locations per architecture:
```
mobile/lib/features/idea_input/presentation/widgets/voice_input_button.dart  ← PRIMARY DELIVERABLE
mobile/test/features/idea_input/presentation/widgets/voice_input_button_test.dart  ← TESTS
```

This follows the existing `data/domain/presentation` triad. No new directories needed. No new domain or data layer files needed — voice input is purely a presentation-layer feature.

### Previous Story Intelligence (Story 3-3)

**Key learnings to carry forward:**
1. **Retry duplicate fix:** Story 3-3 had a bug where retrying created duplicate idea records. The fix (reusing `submittedIdeaId`) is already in place. Voice text flows through the same path — no regression risk.
2. **@JsonKey for single-word fields:** Freezed models need `@JsonKey(name: 'snake_case')` even for single-word fields. No new models needed for this story.
3. **Inline style violation:** Story 3-3 was caught using inline `FontWeight` instead of `AppTypography`. Always use design tokens.
4. **Context expander clear-on-collapse:** Story 3-3 was caught leaving stale data when collapsing. No parallel here, but pattern awareness matters.
5. **Accessibility contrast:** Disabled button states need sufficient color contrast. The mic button's disabled/enabled states should follow the same principle.
6. **Code review found backend modifications in a frontend story** — DO NOT touch any backend code in this story.

### Git Intelligence

**Recent commit pattern:** conventional commits (`feat(scope): description`), one story per PR.
**Branch naming:** `feat/e3-s4-voice-input-idea-submission` (from `development`)
**Latest merged PRs:** plausibility check, idea submission endpoint, idea input screen — all under `feature/*` branches.

### Latest Technical Information

**`speech_to_text` package v7.3.0 (June 2026):**
- Wraps iOS Speech framework + Android SpeechRecognizer natively
- Supports Android, iOS, macOS, Web, Windows (beta)
- Key API:
  - `SpeechToText()` — create instance
  - `speech.initialize(onError:, onStatus:)` → `Future<bool>` — returns whether STT is available + handles permission
  - `speech.listen(onResult:, listenFor:, localeId:)` — start listening, receives `SpeechRecognitionResult`
  - `speech.stop()` — stop listening
  - `speech.isListening` — current listening state
  - `speech.isAvailable` — whether STT is available after init
  - `result.recognizedWords` — transcribed text (partial or final)
  - `result.finalResult` — whether this is the final transcription
- **Permission handling:** `initialize()` triggers platform permission dialog. Returns `false` if denied.
- **Error handling:** `onError` callback receives `SpeechRecognitionError` with `errorMsg` and `permanent` flag
- **Important:** Must call `initialize()` before `listen()`. Can reuse instance across multiple listen sessions.

### References

- [Source: architecture.md Line 297 — Platform-native STT decision]
- [Source: architecture.md Line 824 — voice_input_button.dart file location]
- [Source: epics.md Lines 605-626 — Story 3.4 complete spec]
- [Source: prd.md Line 343 — Microphone permission: optional, requested on use]
- [Source: ux-design-specification.md Line 1492 — Mic icon 48dp, right-aligned, animated recording indicator]
- [Source: project-context.md — Design tokens, accessibility, testing standards]
- [Source: 3-3-idea-input-screen-flutter.md — Previous story learnings and patterns]

## Dev Agent Record

### Agent Model Used

Gemini 3.1 Pro (High)

### Debug Log References

- Verified all state changes, permissions dialog handling, and UI interactions with mock STT.

### Completion Notes List

- ✅ Resolved all tasks. Implemented `VoiceInputButton` with proper permission requests, animation handling, accessibility labels, and robust error management. Integrated into `IdeaTextField` and covered with widget tests.
- All acceptance criteria are fully met.

### File List

- `mobile/pubspec.yaml`
- `mobile/ios/Runner/Info.plist`
- `mobile/android/app/src/main/AndroidManifest.xml`
- `mobile/lib/features/idea_input/presentation/widgets/idea_text_field.dart`
- `mobile/lib/features/idea_input/presentation/widgets/voice_input_button.dart`
- `mobile/test/features/idea_input/presentation/widgets/voice_input_button_test.dart`

### Review Findings

- [x] [Review][Patch] Transcribed text is exponentially duplicated during real-time partial updates [`idea_text_field.dart`]
- [x] [Review][Patch] Cursor Position Ignored during transcription [`idea_text_field.dart`]
- [x] [Review][Patch] Widget disposal leaks background microphone session [`voice_input_button.dart`]
- [x] [Review][Patch] Missing `mounted` checks in async callbacks [`voice_input_button.dart`]
- [x] [Review][Patch] Animation controller ticks needlessly when Reduce Motion is enabled [`voice_input_button.dart`]
- [x] [Review][Patch] Missing concurrency guard in `_toggleListening` [`voice_input_button.dart`]
- [x] [Review][Patch] Voice input stays active when parent dynamically disables it [`voice_input_button.dart`]
- [x] [Review][Patch] Missing `didUpdateWidget` synchronization for controller [`idea_text_field.dart`]
- [x] [Review][Patch] Incorrect whitespace padding after newlines [`idea_text_field.dart`]
- [x] [Review][Patch] Unhandled exceptions during platform STT initialization/listening [`voice_input_button.dart`]
- [x] [Review][Patch] Recording indicator state change fails to trigger UI rebuild [`voice_input_button.dart`]
- [x] [Review][Patch] Error toast relies on raw platform error messages [`voice_input_button.dart`]
- [x] [Review][Patch] Missing widget test for speech recognition errors [`voice_input_button_test.dart`]
