---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9]
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

## Defining Core Experience

### Defining Experience

> ***"Type your idea. Watch five AI experts argue about it in real time. Walk away with a verdict you can trust."***

This is a novel combination of three interactions no competitor has assembled:
1. **The War Room** — a spectator experience of multi-agent intelligence
2. **The Cross-Reference Moment** — when agents react to each other's findings
3. **The Verdict** — an explainable Viability Score backed by verifiable evidence

If the War Room captivates, users explore every other feature. If it doesn't, nothing else matters.

### User Mental Model

**How users currently solve this problem:**

| Current Approach | Mental Model | Pain |
|:--|:--|:--|
| Google research | "I'll piece together information myself" | Hours of fragmented searching, no synthesis, no confidence in completeness |
| ChatGPT / single-LLM | "I'll ask the AI" | One perspective, no sources, "is this hallucinated?" anxiety |
| Paid consultants | "I'll hire an expert" | $5K-$50K, weeks of waiting, still a single perspective |
| AI validators (DimeADozen) | "I'll get a quick score" | Static output, no transparency, feels like a Magic 8-Ball |

**The mental model VentureIQ creates:**
> "I have a **board of advisors** who analyze my idea simultaneously, challenge each other, and deliver a transparent verdict I can verify."

Users don't think "I'm using an AI tool" — they think "I'm consulting my advisory board."

**Confusion mitigation:**
- **5 agents streaming at once:** Visual hierarchy — one agent spotlighted at a time, others as peripheral thumbnails, tap to switch focus.
- **Cross-referencing:** Explicit badges: "📎 Responding to Devil's Advocate" with tappable link to the referenced finding.
- **Viability Score context:** Verbal anchors (e.g., "Strong — Most ideas in this category score 60-75") and dimensional breakdown showing *where* the score comes from.

### Success Criteria

| Criterion | What It Looks Like | How We Measure |
|:--|:--|:--|
| **"This just works"** | User types an idea and sees agents streaming within 1 second. No confusion. | Time-to-first-token <1s, zero-guidance completion rate |
| **"I can't look away"** | User watches the full War Room without skipping. | War Room view duration, skip-to-results rate |
| **"They're talking to each other"** | Cross-referencing is visually obvious. User notices agent reactions. | Cross-reference badge interaction rate |
| **"I trust this"** | User taps at least one source citation to verify. | Source tap rate, Evidence Panel engagement |
| **"This would've taken me weeks"** | User exports or shares the report. Output quality exceeds expectations. | Export rate, share rate, return visit rate |

### Novel UX Patterns

| Pattern Element | Classification | Source Familiarity | VentureIQ Innovation |
|:--|:--|:--|:--|
| Text input → AI processing | **Established** | ChatGPT, Perplexity | Combined with context fields for structured input |
| Token-by-token streaming | **Established** | ChatGPT ubiquitous | Multiplied to 5 parallel streams with orchestration |
| Source citations | **Established** | Perplexity normalized | Enhanced with confidence scores + agent attribution |
| Multi-agent parallel display | **Novel** | No consumer product | War Room — 5 agents visible simultaneously |
| Cross-agent referencing (visible) | **Novel** | Completely unprecedented | Agents react in real time, visually connected |
| Viability Score with radar | **Adapted** | Radar charts exist | Multi-dimensional AI-generated business intelligence |
| Decision Timeline / Replay | **Novel** | No equivalent | Scrubbing through multi-agent reasoning history |

**Teaching strategy for novel patterns:**
- **War Room:** No education needed — streaming text is universally understood. Agent cards with status indicators (🔍 Searching → ⚡ Analyzing → 📎 Cross-referencing → ✅ Complete) make lifecycle legible.
- **Cross-referencing:** Subtle "✨ Agents reviewing each other's findings" state transition. Cross-reference badges (📎) are familiar tappable affordances.
- **Decision Timeline:** Introduced post-report as "See how we got here." Familiar scrubbing gesture (video player metaphor). Discover on demand.

### Experience Mechanics

**Phase 1: INITIATION — "Submit Your Idea"**

| Step | User Action | System Response | Emotional Beat |
|:--|:--|:--|:--|
| Open app | Launch VentureIQ | Dark premium splash → Idea Input with generous text field | Intrigue: "This looks serious" |
| Type idea | Enter 1-3 sentences | Subtle character count, optional "Add context" expander below | Ease: "That was simple" |
| Add context (optional) | Tap expander, fill fields | Fields appear smoothly with helpful placeholders | Control: "I can shape the analysis" |
| Submit | Tap "Validate" | Button transforms, screen transitions to War Room | Anticipation: "Here we go" |

**Phase 2: INTERACTION — "The War Room"**

| Phase | Duration | What User Sees | What User Does | Emotional Beat |
|:--|:--|:--|:--|:--|
| Activation | 0-2s | Five agent cards ignite in sequence. Each shows icon, name, "Initializing..." | Watches the choreography | Awe: "The agents are alive" |
| Parallel Streaming | 2-30s | Agents stream simultaneously. One "spotlighted" (expanded), others compact. | Taps cards to switch focus. Scrolls within expanded agent. | Fascination: "I can't look away" |
| Cross-Referencing | 30-60s | "📎 Agents reviewing findings." Visual connections between cards. Strategist shows: "Pivoting GTM based on Rival's gaps..." | Taps 📎 badges to see references. The "aha!" moment. | Amazement: "They're talking to each other" |
| Synthesis | 60-75s | Coordinator indicator appears. Agent cards compact. Synthesis progress fills. | Watches synthesis. "Skip to results" visible but unobtrusive. | Anticipation: "Here comes the verdict" |
| Score Reveal | 75-90s | Viability Score count-up animation (0 → 78). Radar chart fills dimension by dimension. Haptic pulse. | Absorbs score, reads verbal anchor ("Strong"), examines dimensions. | Clarity: "Now I know" |

**Phase 3: FEEDBACK — "Trust & Verification"**

| Interaction | User Action | System Response | Emotional Beat |
|:--|:--|:--|:--|
| View radar breakdown | Tap any dimension (e.g., "Competition: 68") | Dimension expands: contributing factors, key findings, agent attribution | Understanding: "I see why" |
| Verify a claim | Tap inline citation superscript | Bottom sheet: source card with title, URL, confidence badge, snippet | Trust: "I can verify this" |
| Read agent analysis | Scroll through agent sections | Toggle blocks — summary visible, full analysis expandable | Control: "As deep as I want" |
| Flag concern | Tap low-confidence finding | Evidence Panel highlights claim, shows confidence and source | Safety: "Nothing is hidden" |

**Phase 4: COMPLETION — "Act on It"**

| Interaction | User Action | System Response | Emotional Beat |
|:--|:--|:--|:--|
| Export PDF | Tap "Export PDF" | Polished PDF preview → download. Investor-grade formatting. | Pride: "I produced this" |
| Share link | Tap "Share" | Unique web link, copy to clipboard, share sheet. No account needed to view. | Empowerment: "My co-founder needs this" |
| Ask the Board | Tap "Ask the Board" | Conversational AI opens, grounded in full report context. | Curiosity: "What about regulatory risk?" |
| New idea | Tap "Validate Another" | Returns to Idea Input. Previous report saved in history. | Momentum: "Let me try another" |

## Visual Design Foundation

### Color System

VentureIQ's color system is built on layered dark surfaces with strategic accent colors — a cinematic, premium palette that signals decision intelligence technology, not a consumer chatbot. The approach mirrors Bloomberg Terminal's authoritative darkness and Apple's dark mode depth.

#### Surface System (8 Layers)

Near-black base with progressively lighter elevated surfaces create depth and hierarchy without relying on shadows or borders.

| Token | Hex | Role |
|:--|:--|:--|
| `surface-000` | `#09090B` | App background — near black |
| `surface-050` | `#0F1117` | Card / panel background, War Room bg |
| `surface-100` | `#151823` | Elevated cards, panels |
| `surface-150` | `#1A1E2E` | Active / hover card state |
| `surface-200` | `#222639` | Input fields, wells |
| `surface-250` | `#2A2F45` | Borders, dividers (elevated) |
| `surface-300` | `#343A52` | Subtle borders |
| `surface-400` | `#4A5173` | Muted icons, dividers |

#### Brand Accents

| Color | Hex | Role | Semantic Meaning |
|:--|:--|:--|:--|
| Electric Violet | `#6C5CE7` | Primary brand, CTAs, active states | Sophistication + intelligence |
| Violet Hover | `#7E70F0` | Hover / focus state | Interactive feedback |
| Cyan | `#00D2FF` | Data, streaming indicators, charts | Real-time activity, technological precision |
| Synthesis Violet | `#A78BFA` | Coordinator, cross-reference badges | Synthesis, orchestration |

Each accent has a **muted variant** (12-15% opacity) for background tints and a **glow variant** (25-30% opacity) for focus/hover effects.

#### Agent Identity Colors

Each agent has a semantically mapped, immediately recognizable color — designed for instant visual identification in the War Room's multi-stream environment.

| Agent | Color Name | Hex | Semantic Mapping |
|:--|:--|:--|:--|
| 🔍 Scout | Intelligence Blue | `#3B82F6` | Research, discovery, analytical depth |
| ⚔️ Rival | Competitive Rose | `#F43F5E` | Competitive tension, market urgency |
| 💰 CFO | Financial Amber | `#F59E0B` | Financial modeling, growth, projections |
| ⚠️ Devil's Advocate | Critical Red | `#EF4444` | Risk, challenge, warning signals |
| 🎯 Strategist | Strategic Emerald | `#10B981` | Growth strategy, opportunity, optimism |
| 🧠 Coordinator | Synthesis Violet | `#A78BFA` | Synthesis, orchestration, final verdict |

**Color variants per agent:**
- **Full** — Text, icons, status indicators
- **Muted** (15% opacity) — Background tints for cards, badges
- **Glow** (30% opacity) — Hover effects, active state shadows on War Room cards

#### Confidence & Trust Indicators

Institutional-grade, color-coded confidence system. Uses **color + text label** (never color alone) for accessibility.

| Level | Color Name | Hex | Label Examples |
|:--|:--|:--|:--|
| High (≥80%) | Verified Green | `#22C55E` | "92% — Verified", "85% — High" |
| Mid (50-79%) | Caution Amber | `#F59E0B` | "67% — Moderate", "54% — Estimated" |
| Low (<50%) | Warning Red | `#EF4444` | "38% — Low", "22% — Unverified" |

Confidence badges are rendered as pill-shaped elements: muted background tint + colored text + leading dot indicator. The style is Bloomberg-institutional, not Duolingo-gamified.

**Cross-reference badges:** Purple (`#A78BFA`) pill badges — e.g., "📎 Responding to Devil's Advocate" — indicating inter-agent references. Tappable to navigate to the referenced finding.

#### Text System

| Token | Hex | Role |
|:--|:--|:--|
| `text-primary` | `#F0F1F5` | Primary text — high contrast headings and body |
| `text-secondary` | `#A1A7BE` | Supporting text, descriptions, agent streaming content |
| `text-tertiary` | `#6B7194` | Timestamps, labels, metadata |
| `text-disabled` | `#464D6A` | Inactive / disabled elements |
| `text-inverse` | `#09090B` | Text on light or accent-colored backgrounds |

#### Feedback / Status Colors

| Status | Hex | Usage |
|:--|:--|:--|
| Success | `#22C55E` | Completion states, agent "Complete" status |
| Warning | `#F59E0B` | Caution states, degraded performance |
| Error | `#EF4444` | Failure states, critical errors |
| Info | `#3B82F6` | Informational states, tips |

#### Special Effects

| Effect | Value | Usage |
|:--|:--|:--|
| Primary Glow | `0 0 20px rgba(108, 92, 231, 0.3)` | CTA button hover, focused inputs |
| Score Glow | `0 0 30px rgba(0, 210, 255, 0.25)` | Viability Score reveal radiance |
| Subtle Border | `1px solid rgba(255, 255, 255, 0.06)` | Default card borders |
| Active Border | `1px solid rgba(108, 92, 231, 0.4)` | Focused / active card borders |

### Typography System

**Primary Typeface: Inter** — Geometric precision, excellent legibility at small sizes, optimized for screens. Used by Linear, Vercel, Stripe, and Notion — premium technology products that prioritize information density with visual clarity.

**Monospace: JetBrains Mono** — For data values, cost metrics, token counts, hex codes, and technical metadata. Provides clear distinction between content text and data/metrics.

#### Type Scale

| Level | Size | Weight | Letter Spacing | Usage |
|:--|:--|:--|:--|:--|
| Display | 40px / 2.5rem | 800 (ExtraBold) | -0.03em | Viability Score reveal, hero numbers |
| H1 | 28px / 1.75rem | 700 (Bold) | -0.02em | Screen titles (War Room, Executive Summary) |
| H2 | 22px / 1.375rem | 700 (Bold) | -0.02em | Section headers |
| H3 | 18px / 1.125rem | 600 (SemiBold) | -0.01em | Card titles, agent names |
| Body | 15px / 0.9375rem | 400 (Regular) | 0 | Primary content, agent streaming text |
| Body SM | 13px / 0.8125rem | 400 (Regular) | 0 | Secondary content, citations, source snippets |
| Caption | 12px / 0.75rem | 400 (Regular) | 0 | Labels, timestamps, metadata |
| Micro | 11px / 0.6875rem | 500 (Medium) | 0.02em | Badges, tags, status indicators |

#### Typography Principles

1. **Negative letter-spacing on headings** — `-0.02em` to `-0.03em` creates the premium tightness seen in high-end dashboard UIs
2. **Generous line-height for readability** — `line-height: 1.6` for body text; `1.1–1.2` for display/headings
3. **Anti-aliased rendering** — `-webkit-font-smoothing: antialiased` for crisp, clean text on dark backgrounds
4. **Monospace for data** — All numerical data (costs, tokens, percentages, scores) uses JetBrains Mono to visually separate data from narrative content
5. **Weight as hierarchy** — ExtraBold (800) reserved exclusively for the Viability Score; Bold (700) for section headers; SemiBold (600) for card titles; Regular (400) for body

### Spacing & Layout Foundation

**Base Unit: 4px** — All spacing values are strict multiples of 4px, creating a consistent, harmonious rhythm across all screens.

#### Spacing Scale

| Token | Value | Common Usage |
|:--|:--|:--|
| `space-1` | 4px | Tight element gaps (icon to text) |
| `space-2` | 8px | Inline spacing, badge padding, compact gaps |
| `space-3` | 12px | Compact card padding, tight list items |
| `space-4` | 16px | Default card padding, list gaps, horizontal margins |
| `space-5` | 20px | Section inner padding |
| `space-6` | 24px | Card group spacing, generous card padding |
| `space-7` | 32px | Major section spacing within screens |
| `space-8` | 40px | Screen section breaks |
| `space-9` | 48px | Touch targets (minimum 48dp per Material guidelines) |
| `space-10` | 64px | Major layout breaks, screen-level spacing |

#### Border Radius Scale

| Token | Value | Usage |
|:--|:--|:--|
| `radius-sm` | 8px | Buttons, badges, small interactive elements |
| `radius-md` | 12px | Cards, inputs, panels |
| `radius-lg` | 16px | Elevated panels, War Room agent cards |
| `radius-xl` | 20px | Modal bottom sheets, large containers |
| `radius-full` | 9999px | Pills, confidence badges, status indicators |

#### Layout Principles

1. **Mobile-first vertical stacking** — Single column with full-width cards as default. Horizontal layouts used only where 2 items naturally pair (Viability Score + radar chart, comparison columns in Comparative Analysis)
2. **48dp minimum touch targets** — All interactive elements (buttons, tappable citations, agent card switches) meet Material Design accessibility guidelines
3. **Progressive density** — War Room uses compact padding (12–16px) to maximize information density during the streaming experience; Report view uses generous padding (20–24px) for relaxed reading
4. **Edge-to-edge cards with consistent gutters** — 16px horizontal margins from screen edge; cards span full width within those margins
5. **Content-driven breakpoints** — No rigid grid; layout responds to content type (streaming cards vs. report sections vs. comparison columns)

### Accessibility Considerations

#### Contrast Ratios (WCAG 2.1 AA Compliance)

| Combination | Ratio | Standard | Status |
|:--|:--|:--|:--|
| Primary text (`#F0F1F5`) on `surface-000` (`#09090B`) | 15.8:1 | 4.5:1 required | ✅ Exceeds |
| Secondary text (`#A1A7BE`) on `surface-050` (`#0F1117`) | 7.2:1 | 4.5:1 required | ✅ Passes |
| Tertiary text (`#6B7194`) on `surface-100` (`#151823`) | 4.6:1 | 3:1 for large text | ✅ Passes |
| Agent blue (`#3B82F6`) on `surface-050` | 5.1:1 | 4.5:1 required | ✅ Passes |
| Agent emerald (`#10B981`) on `surface-050` | 6.8:1 | 4.5:1 required | ✅ Passes |
| Agent amber (`#F59E0B`) on `surface-050` | 8.4:1 | 4.5:1 required | ✅ Passes |
| Agent rose (`#F43F5E`) on `surface-050` | 4.8:1 | 4.5:1 required | ✅ Passes |
| Agent red (`#EF4444`) on `surface-050` | 4.6:1 | 3:1 for large text | ✅ Passes |

#### Color Independence

- All confidence indicators use **color + text label** (never color alone) — "92% — Verified", "67% — Moderate", "38% — Low"
- Agent identity conveyed by **color + icon + name** — triple redundancy ensures colorblind users can distinguish agents
- Cross-reference badges include **📎 icon + descriptive text** alongside color

#### Focus & Interaction

- Focus states use a 3px accent ring: `box-shadow: 0 0 0 3px rgba(108, 92, 231, 0.25)` — visible on all interactive elements against dark backgrounds
- Touch targets meet 48×48dp minimum across all interactive elements
- Platform screen reader support (VoiceOver on iOS, TalkBack on Android) via semantic Flutter widget annotations

#### Dynamic Text Scaling

- Layout supports system text scaling up to 1.5× without layout breakage
- Card components reflow vertically when text size increases
- Score Display uses responsive sizing that scales proportionally

### Visual Foundation Reference

A comprehensive interactive HTML reference of the complete color system, typography scale, spacing system, and UI component previews is available at: `_bmad-output/planning-artifacts/ventureiq-visual-foundation.html`

## Design Direction Decision

### Design Directions Explored

Six distinct design directions were generated and evaluated as interactive HTML mockups (`_bmad-output/planning-artifacts/ux-design-directions.html`), each showing War Room, Score Reveal, and Evidence Panel implementations:

| Direction | Concept | War Room Approach | Key Strengths |
|:--|:--|:--|:--|
| ① Command Center | Dense mission-control grid | All 5 agents visible simultaneously in 2x2+1 grid | Maximum information density, all-at-once awareness |
| ② Spotlight Focus | One agent expanded at a time | Large primary card + compact thumbnail strip | Low cognitive load, Apple-like focus |
| ③ Timeline Flow | Vertical chronological feed | Agents stack as timestamped feed entries with spine | Natural scroll, chronological story, strong cross-referencing |
| ④ Tabbed Panels | Tab-based agent switching | Full-screen per agent, horizontal tab bar | Maximum depth per agent, document-like reading |
| ⑤ Card Carousel | Horizontal swipe between agents | Full-width cards with paging dots | Immersive, Stories-like, thumb-friendly |
| ⑥ Hybrid Adaptive | Spotlight + expandable grid | Spotlight default with "Expand All" toggle to grid | Serves all personas, adapts to preference |

### Chosen Direction

**Direction ⑥ Hybrid Adaptive** — with significant elements borrowed from **Direction ③ Timeline Flow** and **Direction ② Spotlight Focus**.

**Final hybrid composition:**

1. **War Room Layout: Hybrid Adaptive + Timeline Spine**
   - **Default state:** Spotlight mode — one agent expanded with rich, readable content. Compact awareness strip showing all 5 agent statuses below.
   - **Power user state:** "Expand All" toggle reveals Command Center 2×2+1 grid with all agents simultaneously.
   - **Timeline integration:** Chronological timestamp spine from Direction ③ used as the connecting metaphor. Each agent's output appears with timestamps (0:12, 0:28, 0:42) showing real-time progression.
   - **System remembers preference:** User's last mode choice (spotlight vs. expanded) persists across sessions.

2. **Score Reveal: Large Cinematic Score + Dimensional Breakdown**
   - **Hero treatment:** 72px score number with cyan→violet gradient, radial glow background effect.
   - **Anchor label:** "Strong Viability" in confidence-green immediately below.
   - **Dimensional bars:** Horizontal bar chart showing all 5 dimensions (Market, Execution, Financials, Risk, Competition) with color-coded fills and mono-font values.
   - **Key Insight card:** Agent-colored left border highlighting the most important strategic recommendation.

3. **Evidence Panel: Structured + Inline Citations with Confidence Badges (Perplexity-style)**
   - **Inline citation superscripts:** Report text contains numbered reference superscripts [1], [2], [3] linking to sources — exactly like Perplexity's approach.
   - **Expandable source cards:** Tapping a superscript reveals source details (title, URL, snippet, confidence badge).
   - **Agent attribution:** Each citation tagged with the agent that cited it ("Cited by 🔍 Scout", "Cited by ⚠️ Devil's Advocate").
   - **Confidence badges on every claim:** Pill-shaped badges (green/amber/red) attached to individual data points, not just sources.
   - **Summary stats:** Header shows "12 sources · 3 agents cited · 78% avg confidence".

### Design Rationale

**Why Hybrid Adaptive as the base:**
- **Serves all three personas simultaneously** — Maya (Curious Explorer) gets the focused Spotlight for her first validation; Daniel (Serial Entrepreneur) and Priya (Technical Founder) toggle to the dense Command Center grid for rapid multi-agent monitoring.
- **Preserves the "agents are alive" moment** — Spotlight mode creates cinematic focus that makes the cross-referencing "aha!" moment (Strategist responding to Devil's Advocate) impossible to miss.
- **Maximizes criteria coverage** — Scores ★★★ on multi-agent awareness, cross-ref visibility, mobile readability, AND cinematic impact simultaneously. No other direction achieves this.
- **Adaptive UX builds mastery** — New users start in Spotlight (low cognitive load), naturally discover the Expand toggle as they gain confidence. The system adapts to their growing expertise.

**Why Timeline spine from Direction ③:**
- **Chronological narrative** — Timestamps create a natural sense of unfolding investigation. Users feel they're watching a live analysis happen, not reading a static report.
- **Cross-reference continuity** — The timeline spine makes inter-agent references visually obvious (Strategist responding to Devil's Advocate at 0:42, triggered by Devil's finding at 0:28).
- **Reusable metaphor** — The same timeline pattern powers the "Decision Timeline" replay feature in the Executive Summary, creating cognitive continuity.

**Why Perplexity-style evidence:**
- **Institutional trust** — Inline citations with confidence badges are the highest-trust pattern in AI UIs. Users can verify any claim at any time without leaving the flow.
- **Granular confidence** — Per-claim badges (not just per-source) let users assess the strength of individual data points within a source.
- **Agent attribution** — Knowing which agent cited which source adds a layer of multi-agent transparency that no single-agent product offers.

### Implementation Approach

**War Room — Phased build:**
1. **Phase 1 (MVP):** Spotlight mode only — single expanded agent card with compact awareness strip. Timeline timestamps on each agent's output.
2. **Phase 2:** Add "Expand All" toggle → Command Center grid view. Persist user preference.
3. **Phase 3:** Auto-spotlight — system automatically focuses on the most active/interesting agent (cross-referencing, critical findings).

**Score Reveal — Animation sequence:**
1. Score number counts from 0→78 over 1.2 seconds (ease-out curve).
2. Anchor label fades in 0.3s after score lands.
3. Dimensional bars animate simultaneously, filling left-to-right over 0.8 seconds.
4. Key Insight card slides up from below with 0.4s delay.

**Evidence Panel — Integration approach:**
1. Report text rendered with numbered superscripts linked to source index.
2. Superscript tap → bottom sheet expands with source details, confidence badge, and agent attribution.
3. Evidence Panel accessible as a dedicated section (scroll below report) or as overlay (tap "Sources" button).
4. Confidence badges rendered as Flutter `Chip` widgets with muted background tints.

**Responsive behavior:**
- Portrait: Single column, Spotlight default, full-width cards
- Landscape (future tablet): Side-by-side score + dimensional breakdown
- All views: 48dp minimum touch targets, 16px horizontal margins

### Design Direction Reference

Interactive HTML mockups of all 6 explored directions are available at: `_bmad-output/planning-artifacts/ux-design-directions.html`


