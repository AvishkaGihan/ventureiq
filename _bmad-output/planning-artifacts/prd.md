---
stepsCompleted: ["step-01-init", "step-02-discovery", "step-02b-vision", "step-02c-executive-summary", "step-03-success", "step-04-journeys", "step-05-domain", "step-06-innovation", "step-07-project-type", "step-08-scoping", "step-09-functional", "step-10-nonfunctional", "step-11-polish", "step-12-complete"]
date: '2026-04-13'
lastEdited: '2026-04-14'
editHistory:
  - date: '2026-04-14'
    changes: 'Refined FR/NFR measurability; removed implementation leakage from requirements; added API documentation and enumerated error codes.'
  - date: '2026-04-14'
    changes: 'Standardized NFR verification methods so all NFRs are explicitly testable (security, scalability, reliability, observability, accessibility, integration).'
inputDocuments:
  - "product-brief-ventureiq.md"
  - "product-brief-ventureiq-distillate.md"
documentCounts:
  briefs: 2
  research: 0
  brainstorming: 0
  projectDocs: 0
classification:
  projectType: "mobile_app + api_backend (hybrid)"
  domain: "AI-powered Decision Intelligence"
  complexity: "high"
  projectContext: "greenfield"
  strategicFraming: "portfolio-first with production-grade SaaS architecture"
workflowType: 'prd'
---

# Product Requirements Document - VentureIQ

**Author:** Avishka Gihan
**Date:** 2026-04-13

## Executive Summary

Forty-two percent of startups fail because they build something nobody wants. Traditional market research costs $5,000–$50,000, takes weeks, and delivers static PDFs. The current generation of AI validation tools — single-LLM pattern matchers like IdeaProof, ValidatorAI, and DimeADozen — produce fast but unverifiable reports with no source transparency, no multi-perspective reasoning, and no way for users to assess whether the output is trustworthy enough to bet on.

**VentureIQ is a real-time, multi-agent decision intelligence platform** that transforms a raw business idea into an investor-grade validation brief in under 90 seconds. Five specialized AI agents — Scout (market research), Rival (competitor intelligence), CFO (financial modeling), Devil's Advocate (risk analysis), and Strategist (go-to-market) — execute in parallel, streaming their reasoning live in a cinematic War Room. A structured cross-referencing pass follows: agents read each other's outputs and adjust — the Strategist pivots GTM based on competitive gaps the Rival surfaced; the CFO adjusts projections against churn risks the Devil's Advocate flagged. A Coordinator then synthesizes everything into an explainable Viability Score with weighted breakdowns across five dimensions.

VentureIQ is not about generating insights — it is about enabling **confident decision-making**. Three architectural pillars form the "confidence stack" that no competitor offers:

- **Visibility** — the War Room streams agent reasoning in real time, so users see *how* conclusions are reached
- **Verifiability** — every claim carries a confidence score and clickable source citation (the Trust Layer)
- **Multi-perspective reasoning** — cross-agent intelligence ensures no single blind spot goes unchallenged

The platform targets founders validating ideas before committing resources, freelancers and consultants producing client-facing research briefs, and product managers evaluating pivots or competitive scenarios. Delivered as a Flutter mobile app (iOS & Android) backed by a client-agnostic FastAPI/LangGraph backend, the system is architected for web client extensibility and future B2B API distribution without backend refactoring.

### What Makes This Special

VentureIQ creates a **fourth category** in the AI validation market — real-time multi-agent orchestration with cross-validation, live streaming, and production observability — that no existing tool occupies. The defining moat is the Trust Layer: in a market plagued by hallucination anxiety, attaching confidence scores and direct source links to every metric is the feature that transforms AI-generated analysis into something users can stake decisions on. The Decision Timeline — a visual replay of multi-agent reasoning — is a novel UX innovation with no equivalent in any current AI product.

As a portfolio project, every architectural decision serves double duty: production-grade observability, cost engineering, token budgeting, and fault tolerance make the product commercially viable *and* demonstrate the senior-level engineering capability that attracts high-quality freelance clients and AI-focused roles.

## Project Classification

| Dimension             | Value                                                                                                                                   |
| :-------------------- | :-------------------------------------------------------------------------------------------------------------------------------------- |
| **Project Type**      | Mobile App (Flutter iOS/Android) + API Backend (FastAPI) — hybrid, web-ready                                                            |
| **Domain**            | AI-powered Decision Intelligence                                                                                                        |
| **Complexity**        | High — multi-agent LLM orchestration, real-time WebSocket streaming, cross-agent state synchronization, observability, cost engineering |
| **Project Context**   | Greenfield — new product from scratch                                                                                                   |
| **Strategic Framing** | Portfolio-first with production-grade SaaS architecture; commercially extensible                                                        |

## Success Criteria

### User Success

- **Idea-to-insight in under 90 seconds** — a user submits a raw business idea and receives a complete, multi-perspective validation brief before they'd finish writing a Google search query
- **Decision confidence, not just data** — users finish a session feeling they have enough verified, multi-perspective evidence to make a real go/no-go decision, not just "interesting AI output"
- **The cross-referencing "aha!" moment** — users witness agents reacting to each other's findings in real time (e.g., Strategist pivoting GTM based on Rival's competitive gaps), demonstrating reasoning depth that no single-LLM tool can replicate
- **Trust through transparency** — every claim in the report links to a source with a confidence score; users can verify any metric themselves rather than trusting a black box
- **Re-engagement through Ask the Board** — users return to interrogate and build on past analyses, with cross-session memory making each conversation contextually richer

### Business Success

- **Portfolio impact** — the project demonstrably showcases senior-level AI system design (multi-agent orchestration, streaming architecture, observability, cost engineering), resulting in multiple high-quality client or recruiter conversations
- **Demo-ready quality** — the War Room experience is compelling enough to anchor a portfolio presentation or technical interview, creating an immediate "this is different" reaction
- **Commercial viability signal** — architecture supports Freemium (3 reports/month), Pro ($29/mo), and API tiers without significant refactoring, validating future monetization potential
- **B2B expansion readiness** — Comparative Analysis mode is functional enough to demonstrate accelerator/incubator cohort evaluation use case

### Technical Success

- **Multi-agent reliability** — all 5 agents + Coordinator complete the hybrid parallel→cross-referencing→synthesis pipeline consistently without failures or state corruption
- **Real-time streaming** — token-by-token streaming via WebSocket/SSE delivers visible agent reasoning with <1 second to first token (architectural target)
- **Performance targets (architected to achieve):**
  - Initial response latency: <2 seconds
  - Token streaming start: <1 second
  - Full report generation: 60–90 seconds
  - Designed for 100+ concurrent users
- **Observability** — execution tracing, latency monitoring, and cost-per-request logging are operational and demonstrate production-grade engineering practices
- **Cost predictability** — token budgeting per agent and model routing prevent runaway costs; cost-per-report is measurable and within viable unit economics for $29/mo pricing
- **Security baseline** — input sanitization against prompt injection, API key isolation via backend proxying, PII-safe processing, rate limiting

### Measurable Outcomes

| Metric                            | Target                                      | Type                    |
| :-------------------------------- | :------------------------------------------ | :---------------------- |
| Idea-to-first-token               | <1 second                                   | Architectural target    |
| Idea-to-full-report               | 60–90 seconds                               | Architectural target    |
| Agent completion rate             | >95% success without errors                 | Engineering requirement |
| Source citation coverage          | Every quantitative claim cited              | Product requirement     |
| Concurrent user capacity          | 100+                                        | Architectural target    |
| Cost per report                   | Viable at $29/mo plan scale                 | Business validation     |
| Portfolio conversations generated | Multiple serious client/recruiter inquiries | Business success        |

## Product Scope

### V1 Feature Set

All 12 screens ship as a unified V1 — no features are deferred or excluded. The complete feature set is delivered iteratively across structured sprints following the dependency-driven execution order defined in Project Scoping & Phased Development:

| Screen                    | Execution Tier | Core Capability                               |
| :------------------------ | :------------- | :-------------------------------------------- |
| Idea Input (text + voice) | Tier 1         | Primary user entry point                      |
| **War Room** ⭐            | Tier 1         | Cinematic agent streaming + cross-referencing |
| Executive Summary         | Tier 1         | Viability Score with weighted radar chart     |
| Evidence Panel            | Tier 1         | Trust Layer — sources, confidence scores      |
| Market & Competitor Map   | Tier 2         | Positioning visualization                     |
| Risk Radar & GTM          | Tier 2         | Risk rankings + launch plan                   |
| Scenario Simulator        | Tier 2         | Interactive what-if variable sliders          |
| Comparative Analysis      | Tier 2         | Side-by-side A/B idea evaluation              |
| Ask the Board             | Tier 2         | Conversational AI with cross-session memory   |
| Decision Timeline         | Tier 3         | Replay Mode — agent reasoning scrubbing       |
| Export & Share            | Tier 3         | PDF download + shareable web link             |
| Splash / Onboarding       | Tier 3         | First impression, product positioning         |

**Infrastructure (spans all tiers):** FastAPI backend, LangGraph orchestration, Redis caching/state, PostgreSQL persistence, ChromaDB memory, observability stack, Docker deployment.

### Vision (Future)

Post-V1 growth features and long-term vision are detailed in the Project Scoping & Phased Development section.

- **Trusted decision intelligence layer** — extends beyond startup validation into product strategy, investment analysis, and competitive intelligence
- **Organizational tool** — teams use VentureIQ as a standard decision framework for ambiguous, high-stakes business decisions
- **Platform ecosystem** — third-party agents and custom agent configurations
- **Global expansion** — multi-language support for international markets

## User Journeys

### Journey 1: Maya — The First-Time Founder (Primary Success Path)

**Who she is:** Maya, 28, a product designer at a mid-size tech company. She's been sketching an idea for six months — an AI-powered fitness app for busy professionals — but can't justify quitting her job without knowing if the market is real. She's spent weekends Googling market reports, reading Crunchbase profiles, and building spreadsheets that feel like guesswork.

**Opening Scene:** It's Sunday night. Maya has a pitch meeting with a potential co-founder on Wednesday. She needs something more convincing than her Google Docs research dump. She downloads VentureIQ after seeing it mentioned in an indie hackers thread.

**Rising Action:** Maya opens the app and types: *"An AI-powered fitness app for busy professionals who don't have time for traditional workout routines."* She adds context: target audience is 25-45 urban professionals, monetization via subscription. She taps "Validate."

The War Room lights up. Five agent cards appear — Scout, Rival, CFO, Devil's Advocate, Strategist — each showing a pulsing "thinking" state. Within a second, Scout starts streaming: *"The global digital fitness market reached $27.4B in 2025 with a projected CAGR of 18.2%..."* — with a clickable source link inline. Maya watches, riveted, as all five agents work simultaneously.

Then the cross-referencing moment: Devil's Advocate flags a 60% historical churn rate in B2C fitness apps. Seconds later, Strategist's stream pivots mid-analysis: *"Given the churn risk identified in B2C fitness (see Devil's Advocate analysis), recommending pivot to B2B corporate wellness positioning..."* Maya sees one agent reacting to another's findings in real time. This isn't generic AI — it's a panel of experts challenging each other.

**Climax:** The Coordinator synthesizes everything into a 78/100 Viability Score. The radar chart shows strong Market (85) and Financials (79), but weaker Competition (68) and Risk (72). Maya taps the Evidence Panel — every claim has a confidence score and source link. She taps "60% churn rate" and sees the original research paper. She doesn't have to trust the AI — she can verify it herself.

**Resolution:** Maya exports an investor-grade PDF and shares the web link with her potential co-founder. At Wednesday's meeting, she presents with a level of preparation that would have taken a consulting firm two weeks and $10,000 to produce. The co-founder is in. Maya's new reality: she went from "I think this might work" to "here's exactly why this works, here's the risk, and here's the strategy to mitigate it" — in 90 seconds.

**Requirements revealed:** Idea input with context fields, real-time War Room streaming, cross-agent referencing visibility, Viability Score with radar chart, Evidence Panel with source links, PDF export, shareable web links.

---

### Journey 2: Daniel — The Freelance Consultant (Client-Facing Research)

**Who he is:** Daniel, 35, runs a one-person strategy consultancy. His clients — mainly SMB founders — pay him to assess new market opportunities. His current workflow: 15-20 hours of manual research per client report, priced at $3,000. He's good, but he can only take 2-3 clients per month before burning out.

**Opening Scene:** Daniel has three client requests sitting in his inbox and a week to deliver all of them. One client wants to launch a pet telehealth platform; another is evaluating a B2B SaaS for restaurant inventory management; the third is considering a sustainable fashion marketplace. Daniel can't physically do three deep dives in parallel.

**Rising Action:** Daniel opens VentureIQ and runs all three ideas sequentially, spending about 2 minutes on each (typing the idea + adding context fields). For the pet telehealth idea, he watches the War Room — not because he needs entertainment, but because he's evaluating whether the analysis is rigorous enough to show a client. He pays close attention to the CFO's multi-scenario revenue projections (conservative/base/optimistic) and the Rival's competitive landscape mapping.

He opens Comparative Analysis and places the restaurant SaaS and the sustainable fashion marketplace side-by-side. The structured diff view immediately highlights that the restaurant SaaS scores significantly higher on market timing and lower on competitive density — a clear recommendation emerges from the data, not from his gut.

**Climax:** Daniel opens Ask the Board for the pet telehealth report. He asks: *"What's the regulatory landscape for pet telehealth across different US states?"* The AI responds with a grounded analysis citing specific veterinary telemedicine regulations, pulling context from the full report. He follows up: *"How does this affect the CFO's revenue projections?"* — and the system connects the regulatory constraints to the financial model. Daniel is having the kind of conversation he'd normally only have with a domain expert.

**Resolution:** Daniel delivers three polished reports in 2 days instead of 3 weeks. His per-report cost dropped from 15 hours of labor to 30 minutes of refinement. He raises his prices, takes on more clients, and starts offering "rapid validation sprints" as a new service tier using VentureIQ as his backend intelligence engine.

**Requirements revealed:** Multi-report workflow, Comparative Analysis with side-by-side diff, Ask the Board with cross-session memory and report grounding, CFO multi-scenario projections, client-shareable PDF exports.

---

### Journey 3: Priya — The Product Manager (Pivot Evaluation)

**Who she is:** Priya, 31, is a senior PM at a Series B startup. Her product's growth has stalled, and leadership wants a pivot recommendation by end of quarter. She's been evaluating three potential directions but can't get consensus because every stakeholder has a different opinion and nobody has data.

**Opening Scene:** Priya is in a Monday standup where the CEO asks, "Where are we on the pivot analysis?" She's been building slides manually from scattered research. She needs a structured, evidence-backed comparison — not another opinion deck.

**Rising Action:** Priya runs three validation scenarios through VentureIQ — the current product direction, a vertical SaaS pivot, and a platform play. For each, she uses the Scenario Simulator to adjust key variables: pricing at $19/mo vs $49/mo, targeting SMB vs mid-market, US-only vs global launch. She watches how the Viability Score shifts across 12 different parameter combinations.

She pulls up the Decision Timeline for the strongest-scoring scenario to understand *why* the agents scored it highly. She scrubs through the replay: she can see the exact moment Scout's market data influenced CFO's projections, and where Strategist's GTM plan diverged based on Rival's competitive analysis. She screenshots key moments for her stakeholder deck.

**Climax:** Using Comparative Analysis, Priya places all three directions side-by-side with the Scenario Simulator results layered in. The data tells a clear story: the vertical SaaS pivot scores 82/100 vs. 61/100 for the platform play — primarily driven by lower competitive density and faster path to revenue. Risk Radar shows the platform play has 3 critical unmitigated risks vs. 1 for the vertical pivot.

**Resolution:** Priya presents to the leadership team with a deck that looks like it took a strategy consulting firm a month. The CEO approves the vertical SaaS pivot within 15 minutes. Priya's new reality: she replaced weeks of subjective debate with a structured, evidence-backed analysis that made the decision obvious.

**Requirements revealed:** Scenario Simulator with variable sliders, Decision Timeline with replay scrubbing, Comparative Analysis across multiple scenarios, Risk Radar with ranked risk visualization, multi-session persistence.

---

### Journey 4: Alex — The Platform Operator (Admin/Observability)

**Who he is:** Alex is Avishka (the developer) wearing the ops hat — monitoring VentureIQ in production to ensure reliability, catch issues before users notice, and keep costs predictable. This journey demonstrates production-grade engineering thinking.

**Opening Scene:** Alex opens the observability dashboard on Monday morning. Over the weekend, VentureIQ processed 47 reports. He needs to verify everything ran cleanly, check costs, and identify any degradation patterns.

**Rising Action:** Alex checks the LangSmith traces for weekend executions. He sees that average report generation time was 72 seconds (within the 60-90s target), but two reports took 140+ seconds. He drills into the slow traces and finds that DuckDuckGo rate limiting caused Scout and Rival to hit retry loops. He notes this for the reliability backlog.

He checks the Prometheus dashboard: cost-per-report averaged $0.12 in Gemini API calls, well within the $29/mo unit economics at the expected usage volume. Token consumption per agent is within budget limits — no runaway loops detected. Redis cache hit rate is 34%, meaning repeat queries and common market data lookups are already saving API calls.

**Climax:** Alex notices that the Devil's Advocate agent has a 7% higher error rate than other agents — it's occasionally producing output that fails structured validation. He opens the LangSmith trace for a failed execution: the agent's response exceeded the token budget and was truncated mid-JSON. He adjusts the token budget ceiling for Devil's Advocate and adds a graceful degradation handler.

**Resolution:** Alex creates a Monday health report: 47 reports processed, 95.7% success rate, $5.64 total API cost, 2 slow reports due to search provider throttling, 1 agent tuning adjustment deployed. This is the kind of operational discipline that separates a portfolio demo from a production system.

**Requirements revealed:** LangSmith/Prometheus integration, execution tracing per agent, cost-per-report and cost-per-agent tracking, token budget monitoring, error rate dashboards, search provider health monitoring, Redis cache analytics.

---

### Journey 5: Dev (Future) — The API Consumer (High-Level)

**Who they are:** A developer at an accelerator who wants to embed VentureIQ's 5-agent pipeline into their internal startup evaluation platform.

**High-level flow:** Authenticates via API key → submits idea payload via REST endpoint → receives streaming results via WebSocket/SSE → retrieves structured JSON report → uses structured output for custom dashboards and batch evaluation of startup cohorts.

**Key integration points:** RESTful API for submission and report retrieval, WebSocket/SSE for real-time streaming, structured JSON output schema, API key authentication with usage-based rate limiting, webhook callbacks for async report completion.

**Requirements revealed (future-ready):** Client-agnostic API design, structured JSON output contracts, API authentication and rate limiting infrastructure, usage tracking for billing, batch submission endpoint for cohort evaluation.

### Journey Requirements Summary

| Capability Area                   | Journeys That Require It |
| :-------------------------------- | :----------------------- |
| Real-time War Room streaming      | Maya, Daniel, Priya      |
| Cross-agent referencing (visible) | Maya, Priya              |
| Viability Score + radar chart     | Maya, Daniel, Priya      |
| Evidence Panel (Trust Layer)      | Maya, Daniel             |
| Scenario Simulator                | Priya                    |
| Comparative Analysis              | Daniel, Priya            |
| Ask the Board (conversational AI) | Daniel                   |
| Decision Timeline (replay)        | Priya                    |
| PDF export + shareable web links  | Maya, Daniel             |
| Voice input                       | Maya                     |
| Multi-session persistence         | Daniel, Priya            |
| Observability dashboards          | Alex                     |
| Cost/token tracking               | Alex                     |
| Agent error monitoring            | Alex                     |
| Client-agnostic API               | Dev (future)             |

## Domain-Specific Requirements

### AI/LLM Constraints

- **Hallucination mitigation** — every quantitative claim must carry a source citation and confidence score (the Trust Layer). If an agent cannot find a verifiable source for a claim, it must flag the output as "unverified estimate" with a reduced confidence score rather than presenting it as fact
- **Prompt injection defense** — all user inputs (idea text, context fields, Ask the Board queries) are sanitized before reaching any agent prompt. Inter-agent data flowing through LangGraph shared state is treated as untrusted and validated against expected schemas
- **Token budget enforcement** — each agent operates within a hard token ceiling. If an agent exceeds its budget, output is gracefully truncated with a structured summary rather than raw mid-sentence cutoff. The Coordinator handles partial agent outputs without pipeline failure
- **Early stopping** — if the idea fails base plausibility checks (e.g., nonsensical input, single-word submissions without context), the system surfaces a helpful prompt to refine input rather than consuming LLM resources on low-quality queries

### LLM Provider Strategy

- **Primary provider:** Google Gemini 2.5 Flash via Google AI Studio — used for all agents and synthesis in standard operation
- **Fallback provider:** Open models via OpenRouter (e.g., Llama 3, Mistral) — activated automatically when Gemini is unavailable, rate-limited, or experiencing elevated latency
- **Routing logic:** Backend detects provider health via response latency and error rates; automatic failover is transparent to the user with no UX interruption
- **Model routing optimization:** Lightweight tasks (e.g., input classification, plausibility checks) route to cheaper/faster models; complex synthesis (Coordinator, cross-referencing) routes to higher-capability models
- **Architecture requirement:** LLM calls are abstracted behind a provider-agnostic interface, enabling provider swaps without agent code changes

### Search Provider Reliability

- **Primary:** DuckDuckGo Search — zero-cost, no API key required
- **Known risk:** DuckDuckGo rate limiting under concurrent load (flagged in product brief)
- **Mitigation:** Implement retry with exponential backoff, request queuing, and Redis-based response caching for common market data queries
- **Future consideration:** Evaluate SerpAPI or Tavily as premium fallback providers if DuckDuckGo reliability proves insufficient at scale

### Data Privacy & Security

- **User idea confidentiality** — business ideas are treated as sensitive intellectual property. User-submitted ideas and generated reports are never used for model training, analytics, or shared with third parties
- **Encryption at rest** — all user data (ideas, reports, session history) is encrypted at rest in PostgreSQL. Redis ephemeral state is cleared after session expiration
- **PII-safe processing** — no personally identifiable information is stored in ChromaDB vector storage or included in LLM prompts beyond what the user explicitly provides in their idea submission
- **API key isolation** — all LLM and search provider API keys are stored server-side only; the Flutter client never has direct access to any third-party API credentials
- **Rate limiting** — IP-based and user-based rate limiting prevents abuse and protects against cost runaway from malicious usage

### Cost Engineering Constraints

- **Cost-per-report tracking** — every report execution logs total token consumption and API cost across all agents, stored for unit economics validation
- **Budget ceiling per report** — hard limit on total tokens consumed per report (across all 5 agents + Coordinator) to prevent runaway costs; if ceiling is hit, remaining agents produce condensed output
- **Cache-first strategy** — Redis caches search results and common market data queries; repeat or similar queries bypass LLM calls where cached data remains fresh
- **Target unit economics** — cost-per-report must remain viable at $29/mo Pro tier pricing across expected usage patterns

## Innovation & Novel Patterns

### Detected Innovation Areas

**1. Multi-Agent Cross-Referencing Architecture**
No existing AI validation tool uses multiple specialized agents that read each other's outputs and adjust their analyses in real time. The hybrid parallel→cross-referencing→synthesis execution model is a genuine architectural innovation — it produces emergent intelligence that a single LLM cannot replicate regardless of prompt engineering sophistication.

**2. The Confidence Stack (Decision UX Innovation)**
Three independent UX patterns — real-time reasoning visibility (War Room), source-level verifiability (Trust Layer), and multi-perspective reasoning (cross-agent intelligence) — are combined into a single "confidence stack" that no competitor offers. Each pattern exists in isolation elsewhere; the combination is novel and directly addresses the #1 barrier to AI adoption: trust.

**3. Decision Timeline / Replay Mode**
No AI product currently offers the ability to scrub through a visual timeline of how multi-agent reasoning unfolded. This is a novel UX concept that transforms AI analysis from a black-box output into an inspectable, reproducible process — bringing transparency standards from scientific methodology into consumer AI.

**4. Cinematic War Room Experience**
The concept of turning AI processing into a *live spectator experience* — where users watch agents think, search, analyze, and react to each other in real time — is a UX innovation that reframes "loading time" as "engagement time." This inverts the typical AI product pattern where processing is hidden behind spinners.

### Market Context & Competitive Landscape

The AI validation market (2026) has settled into three tiers:
- **Auto-validators** (IdeaProof, ValidatorAI) — fast, single-LLM, no transparency
- **Demand-based tools** (Preuve AI, Trend Seeker) — slow, evidence-focused, no synthesis
- **Hybrid planning platforms** (IdeaBuddy, Cambium AI) — template-driven, static documents

VentureIQ creates a **fourth tier: real-time multi-agent decision intelligence** — occupying an entirely uncontested category. The closest conceptual analog is a multi-analyst research desk (McKinsey, BCG) compressed into a 90-second automated experience.

### Validation Approach

- **Cross-agent intelligence validation** — demonstrate that cross-referencing produces measurably different (and better) recommendations than running agents independently. Test: compare report quality with and without the cross-referencing pass
- **Trust Layer impact** — measure whether source citations and confidence scores increase user decision confidence vs. identical reports without them. Test: user feedback surveys on report trustworthiness
- **War Room engagement** — validate that real-time streaming increases completion rates vs. a "submit and wait" pattern. Test: A/B comparison of War Room vs. loading-screen UX
- **Decision Timeline utility** — validate that replay capability adds value beyond the initial report. Test: usage analytics on timeline feature engagement

### Innovation Risk Mitigation

Risks specific to VentureIQ's novel features. For project execution and resource risks, see Project Scoping & Phased Development → Risk Mitigation Strategy.

| Innovation              | Risk                                              | Mitigation                                                                                             |
| :---------------------- | :------------------------------------------------ | :----------------------------------------------------------------------------------------------------- |
| Cross-agent referencing | Agents amplify each other's errors                | Coordinator validates cross-references against source data; confidence scores flag low-evidence claims |
| War Room streaming      | Users find real-time streaming overwhelming       | Progressive disclosure — summary view by default, expandable detail; user can skip to results          |
| Decision Timeline       | Low adoption if users only care about final score | Position as "show your work" for sharing with stakeholders; embed timeline highlights in PDF export    |
| Trust Layer             | Source links break or become stale                | Cache source content at generation time; flag links verified vs. unverified; timestamp all citations   |

## Mobile App + API Backend Specific Requirements

### Project-Type Overview

VentureIQ is a hybrid **Flutter mobile app** (iOS & Android) backed by a **FastAPI Python backend**. The mobile client handles presentation, real-time streaming display, and offline report caching. The backend handles all AI orchestration, data persistence, and external service integration. The architecture enforces strict client-agnostic API design to support future web clients and third-party API consumers without backend changes.

### Platform Requirements

- **Framework:** Flutter (single codebase for iOS & Android)
- **Minimum OS versions:** iOS 15+, Android 10+ (API 29+)
- **Offline capability:** Cached reports viewable offline; all AI processing requires active internet connection. Local SQLite or Hive for report cache storage on device
- **App size target:** <50MB initial download (lazy-load assets where possible)
- **Deep linking:** Support for shareable report web links that open in-app when installed, or render in browser when not

### Device Permissions

| Permission         | Purpose                                | Required/Optional                      |
| :----------------- | :------------------------------------- | :------------------------------------- |
| Internet           | Core functionality — all AI processing | Required                               |
| Microphone         | Voice input for idea submission        | Optional (requested on use)            |
| Push Notifications | Report completion, re-engagement       | Optional (prompted after first report) |
| Local Storage      | Offline report cache                   | Required                               |

### Push Notification Strategy

- **Report completion** — notify when async report generation completes (especially relevant if user backgrounds the app during 60-90s processing)
- **Re-engagement** — periodic nudges for users who haven't validated an idea recently (configurable, respectful frequency)
- **Cross-agent highlight** — optional notification when a saved report's market data has significantly changed (future feature)
- **Implementation:** Firebase Cloud Messaging (FCM) for both iOS and Android via Flutter

### Store Compliance

- **App Store (iOS):** Ensure compliance with App Store Review Guidelines — particularly around AI-generated content disclosure and subscription billing via in-app purchases for Pro tier
- **Google Play:** Comply with Play Store policies on AI content, data safety declarations, and subscription management
- **Privacy policy & Terms of Service:** Required before store submission; must disclose AI processing, data handling, and third-party API usage

### Authentication Model

- **Primary:** Google Sign-In via Firebase Authentication — single-tap sign-in on both platforms
- **Anonymous access:** Freemium users can use the app without signing in (anonymous Firebase auth); rate-limited to 3 reports/month via device fingerprinting
- **Account upgrade flow:** Anonymous users prompted to sign in when hitting free tier limits or wanting to save reports persistently
- **Session management:** JWT-based tokens issued by FastAPI backend; refresh token rotation for security
- **Future expansion:** Apple Sign-In, email/password (deferred from V1 to reduce auth complexity)

### API Architecture

- **Base URL pattern:** `/api/v1/` — versioned from day one
- **Protocol:** REST for CRUD operations + WebSocket for real-time streaming
- **Data format:** JSON request/response bodies; structured output schemas for all agent outputs

### API Documentation

- **API contract:** Maintain a versioned, machine-readable API specification (OpenAPI 3.0 or equivalent) covering endpoints, authentication, schemas, error codes, and rate limits
- **Reference docs:** Provide human-readable API reference docs with example requests/responses for each endpoint and streaming event type
- **Change discipline:** Update documentation alongside any API change; keep docs aligned to deployed `/api/v1/` behavior

### Core Endpoint Specification

| Endpoint                            | Method | Purpose                           |
| :---------------------------------- | :----- | :-------------------------------- |
| `/api/v1/auth/google`               | POST   | Google Sign-In token exchange     |
| `/api/v1/auth/anonymous`            | POST   | Anonymous session creation        |
| `/api/v1/ideas`                     | POST   | Submit new idea for validation    |
| `/api/v1/ideas/{id}`                | GET    | Retrieve idea and metadata        |
| `/api/v1/reports/{id}`              | GET    | Retrieve completed report         |
| `/api/v1/reports/{id}/export`       | GET    | Generate PDF export               |
| `/api/v1/reports/{id}/share`        | POST   | Create shareable web link         |
| `/api/v1/reports/compare`           | POST   | Comparative analysis (2+ reports) |
| `/api/v1/scenarios/{report_id}`     | POST   | Run scenario simulation           |
| `/api/v1/board/{report_id}`         | POST   | Ask the Board conversation        |
| `/api/v1/board/{report_id}/history` | GET    | Conversation history              |
| `ws://api/v1/stream/{idea_id}`      | WS     | Real-time War Room streaming      |

### Data Schemas

- **Idea submission:** `{ idea: string, context: { target_audience?, industry?, monetization?, region? } }`
- **Agent output (per agent):** `{ agent: string, status: enum, content: string, sources: [{ url, title, confidence }], metadata: { tokens_used, latency_ms } }`
- **Report:** `{ id, idea_id, viability_score: { overall, breakdown: { market, competition, financials, risk, execution } }, agents: [AgentOutput], cross_references: [...], created_at }`
- **Streaming event:** `{ event_type: enum(started|searching|analyzing|cross_referencing|complete|error), agent: string, content_delta: string, timestamp }`

### Rate Limiting

| Tier             | Limit           | Enforcement              |
| :--------------- | :-------------- | :----------------------- |
| Anonymous        | 3 reports/month | Device fingerprint + IP  |
| Free (signed in) | 3 reports/month | User ID                  |
| Pro ($29/mo)     | Unlimited       | User ID, fair-use policy |
| API (future)     | Usage-based     | API key, configurable    |

### Error Handling

- **Structured error responses:** All API errors return `{ error_code: string, message: string, details?: object }` where `error_code` is one of the enumerated codes below
- **Agent failure graceful degradation:** If individual agents fail, remaining agents complete; Coordinator synthesizes available data with reduced confidence score
- **WebSocket reconnection:** Client auto-reconnects on connection drop; server replays missed events from a server-side stream buffer

### Error Codes

| error_code                    | HTTP status | Description                                         | Retryable |
| :---------------------------- | :---------: | :-------------------------------------------------- | :-------: |
| `AUTH_REQUIRED`               |     401     | Missing authentication for a protected endpoint     |    No     |
| `AUTH_INVALID_TOKEN`          |     401     | Provided access token/session is invalid or expired |    No     |
| `AUTH_PROVIDER_TOKEN_INVALID` |     401     | Third-party identity token exchange failed          |    No     |
| `RATE_LIMIT_EXCEEDED`         |     429     | Tier-based usage limit exceeded                     |    Yes    |
| `INPUT_VALIDATION_ERROR`      |     400     | Request payload is invalid (schema/fields)          |    No     |
| `IDEA_NOT_FOUND`              |     404     | Idea ID does not exist                              |    No     |
| `REPORT_NOT_FOUND`            |     404     | Report ID does not exist                            |    No     |
| `REPORT_NOT_READY`            |     409     | Report is still generating and not yet available    |    Yes    |
| `PROVIDER_RATE_LIMITED`       |     503     | Upstream provider rate-limited the request          |    Yes    |
| `PROVIDER_UNAVAILABLE`        |     503     | Upstream provider unavailable/timeouts              |    Yes    |
| `EXPORT_FAILED`               |     500     | PDF export generation failed                        |    Yes    |
| `SHARE_LINK_FAILED`           |     500     | Share link creation failed                          |    Yes    |
| `STREAM_NOT_FOUND`            |     404     | Streaming session/resource does not exist           |    No     |
| `INTERNAL_ERROR`              |     500     | Unhandled server error                              |    Yes    |

### Implementation Considerations

- **State management (Flutter):** Use Riverpod or Bloc for reactive state management — particularly critical for War Room real-time updates across multiple agent streams
- **WebSocket management:** Implement connection pooling and heartbeat on the client; handle backgrounding gracefully (pause streaming, resume on foreground)
- **Image/chart rendering:** Radar chart (Viability Score) and market position charts rendered client-side using `fl_chart` or equivalent Flutter charting library
- **PDF generation:** Server-side via ReportLab; client requests PDF and receives download URL
- **Local caching strategy:** Cache completed reports in local storage (Hive/SQLite) for offline viewing; cache invalidation on report update

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Complete System V1 — No Feature Deferral

VentureIQ rejects the traditional "thin slice" MVP model. The product's value proposition is inherently systemic — the War Room's impact depends on the Trust Layer; the Trust Layer depends on all 5 agents producing cited, scored output; Comparative Analysis depends on the full report data model; the Decision Timeline depends on timestamped event persistence designed into the agent pipeline from day one. Stripping features doesn't create a simpler product — it creates an incoherent one.

The MVP *is* the complete V1 system: all 12 screens, all 5 agents + Coordinator, the full hybrid parallel→cross-referencing→synthesis pipeline, and every interactive feature (Scenario Simulator, Comparative Analysis, Ask the Board, Decision Timeline, Export & Share).

**Why this is the right call:**
- **Portfolio coherence** — the project's value as a portfolio showcase depends on demonstrating end-to-end system thinking, not isolated features. A partial system signals "I started something"; a complete system signals "I shipped something production-grade"
- **Architectural integrity** — features are deeply interdependent. The Decision Timeline requires the same event persistence infrastructure as War Room streaming. The Scenario Simulator reuses the agent pipeline with modified parameters. Building "phase 1" without designing for "phase 2" creates technical debt that's more expensive than building it right once
- **Competitive differentiation** — VentureIQ's moat is the *combination* of capabilities (multi-agent + streaming + Trust Layer + interactivity). Removing any pillar reduces the product to something existing competitors already offer

**Resource Requirements:** Solo developer (full-stack: Flutter + Python/FastAPI + LangGraph + infrastructure). Structured sprint execution with disciplined scope management within the unified V1.

### Execution Priority Within V1

While all features ship as a single unified system, implementation follows a deliberate **dependency-driven execution order** that ensures the system is buildable, testable, and demoable at every stage:

**Tier 1 — Core Runtime (Build First)**
The foundational pipeline that everything else depends on:
- FastAPI backend + LangGraph orchestration engine
- 5-agent parallel execution with token streaming (WebSocket/SSE)
- Cross-referencing pass with shared state
- Coordinator synthesis → Viability Score with weighted breakdown
- War Room UI (Flutter) with real-time agent streaming display
- Trust Layer infrastructure (confidence scores + source citations on all agent outputs)
- Idea Input screen (text + voice)
- Executive Summary screen with radar chart
- Evidence Panel (Trust Layer display)

**Tier 2 — Extended Intelligence (Build on Core)**
Features that extend the core pipeline with additional interaction models:
- Scenario Simulator (parameterized re-execution with variable sliders)
- Market & Competitor Map (positioning visualization from Rival/Scout data)
- Risk Radar & GTM (risk rankings + launch plan from Devil's Advocate/Strategist data)
- Ask the Board (conversational AI grounded in report, with ChromaDB cross-session memory)
- Comparative Analysis (side-by-side evaluation using structured report data model)

**Tier 3 — Experience Completion (Build to Ship)**
Features that complete the production-grade experience:
- Decision Timeline / Replay Mode (scrubbing through timestamped agent events)
- Export & Share (PDF generation via ReportLab + shareable web links)
- Splash / Onboarding screens
- Push notifications (report completion, re-engagement)
- Offline report caching (Hive/SQLite local storage)

**Tier 4 — Production Hardening (Continuous)**
Infrastructure that spans all tiers and is built incrementally:
- Authentication (Firebase Google Sign-In + anonymous access)
- Rate limiting (IP-based + user-based, tier-aware)
- Observability stack (LangSmith traces, Prometheus metrics, cost-per-report logging)
- Token budgeting enforcement and graceful degradation
- Redis caching strategy (search results, market data, partial agent outputs)
- Error handling and WebSocket reconnection resilience

**Critical design principle:** Even though Tier 2 and Tier 3 features are built after Tier 1, their **data models, API contracts, and event schemas are designed in Tier 1**. The Decision Timeline's timestamped event model is built into the streaming infrastructure from day one. The Scenario Simulator's parameterized execution is designed into the agent pipeline interface from the start. No feature is an afterthought — the architecture accommodates everything before the first line of code.

### Growth Features (Post-V1)

Features explicitly excluded from V1 that represent future expansion:
- Web client for browser-based access and shareable link rendering
- B2B API tier with usage-based pricing for third-party integrations
- Advanced model routing with multi-provider LLM support (beyond Gemini + OpenRouter fallback)
- Accelerator/incubator batch evaluation workflows
- Enhanced Scenario Simulator with saved scenario comparison history
- Multi-language support for international markets
- Platform ecosystem with third-party agents and custom agent configurations

### Risk Mitigation Strategy

**Technical Risks:**

| Risk                            | Impact                                                                                                 | Mitigation                                                                                                                                                                         |
| :------------------------------ | :----------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Multi-agent pipeline complexity | High — 5 agents + Coordinator with cross-referencing is architecturally demanding for a solo developer | Disciplined LangGraph graph design; each agent is a self-contained node with well-defined input/output contracts; extensive integration testing at the pipeline level              |
| Real-time streaming reliability | High — WebSocket connections across mobile networks are inherently unstable                            | Client-side reconnection with server-side event replay from Redis cache; heartbeat monitoring; graceful degradation to polling if WebSocket fails                                  |
| DuckDuckGo rate limiting        | Medium — free search API with no SLA                                                                   | Aggressive Redis caching of search results; exponential backoff with retry queuing; architecture supports swapping to premium provider (SerpAPI/Tavily) without agent code changes |
| Token budget overruns           | Medium — LLM costs can escalate unpredictably                                                          | Hard token ceilings per agent; model routing (lightweight tasks → cheaper models); cost-per-report logging with alerting; graceful truncation with structured summaries            |
| Cross-agent error amplification | Medium — agents reading each other's outputs could propagate errors                                    | Coordinator validates cross-references against source data; confidence scores flag low-evidence claims; each agent maintains independent source grounding                          |

**Market Risks:**

| Risk                             | Impact                                                                       | Mitigation                                                                                                                                                                     |
| :------------------------------- | :--------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AI trust skepticism              | Medium — users may distrust AI-generated analysis regardless of transparency | Trust Layer is the direct mitigation — every claim cited with confidence scores; Decision Timeline shows reasoning process; the product's entire UX is designed to build trust |
| Portfolio vs. commercial tension | Low — optimizing for portfolio impact may diverge from commercial viability  | Architecture is intentionally production-grade; commercial patterns (auth, rate limiting, billing tiers) are built in even though monetization isn't the V1 priority           |

**Resource Risks:**

| Risk                            | Impact                                                                      | Mitigation                                                                                                                                                                                                                                      |
| :------------------------------ | :-------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Solo developer bottleneck       | High — single point of failure for all development, testing, and deployment | Structured sprint execution with clear priorities; dependency-driven build order ensures demoable system at every stage; no feature is architecturally dependent on another feature being "done" (only on shared infrastructure being in place) |
| Scope creep within V1           | Medium — "all features ship" philosophy could lead to endless polish cycles | Fixed feature set defined in PRD; "done" criteria defined per feature; structured sprints with explicit completion gates                                                                                                                        |
| LLM API cost during development | Low — development and testing consume tokens                                | Use lower-cost models during development; mock agent responses for UI development; cache development queries aggressively                                                                                                                       |

## Functional Requirements

### Idea Submission & Input

- **FR1:** Users can submit a business idea as free-form text
- **FR2:** Users can submit a business idea via voice input
- **FR3:** Users can provide optional context fields alongside their idea (target audience, industry, monetization model, region)
- **FR4:** The system can assess idea plausibility and prompt the user to refine low-quality or nonsensical submissions before consuming AI resources

### Real-Time Analysis & War Room

- **FR5:** The system can execute five specialized AI agents (Scout, Rival, CFO, Devil's Advocate, Strategist) in parallel to analyze a submitted idea
- **FR6:** Users can observe each agent's reasoning streamed in real time as it is generated
- **FR7:** Users can see each agent's current lifecycle state (started, searching, analyzing, cross-referencing, complete)
- **FR8:** The system can execute a cross-referencing pass where agents adjust their outputs based on other agents' findings
- **FR9:** Users can observe cross-agent referencing as it occurs (e.g., Strategist reacting to Devil's Advocate findings)
- **FR10:** The system can synthesize all agent outputs into a unified Viability Score with weighted breakdown across five dimensions (Market, Competition, Financials, Risk, Execution)

### Report & Viability Assessment

- **FR11:** Users can view an Executive Summary with a Viability Score and visual radar chart breakdown
- **FR12:** Users can view each individual agent's full analysis within a completed report
- **FR13:** Users can access an Evidence Panel displaying source citations and confidence scores for all quantitative claims
- **FR14:** Users can tap any cited claim to view or navigate to the original source
- **FR15:** The system can flag claims as "unverified estimate" when verifiable sources are unavailable

### Market & Competitive Intelligence

- **FR16:** Users can view a Market & Competitor Map with positioning visualization and identified market gaps
- **FR17:** Users can view competitive landscape analysis including competitor strengths, weaknesses, and whitespace opportunities

### Risk & Go-to-Market

- **FR18:** Users can view a Risk Radar with ranked risks including likelihood, impact, and mitigation strategies
- **FR19:** Users can view a Go-to-Market plan with launch strategy, target persona, and key metrics

### Scenario Simulation

- **FR20:** Users can adjust key business variables (pricing, target audience, region, etc.) via interactive sliders
- **FR21:** The system can re-execute or recalculate agent projections based on modified scenario variables
- **FR22:** Users can observe how the Viability Score shifts across different parameter combinations

### Comparative Analysis

- **FR23:** Users can place two or more previously generated reports side-by-side for structured comparison
- **FR24:** Users can view a diff-style visualization highlighting key differences between compared ideas
- **FR25:** The system can surface a comparative recommendation that includes (a) a recommended option or "no recommendation", (b) per-dimension score deltas, and (c) key drivers/assumptions behind the recommendation

### Conversational AI (Ask the Board)

- **FR26:** Users can ask follow-up questions about a completed report in a conversational interface
- **FR27:** The system can respond to user questions grounded in the full report context and agent findings
- **FR28:** The system can maintain cross-session conversation history so returning users resume with prior context
- **FR29:** Users can view the full conversation history for each report

### Decision Timeline & Replay

- **FR30:** Users can view a visual timeline of how multi-agent analysis unfolded for a given report
- **FR31:** Users can scrub through the timeline to inspect specific moments in the agent reasoning process
- **FR32:** Users can identify key inflection points where one agent's findings influenced another

### Export & Sharing

- **FR33:** Users can export a completed report as a PDF that includes the Executive Summary, Viability Score breakdown, agent analyses, and citations/confidence scores
- **FR34:** Users can generate a shareable web link to a report
- **FR35:** Recipients of a shared link can view the report without requiring a VentureIQ account

### User Account & Access

- **FR36:** Users can sign in with a Google account
- **FR37:** Users can use the app without signing in (anonymous access) to generate and view reports on-device; cross-device access requires sign-in
- **FR38:** Anonymous users can upgrade to a signed-in account and retain their data
- **FR39:** The system can enforce tier-based usage limits (3 reports/month for free tier, unlimited for Pro) — _Note: In-app purchase and platform-native receipt validation (App Store/Play Store) deferred to post-V1; V1 enforces tiers via server-side rate limiting_
- **FR40:** Users can view their report history and revisit previously generated reports

### Offline & Persistence

- **FR41:** Users can view previously generated reports while offline
- **FR42:** Signed-in users can access their reports across sessions and devices

### Notifications

- **FR43:** Users can receive push notifications when a report finishes generating (especially after backgrounding the app)
- **FR44:** Users can opt in/out of re-engagement notifications

### Observability & Operations (Operator)

- **FR45:** Operators can view execution traces per agent including latency and token consumption
- **FR46:** Operators can monitor cost-per-report and cost-per-agent metrics in real time
- **FR47:** Operators can track agent error rates and identify degradation patterns
- **FR48:** Operators can monitor search provider health and cache hit rates
- **FR49:** Operators can view aggregated system health summaries across time periods

### System Safety & Integrity

- **FR50:** The system can sanitize all user inputs against prompt injection before passing to agents
- **FR51:** The system can enforce per-agent token budget ceilings with graceful degradation on exceeding limits
- **FR52:** The system can complete reports with reduced confidence when individual agents fail (graceful degradation)
- **FR53:** The system can automatically reconnect streaming sessions after connection drops and replay missed events
- **FR54:** Users can delete their account and all associated data
- **FR55:** Users can explicitly save specific scenario combinations to their history
- **FR56:** New users are presented with an onboarding carousel explaining the core value proposition

## Non-Functional Requirements

### Performance

- **NFR1:** Time-to-first-token for War Room streaming must be under 2 seconds from idea submission, measured end-to-end from client submission to first token rendered in the client UI under standard load
- **NFR2:** Agent token streaming must display with under 1 second latency between token generation and client display, measured using server emission timestamps and client render timestamps under standard load
- **NFR3:** Full 5-agent report generation (parallel execution → cross-referencing → synthesis) must complete within 60–90 seconds under standard load, measured end-to-end from idea submission to report completion
- **NFR4:** App launch to interactive state must occur within 3 seconds on mid-range devices (circa 2023 hardware), measured as time-to-interactive via mobile performance instrumentation
- **NFR5:** Offline report retrieval from local cache must load within 500 milliseconds, measured on-device as time to render the cached report view
- **NFR6:** Scenario Simulator variable adjustments must reflect updated projections within 10 seconds, measured end-to-end from parameter change to updated projections rendered in the UI
- **NFR7:** Ask the Board conversational responses must begin streaming within 3 seconds of query submission, measured end-to-end from request submit to first token rendered in the client UI
- **NFR8:** PDF export generation must complete within 15 seconds of user request, measured end-to-end from export request to PDF ready for download

### Security

- **NFR9:** All data in transit must be encrypted via TLS 1.2+, verified via periodic TLS configuration audits and automated SSL/TLS scans of all public endpoints
- **NFR10:** All user data at rest (ideas, reports, session history) must be encrypted in the primary persistent datastore, verified via periodic security configuration audits
- **NFR11:** All LLM and search provider API keys must be stored server-side only; the mobile client must never have access to third-party API credentials, verified via code review and client artifact inspection to confirm no embedded credentials
- **NFR12:** All user inputs must be sanitized against prompt injection before reaching any agent prompt, verified via automated sanitization tests using a prompt-injection test corpus
- **NFR13:** Inter-agent data flowing through shared state must be validated against expected schemas before consumption, verified via schema validation tests and inter-agent integration tests
- **NFR14:** User-submitted ideas and generated reports must never be used for model training, analytics beyond operational metrics, or shared with third parties, verified via data handling policy/configuration audits and code review of logging/export paths
- **NFR15:** No personally identifiable information beyond what the user explicitly provides may be stored in vector storage used for semantic memory or included in LLM prompts, verified via PII detection tests on stored vectors and prompt logs
- **NFR16:** Access tokens must implement refresh token rotation; session tokens must expire after a configurable inactivity period, verified via token lifecycle unit tests and session timeout integration tests
- **NFR17:** Ephemeral session/state data must be cleared after session expiration, verified via TTL/cleanup tests and periodic storage audits

### Scalability

- **NFR18:** The system must be architected to support 100+ concurrent users without degradation beyond 10% of baseline latency targets, measured via load testing at 100 concurrent active sessions against baseline latency targets
- **NFR19:** The backend must support horizontal scaling via stateless application servers with shared state stores and shared persistent datastores, verified via multi-instance deployment tests confirming statelessness and shared datastore consistency
- **NFR20:** WebSocket streaming must support at least 100 concurrent active streams with <1% server-side connection errors, measured via load testing and connection error logs
- **NFR21:** LLM API call concurrency must enforce provider rate limits with backpressure so rate-limit errors attributable to concurrency control are 0 in load tests at the configured ceiling, measured via provider response codes and internal counters
- **NFR22:** A cache layer must reduce redundant LLM/search calls by at least 20% per report compared to a no-cache baseline in a standardized test run, with configurable TTL, measured via request counters in logs/metrics

### Reliability

- **NFR23:** The system must achieve >95% agent completion rate (all 5 agents + Coordinator finishing without errors), measured via execution logs over a rolling 7-day window
- **NFR24:** Individual agent failures must not crash the pipeline; the Coordinator must synthesize available data with a reduced confidence score, verified via agent failure injection tests confirming pipeline continuation and reduced-confidence output
- **NFR25:** WebSocket disconnections must trigger automatic client reconnection with server-side replay of missed events from a server-side stream buffer, verified via connection-drop simulation tests confirming automatic reconnection and gapless event replay
- **NFR26:** LLM provider unavailability must trigger automatic failover to a fallback provider transparently to the user, verified via provider-outage simulation tests confirming transparent failover and report completion
- **NFR27:** Search provider rate limiting must be handled with exponential backoff, request queuing, and cached fallback data, verified via rate-limit simulation tests confirming backoff, queuing, and cached fallback behavior
- **NFR28:** Token budget overruns must result in graceful output truncation with structured summaries, not raw mid-sentence cutoffs, verified via token-budget exhaustion tests confirming structured-summary output
- **NFR29:** The system must handle app backgrounding during report generation and resume streaming on foreground without data loss, verified via app background/foreground lifecycle tests confirming stream resume via buffered replay without loss

### Observability

- **NFR30:** Every report execution must generate a complete trace capturing per-agent latency, token consumption, and API cost, verified via trace audits confirming required fields are present per execution
- **NFR31:** Execution traces must be accessible via a tracing UI or exportable to tracing infrastructure, verified via operational checks confirming traces are viewable in a UI or exportable
- **NFR32:** Metrics must capture request latency, error rates, cache hit ratios, and cost-per-report at minimum, verified via metrics audits confirming required fields are emitted and queryable
- **NFR33:** Agent error rates must be trackable per-agent with historical trend visibility, verified via metrics/dashboards checks confirming per-agent error-series and historical retention
- **NFR34:** Cost-per-report must be calculable from logged token consumption and provider pricing, verified via cost calculation tests confirming accurate token-to-cost mapping per report

### Accessibility

- **NFR35:** The app must support platform-native screen reader accessibility (VoiceOver on iOS, TalkBack on Android) for core user flows (idea submission, report viewing), verified via VoiceOver/TalkBack testing of core flows (labels, focus order, actions)
- **NFR36:** All interactive elements must meet minimum touch target sizes (48x48dp) per platform guidelines, verified via automated UI checks and manual accessibility audit
- **NFR37:** Text contrast ratios must meet WCAG 2.1 AA standards (4.5:1 for normal text, 3:1 for large text), verified via design review and accessibility audit
- **NFR38:** The app must support dynamic text sizing based on system accessibility settings, verified via accessibility testing across system text scales without layout breakage

### Integration

- **NFR39:** All LLM interactions must be abstracted behind a provider-agnostic interface enabling provider swaps without agent code changes, verified via provider-swap integration tests demonstrating no agent code changes
- **NFR40:** Search provider integration must be abstracted to support swapping providers (free vs. paid) without agent code changes, verified via provider-swap integration tests demonstrating no agent code changes
- **NFR41:** Authentication must support both Google account sign-in and anonymous authentication flows, verified via authentication integration tests for both flows
- **NFR42:** Push notifications must achieve >= 99% delivery success (excluding invalid/unregistered devices), measured via push provider delivery receipts and in-app receipt telemetry
- **NFR43:** The API must maintain backward compatibility within major versions (v1); breaking changes require version increment, verified via backward-compatibility contract tests and versioning policy enforcement
