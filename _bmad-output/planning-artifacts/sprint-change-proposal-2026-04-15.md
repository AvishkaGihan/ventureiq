---
trigger: Implementation Readiness Assessment Report (2026-04-15)
scope: Minor
mode: Batch
status: Applied
appliedAt: 2026-04-15
---

# Sprint Change Proposal — Post-Readiness Alignment

**Date:** 2026-04-15
**Trigger:** Implementation Readiness Assessment identified 6 documentation alignment issues
**Scope Classification:** Minor — all changes are documentation synchronization, no structural/architectural changes

---

## 1. Issue Summary

The Implementation Readiness Assessment (2026-04-15) performed a systematic cross-document analysis across the PRD, Architecture, Epics, and UX Specification. It found **6 documentation alignment issues** (3 major, 3 minor) — all traceable to the epics and architecture documents being authored against an earlier PRD version (FR1–FR53) before FR54–FR56 were added, and minor WebSocket event naming inconsistencies across documents.

No architectural flaws, structural problems, or missing features were found. All issues were documentation synchronization gaps.

---

## 2. Impact Analysis

### Epic Impact
- **No epic additions, removals, or resequencing required**
- Existing stories already cover FR54–FR56 in their acceptance criteria — only the FR Coverage Map and Requirements Inventory sections needed updating

### Artifact Conflicts Resolved

| Artifact | Issue | Resolution |
|---|---|---|
| **epics.md** | Requirements Inventory missing FR54–FR56 | Added FR54, FR55, FR56 text |
| **epics.md** | FR Coverage Map missing FR54–FR56 | Added FR54→Epic 15, FR55→Epic 9, FR56→Epic 15 |
| **epics.md** | Story 4.2 missing `control_spotlight` | Added to WebSocket control event list |
| **epics.md** | FR39 silent on receipt validation deferral | Added explicit deferral note |
| **architecture.md** | FR count stated as 53 (should be 56) | Updated to 56 in all 5 locations |
| **architecture.md** | Requirements table missing FR54–FR56 rows | Added 3 rows with architectural implications |
| **architecture.md** | Coverage validation missing FR54–FR56 | Added 3 coverage rows |
| **architecture.md** | WebSocket events missing `control_pause` | Added to client→server event table |
| **architecture.md** | Gap analysis missing NFR10/NFR14 note | Added deployment-enforced note |
| **prd.md** | FR39 included receipt validation in V1 scope | Deferred to post-V1 with explicit note |

### Technical Impact
- **Zero code impact** — no implementation is in progress yet
- **Zero timeline impact** — all changes are metadata/documentation only

---

## 3. Recommended Approach

**Selected: Direct Adjustment** — modify existing document sections in place.

**Rationale:**
- All issues are documentation alignment gaps, not structural problems
- Changes are additive (adding missing entries) or clarifying (deferral notes)
- No stories, epics, or architectural decisions need restructuring
- Effort: **Low** | Risk: **Low** | Timeline impact: **None**

---

## 4. Detailed Change Proposals (Applied)

### 4.1 epics.md — Requirements Inventory (FR54–FR56 Added)

```diff
 FR53: The system can automatically reconnect streaming sessions after connection drops and replay missed events
+FR54: Users can delete their account and all associated data
+FR55: Users can explicitly save specific scenario combinations to their history
+FR56: New users are presented with an onboarding carousel explaining the core value proposition
```

### 4.2 epics.md — FR Coverage Map (FR54–FR56 Added)

```diff
 FR53: Epic 4 — WebSocket reconnection
+FR54: Epic 15 — Account & data deletion
+FR55: Epic 9 — Save scenario combinations
+FR56: Epic 15 — Onboarding carousel
```

### 4.3 epics.md — FR39 Deferral Note Added

```diff
-FR39: The system can enforce tier-based usage limits (3 reports/month for free tier, unlimited for Pro)
+FR39: The system can enforce tier-based usage limits (3 reports/month for free tier, unlimited for Pro) — Note: In-app purchase and platform receipt validation deferred to post-V1
```

### 4.4 epics.md — Story 4.2 WebSocket Controls Aligned

```diff
-**And** Client→server control messages support: `control_pause`, `control_resume`, `control_skip`
+**And** Client→server control messages support: `control_pause`, `control_resume`, `control_skip`, `control_spotlight`
```

### 4.5 architecture.md — FR Count Updated (5 locations)

All references to "53 FRs" updated to "56 FRs":
- Requirements Overview header
- Requirements Coverage Validation count
- Architecture Completeness Checklist
- Architecture Readiness Assessment

### 4.6 architecture.md — FR54–FR56 Added to Requirements Table

```diff
 | System Safety (FR50-53) | ... | ... |
+| User Lifecycle (FR54) | Account & data deletion | Cascading delete across PostgreSQL, ChromaDB, Redis |
+| Scenario Persistence (FR55) | Save scenario combinations | Scenario state persistence, history linkage |
+| Onboarding (FR56) | First-launch onboarding carousel | Hive flag for onboarding completion |
```

### 4.7 architecture.md — `control_pause` Added to WebSocket Events

```diff
 | `control_resume` | `agent` (optional) | Client → Server |
+| `control_pause` | `agent` (optional) | Client → Server |
 | `control_spotlight` | `agent` | Client → Server |
 | `control_skip` | — | Client → Server |
```

### 4.8 architecture.md — NFR10/NFR14 Gap Acknowledged

```diff
 3. Push notification triggers beyond report completion — implementation decision
+4. NFR10 (encryption at rest) and NFR14 (no-training-data policy) — enforced via PostgreSQL configuration and data handling policy during deployment; no dedicated epic required
```

### 4.9 prd.md — FR39 Receipt Validation Deferred

```diff
-- **FR39:** The system can enforce tier-based usage limits ... and validate Pro tier subscriptions via platform native receipt validation (App Store/Play Store)
+- **FR39:** The system can enforce tier-based usage limits ... — Note: In-app purchase and platform-native receipt validation (App Store/Play Store) deferred to post-V1; V1 enforces tiers via server-side rate limiting
```

---

## 5. Implementation Handoff

**Scope:** Minor — all changes applied directly by the current agent session.

**Status: ✅ ALL CHANGES APPLIED**

All 6 issues from the Implementation Readiness Assessment have been resolved:

| # | Issue | Status |
|---|---|---|
| 1 | FR Coverage Map incomplete (FR54–FR56) | ✅ Fixed in epics.md |
| 2 | Architecture FR count mismatch (53→56) | ✅ Fixed in architecture.md |
| 3 | FR39 receipt validation gap | ✅ Deferred in prd.md + epics.md |
| 4 | WebSocket event type discrepancy | ✅ Aligned across architecture.md + epics.md |
| 5 | NFR10/NFR14 unassigned | ✅ Documented in architecture.md gap analysis |
| 6 | Epics requirements inventory incomplete | ✅ FR54–FR56 added to epics.md |

**Success Criteria:** All documents (PRD, Architecture, Epics) now reference a consistent set of 56 FRs, 43 NFRs, 4 WebSocket control events, and explicit deferral of receipt validation to post-V1.

**Next Step:** Project is ready for Epic 1 implementation.
