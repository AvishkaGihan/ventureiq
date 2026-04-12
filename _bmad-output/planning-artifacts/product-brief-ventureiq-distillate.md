---
title: "Product Brief Distillate: VentureIQ"
type: llm-distillate
source: "product-brief-ventureiq.md"
created: "2026-04-12T23:07:00+05:30"
purpose: "Token-efficient context for downstream PRD creation"
---

# VentureIQ — Detail Pack for PRD Creation

## Requirements Hints

- **All 12 screens are V1 scope** — no feature deferral. Splash, Onboarding, Idea Input (text+voice), War Room, Executive Summary, Evidence Panel, Market Map, Scenario Simulator, Risk Radar & GTM, Comparative Analysis, Ask the Board, Decision Timeline, Export & Share
- **Voice input is explicitly in scope** — implies speech-to-text integration in the Flutter client; infrastructure TBD
- **Cross-session memory for Ask the Board** — user expects conversational AI to remember prior sessions, requiring persistent vector storage per user
- **Shareable web links** — reports must be accessible via unique URLs, implying a public-facing report rendering layer
- **PDF export must be "investor-grade"** — polished formatting via ReportLab, not raw data dumps
- **Side-by-side comparison output** for Comparative Analysis — implies a structured data model for saved ideas that supports diff-style rendering
- **Radar chart visualization** for Viability Score — weighted breakdown across Market, Risk, Financials, Competition, Execution dimensions
- **Decision Timeline / Replay Mode** — scrubbing through agent execution requires persisting timestamped agent events (not just final outputs)
- **Scenario Simulator** — interactive sliders for variables (price, audience, region) that re-trigger agent projections — implies parameterized re-execution or cached partial results
- **Agent "thinking states"** visible in War Room — requires streaming lifecycle events (started, searching, analyzing, cross-referencing, complete) alongside token output

## Technical Context

- **Flutter** for iOS & Android mobile client
- **FastAPI (Python)** backend with WebSocket/SSE for token streaming
- **LangGraph** for multi-agent orchestration — graph state management
- **Google Gemini 2.5 Flash** via Google AI Studio as primary LLM
- **Redis** — agent result caching, real-time state, rate limiting (IP/user-based)
- **PostgreSQL** — user data, reports, session history persistence
- **ChromaDB + sentence-transformers** — semantic search and memory layer
- **DuckDuckGo Search** — web search tool for agents (note: rate limiting risk flagged by reviewers)
- **LangSmith / Prometheus** — execution tracing, latency monitoring, cost-per-request logging
- **ReportLab** — PDF generation
- **Celery / RQ** — background processing for async jobs
- **Docker** — containerized deployment, cloud-ready architecture
- **CI/CD pipeline** — automated testing and deployment (tooling TBD)

### Execution Model (Critical Architecture Detail)
- **Hybrid parallel→cross-referencing→synthesis** model
- **Pass 1:** All 5 agents run in parallel, producing independent analyses while streaming tokens to client
- **Pass 2:** Structured cross-referencing — agents (or Coordinator) read shared state and adjust outputs. Example: CFO adjusts projections based on Devil's Advocate churn risk; Strategist pivots GTM based on Rival's competitive gaps
- **Pass 3:** Coordinator synthesizes all outputs into final Viability Score with weighted breakdown
- This implies a LangGraph graph structure with parallel fan-out → conditional edges → synthesis node

### Security & Safety
- Input sanitization against prompt injection
- Backend proxying hides all API keys from client
- PII-safe processing — no sensitive user data in vector DB
- Token budgeting with hard limits per agent to prevent runaway loops
- Early stopping if idea fails base plausibility checks

### Cost Engineering
- Model routing: lightweight tasks → cheaper models; complex synthesis → advanced models
- Redis caching bypasses LLM calls for repeated queries and standard market data
- Token budgeting per agent enforces cost predictability

## The Agent Crew (Detailed)

| Agent | Role | Output | Key Detail |
|:--|:--|:--|:--|
| 🔍 Scout | Market Research | Market sizing, growth rate, trends, cited sources | Pulls live CAGR data, market reports |
| ⚔️ Rival | Competitor Intelligence | Competitor landscape, strengths/weaknesses, market gap | Maps competitive positioning, identifies whitespace |
| 💰 CFO | Financial Modelling | Multi-year revenue projections across scenarios | Freemium/premium modeling, multi-scenario (conservative/base/optimistic) |
| ⚠️ Devil's Advocate | Risk Analysis | Risk breakdown, failure modes, mitigations | Quantified risk scoring (likelihood × impact), historical failure rate data |
| 🎯 Strategist | Go-to-Market | Launch plan, target persona, key metrics | Can pivot strategy based on cross-agent signals |
| 🧠 Coordinator | Synthesis | Explainable Viability Score, executive summary, cross-checks | Weighted scoring across 5 dimensions, aggregation logic |

- All agents provide **Confidence Scores** and **Source Citations** — the Trust Layer
- Agents can influence each other via structured state sharing in the cross-referencing pass

## Competitive Intelligence (From Web Research)

### Direct Competitors (AI Validation Tools — 2026)
- **IdeaProof** — AI auto-validator, instant pattern matching. No multi-agent, no streaming, no cross-validation
- **ValidatorAI** — Quick LLM-based risk screening. Single-agent, static output
- **DimeADozen** — AI validation reports. No source transparency, no interactivity
- **Preuve AI** — Demand-based, scrapes Reddit/forums for evidence. Slow (48-72hrs), different category
- **Trend Seeker** — Social listening for demand evidence. Complementary, not competitive
- **IdeaBuddy / Cambium AI / Venturekit** — Hybrid planning platforms. Static documents, template-driven

### VentureIQ's Unique Position
- Creates a **fourth category** not occupied by any existing tool: real-time multi-agent orchestration with cross-validation, live streaming, and production observability
- No competitor offers cinematic War Room, agent cross-referencing, or Decision Timeline
- Trust Layer (confidence + citations) is the primary moat

### Key Market Data Points
- 42% of startups fail because they build something nobody wants
- 84% of founders find traditional market research too slow and expensive
- AI validation tools charge $29-$59 per report or offer subscription models
- Industry experts recommend layered validation (AI screen → demand check → willingness-to-pay)
- VentureIQ effectively collapses all three validation layers into one automated pipeline

## Detailed User Scenarios

### Demo Scenario (Portfolio Hook)
- **Input:** "An AI-powered fitness app for busy professionals"
- **Scout** immediately pulls 2025 CAGR data for digital health market
- **Rival** maps MyFitnessPal and Noom, identifies gap in "time-poor executive fitness"
- **CFO** streams freemium revenue projection over 3 years
- **Devil's Advocate** flags 60% historical churn rate in similar B2C apps
- **Strategist** pivots GTM to B2B corporate wellness packages to mitigate churn
- **Output:** 78/100 Viability Score → Decision Insight: "Pivot to B2B corporate wellness"
- This scenario demonstrates cross-agent intelligence (Strategist reacting to Devil's Advocate)

### User Journey (Core Flow)
1. Splash / Onboarding → First impression, communicates product power
2. Idea Input → Text or voice with context fields
3. War Room ⭐ → Cinematic dashboard, agent streaming, cross-referencing visible
4. Executive Summary → Viability Score + radar chart
5. Evidence Panel → Trust Layer with sources, links, confidence
6. Market & Competitor Map → Positioning visualization
7. Scenario Simulator → Interactive what-if sliders
8. Risk Radar & GTM → Ranked risks + launch plan
9. Comparative Analysis → Side-by-side A/B of saved ideas
10. Ask the Board → Conversational AI grounded in report
11. Decision Timeline → Replay Mode scrubbing
12. Export & Share → PDF + shareable web link

## UI & Design Direction

- **Aesthetic:** Cinematic, advanced, premium — dark authoritative theme
- **Nothing generic** — every screen should feel like operating serious technology
- **Rich animations, polished transitions** throughout
- **Trust signals as first-class UI** — citations, confidence intervals, agent execution logs are visible and beautiful
- **Agent "thinking states"** visible in War Room (started, searching, analyzing, cross-referencing, complete)
- **Real-time token streaming** with typing simulation effects

## Monetization Strategy

- **Freemium:** 3 free reports/month, basic web search grounding
- **Pro SaaS ($29/mo):** Unlimited reports, Scenario Simulation, Comparative Analysis, PDF exports
- **API Tier:** Usage-based pricing for B2B embedding of the 5-agent pipeline
- **B2B Expansion:** Comparative Analysis mode positions uniquely for accelerators/incubators evaluating startup cohorts

## Performance SLAs (Targets — Architected to Achieve)

- Initial response latency: < 2 seconds
- Token streaming start: < 1 second
- Full report generation: 60–90 seconds
- Concurrent users: designed for 100+

## Scope Signals

- **All features are V1** — nothing deferred
- **Built iteratively across structured sprints** — phased engineering, not monolithic delivery
- **Portfolio-first** — designed to attract freelance clients and AI-focused roles
- **Commercially viable** — architecture supports evolution into production SaaS if traction emerges

## Open Questions (For PRD Phase)

- **Speech-to-text provider** for voice input — platform-native (iOS/Android) or cloud API (Whisper, Deepgram)?
- **ChromaDB data model** — what exactly is stored? User report history? Market data corpus? Clarify RAG strategy
- **Cross-referencing mechanism** — exact LangGraph implementation: conditional edges, second graph invocation, or state mutation callbacks?
- **Scenario Simulator re-execution** — full agent re-run with modified parameters, or cached partial results with delta computation?
- **Replay Mode data model** — granularity of timestamped events to persist for timeline scrubbing
- **Shareable link infrastructure** — public report rendering service, auth model for shared links, expiration policy
- **Cost-per-report estimate** — 5 Gemini calls + web searches per report — validate against $29/mo unit economics at scale
- **DuckDuckGo reliability** — rate limiting and availability SLA for production use; evaluate alternatives (SerpAPI, Tavily)
- **Testing strategy details** — specific test frameworks, coverage targets, load testing tooling (Locust, k6?)
- **Cloud deployment target** — AWS, GCP, or other? Kubernetes or simpler container deployment?

## Rejected Ideas / Decisions Made

- **No feature deferral** — user explicitly rejected phased feature delivery; all 12 screens ship in V1
- **Not a pure commercial product (yet)** — portfolio-first framing, but commercially designed
- **"Architected to achieve" SLA language** — not claiming proven benchmarks; targets are design goals validated through architecture, not production evidence
