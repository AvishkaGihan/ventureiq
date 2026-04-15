---
stepsCompleted: ["step-01-validate-prerequisites", "step-02-design-epics", "step-03-create-stories"]
inputDocuments:
  - "prd.md"
  - "architecture.md"
  - "ux-design-specification.md"
---

# VentureIQ - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for VentureIQ, decomposing the requirements from the PRD, UX Design Specification, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: Users can submit a business idea as free-form text
FR2: Users can submit a business idea via voice input
FR3: Users can provide optional context fields alongside their idea (target audience, industry, monetization model, region)
FR4: The system can assess idea plausibility and prompt the user to refine low-quality or nonsensical submissions before consuming AI resources
FR5: The system can execute five specialized AI agents (Scout, Rival, CFO, Devil's Advocate, Strategist) in parallel to analyze a submitted idea
FR6: Users can observe each agent's reasoning streamed in real time as it is generated
FR7: Users can see each agent's current lifecycle state (started, searching, analyzing, cross-referencing, complete)
FR8: The system can execute a cross-referencing pass where agents adjust their outputs based on other agents' findings
FR9: Users can observe cross-agent referencing as it occurs (e.g., Strategist reacting to Devil's Advocate findings)
FR10: The system can synthesize all agent outputs into a unified Viability Score with weighted breakdown across five dimensions (Market, Competition, Financials, Risk, Execution)
FR11: Users can view an Executive Summary with a Viability Score and visual radar chart breakdown
FR12: Users can view each individual agent's full analysis within a completed report
FR13: Users can access an Evidence Panel displaying source citations and confidence scores for all quantitative claims
FR14: Users can tap any cited claim to view or navigate to the original source
FR15: The system can flag claims as "unverified estimate" when verifiable sources are unavailable
FR16: Users can view a Market & Competitor Map with positioning visualization and identified market gaps
FR17: Users can view competitive landscape analysis including competitor strengths, weaknesses, and whitespace opportunities
FR18: Users can view a Risk Radar with ranked risks including likelihood, impact, and mitigation strategies
FR19: Users can view a Go-to-Market plan with launch strategy, target persona, and key metrics
FR20: Users can adjust key business variables (pricing, target audience, region, etc.) via interactive sliders
FR21: The system can re-execute or recalculate agent projections based on modified scenario variables
FR22: Users can observe how the Viability Score shifts across different parameter combinations
FR23: Users can place two or more previously generated reports side-by-side for structured comparison
FR24: Users can view a diff-style visualization highlighting key differences between compared ideas
FR25: The system can surface a comparative recommendation that includes (a) a recommended option or "no recommendation", (b) per-dimension score deltas, and (c) key drivers/assumptions behind the recommendation
FR26: Users can ask follow-up questions about a completed report in a conversational interface
FR27: The system can respond to user questions grounded in the full report context and agent findings
FR28: The system can maintain cross-session conversation history so returning users resume with prior context
FR29: Users can view the full conversation history for each report
FR30: Users can view a visual timeline of how multi-agent analysis unfolded for a given report
FR31: Users can scrub through the timeline to inspect specific moments in the agent reasoning process
FR32: Users can identify key inflection points where one agent's findings influenced another
FR33: Users can export a completed report as a PDF that includes the Executive Summary, Viability Score breakdown, agent analyses, and citations/confidence scores
FR34: Users can generate a shareable web link to a report
FR35: Recipients of a shared link can view the report without requiring a VentureIQ account
FR36: Users can sign in with a Google account
FR37: Users can use the app without signing in (anonymous access) to generate and view reports on-device; cross-device access requires sign-in
FR38: Anonymous users can upgrade to a signed-in account and retain their data
FR39: The system can enforce tier-based usage limits (3 reports/month for free tier, unlimited for Pro)
FR40: Users can view their report history and revisit previously generated reports
FR41: Users can view previously generated reports while offline
FR42: Signed-in users can access their reports across sessions and devices
FR43: Users can receive push notifications when a report finishes generating (especially after backgrounding the app)
FR44: Users can opt in/out of re-engagement notifications
FR45: Operators can view execution traces per agent including latency and token consumption
FR46: Operators can monitor cost-per-report and cost-per-agent metrics in real time
FR47: Operators can track agent error rates and identify degradation patterns
FR48: Operators can monitor search provider health and cache hit rates
FR49: Operators can view aggregated system health summaries across time periods
FR50: The system can sanitize all user inputs against prompt injection before passing to agents
FR51: The system can enforce per-agent token budget ceilings with graceful degradation on exceeding limits
FR52: The system can complete reports with reduced confidence when individual agents fail (graceful degradation)
FR53: The system can automatically reconnect streaming sessions after connection drops and replay missed events

### NonFunctional Requirements

NFR1: Time-to-first-token for War Room streaming must be under 2 seconds from idea submission, measured end-to-end from client submission to first token rendered in the client UI under standard load
NFR2: Agent token streaming must display with under 1 second latency between token generation and client display, measured using server emission timestamps and client render timestamps under standard load
NFR3: Full 5-agent report generation (parallel execution → cross-referencing → synthesis) must complete within 60–90 seconds under standard load, measured end-to-end from idea submission to report completion
NFR4: App launch to interactive state must occur within 3 seconds on mid-range devices (circa 2023 hardware), measured as time-to-interactive via mobile performance instrumentation
NFR5: Offline report retrieval from local cache must load within 500 milliseconds, measured on-device as time to render the cached report view
NFR6: Scenario Simulator variable adjustments must reflect updated projections within 10 seconds, measured end-to-end from parameter change to updated projections rendered in the UI
NFR7: Ask the Board conversational responses must begin streaming within 3 seconds of query submission, measured end-to-end from request submit to first token rendered in the client UI
NFR8: PDF export generation must complete within 15 seconds of user request, measured end-to-end from export request to PDF ready for download
NFR9: All data in transit must be encrypted via TLS 1.2+, verified via periodic TLS configuration audits and automated SSL/TLS scans of all public endpoints
NFR10: All user data at rest (ideas, reports, session history) must be encrypted in the primary persistent datastore, verified via periodic security configuration audits
NFR11: All LLM and search provider API keys must be stored server-side only; the mobile client must never have access to third-party API credentials, verified via code review and client artifact inspection to confirm no embedded credentials
NFR12: All user inputs must be sanitized against prompt injection before reaching any agent prompt, verified via automated sanitization tests using a prompt-injection test corpus
NFR13: Inter-agent data flowing through shared state must be validated against expected schemas before consumption, verified via schema validation tests and inter-agent integration tests
NFR14: User-submitted ideas and generated reports must never be used for model training, analytics beyond operational metrics, or shared with third parties, verified via data handling policy/configuration audits and code review of logging/export paths
NFR15: No personally identifiable information beyond what the user explicitly provides may be stored in vector storage used for semantic memory or included in LLM prompts, verified via PII detection tests on stored vectors and prompt logs
NFR16: Access tokens must implement refresh token rotation; session tokens must expire after a configurable inactivity period, verified via token lifecycle unit tests and session timeout integration tests
NFR17: Ephemeral session/state data must be cleared after session expiration, verified via TTL/cleanup tests and periodic storage audits
NFR18: The system must be architected to support 100+ concurrent users without degradation beyond 10% of baseline latency targets, measured via load testing at 100 concurrent active sessions against baseline latency targets
NFR19: The backend must support horizontal scaling via stateless application servers with shared state stores and shared persistent datastores, verified via multi-instance deployment tests confirming statelessness and shared datastore consistency
NFR20: WebSocket streaming must support at least 100 concurrent active streams with <1% server-side connection errors, measured via load testing and connection error logs
NFR21: LLM API call concurrency must enforce provider rate limits with backpressure so rate-limit errors attributable to concurrency control are 0 in load tests at the configured ceiling, measured via provider response codes and internal counters
NFR22: A cache layer must reduce redundant LLM/search calls by at least 20% per report compared to a no-cache baseline in a standardized test run, with configurable TTL, measured via request counters in logs/metrics
NFR23: The system must achieve >95% agent completion rate (all 5 agents + Coordinator finishing without errors), measured via execution logs over a rolling 7-day window
NFR24: Individual agent failures must not crash the pipeline; the Coordinator must synthesize available data with a reduced confidence score, verified via agent failure injection tests confirming pipeline continuation and reduced-confidence output
NFR25: WebSocket disconnections must trigger automatic client reconnection with server-side replay of missed events from a server-side stream buffer, verified via connection-drop simulation tests confirming automatic reconnection and gapless event replay
NFR26: LLM provider unavailability must trigger automatic failover to a fallback provider transparently to the user, verified via provider-outage simulation tests confirming transparent failover and report completion
NFR27: Search provider rate limiting must be handled with exponential backoff, request queuing, and cached fallback data, verified via rate-limit simulation tests confirming backoff, queuing, and cached fallback behavior
NFR28: Token budget overruns must result in graceful output truncation with structured summaries, not raw mid-sentence cutoffs, verified via token-budget exhaustion tests confirming structured-summary output
NFR29: The system must handle app backgrounding during report generation and resume streaming on foreground without data loss, verified via app background/foreground lifecycle tests confirming stream resume via buffered replay without loss
NFR30: Every report execution must generate a complete trace capturing per-agent latency, token consumption, and API cost, verified via trace audits confirming required fields are present per execution
NFR31: Execution traces must be accessible via a tracing UI or exportable to tracing infrastructure, verified via operational checks confirming traces are viewable in a UI or exportable
NFR32: Metrics must capture request latency, error rates, cache hit ratios, and cost-per-report at minimum, verified via metrics audits confirming required fields are emitted and queryable
NFR33: Agent error rates must be trackable per-agent with historical trend visibility, verified via metrics/dashboards checks confirming per-agent error-series and historical retention
NFR34: Cost-per-report must be calculable from logged token consumption and provider pricing, verified via cost calculation tests confirming accurate token-to-cost mapping per report
NFR35: The app must support platform-native screen reader accessibility (VoiceOver on iOS, TalkBack on Android) for core user flows (idea submission, report viewing), verified via VoiceOver/TalkBack testing of core flows (labels, focus order, actions)
NFR36: All interactive elements must meet minimum touch target sizes (48x48dp) per platform guidelines, verified via automated UI checks and manual accessibility audit
NFR37: Text contrast ratios must meet WCAG 2.1 AA standards (4.5:1 for normal text, 3:1 for large text), verified via design review and accessibility audit
NFR38: The app must support dynamic text sizing based on system accessibility settings, verified via accessibility testing across system text scales without layout breakage
NFR39: All LLM interactions must be abstracted behind a provider-agnostic interface enabling provider swaps without agent code changes, verified via provider-swap integration tests demonstrating no agent code changes
NFR40: Search provider integration must be abstracted to support swapping providers (free vs. paid) without agent code changes, verified via provider-swap integration tests demonstrating no agent code changes
NFR41: Authentication must support both Google account sign-in and anonymous authentication flows, verified via authentication integration tests for both flows
NFR42: Push notifications must achieve >= 99% delivery success (excluding invalid/unregistered devices), measured via push provider delivery receipts and in-app receipt telemetry
NFR43: The API must maintain backward compatibility within major versions (v1); breaking changes require version increment, verified via backward-compatibility contract tests and versioning policy enforcement

### Additional Requirements

- Architecture specifies **manual scaffolding** for both Flutter (`flutter create`) and Python backend (`uv init`), confirming greenfield starter template — impacts Epic 1, Story 1
- **Monorepo structure** required: `ventureiq/mobile/` (Flutter) + `ventureiq/backend/` (Python FastAPI) + root docker-compose.yml
- **Docker Compose** local dev environment required from day one: backend + Redis + PostgreSQL + ChromaDB containers
- **Layered data model** architecture: separate Pydantic schemas (API), SQLAlchemy models (DB), TypedDict state (LangGraph) with explicit mapping between layers
- **Redis logical databases**: db0 (streaming state), db1 (cache), db2 (rate limiting) — requires RedisManager abstraction
- **JWT architecture**: Firebase → Backend token exchange pattern — client sends Firebase ID token, backend verifies and issues its own JWT with custom claims
- **WebSocket single-connection model**: one bidirectional connection per streaming session with typed event envelope format
- **Provider-agnostic abstraction**: LLMProvider ABC and SearchProvider ABC in `app/providers/` — required before any agent implementation
- **Google Cloud Run (2nd gen)** deployment target with multi-stage Docker builds
- **GitHub Actions CI/CD** pipeline: backend-ci.yml, mobile-ci.yml, deploy.yml
- **Pydantic BaseSettings** + `.env` for local config, GCP Secret Manager for production
- **Alembic** database migrations from day one — schema versioning alongside code
- **API response envelope format**: `{ data, meta: { request_id } }` for success, `{ error: { code, message, details }, meta }` for errors — enforced on all endpoints
- **WebSocket event format**: `{ event_type, timestamp, payload }` — 10 server→client event types, 3 client→server control types
- **Ruff** for Python linting/formatting, **Dart analyzer** for Flutter — enforced in CI
- **freezed + json_serializable** for all Dart data classes — no manual equals/hashCode/copyWith
- **Structured JSON logging** with `request_id` propagation across all backend layers
- **12-step implementation sequence** defined in Architecture: monorepo → FastAPI skeleton → DB models → Firebase Auth → LangGraph agents → WebSocket streaming → Flutter shell → War Room UI → Report persistence → Extended features → CI/CD → Observability
- **~120 explicitly named files** across both platforms in the directory structure specification

### UX Design Requirements

UX-DR1: Implement the complete dark premium design token system — 8-layer surface palette (`surface-000` through `surface-400`), brand accents (Electric Violet, Cyan, Synthesis Violet), 6 agent identity colors with full/muted/glow variants, confidence indicator colors (green/amber/red), 5-level text system, and special effects (glows, borders)
UX-DR2: Implement the typography system — Inter as primary typeface, JetBrains Mono for monospace data, 8-level type scale (Display 40px through Micro 11px) with specific weights, letter-spacing values, and line-height rules
UX-DR3: Implement the spacing and layout foundation — 4px base unit, 10-level spacing scale (space-1 through space-10), 5-level border radius scale (radius-sm through radius-full), mobile-first vertical stacking, 48dp touch targets, edge-to-edge cards with consistent gutters
UX-DR4: Build the WarRoomAgentCard custom component — 3 variants (Expanded/Spotlight, Compact/Awareness Strip, Grid/Command Center) with 6 states (initializing, searching, analyzing, cross-referencing, complete, error), composing StreamingTextDisplay + AgentStatusIndicator + CrossReferenceBadge
UX-DR5: Build the StreamingTextDisplay custom component — token-by-token rendering with ~30ms cadence, inline InlineCitationSuperscript elements, blinking Cyan cursor, auto-scroll behavior, 3 states (streaming, paused, complete)
UX-DR6: Build the CrossReferenceBadge custom component — tappable inline badge ("📎 Responding to [Agent Name]") in Synthesis Violet, 3 states (default, tapped, highlight pulse), 2 variants (Inline, Card Header)
UX-DR7: Build the ConfidenceBadge custom component — institutional-grade pill-shaped indicators with color + text label, 3 confidence levels (High ≥80% green, Mid 50-79% amber, Low <50% red), 3 variants (Pill, Compact, Large)
UX-DR8: Build the ViabilityScoreDisplay custom component — cinematic hero element with Cyan→Violet gradient, radial glow, count-up animation (0→score over 1.2s with haptic), anchor labels by score range, 3 variants (Hero 72px, Card 28px, Inline 15px)
UX-DR9: Build the DimensionalBreakdownBar custom component — horizontal progress bars for 5 dimensions (Market/Competition/Financials/Risk/Execution) with dimension-appropriate colors, animated fill (0.8s staggered), tappable for detail sheet
UX-DR10: Build the RadarChart custom component — 5-axis spider chart via fl_chart or CustomPaint, Electric Violet filled polygon at 20% opacity, animated vertex expansion, comparison overlay variant with dual polygons, text alternative for screen readers
UX-DR11: Build the SourceCitationCard custom component — expandable source details with title, URL/favicon, ConfidenceBadge, snippet, agent attribution with agent-colored 4dp left border, 3 states (collapsed, expanded, bottom_sheet)
UX-DR12: Build the InlineCitationSuperscript custom component — numbered superscript references [1][2] in Electric Violet, tappable to open SourceCitationCard as bottom sheet, Micro typography (11px)
UX-DR13: Build the AgentStatusIndicator custom component — multi-phase lifecycle indicator with phase-appropriate icons and text (Started→Searching→Analyzing→Cross-referencing→Complete→Error), 3 variants (Badge, Full, Dot)
UX-DR14: Build the DecisionTimeline custom component — horizontal scrubbing timeline with agent-colored event markers, draggable scrubber thumb, event detail panel, causal connection lines, playback controls (play/pause, speed)
UX-DR15: Build the ScenarioSlider custom component — variable slider with label, JetBrains Mono value display, Cyan track, tick marks, delta indicator (↑+4/↓-6 with color), original value marker
UX-DR16: Build the ReportHistoryCard custom component — report card with idea title, ViabilityScoreDisplay (Card variant), date, agent completion status, selection checkbox for comparative analysis
UX-DR17: Build the KeyInsightCard custom component — callout card with agent-colored 4dp left border, agent icon + name attribution, 1-3 sentence insight text
UX-DR18: Build the AskTheBoardBubble custom component — chat message bubble with InlineCitationSuperscript, agent attribution, ConfidenceBadge on claims, 2 variants (User right-aligned, Board left-aligned with streaming)
UX-DR19: Implement War Room Hybrid Adaptive layout — Spotlight mode as default (one expanded agent + compact awareness strip) with "Expand All" toggle to Command Center 2×2+1 grid, user preference persistence, auto-spotlight for most active agent
UX-DR20: Implement the Score Reveal animation sequence — score count-up (0→final over 1.2s ease-out), anchor label fade-in (0.3s delay), dimensional bars animation (0.8s simultaneous fill, 0.1s stagger), KeyInsightCard slide-up (0.4s delay), haptic pulse on landing
UX-DR21: Implement the Evidence Panel — Perplexity-style inline citation superscripts in report text, expandable source cards on tap (bottom sheet), agent attribution per citation, confidence badges per claim, summary stats header ("12 sources · 3 agents cited · 78% avg confidence")
UX-DR22: Theme all Material Design 3 components to VentureIQ specification — Card, BottomSheet, TextField, FilledButton, TextButton, Chip, NavigationBar, TabBar, ExpansionTile, SegmentedButton, Slider, SnackBar, LinearProgressIndicator, Dialog, ListTile, Divider, SearchBar — no component should look like default Material
UX-DR23: Implement the responsive design system — ResponsiveConfig utility with 3 screen tiers (Compact 320-374dp, Standard 375-413dp, Large 414-480dp), screen-tier-adaptive War Room, proportional Score Reveal scaling, safe area handling, keyboard avoidance
UX-DR24: Implement full accessibility compliance — VoiceOver/TalkBack screen reader support with semantic labels for all custom widgets, live region strategy for War Room streaming, touch target compliance (48dp minimum), dynamic text scaling support up to 1.5×, Reduce Motion support replacing all animations with instant state changes
UX-DR25: Implement complete button hierarchy system — Primary (Electric Violet filled), Secondary (outlined), Tertiary (ghost/text), Destructive (Red outlined + confirmation), Icon buttons — with hover, focus, disabled, and loading states per variant
UX-DR26: Implement feedback patterns — Success/Error/Warning/Info states with colored left borders and icons, skeleton shimmer loading screens, streaming-as-progress in War Room, toast/snackbar rules (bottom position, 4s auto-dismiss, max 1 visible)
UX-DR27: Implement navigation patterns — 4-tab bottom navigation (Home, Reports, Board, Profile), screen transitions (slide-in/out/up, fade crossfade), back/escape gesture handling with War Room exit confirmation, deep linking for shared report URLs
UX-DR28: Implement modal & overlay patterns — bottom sheet (surface-100, radius-xl, drag handle, half/full snap points), confirmation dialog (destructive actions only), fullscreen overlay (PDF preview, expanded timeline)
UX-DR29: Implement empty state patterns — No Reports Yet (encouraging CTA), No Conversation History (starter question chips), Agent Error (transparent partial results), Offline (emphasize cached reports available)
UX-DR30: Implement animation timing standards — micro-interactions (0.15-0.2s), content transitions (0.25-0.3s), expansions (0.3-0.4s), data reveals (0.8-1.2s), attention pulses (0.3s×2), stagger delays (0.05-0.1s per item)

### FR Coverage Map

FR1: Epic 3 — Text idea submission
FR2: Epic 3 — Voice idea submission
FR3: Epic 3 — Optional context fields
FR4: Epic 3 — Plausibility check
FR5: Epic 4 — Five parallel AI agents
FR6: Epic 4 — Real-time agent streaming
FR7: Epic 4 — Agent lifecycle states
FR8: Epic 5 — Cross-referencing pass
FR9: Epic 5 — Observable cross-referencing
FR10: Epic 5 — Viability Score synthesis
FR11: Epic 6 — Executive Summary + radar chart
FR12: Epic 6 — Individual agent analysis view
FR13: Epic 6 — Evidence Panel
FR14: Epic 6 — Tappable source citations
FR15: Epic 6 — Unverified estimate flagging
FR16: Epic 7 — Market & Competitor Map
FR17: Epic 7 — Competitive landscape analysis
FR18: Epic 7 — Risk Radar
FR19: Epic 7 — Go-to-Market plan
FR20: Epic 9 — Variable sliders
FR21: Epic 9 — Re-execute with new parameters
FR22: Epic 9 — Score shift observation
FR23: Epic 8 — Side-by-side reports
FR24: Epic 8 — Diff visualization
FR25: Epic 8 — Comparative recommendation
FR26: Epic 10 — Conversational follow-ups
FR27: Epic 10 — Report-grounded responses
FR28: Epic 10 — Cross-session memory
FR29: Epic 10 — Conversation history view
FR30: Epic 11 — Visual reasoning timeline
FR31: Epic 11 — Timeline scrubbing
FR32: Epic 11 — Causal inflection points
FR33: Epic 12 — PDF export
FR34: Epic 12 — Shareable web link
FR35: Epic 12 — Public link viewing
FR36: Epic 2 — Google Sign-In
FR37: Epic 2 — Anonymous access
FR38: Epic 2 — Anonymous→signed-in upgrade
FR39: Epic 2 — Tier-based usage limits
FR40: Epic 8 — Report history
FR41: Epic 13 — Offline report viewing
FR42: Epic 13 — Cross-device report access
FR43: Epic 13 — Push notifications
FR44: Epic 13 — Notification opt-in/out
FR45: Epic 14 — Execution traces
FR46: Epic 14 — Cost-per-report monitoring
FR47: Epic 14 — Agent error tracking
FR48: Epic 14 — Search provider health
FR49: Epic 14 — System health summaries
FR50: Epic 4 — Prompt injection defense
FR51: Epic 4 — Token budget enforcement
FR52: Epic 4 — Graceful degradation
FR53: Epic 4 — WebSocket reconnection

## Epic List

### Epic 1 — Walking Skeleton (Idea to Mock Report)
Developers have a fully operational monorepo with both platforms scaffolded, local dev environment running, and the foundational design system + networking layer ready for feature development.
**FRs covered:** None directly (infrastructure enables all FRs)
**NFRs addressed:** NFR4, NFR9, NFR11, NFR19, NFR35-38, NFR39-40
**UX-DRs addressed:** UX-DR1, UX-DR2, UX-DR3, UX-DR22, UX-DR23, UX-DR25, UX-DR26, UX-DR27, UX-DR28, UX-DR29, UX-DR30

### Epic 2: User Authentication & Access Control
Users can sign in with Google, use the app anonymously, upgrade to a signed-in account, and have their access enforced by tier-based limits.
**FRs covered:** FR36, FR37, FR38, FR39
**NFRs addressed:** NFR16, NFR17, NFR41

### Epic 3: Idea Submission & Validation
Users can submit a business idea (text or voice) with optional context, receive plausibility feedback, and have validated input ready for AI analysis.
**FRs covered:** FR1, FR2, FR3, FR4
**NFRs addressed:** NFR12, NFR36
**UX-DRs addressed:** UX-DR24

### Epic 4: Multi-Agent Analysis & War Room Experience
Users can watch five specialized AI agents analyze their idea in real time with live streaming, see agent statuses, and experience the cinematic War Room with spotlight/grid modes.
**FRs covered:** FR5, FR6, FR7, FR50, FR51, FR52, FR53
**NFRs addressed:** NFR1, NFR2, NFR3, NFR20, NFR21, NFR22, NFR23, NFR24, NFR25, NFR26, NFR27, NFR28, NFR29
**UX-DRs addressed:** UX-DR4, UX-DR5, UX-DR13, UX-DR19

### Epic 5: Cross-Agent Intelligence & Viability Scoring
Users can see agents react to each other's findings in real time and receive a synthesized Viability Score with weighted breakdown across five dimensions.
**FRs covered:** FR8, FR9, FR10
**NFRs addressed:** NFR13, NFR30
**UX-DRs addressed:** UX-DR6, UX-DR8, UX-DR9, UX-DR20

### Epic 6: Report & Evidence Panel (Trust Layer)
Users can view the Executive Summary with radar chart, browse individual agent analyses, verify any claim via source citations with confidence scores, and trust the output enough to act on it.
**FRs covered:** FR11, FR12, FR13, FR14, FR15
**NFRs addressed:** NFR5, NFR37
**UX-DRs addressed:** UX-DR7, UX-DR10, UX-DR11, UX-DR12, UX-DR17, UX-DR21

### Epic 7: Market Intelligence & Risk Analysis Views
Users can view detailed Market & Competitor Maps with positioning visualization, competitive landscape analysis, ranked Risk Radar, and Go-to-Market plans.
**FRs covered:** FR16, FR17, FR18, FR19

### Epic 8: Report History & Comparative Analysis
Users can view their report history, revisit past reports, and place two or more reports side-by-side for structured comparison with diff visualization and comparative recommendations.
**FRs covered:** FR23, FR24, FR25, FR40
**UX-DRs addressed:** UX-DR16

### Epic 9: Scenario Simulation
Users can adjust key business variables via interactive sliders, re-run analysis with modified parameters, and observe how the Viability Score shifts across different scenarios.
**FRs covered:** FR20, FR21, FR22
**NFRs addressed:** NFR6
**UX-DRs addressed:** UX-DR15

### Epic 10: Ask the Board (Conversational AI)
Users can ask follow-up questions about a report in a conversational interface, receive grounded responses with citations, and maintain cross-session conversation history.
**FRs covered:** FR26, FR27, FR28, FR29
**NFRs addressed:** NFR7, NFR15
**UX-DRs addressed:** UX-DR18

### Epic 11: Decision Timeline & Replay
Users can view a visual timeline of how multi-agent analysis unfolded, scrub through key moments, and identify causal chains where one agent's findings influenced another.
**FRs covered:** FR30, FR31, FR32
**UX-DRs addressed:** UX-DR14

### Epic 12: Export & Share
Users can export investor-grade PDF reports and generate shareable web links that recipients can view without a VentureIQ account.
**FRs covered:** FR33, FR34, FR35
**NFRs addressed:** NFR8, NFR43

### Epic 13: Offline Access & Push Notifications
Users can view cached reports while offline, access reports across devices when signed in, and receive push notifications when reports finish generating.
**FRs covered:** FR41, FR42, FR43, FR44
**NFRs addressed:** NFR42

### Epic 14: Observability & Production Operations
Operators can monitor system health through execution traces, cost tracking, error rate dashboards, and cache performance metrics.
**FRs covered:** FR45, FR46, FR47, FR48, FR49
**NFRs addressed:** NFR30-34, NFR18

### Epic 15: Splash, Onboarding & Polish
Users experience a polished first impression with cinematic splash screen, intuitive onboarding, and a complete production-ready feel.
**FRs covered:** None directly (UX completion)

---

## Epic 1 — Walking Skeleton (Idea to Mock Report)

Developers have a fully operational monorepo with both platforms scaffolded, local dev environment running, and the foundational design system + networking layer ready for feature development.

### Story 1.1: Monorepo Scaffolding & Project Initialization

As a **developer**,
I want the monorepo initialized with Flutter mobile app and Python FastAPI backend scaffolded with all tooling configured,
So that I have a working development foundation for both platforms.

**Acceptance Criteria:**

**Given** a clean workspace
**When** the monorepo is initialized
**Then** the following structure exists: `ventureiq/mobile/` (Flutter app via `flutter create --org com.ventureiq --platforms android,ios --project-name ventureiq_app ./mobile`) and `ventureiq/backend/` (Python project via `uv init --name ventureiq-backend --python 3.13`)
**And** `docker-compose.yml` at root defines services for backend, Redis 7.x, PostgreSQL, and ChromaDB
**And** `.env.example` documents all required environment variables
**And** `README.md` contains project overview and setup instructions
**And** Flutter app builds and runs (`flutter run`) showing default screen
**And** Backend starts (`uvicorn app.main:app`) with a health check endpoint returning `200 OK` at `GET /api/v1/health`
**And** Ruff is configured for Python linting/formatting in `pyproject.toml`
**And** Dart analyzer is configured via `analysis_options.yaml`
**And** `.gitignore` covers both platforms

### Story 1.2: Backend Core Infrastructure (Config, Logging, Error Handling)

As a **developer**,
I want the backend core layer established with configuration management, structured logging, and the error handling framework,
So that all subsequent backend features have consistent infrastructure to build upon.

**Acceptance Criteria:**

**Given** the backend project from Story 1.1
**When** the core infrastructure is implemented
**Then** `app/core/config.py` implements Pydantic `BaseSettings` loading from `.env` with typed fields for database URLs, Redis URLs, API keys, and feature flags
**And** `app/core/logging.py` implements structured JSON logging with `request_id` propagation
**And** `app/core/exceptions.py` defines custom exception classes for all 12 enumerated error codes from the PRD (AUTH_REQUIRED, RATE_LIMIT_EXCEEDED, etc.)
**And** `app/core/middleware.py` implements RequestID middleware that generates and propagates UUIDs across all requests
**And** `app/main.py` uses FastAPI lifespan context manager for startup/shutdown
**And** the global error handler catches custom exceptions and returns structured error responses in the envelope format: `{ "error": { "code", "message", "details" }, "meta": { "request_id" } }`
**And** all success responses follow the envelope format: `{ "data": ..., "meta": { "request_id" } }`
**And** unit tests exist for config loading, error handler, and response envelope formatting

### Story 1.3: Database & Cache Foundation (PostgreSQL, Redis, Alembic)

As a **developer**,
I want PostgreSQL and Redis connections established with migration infrastructure,
So that data persistence and caching are available for all features.

**Acceptance Criteria:**

**Given** the backend core from Story 1.2
**When** database infrastructure is implemented
**Then** `app/db/base.py` creates async SQLAlchemy engine and `AsyncSessionLocal` session factory connected to PostgreSQL
**And** `app/db/redis.py` implements `RedisManager` with three logical databases: db0 (streaming state), db1 (cache), db2 (rate limiting)
**And** Alembic is initialized with `alembic.ini` and `migrations/env.py` configured for async SQLAlchemy
**And** A base SQLAlchemy model (`Base`) is defined with standard fields (`id` UUID PK, `created_at`, `updated_at`)
**And** `app/core/dependencies.py` provides FastAPI `Depends` functions: `get_db()` yielding async sessions and `get_redis()` yielding Redis connections
**And** Docker Compose services (PostgreSQL, Redis) start correctly and the backend connects on startup
**And** `alembic revision --autogenerate` produces valid initial migration
**And** `alembic upgrade head` applies migrations successfully
**And** Integration tests verify database health check and Redis connectivity

### Story 1.4: Provider Abstraction Layer (LLM & Search)

As a **developer**,
I want provider-agnostic interfaces for LLM and search integrations,
So that agents can be built against stable abstractions and providers can be swapped without code changes.

**Acceptance Criteria:**

**Given** the backend core from Story 1.2
**When** provider abstractions are implemented
**Then** `app/providers/llm/base.py` defines `LLMProvider` ABC with methods: `generate(prompt, config) -> str`, `stream(prompt, config) -> AsyncIterator[str]`, and `get_model_info() -> ModelInfo`
**And** `app/providers/llm/gemini.py` implements `GeminiProvider` using Google Gemini 2.5 Flash via `langchain-google-genai`
**And** `app/providers/llm/openrouter.py` implements `OpenRouterProvider` as fallback
**And** `app/providers/search/base.py` defines `SearchProvider` ABC with method: `search(query, num_results) -> list[SearchResult]`
**And** `app/providers/search/duckduckgo.py` implements `DuckDuckGoProvider`
**And** Provider selection is configured via Pydantic settings (primary + fallback)
**And** LLM provider includes automatic failover: on persistent error or elevated latency from primary, transparently switches to fallback (NFR26)
**And** Search provider includes retry with exponential backoff on rate limiting (NFR27)
**And** Unit tests verify provider interfaces and mock-based provider swap tests confirm no agent code changes needed (NFR39, NFR40)

### Story 1.5: Flutter App Shell with Navigation & Theme Foundation

As a **developer**,
I want the Flutter app configured with Riverpod, GoRouter, Dio networking, and the VentureIQ design system foundation,
So that all mobile features have a consistent architecture and premium visual identity from day one.

**Acceptance Criteria:**

**Given** the Flutter project from Story 1.1
**When** the app shell is implemented
**Then** `main.dart` wraps the app in `ProviderScope` and uses `MaterialApp.router` with GoRouter
**And** `app_router.dart` defines initial routes (splash, home/idea-input) with placeholder screens
**And** `core/theme/app_theme.dart` creates the dark `ThemeData` with complete `ColorScheme` mapping VentureIQ's surface system (`surface-000` through `surface-400`), brand accents (Electric Violet `#6C5CE7`, Cyan `#00D2FF`), and agent identity colors (UX-DR1)
**And** `core/theme/app_typography.dart` configures `TextTheme` with Inter + JetBrains Mono at all 8 type scale levels with correct weights and letter-spacing (UX-DR2)
**And** `core/theme/app_spacing.dart` defines the spacing scale (4px base, space-1 through space-10) and border radius scale (UX-DR3)
**And** All Material 3 components are themed to VentureIQ spec: Card, BottomSheet, TextField, FilledButton, TextButton, Chip, NavigationBar, SnackBar, Dialog — no component looks like default Material (UX-DR22)
**And** `core/networking/dio_client.dart` creates a Dio instance with base URL configuration, JSON interceptors, and logging interceptor
**And** `core/networking/api_endpoints.dart` defines API endpoint constants
**And** `core/networking/api_response.dart` implements response envelope parser
**And** `core/utils/responsive.dart` implements `ResponsiveConfig` with 3 screen tiers (Compact/Standard/Large) and properties (horizontalMargin, cardPadding, heroScoreSize, etc.) (UX-DR23)
**And** 4-tab bottom navigation is implemented (Home, Reports, Board, Profile) with Electric Violet active state (UX-DR27)
**And** Screen transitions follow spec: slide-in from right (forward), slide-up from bottom (modals), fade crossfade (tabs) (UX-DR27)
**And** Widget tests verify theme application and responsive config

### Story 1.6: Shared UI Component Library (Foundation)

As a **developer**,
I want the foundational shared UI components built following the UX specification,
So that all feature screens have consistent, accessible, premium building blocks.

**Acceptance Criteria:**

**Given** the design system from Story 1.5
**When** shared components are implemented
**Then** `core/widgets/skeleton_loader.dart` implements animated shimmer loading skeleton on `surface-100` (UX-DR26)
**And** `core/widgets/error_card.dart` implements error feedback card with colored left border (Success/Error/Warning/Info variants), icon, message text, and optional retry action (UX-DR26)
**And** `core/widgets/confidence_badge.dart` implements ConfidenceBadge with 3 levels (High ≥80% green, Mid 50-79% amber, Low <50% red), pill-shaped with color + text label, 3 variants (Pill, Compact, Large) (UX-DR7)
**And** `core/widgets/agent_status_indicator.dart` implements AgentStatusIndicator with 6 phases (Started, Searching, Analyzing, Cross-referencing, Complete, Error), 3 variants (Badge, Full, Dot) (UX-DR13)
**And** `core/constants/enums.dart` defines `AgentRole` (scout, rival, cfo, devilsAdvocate, strategist, coordinator) and `ReportStatus` enums
**And** All components meet 48dp minimum touch targets (NFR36)
**And** All components include `Semantics` wrappers for screen reader support (NFR35)
**And** All components support Reduce Motion via `MediaQuery.disableAnimationsOf(context)` (UX-DR24)
**And** Widget tests with golden comparisons verify each component's visual output
**And** Components support dynamic text scaling up to 1.5× without layout breakage (UX-DR24, NFR38)

---

## Epic 2: User Authentication & Access Control

Users can sign in with Google, use the app anonymously, upgrade to a signed-in account, and have their access enforced by tier-based limits.

### Story 2.1: Firebase Authentication & JWT Exchange (Backend)

As a **developer**,
I want Firebase authentication integrated with the backend JWT exchange pattern,
So that the backend can verify Firebase ID tokens and issue its own JWTs with custom claims for all subsequent API authorization.

**Acceptance Criteria:**

**Given** the backend infrastructure from Epic 1
**When** the auth system is implemented
**Then** `app/core/security.py` implements Firebase ID token verification using Firebase Admin SDK
**And** `app/core/security.py` implements backend JWT generation with custom claims (`user_id`, `tier`, `auth_method`)
**And** `app/api/v1/endpoints/auth.py` provides `POST /api/v1/auth/exchange` that accepts a Firebase ID token and returns a backend JWT + refresh token pair
**And** `app/api/v1/endpoints/auth.py` provides `POST /api/v1/auth/refresh` that accepts a refresh token and returns a new JWT + rotated refresh token (NFR16)
**And** JWT access tokens expire after a configurable period (default: 1 hour)
**And** Refresh token rotation is enforced — each refresh token is single-use (NFR16)
**And** `app/core/dependencies.py` provides `get_current_user()` dependency that extracts and validates JWT from `Authorization: Bearer` header
**And** Unauthenticated requests to protected endpoints return `401` with error code `AUTH_REQUIRED`
**And** Unit tests verify token exchange, refresh rotation, and expired token rejection

### Story 2.2: Anonymous & Google Sign-In (Flutter)

As a **user**,
I want to use VentureIQ immediately without signing in, or sign in with my Google account,
So that I can start validating ideas instantly and optionally persist my data across devices.

**Acceptance Criteria:**

**Given** the Flutter app shell from Epic 1
**When** authentication flows are implemented
**Then** `features/auth/data/auth_repository.dart` implements Firebase Anonymous sign-in and Google Sign-In
**And** `features/auth/data/auth_remote_data_source.dart` handles the backend JWT exchange (`POST /api/v1/auth/exchange`) after Firebase auth
**And** `features/auth/presentation/auth_notifier.dart` (Riverpod) manages auth state: `unauthenticated`, `anonymous`, `authenticated`
**And** On first app launch, Firebase Anonymous sign-in triggers automatically and the backend JWT is obtained transparently
**And** Users can tap "Sign in with Google" from the Profile/Settings tab to upgrade to Google auth (FR36)
**And** The Dio interceptor in `core/networking/dio_client.dart` automatically attaches the JWT `Authorization: Bearer` header to all API requests
**And** The Dio interceptor automatically attempts token refresh on `401` responses using the stored refresh token
**And** Auth tokens are stored securely using `flutter_secure_storage`
**And** Anonymous users can use the app to generate and view reports on-device (FR37)
**And** Widget tests verify auth state transitions and Google sign-in flow

### Story 2.3: Anonymous-to-Authenticated Upgrade & Data Retention

As an **anonymous user**,
I want to upgrade to a signed-in Google account and keep all my existing reports and data,
So that I don't lose my work when I decide to create a permanent account.

**Acceptance Criteria:**

**Given** a user is using the app anonymously with existing local data
**When** the user taps "Sign in with Google" and completes Google OAuth
**Then** Firebase `linkWithCredential` links the anonymous UID to the Google credential (FR38)
**And** `POST /api/v1/auth/upgrade` notifies the backend to migrate any server-side data from the anonymous user ID to the authenticated user ID
**And** A new backend JWT is issued with `auth_method: "google"` and updated claims
**And** All locally cached reports (Hive) are re-tagged with the authenticated user ID
**And** The user sees a success toast: "Account created! Your data has been preserved."
**And** If the Google account is already linked to another VentureIQ account, an error is shown: "This Google account is already in use"
**And** The upgrade is atomic — if any step fails, the user remains anonymous with their data intact
**And** Unit tests verify the upgrade flow including error cases

### Story 2.4: Tier-Based Usage Limits & Rate Limiting

As a **platform operator**,
I want tier-based usage limits enforced so free users are limited to 3 reports/month while Pro users have unlimited access,
So that the platform can sustainably serve users while incentivizing upgrades.

**Acceptance Criteria:**

**Given** a user is authenticated (anonymous or signed-in)
**When** usage limits are checked
**Then** `app/services/rate_limit_service.py` tracks report generation count per user per calendar month using Redis db2
**And** Free tier users are limited to 3 reports per month (FR39)
**And** Pro tier users have unlimited report generation
**And** `app/core/middleware.py` includes rate limiting middleware that checks usage before report generation endpoints
**And** When a free user exceeds the limit, the API returns `429` with error code `RATE_LIMIT_EXCEEDED` and a message indicating remaining time until reset
**And** The Flutter client displays a clear upgrade prompt when the rate limit is reached, showing usage count ("3/3 reports used this month")
**And** `features/auth/presentation/widgets/usage_indicator.dart` shows current usage in the Profile tab
**And** Ephemeral rate limit data in Redis has TTL set to auto-expire at month end (NFR17)
**And** Unit tests verify limit enforcement, month-boundary reset, and tier-based bypass

---

## Epic 3: Idea Submission & Validation

Users can submit a business idea (text or voice) with optional context, receive plausibility feedback, and have validated input ready for AI analysis.

### Story 3.1: Idea Submission Endpoint & Input Sanitization (Backend)

As a **developer**,
I want an API endpoint that receives business ideas, sanitizes them against prompt injection, and stores them for analysis,
So that user-submitted ideas are validated and safe before consuming AI resources.

**Acceptance Criteria:**

**Given** the backend infrastructure from Epics 1-2
**When** the idea submission endpoint is implemented
**Then** `app/models/idea.py` defines SQLAlchemy `Idea` model with fields: `id` (UUID), `user_id`, `idea_text`, `target_audience`, `industry`, `monetization_model`, `region`, `status`, `created_at`
**And** `app/schemas/idea.py` defines Pydantic request schema `IdeaCreateRequest` (idea_text required, context fields optional) and response schema `IdeaResponse`
**And** `app/api/v1/endpoints/ideas.py` provides `POST /api/v1/ideas` that validates, sanitizes, and persists the idea
**And** `app/services/sanitization_service.py` implements input sanitization against prompt injection using pattern matching and content filtering (NFR12, FR50)
**And** Ideas shorter than 10 characters or flagged as non-business content return `422` with helpful guidance: "Add more detail about your business idea for better results"
**And** Alembic migration creates the `ideas` table
**And** The endpoint returns the created idea with `status: "pending"` in the standard envelope format
**And** Rate limiting middleware (from Story 2.4) is applied — free tier users blocked after 3 reports/month
**And** Unit tests verify sanitization against a prompt injection test corpus and input validation edge cases

### Story 3.2: Plausibility Check via LLM

As a **user**,
I want my idea checked for basic plausibility before the full analysis runs,
So that I can refine vague or nonsensical submissions and get better results.

**Acceptance Criteria:**

**Given** a valid idea is submitted via `POST /api/v1/ideas`
**When** plausibility is assessed
**Then** `app/services/plausibility_service.py` sends the sanitized idea to the LLM provider (via the abstraction from Story 1.4) with a structured prompt asking for a plausibility assessment
**And** The plausibility check returns one of: `pass` (proceed to analysis), `refine` (suggest improvements), or `reject` (nonsensical/harmful)
**And** For `refine`, the response includes specific guidance (e.g., "Consider specifying your target customer segment") (FR4)
**And** For `reject`, the response includes a clear reason without exposing internal details
**And** The plausibility check uses the lightweight/fast LLM configuration (low token budget) to minimize cost
**And** Results are cached in Redis db1 (keyed by normalized idea text hash) to avoid repeat LLM calls for identical ideas (NFR22)
**And** `POST /api/v1/ideas/{id}/plausibility` endpoint returns the plausibility result
**And** The idea's `status` is updated to `plausibility_passed` or `plausibility_failed`
**And** Unit tests verify all three plausibility outcomes and cache behavior

### Story 3.3: Idea Input Screen (Flutter)

As a **user**,
I want a beautiful, zero-friction screen to type my business idea with optional context fields,
So that I can start validating my idea with a single tap.

**Acceptance Criteria:**

**Given** the Flutter app with auth from Epic 2
**When** the Idea Input screen is implemented
**Then** `features/idea_input/presentation/idea_input_screen.dart` displays a generous text field on `surface-200` with `radius-md` (12dp), Electric Violet focus border + glow, and placeholder "Describe your business idea..." (FR1)
**And** Character count displays in `text-tertiary` right-aligned (subtle, no hard max)
**And** Below the main field, "Add context (optional)" text button with ▼ chevron collapses/expands context fields with 0.3s ease animation
**And** Expanded context fields include: Target Audience, Industry, Monetization Model, Region — each with `surface-200` fill and helpful placeholder text (FR3)
**And** Context fields are optional — the "Validate" button is enabled with just the idea text
**And** The "Validate" primary button (Electric Violet filled, full-width, 48dp) calls `POST /api/v1/ideas` and then `POST /api/v1/ideas/{id}/plausibility`
**And** `features/idea_input/presentation/idea_input_notifier.dart` manages form state and API calls via Riverpod
**And** On plausibility `pass`, screen transitions to War Room (slide-in from right)
**And** On plausibility `refine`, inline info card (Intelligence Blue left border) shows refinement suggestions below the input
**And** On plausibility `reject`, error card (Error Red left border) shows the reason
**And** Inline validation shows error on blur, not on keystroke
**And** Touch targets meet 48dp minimum on all interactive elements (NFR36)
**And** Screen reader announces: "Business idea input field. Type your idea and tap Validate." (NFR35)
**And** Widget tests verify form validation, plausibility response handling, and context field expansion

### Story 3.4: Voice Input for Idea Submission

As a **user**,
I want to dictate my business idea using voice input,
So that I can submit ideas hands-free when typing is inconvenient.

**Acceptance Criteria:**

**Given** the Idea Input screen from Story 3.3
**When** voice input is implemented
**Then** A microphone icon button (48×48dp) appears right-aligned within the idea text field (FR2)
**And** Tapping the microphone requests microphone permission (if not already granted) using platform-native permission dialog
**And** During recording, the microphone icon transforms to an animated recording indicator (pulsing red dot)
**And** Speech-to-text uses platform-native speech recognition (iOS Speech framework / Android SpeechRecognizer)
**And** Transcribed text is inserted into the idea text field in real time as the user speaks
**And** Tapping the recording indicator stops recording and finalizes the transcription
**And** If microphone permission is denied, a helpful info toast explains how to enable it in system settings
**And** If speech recognition fails (no network, unsupported language), an error toast is shown with clear guidance
**And** The transcribed text can be edited manually before submission
**And** Screen reader announces: "Voice input button. Tap to dictate your idea." (NFR35)
**And** Widget tests verify recording states and permission handling

---

## Epic 4: Multi-Agent Analysis & War Room Experience

Users can watch five specialized AI agents analyze their idea in real time with live streaming, see agent statuses, and experience the cinematic War Room with spotlight/grid modes.

### Story 4.1: LangGraph Agent Pipeline (Backend)

As a **developer**,
I want the LangGraph pipeline that orchestrates five specialized AI agents in parallel,
So that a submitted idea is analyzed from five perspectives simultaneously.

**Acceptance Criteria:**

**Given** the provider abstractions from Story 1.4
**When** the agent pipeline is implemented
**Then** `app/agents/graph.py` defines a LangGraph `StateGraph` with nodes for: `run_scout`, `run_rival`, `run_cfo`, `run_devils_advocate`, `run_strategist`
**And** All five agent nodes execute in parallel using LangGraph's parallel branching
**And** Each agent module (`app/agents/scout.py`, `rival.py`, `cfo.py`, `devils_advocate.py`, `strategist.py`) implements its specialized analysis using the LLMProvider abstraction
**And** `app/agents/tools/web_search.py` wraps SearchProvider for Scout and Rival to use during their research phase
**And** Each agent receives the sanitized idea + context as input and produces structured output conforming to a Pydantic agent output schema
**And** Agent state is managed via LangGraph's `TypedDict` state with fields for each agent's status, output, tokens consumed, and search results
**And** Per-agent token budget ceilings are enforced — exceeding the budget triggers graceful output truncation with a structured summary, not mid-sentence cutoff (FR51, NFR28)
**And** Individual agent failures are caught and stored as error state — pipeline continues with remaining agents (FR52, NFR24)
**And** `app/services/analysis_service.py` orchestrates: validate idea → invoke LangGraph → persist events
**And** Unit tests verify parallel execution, token budget enforcement, and graceful degradation on agent failure

### Story 4.2: WebSocket Streaming Endpoint & Event Buffer

As a **developer**,
I want a WebSocket endpoint that streams agent analysis events to connected clients in real time,
So that users can observe the War Room's live analysis.

**Acceptance Criteria:**

**Given** the LangGraph pipeline from Story 4.1
**When** WebSocket streaming is implemented
**Then** `app/api/v1/websockets/analysis.py` provides `WS /api/v1/ws/analysis/{idea_id}` WebSocket endpoint
**And** The WebSocket uses the single-connection model: one bidirectional connection per analysis session
**And** All server→client events follow the envelope format: `{ "event_type", "timestamp", "payload" }` with types: `agent_token`, `agent_status`, `search_result`, `cross_reference`, `synthesis_progress`, `score_reveal`, `analysis_complete`, `error`, `heartbeat`, `replay_batch`
**And** Client→server control messages support: `control_pause`, `control_resume`, `control_skip`
**And** `app/services/streaming_service.py` buffers all events in Redis db0 with TTL for replay on reconnection
**And** Time-to-first-token is under 2 seconds from WebSocket connection to first `agent_token` event (NFR1)
**And** Agent token streaming latency is under 1 second between server emission and event delivery (NFR2)
**And** JWT authentication is verified on WebSocket handshake — unauthenticated connections are rejected
**And** Heartbeat events sent every 15 seconds to detect stale connections
**And** Unit tests verify event format, auth handshake, and heartbeat mechanism

### Story 4.3: WebSocket Reconnection & Event Replay

As a **user**,
I want my War Room session to automatically reconnect after a connection drop and replay missed events,
So that I never lose analysis progress due to network issues or app backgrounding.

**Acceptance Criteria:**

**Given** an active WebSocket streaming session
**When** the connection drops and reconnects
**Then** The Flutter client detects disconnection and attempts automatic reconnection with exponential backoff (1s, 2s, 4s, max 30s) (FR53)
**And** On reconnect, the client sends a `last_event_timestamp` to the server
**And** The server replays all buffered events after `last_event_timestamp` as a `replay_batch` event from Redis db0 (NFR25)
**And** The client processes replayed events without visual duplication
**And** If the app was backgrounded during analysis, foreground resume triggers reconnection and event replay (NFR29)
**And** A persistent "Reconnecting..." indicator displays during reconnection attempts
**And** If reconnection fails after max retries, a connection error card with "Tap to retry" is shown
**And** The server-side event buffer retains events for at least 5 minutes per analysis session
**And** Integration tests simulate connection drops and verify gapless event replay

### Story 4.4: StreamingTextDisplay & WarRoomAgentCard Widgets

As a **user**,
I want to see each agent's analysis streaming live with a cinematic typing effect,
So that the War Room feels alive and I can follow each agent's reasoning in real time.

**Acceptance Criteria:**

**Given** the design system and shared components from Epic 1
**When** War Room streaming widgets are implemented
**Then** `features/war_room/presentation/widgets/streaming_text_display.dart` renders tokens with ~30ms cadence using an animation controller, displaying a blinking Cyan (`#00D2FF`) cursor at the stream end (UX-DR5)
**And** StreamingTextDisplay auto-scrolls to latest content during streaming; user scroll-up pauses auto-scroll (resumable by scrolling to bottom)
**And** StreamingTextDisplay supports 3 states: `streaming` (cursor + new tokens), `paused` (static cursor + "Resuming..." label), `complete` (no cursor, final text)
**And** `features/war_room/presentation/widgets/war_room_agent_card.dart` implements the Expanded/Spotlight variant showing agent icon + name + AgentStatusIndicator + StreamingTextDisplay (UX-DR4)
**And** The Compact/Awareness Strip variant shows: agent icon (24dp) + agent name + status badge, 64dp height, tappable to switch spotlight
**And** Agent cards use their identity color for border/glow: Scout `#3B82F6`, Rival `#F43F5E`, CFO `#F59E0B`, Devil's Advocate `#EF4444`, Strategist `#10B981`
**And** Card states match spec: `initializing` (pulsing border), `searching` (animated search icon), `analyzing` (streaming), `complete` (✅ badge), `error` (amber/red border with message)
**And** All components include `Semantics` wrappers; streaming text announced in batched chunks (~2 sentences) via live region (UX-DR24)
**And** Reduce Motion support replaces animations with instant state changes
**And** Widget tests verify all states and streaming behavior with mock stream controllers

### Story 4.5: War Room Screen with Hybrid Adaptive Layout

As a **user**,
I want to experience the cinematic War Room where I can watch all five agents analyzing my idea with a spotlight focus and optional grid view,
So that I can follow the live analysis in a way that suits my preference.

**Acceptance Criteria:**

**Given** the agent card widgets from Story 4.4 and WebSocket streaming from Story 4.2
**When** the War Room screen is implemented
**Then** `features/war_room/presentation/war_room_screen.dart` connects to `WS /api/v1/ws/analysis/{idea_id}` on entry and processes incoming events
**And** `features/war_room/presentation/war_room_notifier.dart` (Riverpod) manages the WebSocket connection, parses events into typed models, and updates per-agent state reactively
**And** Default layout is Spotlight mode: one agent expanded (full-width WarRoomAgentCard Expanded variant) with compact awareness strip of all 5 agents below (UX-DR19)
**And** A SegmentedButton toggle ("Spotlight" / "Grid") in the app bar switches to Command Center 2×2+1 grid view using WarRoomAgentCard Grid variant (UX-DR19)
**And** User's layout preference (spotlight vs grid) persists across sessions via Hive
**And** Agent cards ignite in 0.1s-staggered sequence (Scout → Rival → CFO → Devil's Advocate → Strategist) on War Room entry (UX-DR30)
**And** Auto-spotlight follows the most active agent (the one currently streaming tokens)
**And** Tapping a compact agent thumbnail switches spotlight to that agent
**And** "Skip to Results" text button is always visible but unobtrusive — tapping sends `control_skip` and transitions to Score Reveal
**And** Bottom navigation bar is hidden during War Room to maximize immersive experience (UX-DR27)
**And** Back gesture prompts "Exit analysis?" confirmation if agents are still streaming
**And** On Compact screens (320-374dp), Grid toggle is hidden — Spotlight only (UX-DR23)
**And** Full analysis completes within 60-90 seconds (NFR3)
**And** Widget + integration tests verify layout modes, agent switching, and WebSocket event processing

---

## Epic 5: Cross-Agent Intelligence & Viability Scoring

Users can see agents react to each other's findings in real time and receive a synthesized Viability Score with weighted breakdown across five dimensions.

### Story 5.1: Cross-Referencing Pass in LangGraph Pipeline

As a **developer**,
I want a cross-referencing pass where agents adjust their outputs based on other agents' findings,
So that the analysis reflects genuine multi-perspective intelligence rather than five independent reports.

**Acceptance Criteria:**

**Given** the parallel agent execution from Story 4.1
**When** the cross-referencing pass is implemented
**Then** `app/agents/graph.py` adds a `cross_reference` node that runs after all five agents complete their initial analysis
**And** The cross-referencing node reads all five agents' outputs from LangGraph state and produces adjustment prompts for each agent
**And** Each agent receives a secondary prompt containing relevant findings from other agents and produces a cross-referencing addendum (FR8)
**And** Cross-reference events are emitted as `cross_reference` WebSocket events with format: `{ "source_agent", "target_agent", "reference_text", "triggered_by" }`
**And** Inter-agent data is validated against expected Pydantic schemas before consumption (NFR13)
**And** The cross-referencing pass has its own token budget (separate from per-agent budgets)
**And** If the cross-referencing pass fails, the pipeline continues to synthesis with unadjusted agent outputs (graceful degradation)
**And** Unit tests verify cross-reference event emission and schema validation

### Story 5.2: Coordinator Synthesis & Viability Score Computation

As a **developer**,
I want a Coordinator node that synthesizes all agent outputs into a unified Viability Score with dimensional breakdown,
So that users receive a single, explainable assessment of their idea's viability.

**Acceptance Criteria:**

**Given** the cross-referencing pass from Story 5.1
**When** the Coordinator synthesis is implemented
**Then** `app/agents/graph.py` adds a `synthesize` node that runs after cross-referencing
**And** The Coordinator reads all five agents' final outputs (including cross-reference addenda) and generates an executive summary
**And** `app/services/scoring_service.py` computes a 0-100 Viability Score with weighted breakdown across 5 dimensions: Market, Competition, Financials, Risk, Execution (FR10)
**And** Each dimension score includes contributing factors and agent attribution (which agent's findings drive the score)
**And** Synthesis progress is emitted as `synthesis_progress` events (0-100%)
**And** The final score is emitted as a `score_reveal` event containing: overall score, dimensional breakdown, anchor label, and key insight
**And** An `analysis_complete` event is emitted after scoring, signaling the War Room to transition to the report view
**And** Every execution generates a complete trace capturing per-agent latency, token consumption, and API cost (NFR30)
**And** Unit tests verify scoring computation, dimensional weighting, and trace generation

### Story 5.3: CrossReferenceBadge Widget & War Room Integration

As a **user**,
I want to see visible badges when agents react to each other's findings in the War Room,
So that I can witness the "aha!" moment of multi-agent intelligence and understand how agents influence each other.

**Acceptance Criteria:**

**Given** the War Room from Story 4.5
**When** cross-referencing UI is implemented
**Then** `features/war_room/presentation/widgets/cross_reference_badge.dart` renders a tappable pill badge: "📎 Responding to [Agent Name]" in Synthesis Violet (`#A78BFA`) at 15% opacity background (UX-DR6)
**And** The badge has 3 states: `default` (muted pill), `highlight` (animated 0.3s pulse when first appearing), `tapped` (highlighted border, navigates to referenced finding) (FR9)
**And** Inline variant renders within StreamingTextDisplay text flow during an agent's cross-referencing output
**And** Card Header variant displays at the top of WarRoomAgentCard when agent enters `cross_referencing` state
**And** Tapping a CrossReferenceBadge scrolls/navigates to the referenced agent's finding that triggered the cross-reference
**And** War Room notifier processes `cross_reference` WebSocket events and connects them to the correct agent cards
**And** A subtle state transition "✨ Agents reviewing each other's findings" appears when the cross-referencing phase begins
**And** Screen reader announces: "Cross-reference: [Agent] is responding to [Referenced Agent]'s finding. Tap to navigate." (UX-DR24)
**And** Widget tests verify all 3 states, both variants, and navigation behavior

### Story 5.4: Score Reveal Screen & Viability Score Display

As a **user**,
I want a cinematic score reveal with animated count-up, dimensional breakdown bars, and radar chart,
So that I receive the analysis verdict in a dramatic, visually impactful moment.

**Acceptance Criteria:**

**Given** the Coordinator synthesis from Story 5.2
**When** the Score Reveal screen is implemented
**Then** `features/report/presentation/score_reveal_screen.dart` renders the score reveal sequence triggered by the `score_reveal` WebSocket event
**And** `features/report/presentation/widgets/viability_score_display.dart` renders the Hero variant (72px) with Cyan→Violet text gradient and radial glow (UX-DR8)
**And** Score counts from 0→final over 1.2s with ease-out curve; haptic pulse fires on landing (UX-DR20)
**And** Anchor label fades in 0.3s after score lands: "Strong Viability" (≥80 green), "Promising — With Caveats" (60-79 amber), "Needs Work" (40-59 red), "High Risk" (<40 red) (UX-DR8)
**And** `features/report/presentation/widgets/dimensional_breakdown_bar.dart` renders 5 horizontal bars (Market, Competition, Financials, Risk, Execution) with dimension-appropriate colors, filling left-to-right over 0.8s with 0.1s stagger per bar (UX-DR9)
**And** Tapping a dimensional bar opens a detail bottom sheet showing contributing factors and agent attribution
**And** `features/report/presentation/widgets/key_insight_card.dart` slides up from below with 0.4s delay, showing the most important recommendation with agent-colored left border (UX-DR17)
**And** Below the score reveal, an action row shows: "View Report", "Export PDF", "Validate Another"
**And** Screen reader announces final score immediately (no count-up): "Viability Score: [score] out of 100. [anchor label]." (UX-DR24)
**And** Reduce Motion replaces all animations with instant state display
**And** Widget tests verify animation sequence and all score ranges

---

## Epic 6: Report & Evidence Panel (Trust Layer)

Users can view the Executive Summary with radar chart, browse individual agent analyses, verify any claim via source citations with confidence scores, and trust the output enough to act on it.

### Story 6.1: Report Persistence & Retrieval (Backend)

As a **developer**,
I want completed analysis reports persisted with all agent outputs, scores, and citations,
So that reports are durable, retrievable, and available for all downstream features.

**Acceptance Criteria:**

**Given** the Coordinator synthesis from Story 5.2
**When** report persistence is implemented
**Then** `app/models/report.py` defines SQLAlchemy `Report` model with fields: `id` (UUID), `idea_id` (FK), `user_id`, `viability_score`, `dimensional_scores` (JSON), `executive_summary`, `key_insight`, `agent_outputs` (JSON), `citations` (JSON), `status`, `agent_completion_count`, `created_at`
**And** `app/services/report_service.py` persists the complete report after Coordinator synthesis completes
**And** Alembic migration creates the `reports` table
**And** `app/api/v1/endpoints/reports.py` provides `GET /api/v1/reports/{id}` returning the full report in envelope format
**And** `app/api/v1/endpoints/reports.py` provides `GET /api/v1/reports` returning paginated report list (most recent first) for the authenticated user
**And** Reports include confidence scores per citation and unverified estimate flags (FR15)
**And** Each citation includes: source title, URL, snippet, confidence percentage, citing agent, and verified/unverified status
**And** Reports are scoped to the authenticated user — users cannot access others' reports
**And** Unit tests verify report persistence, retrieval, and access control

### Story 6.2: Executive Summary Screen with Radar Chart

As a **user**,
I want to view a comprehensive Executive Summary with a radar chart showing my idea's strengths and weaknesses across all dimensions,
So that I can quickly understand the overall assessment and where to focus.

**Acceptance Criteria:**

**Given** a completed report from Story 6.1
**When** the Executive Summary screen is implemented
**Then** `features/report/presentation/executive_summary_screen.dart` displays: Viability Score (Card variant, 28px), radar chart, dimensional breakdown, executive summary text, and key insight card
**And** `features/report/presentation/widgets/radar_chart.dart` renders a 5-axis spider chart with Electric Violet filled polygon (20% opacity) and 2px solid border (UX-DR10)
**And** Radar chart axes labeled: Market, Competition, Financials, Risk, Execution with score values in JetBrains Mono at each vertex
**And** Concentric grid polygons at 25/50/75/100 levels in `surface-250` stroke
**And** Radar chart vertices animate from center outward dimension-by-dimension over 1.0s on first display (UX-DR10)
**And** Radar chart is 280dp default, scaling per ResponsiveConfig (200dp compact, 320dp large)
**And** Below the chart, the full executive summary text is rendered with inline citation superscripts (FR11)
**And** Each agent's analysis is presented as an ExpansionTile — collapsed shows agent icon + name + 2-line summary; expanded shows full analysis (FR12)
**And** Navigation to Evidence Panel is available via a "View Sources" button
**And** Screen reader provides text alternative for radar chart: "Viability Score breakdown — Market: 85, Competition: 68..." (UX-DR24)
**And** Widget tests verify radar chart rendering and expansion tile behavior

### Story 6.3: Evidence Panel with Inline Citations

As a **user**,
I want to verify any claim in the report by tapping inline citation superscripts to view source details with confidence scores,
So that I can trust the analysis because every claim is verifiable.

**Acceptance Criteria:**

**Given** the Executive Summary from Story 6.2
**When** the Evidence Panel is implemented
**Then** `features/report/presentation/evidence_panel_screen.dart` displays all source citations organized by agent
**And** Report text contains inline `InlineCitationSuperscript` widgets `[1]` `[2]` rendered as tappable superscripts in Electric Violet, Micro typography (11px) (UX-DR12)
**And** Tapping a superscript opens a `SourceCitationCard` as a modal bottom sheet with: source title (tappable to URL), domain/favicon, ConfidenceBadge (Pill variant), relevant snippet, and agent attribution with agent-colored 4dp left border (UX-DR11, FR14)
**And** The Evidence Panel header shows summary stats: "[N] sources · [N] agents cited · [N]% avg confidence" (UX-DR21)
**And** Horizontal FilterChip row allows filtering citations by citing agent (🔍 Scout, ⚔️ Rival, 💰 CFO, ⚠️ DA, 🎯 Strategist)
**And** Each SourceCitationCard shows collapsed view (title + badge + agent) in list, expandable to full details on tap
**And** Claims flagged as unverified display ConfidenceBadge with "Unverified Estimate" label in Warning Red (FR15)
**And** Long-press on report text enables copy to clipboard
**And** Screen reader announces: "Citation [number], tap to view source" for each superscript (UX-DR24)
**And** Widget tests verify superscript rendering, bottom sheet display, and filter behavior

### Story 6.4: Report Local Caching (Flutter)

As a **user**,
I want completed reports cached locally on my device,
So that I can view them quickly without network delays and revisit them offline.

**Acceptance Criteria:**

**Given** a completed report retrieved from the API
**When** local caching is implemented
**Then** `features/report/data/report_local_data_source.dart` caches full report data using Hive
**And** Reports are cached after first retrieval with LRU eviction (max 50 cached reports)
**And** `features/report/data/report_repository.dart` implements cache-first strategy: serve from Hive if available, then fetch from API in background to refresh
**And** Offline report retrieval loads within 500 milliseconds (NFR5)
**And** Cache invalidation occurs when a report is updated server-side (via `updated_at` comparison)
**And** Freezed data classes are used for all report entities (`report_entity.dart`, `viability_score_entity.dart`, `citation_entity.dart`) with `json_serializable` (architecture requirement)
**And** Unit tests verify cache hit/miss behavior, LRU eviction, and offline retrieval performance

---

## Epic 7: Market Intelligence & Risk Analysis Views

Users can view detailed Market & Competitor Maps with positioning visualization, competitive landscape analysis, ranked Risk Radar, and Go-to-Market plans.

### Story 7.1: Market & Competitor Map View

As a **user**,
I want to view a Market & Competitor Map with positioning visualization and identified market gaps,
So that I can understand the competitive landscape and whitespace opportunities.

**Acceptance Criteria:**

**Given** a completed report with Scout and Rival agent outputs
**When** the market intelligence views are implemented
**Then** `features/report/presentation/widgets/market_map_view.dart` renders competitor positioning visualization using agent data (FR16)
**And** Market gaps are highlighted with explanatory annotations derived from Scout's analysis
**And** Competitive landscape section shows competitor strengths, weaknesses, and whitespace opportunities from Rival's output (FR17)
**And** Each data point includes ConfidenceBadge and InlineCitationSuperscript for source verification
**And** Views are scrollable sections within the Executive Summary screen (not separate screens)
**And** Widget tests verify rendering with mock agent output data

### Story 7.2: Risk Radar & Go-to-Market Plan Views

As a **user**,
I want to view a Risk Radar with ranked risks and a Go-to-Market plan with launch strategy,
So that I can understand the critical risks and actionable next steps for my idea.

**Acceptance Criteria:**

**Given** a completed report with Devil's Advocate and Strategist outputs
**When** the risk and GTM views are implemented
**Then** `features/report/presentation/widgets/risk_radar_view.dart` displays ranked risks from Devil's Advocate with likelihood, impact, and mitigation strategies per risk (FR18)
**And** Risks are ordered by severity (likelihood × impact) with color-coded indicators (Critical Red, Caution Amber, Info Blue)
**And** `features/report/presentation/widgets/gtm_plan_view.dart` displays the Go-to-Market plan from Strategist with launch strategy, target persona, and key metrics (FR19)
**And** Each risk and GTM recommendation includes ConfidenceBadge and source citations
**And** Views integrate as expandable sections within the Executive Summary
**And** Widget tests verify risk ordering and GTM plan rendering

---

## Epic 8: Report History & Comparative Analysis

Users can view their report history, revisit past reports, and place two or more reports side-by-side for structured comparison with diff visualization and comparative recommendations.

### Story 8.1: Report History Screen

As a **user**,
I want to view a list of all my previously generated reports with scores and timestamps,
So that I can revisit past analyses and select reports for comparison.

**Acceptance Criteria:**

**Given** the report API from Story 6.1
**When** the history screen is implemented
**Then** `features/history/presentation/history_screen.dart` displays a scrollable list of `ReportHistoryCard` widgets (UX-DR16)
**And** Each card shows: idea title/summary (2 lines max), ViabilityScoreDisplay (Card variant), generation date, agent completion count ("5/5 agents")
**And** SearchBar at top filters reports by idea title (debounced 300ms) (FR40)
**And** Pull-to-refresh fetches latest reports from API
**And** Empty state shows: "No reports yet" with encouraging CTA "Validate an Idea" (UX-DR29)
**And** Selection mode: tapping checkbox on cards enables multi-select; "Compare" button appears when exactly 2 reports selected
**And** Screen reader announces: "Report: [title]. Score: [score] out of 100. Generated [date]." per card
**And** Widget tests verify search filtering, selection mode, and empty state

### Story 8.2: Comparative Analysis Screen

As a **user**,
I want to place two reports side-by-side with diff visualization and a comparative recommendation,
So that I can make an informed decision between competing ideas.

**Acceptance Criteria:**

**Given** 2 reports selected from the History screen (Story 8.1)
**When** comparative analysis is implemented
**Then** `features/history/presentation/comparative_analysis_screen.dart` displays two reports side-by-side (FR23)
**And** `app/api/v1/endpoints/comparisons.py` provides `POST /api/v1/comparisons` accepting two report IDs and returning a comparison result
**And** Diff visualization highlights key score differences between the two ideas with color-coded indicators (green for advantage, red for weakness) (FR24)
**And** Horizontal FilterChip row toggles dimensions (Market, Competition, Financials, Risk, Execution) to filter the comparison view
**And** RadarChart comparison overlay renders two polygons (Electric Violet + Cyan) on the same chart (UX-DR10)
**And** `app/services/comparison_service.py` generates a comparative recommendation: recommended option (or "no recommendation"), per-dimension score deltas, and key drivers/assumptions (FR25)
**And** The recommendation is displayed as a KeyInsightCard at the top with clear rationale
**And** Widget tests verify side-by-side rendering and radar overlay

---

## Epic 9: Scenario Simulation

Users can adjust key business variables via interactive sliders, re-run analysis with modified parameters, and observe how the Viability Score shifts across different scenarios.

### Story 9.1: Scenario Simulator Backend

As a **developer**,
I want an endpoint that re-executes analysis with modified parameters,
So that scenario simulation can produce updated projections.

**Acceptance Criteria:**

**Given** a completed report
**When** scenario simulation is implemented
**Then** `app/api/v1/endpoints/scenarios.py` provides `POST /api/v1/reports/{id}/scenarios` accepting modified parameters (pricing, target audience, region, stage)
**And** `app/services/scenario_service.py` re-invokes relevant agents (primarily CFO and Strategist) with modified parameters, reusing cached Scout/Rival data where parameters don't affect market research (FR21)
**And** Updated dimensional scores and overall Viability Score are computed
**And** Scenario results are persisted with a reference to the original report
**And** Response includes per-dimension deltas ("+4 Market", "-6 Risk") showing impact of changes
**And** Updated projections reflect within 10 seconds (NFR6)
**And** Unit tests verify parameter modification, delta computation, and caching behavior

### Story 9.2: Scenario Simulator Screen (Flutter)

As a **user**,
I want to adjust key business variables via interactive sliders and see how my Viability Score shifts,
So that I can explore different scenarios and find the strongest strategy.

**Acceptance Criteria:**

**Given** a completed report view
**When** the Scenario Simulator is implemented
**Then** `features/scenario/presentation/scenario_simulator_screen.dart` displays interactive ScenarioSlider widgets for key variables (FR20)
**And** `features/scenario/presentation/widgets/scenario_slider.dart` renders: variable label, JetBrains Mono value, Cyan track, tick marks with labels, delta indicator (↑+4 green / ↓-6 red), original value marker (UX-DR15)
**And** Variables include: Pricing Strategy, Target Audience, Region, and Business Stage — pre-populated from original context fields
**And** Tapping "Re-simulate" calls `POST /api/v1/reports/{id}/scenarios` with modified values
**And** During re-simulation, sliders are locked with "Recalculating..." label
**And** Updated score and dimensional breakdown render below with delta indicators showing change from original (FR22)
**And** "Save Scenario" button saves the current parameter set for later comparison
**And** Screen reader announces: "[Variable]: current value [value]. Projected score change: [delta]." per slider
**And** Widget tests verify slider interaction, API call, and delta display

---

## Epic 10: Ask the Board (Conversational AI)

Users can ask follow-up questions about a report in a conversational interface, receive grounded responses with citations, and maintain cross-session conversation history.

### Story 10.1: Conversational AI Backend (RAG Pipeline)

As a **developer**,
I want a conversational endpoint grounded in report context using RAG,
So that users can ask follow-up questions and receive cited, report-specific responses.

**Acceptance Criteria:**

**Given** ChromaDB from Docker Compose and a persisted report
**When** the conversational backend is implemented
**Then** `app/services/conversation_service.py` implements RAG: embeds report content into ChromaDB (per-report collection), retrieves relevant chunks for user queries, and generates grounded responses via LLMProvider
**And** `app/api/v1/endpoints/conversations.py` provides `POST /api/v1/reports/{id}/conversations` for submitting questions and receiving streaming responses
**And** Responses include inline citation references linking to existing report sources (FR27)
**And** `app/models/conversation.py` defines SQLAlchemy model for conversation history: `id`, `report_id`, `user_id`, `messages` (JSON array), `created_at`, `updated_at`
**And** Conversation history is persisted per report and resumable across sessions (FR28)
**And** `GET /api/v1/reports/{id}/conversations` retrieves full conversation history (FR29)
**And** Response streaming begins within 3 seconds (NFR7)
**And** No PII beyond user-provided content is stored in ChromaDB vectors (NFR15)
**And** Alembic migration creates the `conversations` table
**And** Unit tests verify RAG retrieval, citation grounding, and history persistence

### Story 10.2: Ask the Board Screen (Flutter)

As a **user**,
I want a conversational interface to ask follow-up questions about my report and receive grounded AI responses,
So that I can explore specific concerns and get expert-level answers backed by my analysis data.

**Acceptance Criteria:**

**Given** a completed report
**When** the Ask the Board screen is implemented
**Then** `features/ask_the_board/presentation/ask_the_board_screen.dart` displays a chat interface with a text input field at the bottom
**And** `features/ask_the_board/presentation/widgets/ask_the_board_bubble.dart` implements User variant (right-aligned, `surface-200`, bottom-right square corner) and Board variant (left-aligned, `surface-100`, Electric Violet top border, streaming) (UX-DR18)
**And** Board responses stream token-by-token using StreamingTextDisplay with InlineCitationSuperscript for cited claims (FR26)
**And** Agent attribution appears when responses reference specific agents: "Based on CFO's analysis..."
**And** ConfidenceBadge appears on data-bearing claims within responses
**And** Previous conversation history loads on screen entry (FR29)
**And** Empty state shows suggested starter questions as tappable chips: "What's the biggest risk?", "How does the competitive landscape look?", "What would improve my score?" (UX-DR29)
**And** Error state shows: "Couldn't process your question. Tap to retry."
**And** Screen reader announces: "[Sender]: [message]. [timestamp]." per bubble
**And** Widget tests verify streaming, citation rendering, and history loading

---

## Epic 11: Decision Timeline & Replay

Users can view a visual timeline of how multi-agent analysis unfolded, scrub through key moments, and identify causal chains where one agent's findings influenced another.

### Story 11.1: Timeline Event Persistence & API

As a **developer**,
I want analysis events stored with timestamps and causal links,
So that the Decision Timeline can replay how multi-agent analysis unfolded.

**Acceptance Criteria:**

**Given** the streaming events persisted in Redis db0 during analysis (Story 4.2)
**When** timeline persistence is implemented
**Then** `app/services/timeline_service.py` freezes the Redis event buffer into a permanent `timeline_events` JSON column on the Report model after analysis completes
**And** Each event includes: `timestamp`, `agent`, `event_type`, `content_snapshot`, `causal_link` (optional reference to a preceding event that influenced this one)
**And** Causal links are populated for cross-reference events — linking the cross-reference to the original finding that triggered it
**And** `app/api/v1/endpoints/reports.py` extends `GET /api/v1/reports/{id}` to include `timeline_events` in the response
**And** Alembic migration adds `timeline_events` column to `reports` table
**And** Unit tests verify event freezing, causal link construction, and API response

### Story 11.2: Decision Timeline Screen (Flutter)

As a **user**,
I want a visual timeline showing how my analysis unfolded with scrubbing and causal highlights,
So that I can understand the "story behind the score" and identify key inflection points.

**Acceptance Criteria:**

**Given** a completed report with timeline events from Story 11.1
**When** the Decision Timeline is implemented
**Then** `features/timeline/presentation/decision_timeline_screen.dart` renders a horizontal scrubbing timeline (UX-DR14) (FR30)
**And** `features/timeline/presentation/widgets/decision_timeline.dart` uses a CustomPaint or ListView with agent-colored event markers along the timeline axis
**And** A draggable scrubber thumb allows scrubbing through events; the event detail panel below updates to show the selected event's content snapshot (FR31)
**And** Causal connection lines (dashed, Synthesis Violet) connect events that influenced each other, highlighting key inflection points (FR32)
**And** Playback controls (play/pause/speed) auto-advance through events at 1×/2×/4× speed
**And** Agent filter chips at top allow showing/hiding events by agent
**And** Screen reader provides text alternative: "Timeline event [N]: [Agent] [event_type] at [time]. [content]." per event
**And** Widget tests verify scrubbing, playback, and causal link rendering

---

## Epic 12: Export & Share

Users can export investor-grade PDF reports and generate shareable web links that recipients can view without a VentureIQ account.

### Story 12.1: PDF Export

As a **user**,
I want to export a completed report as a professional PDF,
So that I can share my validated idea with investors or team members in a polished format.

**Acceptance Criteria:**

**Given** a completed report
**When** PDF export is implemented
**Then** `app/services/pdf_service.py` generates a PDF using ReportLab including: Executive Summary, Viability Score breakdown, all 5 agent analyses, citation list with confidence scores, and dimensional radar chart as rendered image
**And** `app/api/v1/endpoints/exports.py` provides `POST /api/v1/reports/{id}/export/pdf` returning a download URL
**And** The PDF uses VentureIQ branding (dark theme colors, logo, "Generated by VentureIQ" footer)
**And** PDF generation completes within 15 seconds (NFR8)
**And** Flutter client triggers export via `features/report/presentation/widgets/export_button.dart`, showing progress indicator then opening share sheet with the PDF file (FR33)
**And** Generated PDFs are stored temporarily (24h TTL) and accessible via signed URL
**And** Unit tests verify PDF generation content and timing

### Story 12.2: Shareable Web Links

As a **user**,
I want to generate a shareable web link to my report that anyone can view without an account,
So that I can quickly share my analysis with others for feedback.

**Acceptance Criteria:**

**Given** a completed report
**When** sharing is implemented
**Then** `app/api/v1/endpoints/sharing.py` provides `POST /api/v1/reports/{id}/share` generating a random token and returning a shareable URL (FR34)
**And** `app/api/v1/endpoints/sharing.py` provides `GET /api/v1/shared/{token}` returning the full report data without authentication (FR35)
**And** Shared links expire after a configurable period (default 30 days)
**And** Report owners can revoke shared links via `DELETE /api/v1/reports/{id}/share`
**And** Flutter client shows "Share Report" button that generates the link and opens platform share sheet (FR34)
**And** Deep linking support: tapping a shared VentureIQ link opens the app to the report view (or web fallback) (UX-DR27)
**And** Unit tests verify link generation, public access, and expiry behavior

---

## Epic 13: Offline Access & Push Notifications

Users can view cached reports while offline, access reports across devices when signed in, and receive push notifications when reports finish generating.

### Story 13.1: Offline Report Access & Cross-Device Sync

As a **user**,
I want to view cached reports while offline and access my reports across multiple devices when signed in,
So that my analyses are always available regardless of network conditions or device.

**Acceptance Criteria:**

**Given** the local cache from Story 6.4
**When** offline access is implemented
**Then** Connectivity monitoring (`core/utils/connectivity.dart`) detects online/offline state and displays appropriate indicators
**And** When offline, the Reports tab shows all locally cached reports with an "Offline Mode" banner (FR41)
**And** Reports cached locally load within 500ms (NFR5) — verified by on-device timing
**And** When online, signed-in users' reports sync from the server with conflict resolution: server-side is canonical (FR42)
**And** Offline state shows: "You're offline. Cached reports are available." with list of cached reports (UX-DR29)
**And** Attempting to generate a new report while offline shows: "Report generation requires internet. Connect and try again."
**And** Widget tests verify offline banner, cached report display, and sync behavior

### Story 13.2: Push Notifications for Report Completion

As a **user**,
I want push notifications when my report finishes generating, especially if I've backgrounded the app,
So that I'm alerted immediately and can review results without waiting.

**Acceptance Criteria:**

**Given** Firebase Cloud Messaging (FCM) integration
**When** push notifications are implemented
**Then** `app/services/notification_service.py` sends FCM push notifications to the user's device when `analysis_complete` event fires and the user's WebSocket is disconnected (FR43)
**And** Notification payload includes: idea title, viability score, and deep link to the report
**And** Flutter client registers for FCM on startup and stores the device token via `POST /api/v1/users/devices`
**And** Tapping the notification deep-links to the completed report screen
**And** Users can opt in/out of re-engagement notifications via Profile settings (FR44)
**And** Notification preferences are persisted server-side per user
**And** Push delivery targets ≥99% success rate for valid devices (NFR42)
**And** Unit tests verify notification trigger logic and opt-in/out behavior

---

## Epic 14: Observability & Production Operations

Operators can monitor system health through execution traces, cost tracking, error rate dashboards, and cache performance metrics.

### Story 14.1: Execution Tracing & Cost Tracking

As an **operator**,
I want execution traces per agent with latency, token consumption, and cost metrics,
So that I can monitor system performance and control AI spending.

**Acceptance Criteria:**

**Given** the analysis pipeline from Epic 4
**When** observability is implemented
**Then** `app/services/tracing_service.py` captures per-agent execution traces: start/end timestamps, token consumption (input + output), API cost (computed using provider pricing tables), search calls made, error events (FR45)
**And** `app/models/trace.py` defines SQLAlchemy `ExecutionTrace` model persisted per report
**And** `app/api/v1/endpoints/admin.py` provides `GET /api/v1/admin/traces` with filtering (date range, idea_id, min_cost) and pagination
**And** Cost-per-report is calculable from logged token data (NFR34), exposed via `GET /api/v1/admin/costs/summary` (FR46)
**And** Alembic migration creates the `execution_traces` table
**And** Structured JSON logging (from Story 1.2) includes `request_id`, `agent_name`, `tokens_used`, and `cost_usd` fields
**And** Unit tests verify trace capture completeness and cost calculation accuracy

### Story 14.2: System Health Dashboard & Monitoring

As an **operator**,
I want dashboards for agent error rates, search provider health, and system metrics,
So that I can proactively identify degradation and ensure reliable service.

**Acceptance Criteria:**

**Given** tracing and logging from Story 14.1
**When** monitoring is implemented
**Then** `app/services/metrics_service.py` exposes Prometheus-compatible metrics at `GET /metrics`: request latency histograms, error rates (per-agent), cache hit ratios (Redis db1), active WebSocket connections, and cost-per-report (NFR32)
**And** Per-agent error rates are tracked with historical trend computation (7-day rolling window) (FR47, NFR33)
**And** Search provider health (DuckDuckGo availability, response times, cache fallback invocations) is tracked (FR48)
**And** `GET /api/v1/admin/health/summary` returns aggregated system health across configurable time periods (FR49)
**And** Health check at `GET /api/v1/health` verifies: database connectivity, Redis connectivity, LLM provider reachability, and search provider reachability
**And** Unit tests verify metric emission and health check endpoint

### Story 14.3: CI/CD Pipeline & Production Deployment

As a **developer**,
I want automated CI/CD pipelines and production-ready deployment configuration,
So that code changes are validated automatically and deployments are consistent and repeatable.

**Acceptance Criteria:**

**Given** the complete backend and mobile codebases
**When** CI/CD is implemented
**Then** `.github/workflows/backend-ci.yml` runs on PR: Ruff lint, pytest with coverage, Alembic migration validation
**And** `.github/workflows/mobile-ci.yml` runs on PR: Dart analyze, Flutter test, build verification (APK)
**And** `.github/workflows/deploy.yml` builds multi-stage Docker image and deploys to Google Cloud Run (2nd gen) on main branch merge
**And** `backend/Dockerfile` uses multi-stage build: builder stage (install deps) → production stage (copy app, set CMD)
**And** GCP Secret Manager is configured for production secrets (API keys, database URLs) — no secrets in code or Docker layers
**And** Cloud Run configuration includes: min instances (1), max instances (10), memory (2Gi), CPU (2), concurrency (80)
**And** Deployment includes automatic rollback on health check failure
**And** All CI checks must pass before PR merge is allowed

---

## Epic 15: Splash, Onboarding & Polish

Users experience a polished first impression with cinematic splash screen, intuitive onboarding, and a complete production-ready feel.

### Story 15.1: Splash Screen & First-Launch Experience

As a **user**,
I want a cinematic splash screen and intuitive first-launch experience,
So that my first impression of VentureIQ feels premium and I understand how to start.

**Acceptance Criteria:**

**Given** the Flutter app from Epic 1
**When** splash and onboarding are implemented
**Then** `features/splash/presentation/splash_screen.dart` displays the VentureIQ logo with a subtle glow animation on `surface-000` for 2 seconds (or until auth initialization completes)
**And** First-launch detection uses Hive flag (`has_completed_onboarding`)
**And** First-launch shows a 3-slide onboarding carousel: (1) "Validate Any Idea" — War Room preview, (2) "AI-Powered Intelligence" — agent introduction, (3) "Evidence-Based Decisions" — trust layer preview
**And** Each slide uses cinematic imagery and Electric Violet/Cyan accent colors
**And** "Get Started" button on final slide triggers anonymous auth and navigates to Home
**And** "Skip" text button is always visible for returning users
**And** Subsequent app launches skip onboarding and go directly to Home (after splash)
**And** Reduce Motion replaces glow animation with static logo display
**And** Widget tests verify first-launch detection and navigation flow

### Story 15.2: Profile Screen & Settings

As a **user**,
I want a Profile screen showing my account details, usage stats, and app settings,
So that I can manage my account and customize my experience.

**Acceptance Criteria:**

**Given** auth from Epic 2 and usage tracking from Story 2.4
**When** the Profile screen is implemented
**Then** `features/profile/presentation/profile_screen.dart` displays: user avatar (from Google), display name, email (or "Anonymous User"), tier badge (Free/Pro)
**And** Usage section shows: reports generated this month (with progress bar toward limit), total reports, member since date
**And** Settings section includes: notification preferences toggle (FR44), War Room layout preference (Spotlight/Grid), and sign-out button
**And** Anonymous users see "Sign in with Google" CTA prominently
**And** Sign-out triggers Firebase sign-out, clears secure storage, and returns to splash
**And** "Delete Account" destructive action (red outlined button) opens confirmation dialog before executing
**And** Widget tests verify profile display for both anonymous and authenticated users
