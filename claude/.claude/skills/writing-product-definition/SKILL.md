---
name: writing-product-definition
description: You MUST use when writing a product definition, defining or reviewing Features, mapping validated requirements to features, or amending feature scope. Symptoms include "write the features", "build the product definition board", "does this belong on the board?", features with acceptance criteria on them, one feature per filter/page/screen, or a validated feature being edited after the client signed off.
---

# Writing Product Definition / Features

## Overview

The Product Definition is the main artifact of the Think phase: the set of **Features** that define the specific, usable capabilities of the product. A Feature is a **product-facing capability that satisfies one or more validated Requirements**. Requirements say what must be true; Features say what the product does about it; Stories slice how it gets built.

**Core tests — every Feature must pass all three:**

1. **Recognisable capability** — named as something a user would recognise ("Vehicle Search"), not a component, page, layer, or standard.
2. **Traceable** — `satisfies` at least one Requirement; every *functional* Requirement is satisfied by at least one Feature.
3. **Right-sized** — larger than a single Story (a specific filter is a Story), smaller than a Requirement ("a user can find safe vehicles" is a Requirement). It must decompose into at least one vertically-sliced Story, and must not overlap another Feature's capability.

## The Feature Card

A Feature card on the product definition board IS, exactly:

```markdown
## FEAT-<n> — <Capability Name>

- **satisfies:** REQ-<…> [, REQ-<…>]
- **informed by:** RFC-<n> <title>            <!-- link, if one informs it -->
- **status:** Draft | Reviewed | Validated | Live | Descoped | Superseded

### Description
- **Context / problem being solved:** …
- **Expected interactions:** …
- **Unknowns:** …
- **Assumptions:** …
- **Business logic:** …
- **Content management requirements:** …
- **Data sources:** …
- **Success metrics & tracking location:** …
- **Out of scope:** …

### Design refs
- <Figma / wireframe links>

### Stories
- STORY-<n> <statement>        <!-- derived child Stories, added as sliced -->
```

Every Description field appears on every card. An honest "None" or "TBD — owner: <who>" is a valid value; a missing field is not, because an absent **Unknowns** or **Out of scope** line reads as "none exist" when nobody asked.

**What is NOT on a Feature card:** acceptance criteria (Given/When/Then lives on Stories), user-story statements ("As a user, I want…" is a Story), test plans, iteration/version slices (V1/V2/V3), estimates, technical approach. If you're writing behaviour concrete enough to test, you're writing a Story — move it down a level.

## Granularity — the ladder

```
REQ    "A user can find and view safety info for a vehicle"   ← need
FEAT   "Vehicle Search", "Vehicle Details"                    ← capability
STORY  "Filter vehicles by Lifestyle", "View search results"  ← slice
```

| Draft says… | It's actually a… | Do this |
| --- | --- | --- |
| One card per filter / tab / button | Story | Group under the capability Feature; track filters as Stories |
| "Search Results Page", "Detail Screen" | Story / design artifact | Fold into the capability Feature it serves |
| "A user can plan and manage all their meals" | Requirement-sized | Split into distinct capabilities (Planner, Shopping List, …) |
| Two cards both claiming the same behaviour | Overlap | Merge, or redraw the boundary so each behaviour has one home |

Heuristic: if the card names a page, screen, or component rather than something a user accomplishes, it's a Story or a design ref, not a Feature.

## Non-Functional Requirements and Enabling Work

**An NFR never gets its own Feature.** Accessibility, performance, "uses the same data as X" — these are cross-cutting constraints that apply to every Feature and are verified through specific test plans in UAT. Note them in each Feature's Description where they shape it (e.g. Data sources), never as an "Accessibility" or "API Integration" card. Where dedicated work exists, it's a **polish Story** (satisfies the NFR directly, e.g. reduced-motion states → WCAG) or an **infra Story** (relates-to an RFC, satisfies the NFR, scheduled into Sprint 0) — not a Feature.

This holds under pressure. "If it's not a Feature it'll be forgotten" → coverage lives in the traceability table (below) and UAT test plans, which is where NFRs are actually verified; a standalone NFR card becomes an end-of-project remediation lump instead.

## Lifecycle and Scope Changes

```
Draft → Reviewed → Validated → Live
  (any) ──────────→ Descoped
        Validated ─→ Superseded
```

- **Draft:** any team member captures a candidate capability.
- **Reviewed:** the Tech Lead confirms it's feasible and well-formed.
- **Validated:** the client agrees it's in scope.
- **Live:** shipped in the product.

**A Validated Feature is never edited in place. No exceptions.** When scope changes — even client-requested, even "just adding a filter", even when re-validation would be a formality:

1. Create a new Feature that **relates-to** the predecessor, carrying the amended scope.
2. Mark the predecessor **Superseded**.

The client validated a specific text; changing that text destroys the audit trail of what was agreed when. "It's basically the same feature", "the change is client-initiated", "a new ID is bureaucratic" — all still edit history in place. New card, relates-to link, predecessor Superseded. Dropped from scope entirely → **Descoped** (including Won't requirements' features).

## Coverage Check (before client review)

Close with a traceability table and verify: **every functional Requirement is satisfied by at least one Validated Feature**; every NFR is marked cross-cutting (with its verifying polish/infra Stories once they exist); no Feature satisfies nothing.

| REQ | Statement | Features |
| --- | --- | --- |
| REQ-1 | Find and view safety info for a vehicle | FEAT-1 Vehicle Search, FEAT-2 Vehicle Details |
| REQ-5 | WCAG 2.2 AA | cross-cutting — all Features; polish Stories 8, 12 |

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Given/When/Then or ACs on a Feature | Move to the child Stories; the Feature keeps Description fields only |
| "WCAG Accessibility" / "API Integration" Features | Cross-cutting constraint + UAT test plans; infra/polish Stories for the work |
| One Feature per filter, tab, or page | Those are Stories under one capability Feature |
| Inventing V1/V2/V3 slices or walking skeletons on the card | Sequencing lives in Stories and Sprints, not the product definition |
| Editing a Validated Feature in place | New Feature relates-to predecessor; mark predecessor Superseded |
| Omitting Unknowns / Assumptions / Out of scope | Every field on every card; "None" or "TBD — owner" beats absence |
| Functional REQ with no Feature | Add one or descope the REQ explicitly — never leave it dangling |

## Quick Reference

- Feature = **capability a user would recognise**, satisfying ≥1 REQ, sliceable into ≥1 Story, overlapping no other Feature.
- Card = id/name + satisfies + RFC link + status + **all nine Description fields** + design refs + child Stories.
- ACs and "As a user…" belong on **Stories**, never Features.
- NFRs are **cross-cutting**, verified in UAT; work lands as polish/infra Stories.
- Validated + scope change = **Supersede + relates-to**, never edit in place.
- Finish with the **traceability table**: every functional REQ → ≥1 Feature.
