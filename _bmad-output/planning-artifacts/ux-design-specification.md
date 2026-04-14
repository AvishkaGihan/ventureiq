---
stepsCompleted: [1, 2, 3, 4, 5, 6]
inputDocuments:
  - "product-brief-ventureiq.md"
  - "product-brief-ventureiq-distillate.md"
  - "prd.md"
  - "prd-validation-report.md"
---

# UX Design Specification — VentureIQ

**Author:** Avishka Gihan
**Date:** 2026-04-14

---

## Executive Summary

### Project Vision

VentureIQ is a real-time, multi-agent decision intelligence platform that transforms a raw business idea into an investor-grade validation brief in under 90 seconds. Five specialized AI agents — Scout, Rival, CFO, Devil's Advocate, and Strategist — operate in parallel within a cinematic War Room, streaming their reasoning live while cross-referencing each other's outputs. The result is an explainable Viability Score backed by confidence ratings and source citations.

The UX vision centers on the **Confidence Stack** — three interlocking patterns that no competitor offers:
- **Visibility** — real-time reasoning via the War Room transforms "loading time" into "engagement time"
- **Verifiability** — every claim carries a confidence score and clickable source citation (the Trust Layer)
- **Multi-perspective reasoning** — cross-agent intelligence is visible to the user, demonstrating analytical depth that single-LLM tools cannot replicate

The product is delivered as a Flutter mobile app (iOS & Android) backed by a FastAPI/LangGraph backend, with 12 screens shipping in V1 as a unified system. The aesthetic direction is cinematic, dark, premium — positioning VentureIQ as serious decision intelligence technology, not a chatbot or simple AI tool.

### Target Users

**Maya — The First-Time Founder (Primary)**
Age 28, product designer validating an idea before quitting her job. Needs to go from "I think this might work" to evidence-backed confidence in 90 seconds. Interaction style: emotional, exploratory, seeking reassurance through data. Values the cinematic War Room experience and shareable PDF exports for co-founder conversations.

**Daniel — The Freelance Consultant (Primary)**
Age 35, one-person strategy consultancy producing client-facing research briefs. Currently spends 15-20 hours per client report at $3,000. Needs efficiency and credibility — the output must be polished enough to present directly to paying clients. Interaction style: professional, efficiency-driven, quality-focused. Values Comparative Analysis, Ask the Board, and multi-report workflows.

**Priya — The Product Manager (Primary)**
Age 31, senior PM at a Series B startup evaluating pivot directions. Needs structured, evidence-backed comparison to replace weeks of subjective stakeholder debate. Interaction style: analytical, comparison-oriented, stakeholder-facing. Values Scenario Simulator, Decision Timeline, and Comparative Analysis.

**Alex — The Platform Operator (Secondary)**
Developer monitoring production health — execution traces, cost-per-report, error rates, cache performance. Interaction style: technical, monitoring-oriented. Primarily uses observability dashboards (LangSmith/Prometheus) rather than the consumer-facing app.

### Key Design Challenges

1. **Information Density vs. Cognitive Overload** — Five simultaneous agent streams, cross-referencing, confidence scores, and multi-dimensional scoring create enormous information density. The War Room must feel thrilling, not overwhelming. Progressive disclosure is critical: summary by default, expandable depth on demand.

2. **Mobile-First Real-Time Streaming** — Token-by-token WebSocket streaming on mobile requires radical information density decisions for 6" screens. The experience must remain legible, beautiful, and performant over cellular networks with potential interruptions (backgrounding, reconnection).

3. **Trust as a UX Pattern** — The Trust Layer must feel trustworthy at a visceral level — not just "we show sources." Visual confidence indicators, citation affordances, and verified/unverified states must communicate authority. The output must be polished enough for Maya to share with a co-founder and Daniel to present to a $3,000 client.

4. **Three User Mindsets, One App** — Maya (emotional/exploratory), Daniel (professional/efficient), and Priya (analytical/comparative) require different interaction patterns. The UX must flex across mindsets without mode-switching or configuration.

5. **The 90-Second Experience** — The War Room transforms loading into engagement, but some users will want to skip ahead. The UX needs both the cinematic experience and a fast-forward path without making either feel second-class.

### Design Opportunities

1. **"Cinematic Intelligence" as Category-Defining UX** — No AI product treats processing as a spectator experience. War Room animations, typography, and real-time choreography can set a new standard that carries virally through screenshots and demos.

2. **Decision Timeline as Novel Interaction** — Scrubbing through multi-agent reasoning is unprecedented. This becomes the "show your work" feature that builds trust and differentiates in portfolios, demos, and investor conversations.

3. **Trust Layer as Visual Brand Identity** — Confidence scores and source citations can become VentureIQ's visual signature — color-coded confidence, animated verification badges, citation ribbons that make trust beautiful rather than clinical.

4. **Dark Premium Aesthetic as Market Signal** — Cinematic, authoritative dark theme positions VentureIQ as serious technology. The aesthetic itself communicates sophistication and separates it from toy-like AI tools.

5. **Agent Personalities as Engagement Hooks** — Each agent's distinct role (Scout 🔍, Rival ⚔️, CFO 💰, Devil's Advocate ⚠️, Strategist 🎯) can be designed with visual identities, animation styles, and streaming "personality" — creating memorable characters users refer to by name.

## Core User Experience

### Defining Experience

The core interaction loop is: **Submit an idea → Watch agents analyze in real time → Receive a trusted, actionable report.** The War Room is the defining experience — the moment where VentureIQ proves it's not another chatbot. If the War Room captivates, users explore every other feature. If it doesn't, nothing else matters.

The core promise collapses into one sentence: *"Type your idea. Watch five AI agents analyze it in real time. Walk away with an investor-grade brief."*

Three interactions must be flawless:
- **Submit** — zero friction from "I have an idea" to "agents are working." No signup walls, no mandatory fields.
- **Watch** — the War Room must be riveting. 90 seconds of loading must feel like 90 seconds of entertainment.
- **Trust** — the Viability Score and Evidence Panel must feel credible enough to stake decisions on, share with co-founders, and present to clients.

### Platform Strategy

**Primary:** Flutter mobile app (iOS 15+ & Android 10+), single codebase, touch-first design.

**Platform capabilities leveraged:**
- Microphone for voice input (optional, requested on use)
- Push notifications for report completion during backgrounding
- Haptic feedback for key moments (score reveal, agent completion, cross-reference triggers)
- Deep linking for shareable report URLs (open in-app or browser fallback)

**Offline:** Cached reports viewable offline via Hive/SQLite; all AI processing requires internet.

**Key constraint:** The War Room — 5 concurrent agent streams — must be designed for a 6" mobile screen. This is the product's hardest UX problem.

**Future extension:** Client-agnostic API backend supports web client addition without backend changes.

### Effortless Interactions

1. **Zero-Friction Idea Submission** — one sentence, one tap. Context fields are optional enhancements, not gates. Anonymous users get 3 free reports without account creation.
2. **Self-Explanatory War Room** — no onboarding tooltips needed. Agent cards, status indicators, and streaming text are visually self-evident.
3. **One-Tap Trust Verification** — every cited claim is tappable inline. One tap reveals source preview with confidence score. No hunting, no navigation.
4. **Fluid Report Navigation** — War Room completion flows seamlessly into Executive Summary → Evidence Panel → agent details. Feels like scrolling a beautifully designed document, not navigating a menu hierarchy.
5. **Instant Export** — one tap for PDF, one tap for shareable link. No configuration dialogs. Defaults are investor-grade.

### Critical Success Moments

1. **"The Agents Are Alive" (0-5s)** — War Room activates, agent cards pulse, first token streams within 1 second. User realizes this is a command center, not a chatbot. If the first 5 seconds don't create a "whoa" reaction, the portfolio mission fails.
2. **"They're Talking to Each Other" (~30-60s)** — cross-referencing pass begins. User sees Strategist react to Devil's Advocate findings in real time. This is the "aha!" moment proving multi-agent intelligence. If cross-referencing isn't visually obvious and emotionally impactful, VentureIQ is just "5 ChatGPT windows."
3. **"I Can Verify This Myself" (Report)** — user taps a bold claim, sees original source with confidence score. Trust is earned, not claimed. This converts AI-skeptic users into advocates.
4. **"This Would've Taken Me Weeks" (Export)** — polished PDF export creates the conversion moment from "interesting" to "indispensable." If the export looks like a data dump, the magic dies.

**Make-or-break flow:** First-time submission → War Room → Score reveal. If this doesn't captivate, no user reaches Scenario Simulator, Comparative Analysis, or Ask the Board.

### Experience Principles

1. **🎬 Spectacle Over Speed** — the 90-second window is a show to choreograph, not a delay to minimize. The War Room isn't loading; it's performing.
2. **🔍 Trust Is Earned, Not Claimed** — never say "our AI is accurate." Make every claim verifiable with one tap. If it can't be cited, flag it transparently.
3. **✨ Complexity Beneath Simplicity** — five agents, cross-referencing, multi-dimensional scoring are enormously complex. The UX should feel effortless. Progressive disclosure: clean surfaces with depth underneath.
4. **📱 Mobile-Native, Not Mobile-Adapted** — every interaction designed for thumb-reach, swipe navigation, 6" viewport. The War Room on mobile should feel better than desktop — intimate, focused, immersive.
5. **🏆 Every Output Is Shareable** — every view should look stunning in isolation because it will be shared in isolation. If a user can't proudly share a screenshot, PDF, or link, the design has failed.

## Desired Emotional Response

### Primary Emotional Goals

**1. Awe → "This is unlike anything I've seen"**
The War Room should trigger the same feeling as watching a mission control room operate — sophisticated technology working in visible concert. This isn't the mild satisfaction of a good tool; it's the visceral thrill of witnessing something operating at a level you didn't think was possible in a consumer product.

**2. Confidence → "I can make this decision now"**
Maya walked in with doubt ("will my idea work?") and walks out with conviction. Daniel feels comfortable putting this in front of a $3,000 client. Priya presents to her CEO and gets a decision in 15 minutes. The Trust Layer doesn't just provide data — it provides the *emotional permission* to act on it.

**3. Empowerment → "I just did something that used to take weeks"**
The moment of export — when the user realizes they just produced $10K-quality research in 90 seconds — should feel like a superpower. Not "the AI is smart" but "I am powerful because I have this."

### Emotional Journey Mapping

| Stage | Emotion | How It Feels | Design Implication |
|:--|:--|:--|:--|
| **Discovery / First Open** | Intrigue + Anticipation | "This looks serious. This looks different." | Dark premium aesthetic, zero clutter, no playful/cartoon elements. The app looks like Bloomberg Terminal meets Apple — authoritative and polished. |
| **Idea Input** | Ease + Momentum | "That was easy. Let's see what happens." | Minimal friction, generous input field, optional context fields feel expansive not restrictive. One tap to launch. |
| **War Room Activation (0-5s)** | Awe + Excitement | "Whoa — the agents are alive." | Cinematic animation, agent cards ignite in sequence, pulsing status indicators, dramatic audio-visual orchestration. |
| **Agent Streaming (5-30s)** | Fascination + Engagement | "I can't look away." | Token-by-token streaming with typing simulation, each agent with distinct visual personality, real-time search results appearing. |
| **Cross-Referencing (30-60s)** | Amazement + Trust | "They're actually talking to each other. This is real intelligence." | Visual connections between agents, highlight animations when one agent references another, "influence lines" or badge notifications. |
| **Score Reveal** | Anticipation → Clarity | "Okay, here's the verdict." | Dramatic score reveal animation (count-up or unveil), radar chart filling in dimension by dimension, haptic pulse. |
| **Evidence Panel** | Trust + Verification | "I don't have to take their word for it." | Clean citation cards, one-tap source previews, confidence badges that feel authoritative (not gamified). |
| **Deep Exploration** | Control + Mastery | "I can go as deep as I want." | Scenario sliders feel responsive, Decision Timeline scrubbing feels like power, Ask the Board feels like consulting a panel of experts. |
| **Export/Share** | Pride + Accomplishment | "I can't believe I just produced this." | Polished PDF preview, one-tap share, the output looks premium enough to be proud of sending. |
| **Return Visit** | Familiarity + Anticipation | "I know exactly what to do, and I'm excited to do it again." | Report history feels like an asset library, Ask the Board remembers context, new ideas feel inviting. |
| **Error / Failure** | Understanding + Patience | "Something went wrong but I know what to do." | Clear, calm error states. Agent failure → graceful degradation with explanation, not cryptic errors. The system feels resilient, not fragile. |

### Micro-Emotions

The make-or-break emotional tensions in VentureIQ:

| Tension | We Want → | We Must Avoid → |
|:--|:--|:--|
| **Confidence vs. Confusion** | User always knows what's happening and what to do next | War Room feels chaotic, too much information with no hierarchy |
| **Trust vs. Skepticism** | Source citations and confidence scores build belief | Claims feel unverifiable, scores feel arbitrary |
| **Excitement vs. Anxiety** | War Room streaming feels thrilling and entertaining | Real-time analysis feels stressful, like watching something that might break |
| **Accomplishment vs. Frustration** | Export feels like completing something valuable | Report feels incomplete, generic, or not polished enough to share |
| **Delight vs. Overwhelm** | Each new feature discovery feels like finding a hidden gem | Too many features visible at once, information overload |
| **Belonging vs. Isolation** | "This tool was built for someone like me" | "This is for technical people / this is too simple for my needs" |

**Most critical tension:** Trust vs. Skepticism. If the user doesn't trust the output, every other emotion is irrelevant. The Trust Layer is the emotional foundation the entire product rests on.

### Design Implications

| Target Emotion | UX Design Approach |
|:--|:--|
| **Awe** | Cinematic War Room choreography — staggered agent activation, glow effects, ambient particle animations, dramatic score reveal with count-up animation and haptic feedback |
| **Confidence** | Trust Layer visibility everywhere — confidence badges, source citation cards, "verified" vs "estimated" labels. Viability Score presented with methodology transparency. |
| **Empowerment** | Export quality. The PDF must look like it came from McKinsey, not a chatbot. Shareable links render beautifully. The user feels like they have a senior analyst on retainer. |
| **Fascination** | Agent personalities with distinct streaming cadences, visual identities, and "thinking" states. Cross-referencing animations that show influence flowing between agents. |
| **Trust** | Nothing hidden, nothing forced. "Show your work" philosophy. Decision Timeline lets you inspect the entire reasoning chain. Unverified claims are transparently flagged, not hidden. |
| **Control** | Scenario Simulator sliders respond instantly. Navigation is fluid and non-linear — jump to any section, return to War Room replay, compare any reports. The user is never trapped. |
| **Calm (in errors)** | Graceful degradation is visible and explained: "4 of 5 agents completed. Confidence adjusted." Not "Something went wrong." Agent failures become *trustworthy* because the system is honest about them. |

### Emotional Design Principles

1. **🎭 Design for "Tell-a-Friend" Moments** — every interaction should create something the user wants to show someone. The War Room is screenshot-worthy. The PDF is share-worthy. The Viability Score is conversation-worthy.

2. **🔒 Trust Is the Emotional Foundation** — confidence scores, citations, and transparency aren't features; they're the emotional infrastructure. Build trust first, delight second. A beautiful product nobody trusts is worthless.

3. **⚡ Choreograph Time, Don't Fight It** — the 90-second analysis is a dramatic arc (activation → analysis → cross-referencing → synthesis → reveal). Design it like a story with rising action, climax, and resolution. The user should feel like 90 seconds was the *perfect* amount of time.

4. **🛡️ Make Failure Feel Safe** — errors, partial results, and degraded outputs should feel like the system being *honest*, not the system being *broken*. A 4-of-5 completion with adjusted confidence is more trustworthy than a 5-of-5 that hides a failure.

5. **👑 The User Is the Hero, Not the AI** — the agents are the user's team, not the show. The user made a smart decision by using VentureIQ. The output is *their* research brief, produced with *their* AI team. The emotional frame: empowerment, not dependence.

## UX Pattern Analysis & Inspiration

### Inspiring Products Analysis

**1. ChatGPT — The Streaming Interaction Benchmark**

| Dimension | What They Nail | VentureIQ Relevance |
|:--|:--|:--|
| **Streaming UX** | Token-by-token text streaming feels alive and conversational. The response builds in front of you. | War Room streaming must feel at least this smooth, but with 5 parallel streams instead of 1. ChatGPT proved streaming is engagement. |
| **Input Simplicity** | One text field. Type and press enter. No configuration blocking the core action. | Idea Input should feel this simple — one field, one tap. Context fields are expansions, not gates. |
| **Conversation Flow** | Each response naturally invites a follow-up. The interface is a conversation, not a form → result pattern. | Ask the Board must feel this conversational — grounded in the report but naturally inviting deeper questions. |
| **Progressive Complexity** | Simple by default, but power users discover system prompts, custom instructions, plugins. | VentureIQ should work beautifully for Maya (just submit) but reveal depth for Priya (scenarios, timelines). |

**Key lesson:** ChatGPT makes AI feel *approachable*. VentureIQ needs approachable *and* authoritative — same ease of interaction, wrapped in a premium aesthetic that signals decision intelligence.

**2. Perplexity — The Trust Layer Pioneer**

| Dimension | What They Nail | VentureIQ Relevance |
|:--|:--|:--|
| **Inline Citations** | Every factual claim has a numbered source reference. Verifiable without leaving the flow. | VentureIQ's Trust Layer must exceed this — not just numbered references, but confidence scores on every citation. |
| **Source Panel** | Structured source cards with title, URL, and snippet. Clean, scannable, authoritative. | Evidence Panel should take direct inspiration — clean cards, one-tap previews, organized by agent. |
| **Answer + Sources = One Unit** | Answer and sources are integrated, not separate screens. Trust is built in the reading flow. | Reports should embed trust signals inline, then provide dedicated Evidence Panel for deep dives. |
| **Query Understanding** | Perplexity reformulates queries, showing it understands what you’re asking. | Plausibility checks should feel helpful — "Here's how I'll analyze your idea" — not rejective. |

**Key lesson:** Perplexity democratized source transparency. VentureIQ adds *multi-perspective* transparency — not just "here are the sources" but "here's how 5 experts interpreted the sources differently."

**3. Notion — The Information Architecture Master**

| Dimension | What They Nail | VentureIQ Relevance |
|:--|:--|:--|
| **Structured Elegance** | Complex hierarchical information feels clean and navigable. Depth without clutter. | Report navigation should feel like browsing a beautifully structured Notion document, not clicking through menus. |
| **Typography & Whitespace** | Generous spacing, clear heading hierarchy, restrained color. Content breathes. | Agent streaming text must use excellent typography — well-typeset report feel, not chat messages. |
| **Blocks as Building Blocks** | Every content piece is a consistent "block" that can be expanded or collapsed. | Report sections follow a card/block metaphor — consistent visual language across content types. |
| **Dark Mode Excellence** | Muted backgrounds, high-contrast text, subtle borders. Nothing glows or screams. | Premium dark ≠ neon glows. Muted backgrounds with strategic pops of color for important elements. |
| **Progressive Disclosure** | Pages reveal depth on click. Toggle blocks hide detail until requested. | War Room → Report uses this — summary by default, expandable depth everywhere. |

**Key lesson:** Notion proved information-dense products can feel calm and elegant. VentureIQ's design system must be even more disciplined about hierarchy, spacing, and progressive disclosure.

### Transferable UX Patterns

**Navigation Patterns:**
- **ChatGPT's conversation list → Notion's sidebar** — Report History as a structured, scannable sidebar or bottom sheet. Each past report is a card with idea title, Viability Score, and date.
- **Perplexity's thread continuity** — Ask the Board maintains conversation continuity. Returning users resume naturally with prior context.

**Interaction Patterns:**
- **ChatGPT's streaming + stop button** — War Room offers a "Skip to Results" affordance, always available, never disruptive.
- **Perplexity's inline source taps** — Source citations tappable inline (numbered superscripts or badges). One tap → source preview card or bottom sheet.
- **Notion's toggle/expand blocks** — Agent cards expand/collapse. Post-report, each agent section is a toggleable block.

**Visual Patterns:**
- **Notion's typography hierarchy** — Clear heading levels with generous spacing. Agent names are H3-weight, key findings are callout blocks.
- **Perplexity's source card design** — Clean cards with title, domain favicon, relevance snippet. VentureIQ adds confidence badges (color-coded: green ≥80%, amber 50-79%, red <50%).
- **ChatGPT's dark mode simplicity** — Dark backgrounds with white text and minimal accent colors. Agent identity colors are the primary color system.

### Anti-Patterns to Avoid

1. **❌ Dashboard Overload (Generic BI Tools)** — VentureIQ's War Room is NOT a dashboard. It's a *narrative experience*. Each agent tells a story; the Viability Score is the conclusion, not one of 47 widgets.

2. **❌ Static AI Output (Wrapper Apps)** — No loading spinner → static document. VentureIQ must feel *alive* — streaming, interactive, explorable. The output is a living analysis.

3. **❌ Gamification of Trust Signals** — Confidence scores should feel *institutional* and *authoritative* (Bloomberg-style), not gamified (Duolingo-style). Color-coded text, not animated trophy icons.

4. **❌ Nested Menu Navigation** — No hamburger → sub-menu → screen patterns. Navigation is flat and fluid — swipe between sections, tap to expand, scroll to explore.

5. **❌ Loading Spinners Hiding Work** — Never show a spinner when you could show agents working. Streaming is the product.

### Design Inspiration Strategy

**What to Adopt Directly:**

| Pattern | Source | Application |
|:--|:--|:--|
| Token streaming with typing simulation | ChatGPT | War Room agent streams |
| Inline numbered source citations | Perplexity | Trust Layer superscript references |
| Toggle/expand content blocks | Notion | Agent analysis sections |
| Dark mode with muted backgrounds | Notion | App-wide dark theme |
| One-field input simplicity | ChatGPT | Idea Input screen |

**What to Adapt:**

| Pattern | Source | Adaptation |
|:--|:--|:--|
| Single-stream response | ChatGPT | → 5 parallel streams with agent identity and orchestrated choreography |
| Flat source list | Perplexity | → Source cards grouped by agent, with confidence scores and verified/unverified badges |
| Static page layout | Notion | → Dynamic, time-based layout (streaming → static post-completion) |
| Conversation history | ChatGPT | → Ask the Board with report-grounded context |
| Search follow-ups | Perplexity | → Scenario Simulator with variable sliders |

**What to Explicitly Avoid:**

| Anti-Pattern | Why |
|:--|:--|
| Dashboard grid layouts | VentureIQ is a narrative, not a monitoring dashboard |
| Gamified trust signals | Confidence must feel institutional, not playful |
| Loading spinners during processing | Streaming is the product — never hide the work |
| Static report outputs | Every section should be interactive and explorable |
| Cluttered multi-widget screens | Mobile-first means radical simplicity with depth on demand |

## Design System Foundation

### Design System Choice

**Material Design 3 — Heavily Themed** is the design system foundation for VentureIQ. Flutter's built-in Material library provides the component infrastructure while a comprehensive custom `ThemeData` transforms the visual identity into VentureIQ's dark, premium, cinematic aesthetic.

This is not "default Material." It is Material as an invisible foundation — providing accessibility, platform conventions, and component architecture — while VentureIQ's design language lives in the theming layer and custom widgets.

### Rationale for Selection

1. **Solo developer efficiency** — Material 3 provides ~80% of needed components (cards, sheets, navigation, inputs, dialogs) out of the box. The remaining 20% are purpose-built custom widgets for VentureIQ-specific elements (War Room cards, confidence badges, radar chart, Decision Timeline).
2. **Premium aesthetic achievability** — Material 3's theming system is powerful enough to create a completely custom look. Apps like Notion and Linear use platform foundations but are unrecognizable as "default" — VentureIQ does the same.
3. **Built-in accessibility** — Touch targets (48x48dp), screen reader semantics, contrast ratios, and dynamic text scaling are provided by default, satisfying accessibility NFRs without manual implementation.
4. **Inspiration alignment** — ChatGPT, Perplexity, and Notion all use heavily themed platform-native components on mobile.

### Implementation Approach

| Layer | Approach |
|:--|:--|
| **Foundation** | Material 3 via Flutter — `ThemeData`, `ColorScheme`, `TextTheme` |
| **Global Theme** | Custom dark `ThemeData` with VentureIQ palette, premium typography, custom component themes |
| **Standard Components** | Material widgets themed to spec — cards, app bars, bottom sheets, text fields, chips, navigation |
| **Custom Components** | Purpose-built: War Room agent cards, streaming text display, confidence badges, radar chart, Decision Timeline, Scenario Simulator sliders, source citation cards |
| **Animation** | Flutter animation framework — staggered agent activation, score reveal, cross-reference highlights |
| **Charting** | `fl_chart` for radar chart and market positioning visualizations |

### Customization Strategy

The customization targets three levels:

**Level 1 — Global Theme Overrides:**
Custom dark `ColorScheme`, typography scale (Inter or Outfit), component shape overrides (16dp radius), elevation replacements (borders + subtle glows instead of shadows).

**Level 2 — Component-Level Theming:**
Every Material component (Card, BottomSheet, AppBar, TextField, Chip, NavigationBar) receives a custom theme matching VentureIQ's premium aesthetic. No component should look like "default Material."

**Level 3 — Custom Widgets:**
Purpose-built widgets for experiences Material doesn't cover: War Room agent cards with streaming state, confidence badge system, radar chart with animated fill, Decision Timeline with scrubbing, source citation cards with inline tap previews.
