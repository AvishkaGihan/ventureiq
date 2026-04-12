---
stepsCompleted: ["step-01-init", "step-02-discovery", "step-02b-vision", "step-02c-executive-summary", "step-03-success", "step-04-journeys", "step-05-domain"]
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

| Dimension | Value |
|:--|:--|
| **Project Type** | Mobile App (Flutter iOS/Android) + API Backend (FastAPI) — hybrid, web-ready |
| **Domain** | AI-powered Decision Intelligence |
| **Complexity** | High — multi-agent LLM orchestration, real-time WebSocket streaming, cross-agent state synchronization, observability, cost engineering |
| **Project Context** | Greenfield — new product from scratch |
| **Strategic Framing** | Portfolio-first with production-grade SaaS architecture; commercially extensible |

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

| Metric | Target | Type |
|:--|:--|:--|
| Idea-to-first-token | <1 second | Architectural target |
| Idea-to-full-report | 60–90 seconds | Architectural target |
| Agent completion rate | >95% success without errors | Engineering requirement |
| Source citation coverage | Every quantitative claim cited | Product requirement |
| Concurrent user capacity | 100+ | Architectural target |
| Cost per report | Viable at $29/mo plan scale | Business validation |
| Portfolio conversations generated | Multiple serious client/recruiter inquiries | Business success |

## Product Scope

### MVP — Minimum Viable Product

All 12 screens are V1 scope, delivered iteratively across structured sprints. Nothing is deferred or excluded — the MVP *is* the complete V1 feature set:

| Screen | Sprint Priority | Core Capability |
|:--|:--|:--|
| Splash / Onboarding | Phase 1 | First impression, product positioning |
| Idea Input (text + voice) | Phase 1 | Primary user entry point |
| **War Room** ⭐ | Phase 1 | Cinematic agent streaming + cross-referencing |
| Executive Summary | Phase 1 | Viability Score with weighted radar chart |
| Evidence Panel | Phase 1 | Trust Layer — sources, confidence scores |
| Market & Competitor Map | Phase 2 | Positioning visualization |
| Risk Radar & GTM | Phase 2 | Risk rankings + launch plan |
| Scenario Simulator | Phase 2 | Interactive what-if variable sliders |
| Comparative Analysis | Phase 3 | Side-by-side A/B idea evaluation |
| Ask the Board | Phase 3 | Conversational AI with cross-session memory |
| Decision Timeline | Phase 3 | Replay Mode — agent reasoning scrubbing |
| Export & Share | Phase 3 | PDF download + shareable web link |

**Infrastructure (spans all phases):** FastAPI backend, LangGraph orchestration, Redis caching/state, PostgreSQL persistence, ChromaDB memory, observability stack, Docker deployment.

### Growth Features (Post-V1)

- Web client for browser-based access and shareable link rendering
- B2B API tier with usage-based pricing for third-party integrations
- Advanced model routing with multi-provider LLM support
- Accelerator/incubator batch evaluation workflows
- Enhanced Scenario Simulator with saved scenario comparison

### Vision (Future)

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

| Capability Area | Journeys That Require It |
|:--|:--|
| Real-time War Room streaming | Maya, Daniel, Priya |
| Cross-agent referencing (visible) | Maya, Priya |
| Viability Score + radar chart | Maya, Daniel, Priya |
| Evidence Panel (Trust Layer) | Maya, Daniel |
| Scenario Simulator | Priya |
| Comparative Analysis | Daniel, Priya |
| Ask the Board (conversational AI) | Daniel |
| Decision Timeline (replay) | Priya |
| PDF export + shareable web links | Maya, Daniel |
| Voice input | Maya |
| Multi-session persistence | Daniel, Priya |
| Observability dashboards | Alex |
| Cost/token tracking | Alex |
| Agent error monitoring | Alex |
| Client-agnostic API | Dev (future) |

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
