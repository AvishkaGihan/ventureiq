# Story 1.5: Flutter App Shell with Navigation & Theme Foundation

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want the Flutter app configured with Riverpod, GoRouter, Dio networking, and the VentureIQ design system foundation,
So that all mobile features have a consistent architecture and premium visual identity from day one.

## Acceptance Criteria

1. **Given** the Flutter project from Story 1.1 **When** the app shell is implemented **Then** `main.dart` wraps the app in `ProviderScope` and uses `MaterialApp.router` with GoRouter
2. **And** `app_router.dart` defines initial routes (splash, home/idea-input) with placeholder screens
3. **And** `core/theme/app_theme.dart` creates the dark `ThemeData` with complete `ColorScheme` mapping VentureIQ's surface system (`surface-000` through `surface-400`), brand accents (Electric Violet `#6C5CE7`, Cyan `#00D2FF`), and agent identity colors (UX-DR1)
4. **And** `core/theme/app_typography.dart` configures `TextTheme` with Inter + JetBrains Mono at all 8 type scale levels with correct weights and letter-spacing (UX-DR2)
5. **And** `core/theme/app_spacing.dart` defines the spacing scale (4px base, space-1 through space-10) and border radius scale (UX-DR3)
6. **And** All Material 3 components are themed to VentureIQ spec: Card, BottomSheet, TextField, FilledButton, TextButton, Chip, NavigationBar, SnackBar, Dialog — no component looks like default Material (UX-DR22)
7. **And** `core/networking/dio_client.dart` creates a Dio instance with base URL configuration, JSON interceptors, and logging interceptor
8. **And** `core/networking/api_endpoints.dart` defines API endpoint constants
9. **And** `core/networking/api_response.dart` implements response envelope parser
10. **And** `core/utils/responsive.dart` implements `ResponsiveConfig` with 3 screen tiers (Compact/Standard/Large) and properties (horizontalMargin, cardPadding, heroScoreSize, etc.) (UX-DR23)
11. **And** 4-tab bottom navigation is implemented (Home, Reports, Board, Profile) with Electric Violet active state (UX-DR27)
12. **And** Screen transitions follow spec: slide-in from right (forward), slide-up from bottom (modals), fade crossfade (tabs) (UX-DR27)
13. **And** Widget tests verify theme application and responsive config

## Tasks / Subtasks

- [x] Task 1: Add dependencies to `pubspec.yaml` (AC: all)
  - [x] 1.1: Add `flutter_riverpod`, `go_router`, `dio`, `google_fonts` with latest stable versions
  - [x] 1.2: Run `flutter pub get` to resolve dependencies

- [x] Task 2: Design System — Color palette (`core/theme/app_colors.dart`) (AC: #3)
  - [x] 2.1: Define all surface tokens: `surface000` through `surface400` (8 layers)
  - [x] 2.2: Define brand accent colors: Electric Violet `#6C5CE7`, Violet Hover `#7E70F0`, Cyan `#00D2FF`, Synthesis Violet `#A78BFA`
  - [x] 2.3: Define agent identity colors with full/muted/glow variants (Scout `#3B82F6`, Rival `#F43F5E`, CFO `#F59E0B`, Devil's Advocate `#EF4444`, Strategist `#10B981`, Coordinator `#A78BFA`)
  - [x] 2.4: Define confidence indicator colors (Verified Green `#22C55E`, Caution Amber `#F59E0B`, Warning Red `#EF4444`)
  - [x] 2.5: Define text system colors (`textPrimary` `#F0F1F5`, `textSecondary` `#A1A7BE`, `textTertiary` `#6B7194`, `textDisabled` `#464D6A`, `textInverse` `#09090B`)
  - [x] 2.6: Define feedback/status colors (Success, Warning, Error, Info)

- [x] Task 3: Design System — Typography (`core/theme/app_typography.dart`) (AC: #4)
  - [x] 3.1: Configure Inter as primary typeface via `google_fonts` package
  - [x] 3.2: Configure JetBrains Mono as monospace typeface
  - [x] 3.3: Define all 8 type scale levels (Display 40px, H1 28px, H2 22px, H3 18px, Body 15px, BodySM 13px, Caption 12px, Micro 11px) with correct weights and letter-spacing
  - [x] 3.4: Create `TextTheme` factory that maps to Material `TextTheme` slots

- [x] Task 4: Design System — Spacing (`core/theme/app_spacing.dart`) (AC: #5)
  - [x] 4.1: Define spacing scale constants: `space1` (4px) through `space10` (64px)
  - [x] 4.2: Define border radius scale: `radiusSm` (8px), `radiusMd` (12px), `radiusLg` (16px), `radiusXl` (20px), `radiusFull` (9999px)

- [x] Task 5: Design System — App Theme (`core/theme/app_theme.dart`) (AC: #3, #6)
  - [x] 5.1: Create dark `ThemeData` with custom `ColorScheme` mapping surface system
  - [x] 5.2: Theme Card: `surface050` fill, `surface300` border (1px), `radiusMd` (12dp), no elevation/shadow
  - [x] 5.3: Theme BottomSheet: `surface100` fill, `radiusXl` top corners, drag handle
  - [x] 5.4: Theme TextField: `surface200` fill, `radiusMd`, Electric Violet focus border + glow
  - [x] 5.5: Theme FilledButton: Electric Violet fill, `radiusSm`, `textInverse` text, hover → `violetHover`
  - [x] 5.6: Theme TextButton: Electric Violet text, no fill, transparent background
  - [x] 5.7: Theme Chip: `surface100` fill, `surface300` border, `radiusFull`
  - [x] 5.8: Theme NavigationBar: `surface050` fill, Electric Violet active indicator, `textTertiary` inactive
  - [x] 5.9: Theme SnackBar: `surface100` fill, `textPrimary` text, `radiusMd`
  - [x] 5.10: Theme Dialog: `surface100` fill, `radiusLg`, `surface300` border
  - [x] 5.11: Set `useMaterial3: true`, `brightness: Brightness.dark`

- [x] Task 6: Networking — Dio Client (`core/networking/dio_client.dart`) (AC: #7)
  - [x] 6.1: Create Dio singleton with base URL from env/config
  - [x] 6.2: Add JSON content-type interceptor (request/response)
  - [x] 6.3: Add logging interceptor (request URI, status, duration)
  - [x] 6.4: Configure connect/receive/send timeouts

- [x] Task 7: Networking — API Endpoints (`core/networking/api_endpoints.dart`) (AC: #8)
  - [x] 7.1: Define base path `/api/v1`
  - [x] 7.2: Define placeholder endpoint constants (health, ideas, reports, auth exchange)

- [x] Task 8: Networking — API Response (`core/networking/api_response.dart`) (AC: #9)
  - [x] 8.1: Create `ApiResponse<T>` model matching backend envelope: `{ data, meta: { request_id } }`
  - [x] 8.2: Create `ApiError` model: `{ code, message, details }`
  - [x] 8.3: Create response parser utility that handles success/error envelopes

- [x] Task 9: Responsive Config (`core/utils/responsive.dart`) (AC: #10)
  - [x] 9.1: Define 3 screen tiers: Compact (320–374dp), Standard (375–413dp), Large (414–480dp)
  - [x] 9.2: Expose tier-specific properties: `horizontalMargin`, `cardPadding`, `heroScoreSize`, `bodyFontSize`
  - [x] 9.3: Create `ResponsiveConfig.of(context)` factory using `MediaQuery`

- [x] Task 10: Navigation — Router (`app_router.dart`) (AC: #2, #11, #12)
  - [x] 10.1: Define `GoRouter` with `ShellRoute` for bottom navigation shell
  - [x] 10.2: Define routes: `/` (splash/redirect), `/home`, `/reports`, `/board`, `/profile`
  - [x] 10.3: Create placeholder screens for each tab (simple `Scaffold` with centered title text)
  - [x] 10.4: Implement bottom navigation shell with 4 tabs (Home, Reports, Board, Profile)
  - [x] 10.5: Implement screen transitions: slide-in-right (forward nav), slide-up (modals), fade crossfade (tabs)
  - [x] 10.6: Active tab uses Electric Violet indicator, inactive uses `textTertiary`

- [x] Task 11: App Entry Point (`main.dart`) (AC: #1)
  - [x] 11.1: Wrap app in `ProviderScope`
  - [x] 11.2: Use `MaterialApp.router` with `routerConfig` from `GoRouter`
  - [x] 11.3: Apply `AppTheme.darkTheme` to the app
  - [x] 11.4: Set `debugShowCheckedModeBanner: false`

- [x] Task 12: Widget Tests (AC: #13)
  - [x] 12.1: Test that `AppTheme.darkTheme` applies dark brightness and custom color scheme
  - [x] 12.2: Test that typography scale returns correct sizes and weights
  - [x] 12.3: Test `ResponsiveConfig` returns correct tier and properties for different widths
  - [x] 12.4: Test router navigates to placeholder screens
  - [x] 12.5: Test bottom navigation switches between tabs
  - [x] 12.6: Verify `ProviderScope` wraps the app (renders without error)

### Review Findings

- [x] [Review][Patch] Hero Score Size Spec Alignment (56/72/80) [mobile/lib/core/utils/responsive.dart]
- [x] [Review][Patch] Large Tier Body Font Size Spec Alignment (15px) [mobile/lib/core/utils/responsive.dart]
- [x] [Review][Patch] Tab Transition Duration Spec Alignment (150ms) [mobile/lib/app_router.dart]
- [x] [Review][Patch] Missing Splash Route [mobile/lib/app_router.dart]
- [x] [Review][Patch] Missing errorBuilder for unregistered routes [mobile/lib/app_router.dart:160]
- [x] [Review][Patch] Unused slideFromRight transition [mobile/lib/app_router.dart]
- [x] [Review][Patch] 4xx errors swallowed by Dio [mobile/lib/core/networking/dio_client.dart:36]
- [x] [Review][Patch] Memory leak in DioClient.reset [mobile/lib/core/networking/dio_client.dart:83]
- [x] [Review][Patch] Brittle breakpoint magic numbers [mobile/lib/core/utils/responsive.dart:88]
- [x] [Review][Patch] Insecure type check for 'error' payload [mobile/lib/core/networking/api_response.dart:65]
- [x] [Review][Patch] Missing 'data' key validation [mobile/lib/core/networking/api_response.dart:104]
- [x] [Review][Patch] Duplicate Card/ElevatedButton themes [mobile/lib/core/theme/app_theme.dart]
- [x] [Review][Patch] Lazy singleton pattern [mobile/lib/core/networking/dio_client.dart]
- [x] [Review][Patch] Fragile hardcoded string in widget tests [mobile/test/widget_test.dart]
- [x] [Review][Patch] Cargo-culted HttpOverrides [mobile/test/widget_test.dart]
- [x] [Review][Defer] Missing landscape responsive handling [mobile/lib/core/utils/responsive.dart:88] — deferred, pre-existing
- [x] [Review][Defer] Missing global error interceptor [mobile/lib/core/networking/dio_client.dart] — deferred, pre-existing


## Dev Notes

### Critical Architecture Constraints

**Project structure MUST follow architecture.md:**

```
mobile/lib/
├── core/
│   ├── theme/
│   │   ├── app_theme.dart      # ThemeData: dark theme, M3 overrides
│   │   ├── app_colors.dart     # Surface palette, agent colors
│   │   ├── app_typography.dart  # Inter + JetBrains Mono
│   │   └── app_spacing.dart    # Spacing scale
│   ├── networking/
│   │   ├── dio_client.dart     # Dio + interceptors
│   │   ├── api_endpoints.dart  # Endpoint constants
│   │   └── api_response.dart   # Response envelope parser
│   ├── constants/              # Created but empty for now
│   │   └── (empty — populated in Story 1.6)
│   ├── utils/
│   │   └── responsive.dart     # ResponsiveConfig
│   └── widgets/                # Created but empty for now
│       └── (empty — populated in Story 1.6)
├── features/                   # Created but empty for now
│   └── (empty — populated starting Epic 2)
├── app_router.dart
└── main.dart
```

[Source: architecture.md#Flutter Project Organization, lines 422-448]

**Placeholder screens** for routes go in a temporary location (e.g., inside `app_router.dart` as private widgets or in a `core/screens/` placeholder file). These will be replaced by feature-specific screens in later stories.

### Design System Specifications

**Surface System (8 Layers) — EXACT hex values required:**

| Token | Hex | Material `ColorScheme` Mapping |
|:--|:--|:--|
| `surface000` | `#09090B` | `surface` (app background) |
| `surface050` | `#0F1117` | `surfaceContainerLow` (card bg) |
| `surface100` | `#151823` | `surfaceContainer` (elevated cards) |
| `surface150` | `#1A1E2E` | `surfaceContainerHigh` (active/hover) |
| `surface200` | `#222639` | `surfaceContainerHighest` (inputs) |
| `surface250` | `#2A2F45` | (custom — not mapped to ColorScheme) |
| `surface300` | `#343A52` | `outline` (borders) |
| `surface400` | `#4A5173` | `outlineVariant` (muted icons/dividers) |

**Brand Accents:**

| Color | Hex | Material Mapping |
|:--|:--|:--|
| Electric Violet | `#6C5CE7` | `primary` |
| Violet Hover | `#7E70F0` | (custom) |
| Cyan | `#00D2FF` | `secondary` |
| Synthesis Violet | `#A78BFA` | `tertiary` |

[Source: ux-design-specification.md#Color System, lines 429-518]

**Typography — EXACT type scale:**

| Level | Size | Weight | Letter Spacing | Material Slot |
|:--|:--|:--|:--|:--|
| Display | 40px | 800 (ExtraBold) | -0.03em | `displayLarge` |
| H1 | 28px | 700 (Bold) | -0.02em | `headlineLarge` |
| H2 | 22px | 700 (Bold) | -0.02em | `headlineMedium` |
| H3 | 18px | 600 (SemiBold) | -0.01em | `titleLarge` |
| Body | 15px | 400 (Regular) | 0 | `bodyLarge` |
| Body SM | 13px | 400 (Regular) | 0 | `bodyMedium` |
| Caption | 12px | 400 (Regular) | 0 | `bodySmall` |
| Micro | 11px | 500 (Medium) | 0.02em | `labelSmall` |

Use `GoogleFonts.inter()` for primary text and `GoogleFonts.jetBrainsMono()` for monospace data. Do NOT bundle fonts as assets — use `google_fonts` runtime fetching for development. Line-height: `1.6` for body, `1.1-1.2` for display/headings.

[Source: ux-design-specification.md#Typography System, lines 519-545]

**Spacing Scale:**

| Token | Value |
|:--|:--|
| `space1` | 4px |
| `space2` | 8px |
| `space3` | 12px |
| `space4` | 16px |
| `space5` | 20px |
| `space6` | 24px |
| `space7` | 32px |
| `space8` | 40px |
| `space9` | 48px |
| `space10` | 64px |

**Border Radius:**

| Token | Value |
|:--|:--|
| `radiusSm` | 8px |
| `radiusMd` | 12px |
| `radiusLg` | 16px |
| `radiusXl` | 20px |
| `radiusFull` | 9999px |

[Source: ux-design-specification.md#Spacing & Layout Foundation, lines 546-581]

**Component Theming Requirements (UX-DR22):**

Every Material component MUST be themed — no default Material look:
- **Card:** `surface050` fill, `1px solid surface300` border, `radiusMd`, 0 elevation (no shadow)
- **BottomSheet:** `surface100` fill, `radiusXl` top corners only, include drag handle
- **TextField:** `surface200` fill, `radiusMd`, Electric Violet focus border, `boxShadow: 0 0 20px rgba(108,92,231,0.3)` glow on focus
- **FilledButton:** Electric Violet bg, `radiusSm`, `textInverse` text, 48dp min height for touch targets
- **TextButton:** Electric Violet text, transparent bg, no border
- **Chip:** `surface100` fill, `surface300` border, `radiusFull`
- **NavigationBar:** `surface050` bg, Electric Violet active indicator, no labels by default (or with `textTertiary` inactive labels)
- **SnackBar:** `surface100` bg, `textPrimary` text, `radiusMd`, bottom position, 4s auto-dismiss
- **Dialog:** `surface100` bg, `radiusLg`, `surface300` border

[Source: ux-design-specification.md#Design System Choice, epics.md#Story 1.5 AC #6]

**Responsive Config (UX-DR23):**

| Tier | Width Range | Horizontal Margin |
|:--|:--|:--|
| Compact | 320–374dp | 12px |
| Standard | 375–413dp | 16px |
| Large | 414–480dp | 20px |

Properties per tier: `horizontalMargin`, `cardPadding`, `heroScoreSize`, `bodyFontSize`.

[Source: ux-design-specification.md#Spacing & Layout Foundation, epics.md#Story 1.5 AC #10]

### Networking Architecture

**Dio Client configuration:**
- Base URL: Configurable (default: `http://10.0.2.2:8000` for Android emulator, `http://localhost:8000` for iOS simulator)
- Connect timeout: 15 seconds
- Receive timeout: 30 seconds
- Send timeout: 15 seconds
- JSON interceptor: sets `Content-Type: application/json`, `Accept: application/json`
- Logging interceptor: logs request method/URL, response status, and duration in debug mode only

**API Response envelope** must match backend format exactly:

```dart
// Success
{ "data": { ... }, "meta": { "request_id": "uuid" } }

// Error
{ "error": { "code": "ERROR_CODE", "message": "...", "details": { ... } }, "meta": { "request_id": "uuid" } }
```

[Source: architecture.md#Format Patterns — API Response Formats, lines 460-488]

### Navigation Architecture

**GoRouter with ShellRoute pattern:**
- Use `ShellRoute` to wrap the 4-tab bottom navigation shell
- Routes: `/home`, `/reports`, `/board`, `/profile`
- Initial route: `/home` (splash screen deferred to Story 15.1)
- Each tab uses a `StatefulShellRoute.indexedStack` for preserving tab state
- Screen transitions:
  - Forward navigation: slide from right (0.3s ease)
  - Modal sheets: slide from bottom
  - Tab switching: fade crossfade (0.25s)
- `GoRouter` instance should be provided as a Riverpod `Provider` for testability

[Source: architecture.md#Frontend Architecture, epics.md#Story 1.5 AC #11-12, ux-design-specification.md#Navigation Patterns UX-DR27]

### Naming Conventions (Dart)

| Element | Convention | Example |
|:--|:--|:--|
| Files | `snake_case.dart` | `app_theme.dart`, `dio_client.dart` |
| Classes | `PascalCase` | `AppTheme`, `DioClient`, `ResponsiveConfig` |
| Functions/Methods | `camelCase` | `buildDarkTheme()`, `getScreenTier()` |
| Variables | `camelCase` | `horizontalMargin`, `cardPadding` |
| Constants | `camelCase` or `kPrefixed` | `surface000`, `kDefaultTimeout` |
| Private members | `_prefixed` | `_dio`, `_interceptors` |
| Riverpod providers | `{feature}{Type}Provider` | `routerProvider` |
| GoRouter routes | `/{kebab-case}` | `/home`, `/reports`, `/board`, `/profile` |

[Source: architecture.md#Naming Patterns — Code Naming Conventions, lines 366-381]

### Dependencies to Add

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^3.3.0    # State management — AsyncNotifier patterns
  go_router: ^7.0.0           # Declarative routing, deep linking, ShellRoute
  dio: ^5.9.2                 # HTTP client with interceptors
  google_fonts: ^8.1.0        # Inter + JetBrains Mono typefaces

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

**DO NOT add:**
- ❌ `riverpod_annotation` / `riverpod_generator` — use manual providers, not code-gen, for this story
- ❌ `freezed` / `json_serializable` / `build_runner` — not needed until data models (Story 2.x+)
- ❌ `web_socket_channel` — not needed until War Room (Story 4.x)
- ❌ `hive` / `hive_flutter` — not needed until offline caching (later stories)
- ❌ `fl_chart` — not needed until Report UI (Story 5/6)
- ❌ `firebase_core` / `firebase_auth` — not needed until Auth (Story 2.x)
- ❌ `flutter_secure_storage` — not needed until Auth (Story 2.x)

### Anti-Patterns to AVOID

- ❌ Do NOT use `ColorScheme.fromSeed()` — define all colors explicitly per UX spec
- ❌ Do NOT leave any component with default Material look — every component must be themed
- ❌ Do NOT hardcode colors/sizes in widgets — always reference `AppColors`, `AppSpacing`, `AppTypography`
- ❌ Do NOT use `Navigator` directly — all navigation through GoRouter
- ❌ Do NOT use `setState` for state management — use Riverpod providers
- ❌ Do NOT use `print()` — use `debugPrint()` or logging
- ❌ Do NOT create feature screens — only placeholder screens for route testing
- ❌ Do NOT implement auth interceptors — that's Story 2.2
- ❌ Do NOT implement WebSocket client — that's Story 4.x
- ❌ Do NOT implement custom widgets (ConfidenceBadge, AgentStatus, etc.) — that's Story 1.6
- ❌ Do NOT manually manage `==`, `hashCode`, `copyWith` — use `freezed` when data models are needed (not this story)

### Scope Boundaries

**IN SCOPE:**
- `pubspec.yaml` — Updated dependencies
- `lib/main.dart` — ProviderScope + MaterialApp.router entry point
- `lib/app_router.dart` — GoRouter with ShellRoute and placeholder screens
- `lib/core/theme/app_colors.dart` — Complete color palette
- `lib/core/theme/app_typography.dart` — Inter + JetBrains Mono type scale
- `lib/core/theme/app_spacing.dart` — Spacing + border radius constants
- `lib/core/theme/app_theme.dart` — Dark ThemeData with all component themes
- `lib/core/networking/dio_client.dart` — Dio instance + interceptors
- `lib/core/networking/api_endpoints.dart` — Endpoint constants
- `lib/core/networking/api_response.dart` — Response envelope parser
- `lib/core/utils/responsive.dart` — ResponsiveConfig with 3 tiers
- Widget tests for theme, typography, responsive config, navigation

**OUT OF SCOPE:**
- **NO** feature screens — only placeholder shells
- **NO** custom widgets (ConfidenceBadge, SkeletonLoader, ErrorCard, AgentStatusIndicator) — Story 1.6
- **NO** auth/JWT interceptors — Story 2.2
- **NO** WebSocket client — Story 4.x
- **NO** local storage (Hive) — later stories
- **NO** Firebase integration — Story 2.x
- **NO** splash screen / onboarding — Story 15.1
- **NO** freezed / code generation — not until data models needed
- **NO** `core/constants/enums.dart` (AgentRole, ReportStatus) — Story 1.6
- **NO** `core/networking/ws_client.dart` — Story 4.x

### Previous Story Intelligence (Story 1.4)

**Patterns from previous stories to follow:**
- `ruff check` equivalent in Flutter: `dart analyze` (enforced by `analysis_options.yaml`)
- `analysis_options.yaml` already configured with strict lints including `prefer_const_constructors`, `require_trailing_commas`, `prefer_single_quotes`, `use_full_hex_values_for_flutter_colors`
- All generated files (`.g.dart`, `.freezed.dart`, `.mocks.dart`) excluded from analysis
- Code must be `avoid_print: true` — use `debugPrint()` or `log()` instead
- `use_key_in_widget_constructors: true` — every widget needs `Key? key` in constructor

**Project context:**
- Dart SDK: `^3.11.1` (from `pubspec.yaml`)
- App name: `ventureiq_app` (org: `com.ventureiq`)
- The Flutter project is in its default scaffold state — `main.dart` has the default counter app
- All existing default code should be replaced completely

### Testing Requirements

**Test framework:** `flutter_test` (already in dev deps)

**Test file locations (mirror source):**
```
mobile/test/
├── core/
│   ├── theme/
│   │   ├── app_theme_test.dart
│   │   ├── app_colors_test.dart
│   │   └── app_typography_test.dart
│   ├── networking/
│   │   └── dio_client_test.dart
│   └── utils/
│       └── responsive_test.dart
├── app_router_test.dart
└── main_test.dart  (optional — verify app renders)
```

**Required test coverage:**
1. `app_theme_test.dart` — Verify `darkTheme` has dark brightness, correct primary/secondary/surface colors from ColorScheme
2. `app_colors_test.dart` — Verify all hex values match spec (spot-check key tokens)
3. `app_typography_test.dart` — Verify type scale sizes, weights, and letter-spacing
4. `responsive_test.dart` — Verify tier detection and properties for widths: 350dp (Compact), 390dp (Standard), 430dp (Large)
5. `app_router_test.dart` — Verify initial route, tab navigation between all 4 tabs
6. `dio_client_test.dart` — Verify Dio instance has correct timeouts and interceptor count

**Test pattern:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('dark theme has correct brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('primary color is Electric Violet', () {
      final theme = AppTheme.darkTheme;
      expect(theme.colorScheme.primary, const Color(0xFF6C5CE7));
    });
  });
}
```

For widget tests involving navigation, wrap with `MaterialApp.router` + `ProviderScope`:

```dart
await tester.pumpWidget(
  ProviderScope(
    child: MaterialApp.router(
      routerConfig: goRouter,
      theme: AppTheme.darkTheme,
    ),
  ),
);
```

### Project Structure Notes

- All files go under `mobile/lib/core/` or `mobile/lib/` (for `main.dart` and `app_router.dart`)
- Empty `__init__` directories: create `core/constants/`, `core/widgets/`, `features/` with placeholder (or just empty) — they'll be populated by subsequent stories
- Follows `data/domain/presentation` triad per feature — but no features in this story, just the core shell
- Test files mirror source structure under `mobile/test/`

[Source: architecture.md#Flutter Project Organization, architecture.md#Test Organization]

### References

- [Source: architecture.md#Flutter Project Organization] — Complete directory structure for mobile
- [Source: architecture.md#Frontend Architecture] — Riverpod dispatcher pattern, offline strategy, voice input
- [Source: architecture.md#Communication Patterns — Riverpod State Management] — Provider naming, notifier classes
- [Source: architecture.md#Format Patterns — API Response Formats] — Envelope format specification
- [Source: architecture.md#Process Patterns — Error Handling] — Flutter `AsyncValue.error` pattern
- [Source: architecture.md#Enforcement Guidelines] — 10 rules for all AI agents
- [Source: architecture.md#Naming Patterns — Code Naming Conventions] — Dart naming conventions
- [Source: epics.md#Story 1.5] — Acceptance criteria (lines 403-426)
- [Source: epics.md#Story 1.6] — Next story context (lines 427-447)
- [Source: ux-design-specification.md#Color System] — Complete color palette (lines 429-518)
- [Source: ux-design-specification.md#Typography System] — Type scale specification (lines 519-545)
- [Source: ux-design-specification.md#Spacing & Layout Foundation] — Spacing and radius scales (lines 546-581)
- [Source: ux-design-specification.md#Accessibility Considerations] — Contrast ratios, touch targets (lines 583-614)

## Dev Agent Record

### Agent Model Used

Gemini 3.1 Pro (High)

### Debug Log References

- Fixed static analysis warnings regarding newer Flutter API changes (`CardThemeData`, `DialogThemeData`).
- Fixed dangling document comment in `api_response.dart`.
- Encountered GoogleFonts fetching exceptions during widget testing due to `GoogleFonts.config.allowRuntimeFetching = false` without local assets. Solved by allowing runtime fetching via `HttpOverrides.global` and `TestWidgetsFlutterBinding.ensureInitialized()` within all test files.

### Completion Notes List

- Design system (colors, typography, spacing) implemented successfully per the design spec without falling back to default Material 3 styling.
- Dio networking established with centralized API endpoints and an envelope parsing utility.
- GoRouter navigation configured with `StatefulShellRoute.indexedStack` for persistent state across the bottom navigation tabs.
- `flutter analyze` passes with 0 issues.
- `flutter test` passes with 118 out of 118 passing tests covering navigation, UI responsiveness, and theme mappings.

### File List

- `mobile/pubspec.yaml`
- `mobile/lib/core/theme/app_colors.dart`
- `mobile/lib/core/theme/app_typography.dart`
- `mobile/lib/core/theme/app_spacing.dart`
- `mobile/lib/core/theme/app_theme.dart`
- `mobile/lib/core/networking/dio_client.dart`
- `mobile/lib/core/networking/api_endpoints.dart`
- `mobile/lib/core/networking/api_response.dart`
- `mobile/lib/core/utils/responsive.dart`
- `mobile/lib/app_router.dart`
- `mobile/lib/main.dart`
- `mobile/test/core/theme/app_theme_test.dart`
- `mobile/test/core/theme/app_colors_test.dart`
- `mobile/test/core/theme/app_typography_test.dart`
- `mobile/test/core/utils/responsive_test.dart`
- `mobile/test/core/networking/dio_client_test.dart`
- `mobile/test/app_router_test.dart`
- `mobile/test/widget_test.dart`
