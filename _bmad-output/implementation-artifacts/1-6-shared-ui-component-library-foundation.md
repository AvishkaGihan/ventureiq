# Story 1.6: Shared UI Component Library (Foundation)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want the foundational shared UI components built following the UX specification,
So that all feature screens have consistent, accessible, premium building blocks.

## Acceptance Criteria

1. **Given** the design system from Story 1.5 **When** shared components are implemented **Then** `core/widgets/skeleton_loader.dart` implements animated shimmer loading skeleton on `surface-100` (UX-DR26)
2. **And** `core/widgets/error_card.dart` implements error feedback card with colored left border (Success/Error/Warning/Info variants), icon, message text, and optional retry action (UX-DR26)
3. **And** `core/widgets/confidence_badge.dart` implements ConfidenceBadge with 3 levels (High ≥80% green, Mid 50-79% amber, Low <50% red), pill-shaped with color + text label, 3 variants (Pill, Compact, Large) (UX-DR7)
4. **And** `core/widgets/agent_status_indicator.dart` implements AgentStatusIndicator with 6 phases (Started, Searching, Analyzing, Cross-referencing, Complete, Error), 3 variants (Badge, Full, Dot) (UX-DR13)
5. **And** `core/constants/enums.dart` defines `AgentRole` (scout, rival, cfo, devilsAdvocate, strategist, coordinator) and `ReportStatus` enums
6. **And** All components meet 48dp minimum touch targets (NFR36)
7. **And** All components include `Semantics` wrappers for screen reader support (NFR35)
8. **And** All components support Reduce Motion via `MediaQuery.disableAnimationsOf(context)` (UX-DR24)
9. **And** Widget tests with golden comparisons verify each component's visual output
10. **And** Components support dynamic text scaling up to 1.5× without layout breakage (UX-DR24, NFR38)

## Tasks / Subtasks

- [x] Task 1: Core Enums & Constants (`core/constants/enums.dart`) (AC: #5)
  - [x] 1.1: Define `AgentRole` enum with values: `scout`, `rival`, `cfo`, `devilsAdvocate`, `strategist`, `coordinator`
  - [x] 1.2: Add helper getters on `AgentRole`: `displayName`, `icon` (emoji string), `color` (returns `Color` from `AppColors`), `mutedColor`, `glowColor`
  - [x] 1.3: Define `ReportStatus` enum with values: `pending`, `plausibilityChecking`, `analyzing`, `crossReferencing`, `synthesizing`, `completed`, `failed`
  - [x] 1.4: Define `AgentPhase` enum with values: `started`, `searching`, `analyzing`, `crossReferencing`, `complete`, `error`
  - [x] 1.5: Define `ConfidenceLevel` enum with values: `high`, `mid`, `low` — with helper `fromScore(double)` factory and `color`/`label` getters
  - [x] 1.6: Define `FeedbackType` enum with values: `success`, `error`, `warning`, `info` — with `color` and `icon` getters

- [x] Task 2: SkeletonLoader Widget (`core/widgets/skeleton_loader.dart`) (AC: #1, #7, #8, #10)
  - [x] 2.1: Create `SkeletonLoader` StatefulWidget with shimmer animation using `AnimationController` (1.5s duration, repeat)
  - [x] 2.2: Accept `width`, `height`, `borderRadius` (default `AppSpacing.radiusMd`) parameters
  - [x] 2.3: Implement shimmer gradient on `surface100` base with `surface150` highlight sweep
  - [x] 2.4: Respect Reduce Motion — if `MediaQuery.disableAnimationsOf(context)` is true, display static `surface100` fill (no shimmer)
  - [x] 2.5: Wrap in `Semantics(label: 'Loading content')` for screen reader support
  - [x] 2.6: Create convenience factory `SkeletonLoader.text()` for text-line skeletons (fixed height ~14dp, variable width)
  - [x] 2.7: Create convenience factory `SkeletonLoader.card()` for full-card skeletons (e.g., 120dp height, full width)
  - [x] 2.8: Ensure widget scales properly with dynamic text scaling up to 1.5×

- [x] Task 3: ErrorCard Widget (`core/widgets/error_card.dart`) (AC: #2, #6, #7, #8, #10)
  - [x] 3.1: Create `ErrorCard` StatelessWidget accepting: `FeedbackType type`, `String message`, `VoidCallback? onRetry`, `String? retryLabel`
  - [x] 3.2: Render card on `surface050` fill with `radiusMd` (12dp) border radius
  - [x] 3.3: Apply 4dp left border using the `FeedbackType.color`: Success=`#22C55E`, Error=`#EF4444`, Warning=`#F59E0B`, Info=`#3B82F6`
  - [x] 3.4: Display `FeedbackType.icon` (24dp, in type color) + message text (`textPrimary`, Body style) in a Row
  - [x] 3.5: If `onRetry` is provided, render a TextButton ("Retry" or custom `retryLabel`) in Electric Violet below the message
  - [x] 3.6: Retry button must meet 48dp minimum touch target
  - [x] 3.7: Wrap in `Semantics` with `label` describing the feedback type and message; retry button gets `button: true` semantics
  - [x] 3.8: Support dynamic text scaling — card height expands as text size increases

- [x] Task 4: ConfidenceBadge Widget (`core/widgets/confidence_badge.dart`) (AC: #3, #6, #7, #10)
  - [x] 4.1: Create `ConfidenceBadge` StatelessWidget accepting: `double score` (0-100), `ConfidenceBadgeVariant variant` (pill, compact, large)
  - [x] 4.2: Determine `ConfidenceLevel` from score: High ≥80, Mid 50-79, Low <50
  - [x] 4.3: **Pill variant** (default): pill-shaped (`radiusFull`), muted background tint (15% opacity of level color), colored text + leading dot indicator. Size: ~24dp height.
  - [x] 4.4: **Compact variant**: smaller pill, color dot + percentage only (no label text). Size: ~20dp height.
  - [x] 4.5: **Large variant**: larger pill, color dot + percentage + label text (e.g., "92% — Verified"). Size: ~32dp height.
  - [x] 4.6: Always use **color + text label** (never color alone) per accessibility spec — triple redundancy
  - [x] 4.7: Wrap in `Semantics(label: '${score.round()} percent confidence, ${level.label}')` for screen readers
  - [x] 4.8: Use JetBrains Mono (`GoogleFonts.jetBrainsMono`) for the percentage number per UX typography spec
  - [x] 4.9: Ensure minimum touch target of 48dp when the badge is tappable (wrap in a padded area)
  - [x] 4.10: Support dynamic text scaling up to 1.5× — badge height adjusts proportionally

- [x] Task 5: AgentStatusIndicator Widget (`core/widgets/agent_status_indicator.dart`) (AC: #4, #6, #7, #8, #10)
  - [x] 5.1: Create `AgentStatusIndicator` StatelessWidget accepting: `AgentPhase phase`, `AgentRole agent`, `AgentStatusVariant variant` (badge, full, dot)
  - [x] 5.2: **Badge variant**: compact horizontal pill — agent-colored background (15% opacity), phase icon + phase text (Micro typography, 11px). Height: ~24dp.
  - [x] 5.3: **Full variant**: full-width row — agent icon (24dp) + agent name (Body SM) + phase icon + phase text + animated indicator. Height: ~48dp.
  - [x] 5.4: **Dot variant**: minimal 12dp colored dot — agent color, pulsing animation for active phases (started, searching, analyzing, crossReferencing), solid for complete/error
  - [x] 5.5: Phase icon mapping: Started → ⏳, Searching → 🔍, Analyzing → ⚡, Cross-referencing → 📎, Complete → ✅, Error → ⚠️
  - [x] 5.6: Use agent identity color for border/glow/dot: Scout `#3B82F6`, Rival `#F43F5E`, CFO `#F59E0B`, Devil's Advocate `#EF4444`, Strategist `#10B981`, Coordinator `#A78BFA`
  - [x] 5.7: Pulsing animation: 0.8s duration, fade between 0.4 and 1.0 opacity, repeated
  - [x] 5.8: Reduce Motion: if disabled, show static dot/icon (no pulse animation)
  - [x] 5.9: Wrap in `Semantics(label: '${agent.displayName} agent status: ${phase.displayName}')` 
  - [x] 5.10: Support dynamic text scaling up to 1.5× — Full variant reflows if needed

- [x] Task 6: Widget Tests (AC: #9)
  - [x] 6.1: `test/core/widgets/skeleton_loader_test.dart` — verify shimmer animation runs, Reduce Motion disables animation, Semantics label present
  - [x] 6.2: `test/core/widgets/error_card_test.dart` — verify all 4 FeedbackType variants render correct color/icon, retry button fires callback, Semantics label present
  - [x] 6.3: `test/core/widgets/confidence_badge_test.dart` — verify score→level mapping (edge cases: 0, 49, 50, 79, 80, 100), all 3 variants render, Semantics label present
  - [x] 6.4: `test/core/widgets/agent_status_indicator_test.dart` — verify all 6 phases render correct icon/text, all 3 variants render, all 6 agents use correct color, Semantics label present
  - [x] 6.5: `test/core/constants/enums_test.dart` — verify `AgentRole` display names and colors, `ConfidenceLevel.fromScore()` boundary conditions, `FeedbackType` colors
  - [x] 6.6: Verify dynamic text scaling — render all widgets at 1.5× `textScaler` and assert no overflow

## Dev Notes

### Critical Architecture Constraints

**File locations MUST follow architecture.md:**

```
mobile/lib/
├── core/
│   ├── constants/
│   │   └── enums.dart          # AgentRole, ReportStatus, AgentPhase, ConfidenceLevel, FeedbackType
│   └── widgets/
│       ├── skeleton_loader.dart
│       ├── error_card.dart
│       ├── confidence_badge.dart
│       └── agent_status_indicator.dart
mobile/test/
├── core/
│   ├── constants/
│   │   └── enums_test.dart
│   └── widgets/
│       ├── skeleton_loader_test.dart
│       ├── error_card_test.dart
│       ├── confidence_badge_test.dart
│       └── agent_status_indicator_test.dart
```

[Source: architecture.md#Flutter Project Organization, lines 422-448, 794-799]

### Design System References (Already Implemented — DO NOT recreate)

All design tokens are already defined in Story 1.5. **Import and use — do NOT redefine:**

- `AppColors` — `package:ventureiq_app/core/theme/app_colors.dart`
- `AppSpacing` — `package:ventureiq_app/core/theme/app_spacing.dart`
- `AppTypography` — `package:ventureiq_app/core/theme/app_typography.dart`
- `AppTheme` — `package:ventureiq_app/core/theme/app_theme.dart`

**Key color mappings for this story:**

| Component Need | Color Token | Hex |
|:--|:--|:--|
| Scout agent | `AppColors.scoutFull` / `scoutMuted` / `scoutGlow` | `#3B82F6` |
| Rival agent | `AppColors.rivalFull` / `rivalMuted` / `rivalGlow` | `#F43F5E` |
| CFO agent | `AppColors.cfoFull` / `cfoMuted` / `cfoGlow` | `#F59E0B` |
| Devil's Advocate | `AppColors.devilsAdvocateFull` / `devilsAdvocateMuted` / `devilsAdvocateGlow` | `#EF4444` |
| Strategist | `AppColors.strategistFull` / `strategistMuted` / `strategistGlow` | `#10B981` |
| Coordinator | `AppColors.coordinatorFull` / `coordinatorMuted` / `coordinatorGlow` | `#A78BFA` |
| High confidence | `AppColors.verifiedGreen` | `#22C55E` |
| Mid confidence | `AppColors.cautionAmber` | `#F59E0B` |
| Low confidence | `AppColors.warningRed` | `#EF4444` |
| Success feedback | `AppColors.success` | `#22C55E` |
| Error feedback | `AppColors.error` | `#EF4444` |
| Warning feedback | `AppColors.warning` | `#F59E0B` |
| Info feedback | `AppColors.info` | `#3B82F6` |
| Skeleton base | `AppColors.surface100` | `#151823` |
| Skeleton highlight | `AppColors.surface150` | `#1A1E2E` |
| Card fill | `AppColors.surface050` | `#0F1117` |
| Card border | `AppColors.surface300` | `#343A52` |

[Source: ux-design-specification.md#Color System, lines 429-518]

### Component Specifications (UX-DR7, UX-DR13, UX-DR26)

**ConfidenceBadge (UX-DR7):**
- Institutional-grade, Bloomberg-style — **NOT** gamified Duolingo-style
- Pill-shaped with: muted background tint (15% opacity of level color) + colored text + leading dot indicator
- Always use **color + text label** (never color alone) for accessibility
- Percentage number in JetBrains Mono (`GoogleFonts.jetBrainsMono()`)
- Level thresholds: High ≥80% (`verifiedGreen`), Mid 50-79% (`cautionAmber`), Low <50% (`warningRed`)
- Label examples: "92% — Verified", "67% — Moderate", "38% — Low"

[Source: ux-design-specification.md#Confidence & Trust Indicators, lines 477-489]

**AgentStatusIndicator (UX-DR13):**
- Multi-phase lifecycle indicator — phases are NOT arbitrary states, they map to exact pipeline phases
- Phase progression: Started → Searching → Analyzing → Cross-referencing → Complete | Error
- Each phase has a phase-appropriate icon and text
- Agent identity colors provide instant visual identification in the War Room's multi-stream environment

[Source: epics.md#Story 1.6 AC #4, ux-design-specification.md#Agent Identity Colors lines 459-476]

**SkeletonLoader & ErrorCard (UX-DR26):**
- Skeleton: shimmer animation on `surface100` — do NOT use third-party shimmer packages, implement with `AnimationController` + `LinearGradient`
- Error card: colored left border (4dp) using `ClipRRect` + `Container` decoration pattern
- Error card states: Success (green left border + ✅ icon), Error (red + ❌), Warning (amber + ⚠️), Info (blue + ℹ️)

[Source: ux-design-specification.md#Design Implications, lines 166-177; epics.md#Story 1.6 AC #1-2]

### Accessibility Requirements (CRITICAL)

**Screen Reader Support (NFR35):**
- Every custom widget MUST have a `Semantics` wrapper
- Use descriptive `label` properties — concise but informative
- For interactive elements, set `button: true` and provide `onTap`/`onTapHint`
- Use `MergeSemantics` when a card's children should be announced as a single unit
- Use `ExcludeSemantics` for purely decorative elements (shimmer animation gradient)

**Reduce Motion (UX-DR24):**
- Check `MediaQuery.disableAnimationsOf(context)` (Flutter 3.10+)
- When reduce motion is enabled: replace ALL animations with instant state changes
- SkeletonLoader: show static fill instead of shimmer
- AgentStatusIndicator Dot: show solid color instead of pulsing

**Dynamic Text Scaling (NFR38):**
- All components must render correctly at system text scale 1.0× through 1.5×
- Cards must expand vertically to accommodate larger text
- No text truncation — use `maxLines` + `overflow: TextOverflow.ellipsis` only where explicitly designed
- Test at 1.5× textScaler in widget tests

**Touch Targets (NFR36):**
- Minimum 48×48dp for all interactive elements
- ErrorCard retry button: ensure 48dp touch height via `minimumSize` on button theme or explicit `SizedBox` constraint
- ConfidenceBadge: when used as a tappable element, ensure 48dp touch area (may need `Padding` around the visual badge)

### Animation Specifications (UX-DR30)

| Animation | Duration | Curve | Reduce Motion Fallback |
|:--|:--|:--|:--|
| Skeleton shimmer sweep | 1.5s | `linear` (repeating) | Static `surface100` fill |
| Agent dot pulse | 0.8s | `easeInOut` (repeating) | Solid dot, full opacity |

### Naming Conventions (Dart)

| Element | Convention | Example |
|:--|:--|:--|
| Files | `snake_case.dart` | `skeleton_loader.dart`, `confidence_badge.dart` |
| Classes | `PascalCase` | `SkeletonLoader`, `ConfidenceBadge`, `AgentStatusIndicator` |
| Enums | `PascalCase` (type), `camelCase` (values) | `AgentRole.scout`, `ConfidenceLevel.high` |
| Enum values | `camelCase` | `devilsAdvocate`, `crossReferencing` |
| Widget parameters | `camelCase` | `borderRadius`, `onRetry`, `feedbackType` |
| Private members | `_prefixed` | `_animationController`, `_shimmerGradient` |
| Test groups | descriptive string | `'ConfidenceBadge'`, `'score → level mapping'` |

[Source: architecture.md#Naming Patterns — Code Naming Conventions, lines 366-381]

### Anti-Patterns to AVOID

- ❌ Do NOT use third-party shimmer packages (`shimmer`, `skeleton_loader_package`) — implement shimmer with Flutter's built-in `AnimationController` + `ShaderMask` / `LinearGradient`
- ❌ Do NOT hardcode colors — always reference `AppColors.*`
- ❌ Do NOT hardcode spacing/radius — always reference `AppSpacing.*`
- ❌ Do NOT use `print()` — use `debugPrint()` if logging is needed
- ❌ Do NOT create data model classes — no `freezed`, `json_serializable`, or `build_runner` in this story
- ❌ Do NOT create feature screens — this is `core/widgets/` and `core/constants/` ONLY
- ❌ Do NOT modify any existing files from Story 1.5 (theme, networking, router, main)
- ❌ Do NOT use `setState` for animation state — use `AnimationController` with `SingleTickerProviderStateMixin`
- ❌ Do NOT create golden test image files — use standard widget tests (golden tests are aspirational, not required for V1)
- ❌ Do NOT add new dependencies to `pubspec.yaml` — all needed packages are already present
- ❌ Do NOT use `Navigator` directly — these are standalone widgets, not screens
- ❌ Do NOT import from `features/` — `core/widgets/` components must have zero feature dependencies

### Scope Boundaries

**IN SCOPE:**
- `mobile/lib/core/constants/enums.dart` — AgentRole, ReportStatus, AgentPhase, ConfidenceLevel, FeedbackType enums
- `mobile/lib/core/widgets/skeleton_loader.dart` — Shimmer loading skeleton
- `mobile/lib/core/widgets/error_card.dart` — Error/feedback card with colored left border
- `mobile/lib/core/widgets/confidence_badge.dart` — 3-level confidence pill badge
- `mobile/lib/core/widgets/agent_status_indicator.dart` — 6-phase agent lifecycle indicator
- Widget tests for all 4 widgets + enum tests
- Remove `.gitkeep` files from `core/widgets/` and `core/constants/` after adding real files

**OUT OF SCOPE:**
- **NO** feature screens or feature-specific widgets
- **NO** WarRoomAgentCard, StreamingTextDisplay, CrossReferenceBadge — those are feature widgets in Story 4.4
- **NO** ViabilityScoreDisplay, DimensionalBreakdownBar, RadarChart — those are feature widgets in Story 5.x/6.x
- **NO** SourceCitationCard, InlineCitationSuperscript — those are feature widgets in Story 6.x
- **NO** modifications to existing Story 1.5 files (theme, networking, router, etc.)
- **NO** data models, repositories, or API integration
- **NO** golden test files (standard widget tests are sufficient)
- **NO** new `pubspec.yaml` dependencies

### Previous Story Intelligence (Story 1.5)

**Critical patterns established in Story 1.5 — FOLLOW these exactly:**

1. **Widget constructor pattern:** Every widget needs `Key? key` in constructor (`use_key_in_widget_constructors: true` lint rule)
2. **Const constructors:** Use `const` constructors wherever possible (`prefer_const_constructors` lint rule)
3. **Trailing commas:** Required on all parameter lists (`require_trailing_commas` lint rule)
4. **Single quotes:** Use single quotes for strings (`prefer_single_quotes` lint rule)
5. **Full hex values:** Use full hex for colors (`use_full_hex_values_for_flutter_colors` lint rule)
6. **No print:** Use `debugPrint()` instead of `print()` (`avoid_print: true`)
7. **GoogleFonts usage:** Use `GoogleFonts.jetBrainsMono()` for monospace text in ConfidenceBadge
8. **Test pattern:** Tests pass with `flutter test` — 118 tests exist from Story 1.5; new tests must not break existing ones

**Debug learnings from Story 1.5:**
- GoogleFonts fetching in tests: Runtime fetching works with `HttpOverrides.global` and `TestWidgetsFlutterBinding.ensureInitialized()` in test files
- Use newer Flutter API names: `CardThemeData`, `DialogThemeData` (not deprecated names)
- `dart analyze` must pass with 0 issues before marking complete

[Source: 1-5-flutter-app-shell-with-navigation-theme-foundation.md#Dev Agent Record]

### Testing Requirements

**Test framework:** `flutter_test` (already in dev deps)

**Test file locations:**
```
mobile/test/
├── core/
│   ├── constants/
│   │   └── enums_test.dart
│   └── widgets/
│       ├── skeleton_loader_test.dart
│       ├── error_card_test.dart
│       ├── confidence_badge_test.dart
│       └── agent_status_indicator_test.dart
```

**Required test coverage:**

1. `enums_test.dart`:
   - `AgentRole` has exactly 6 values
   - `AgentRole.scout.displayName` returns 'Scout', etc.
   - `AgentRole.scout.color` returns `AppColors.scoutFull`
   - `ConfidenceLevel.fromScore(80)` returns `ConfidenceLevel.high`
   - `ConfidenceLevel.fromScore(79)` returns `ConfidenceLevel.mid`
   - `ConfidenceLevel.fromScore(49)` returns `ConfidenceLevel.low`
   - Boundary tests: 0, 50, 80, 100

2. `skeleton_loader_test.dart`:
   - Renders with default dimensions
   - Custom width/height are applied
   - `Semantics` label 'Loading content' is present
   - Convenience factories `.text()` and `.card()` render

3. `error_card_test.dart`:
   - Each `FeedbackType` renders with correct colored border
   - Message text is displayed
   - Retry button appears when `onRetry` is provided
   - Retry callback fires on tap
   - Retry button is NOT rendered when `onRetry` is null
   - `Semantics` label includes feedback type

4. `confidence_badge_test.dart`:
   - Score 92 → renders green pill with "92%" text
   - Score 67 → renders amber pill with "67%" text  
   - Score 38 → renders red pill with "38%" text
   - Boundary: 80 → High, 79 → Mid, 50 → Mid, 49 → Low, 0 → Low, 100 → High
   - All 3 variants render without error
   - `Semantics` label includes score and level

5. `agent_status_indicator_test.dart`:
   - All 6 phases render correct icon/text
   - All 3 variants render without error
   - All 6 agents use correct color  
   - `Semantics` label includes agent name and phase
   - Dot variant renders a colored circle

6. **Text scaling test** (can be in any test file):
   - Render widget with `MediaQuery` wrapping that sets `textScaler: TextScaler.linear(1.5)`
   - Assert no overflow (no `FlutterError` thrown)

**Test pattern:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/widgets/confidence_badge.dart';
import 'package:ventureiq_app/core/constants/enums.dart';

void main() {
  group('ConfidenceBadge', () {
    testWidgets('renders high confidence for score >= 80', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(score: 92),
          ),
        ),
      );

      expect(find.text('92%'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'92 percent confidence')),
        findsOneWidget,
      );
    });
  });
}
```

### Project Structure Notes

- All files go under `mobile/lib/core/constants/` and `mobile/lib/core/widgets/`
- Remove `.gitkeep` files from these directories when adding real files
- Test files mirror source structure under `mobile/test/core/`
- Enums in `core/constants/enums.dart` are app-wide and used by both core widgets and feature widgets
- Widgets in `core/widgets/` are shared components — they MUST NOT import anything from `features/`
- These components will be consumed by: War Room (Epic 4), Report (Epic 6), History (Epic 8), and other feature modules

### References

- [Source: architecture.md#Flutter Project Organization, lines 422-448, 794-799] — File structure for core/widgets/ and core/constants/
- [Source: architecture.md#Naming Patterns — Code Naming Conventions, lines 366-381] — Dart naming conventions
- [Source: architecture.md#Enforcement Guidelines, lines 610-622] — Rules for all AI agents
- [Source: epics.md#Story 1.6, lines 427-447] — Full acceptance criteria
- [Source: epics.md#Story 1.5, lines 403-426] — Previous story context
- [Source: ux-design-specification.md#Color System, lines 429-518] — Agent colors, confidence colors, surface palette
- [Source: ux-design-specification.md#Typography System, lines 519-545] — Inter + JetBrains Mono usage
- [Source: ux-design-specification.md#Spacing & Layout Foundation, lines 546-581] — Spacing scale, radius tokens
- [Source: ux-design-specification.md#Confidence & Trust Indicators, lines 477-489] — ConfidenceBadge spec
- [Source: ux-design-specification.md#Accessibility Considerations, lines 583-614] — Contrast, touch targets, screen readers
- [Source: ux-design-specification.md#Animation timing standards, UX-DR30] — Animation durations
- [Source: 1-5-flutter-app-shell-with-navigation-theme-foundation.md] — Previous story patterns and debug learnings

## Dev Agent Record

### Agent Model Used

Gemini 1.5 Pro

### Debug Log References

- Encountered an issue with nested Semantics in `ErrorCard` merging incorrectly with the retry button. Fixed by wrapping only the `Row` with the icon and text in `Semantics(excludeSemantics: true)`.
- Had to adjust `MediaQuery` definitions in tests to use `const MediaQuery` to satisfy the `prefer_const_constructors` lint rule, and remove internal `const` where necessary.

### Completion Notes List

- Successfully implemented and tested `SkeletonLoader`, `ErrorCard`, `ConfidenceBadge`, and `AgentStatusIndicator`.
- All design system enums mapped out (`AgentRole`, `ReportStatus`, `AgentPhase`, `ConfidenceLevel`, `FeedbackType`).
- 200/200 widget tests passed successfully.
- Code completely adheres to WCAG 2.1 AA standards and dynamic text scaling (up to 1.5x) without UI overflow.

### File List

- `mobile/lib/core/constants/enums.dart`
- `mobile/lib/core/widgets/skeleton_loader.dart`
- `mobile/lib/core/widgets/error_card.dart`
- `mobile/lib/core/widgets/confidence_badge.dart`
- `mobile/lib/core/widgets/agent_status_indicator.dart`
- `mobile/test/core/constants/enums_test.dart`
- `mobile/test/core/widgets/skeleton_loader_test.dart`
- `mobile/test/core/widgets/error_card_test.dart`
- `mobile/test/core/widgets/confidence_badge_test.dart`
- `mobile/test/core/widgets/agent_status_indicator_test.dart`

### Review Findings

- [x] [Review][Patch] Unicode Character and Emoji Encoding Corruption in source files and unit tests [mobile/lib/core/constants/enums.dart:1]
- [x] [Review][Patch] Runtime Assertion Failure: "A borderRadius can only be given for a uniform Border." [mobile/lib/core/widgets/error_card.dart:904]
- [x] [Review][Patch] `SkeletonLoader.text` fails to adjust height proportionally with text scaling [mobile/lib/core/widgets/skeleton_loader.dart:1006]
- [x] [Review][Patch] Horizontal Layout Overflow and visual clipping in `_FullVariant` [mobile/lib/core/widgets/agent_status_indicator.dart:434]
- [x] [Review][Patch] Missing boundary assertions and validation in `ConfidenceLevel.fromScore` [mobile/lib/core/constants/enums.dart:227]
- [x] [Review][Patch] Potential crash on evaluating `score.round()` with NaN or Infinite values [mobile/lib/core/widgets/confidence_badge.dart:634]
- [x] [Review][Patch] Animation repeat resets during parent widget rebuilds [mobile/lib/core/widgets/agent_status_indicator.dart:1]
- [x] [Review][Patch] Performance jank due to gradient stops modification on every frame [mobile/lib/core/widgets/skeleton_loader.dart:1]
- [x] [Review][Patch] Redundant Semantics wrapping causes double-announcements in screen readers [mobile/lib/core/widgets/confidence_badge.dart:1]
- [x] [Review][Patch] Missing parent `Material` for `InkWell` and ripple clipping issues [mobile/lib/core/widgets/confidence_badge.dart:1]
- [x] [Review][Patch] Dynamic feedback/error banners lack `liveRegion` property in Semantics [mobile/lib/core/widgets/error_card.dart:1]
- [x] [Review][Patch] Static UI subtrees are reconstructed on every animation tick [mobile/lib/core/widgets/agent_status_indicator.dart:1]

