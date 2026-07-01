---
name: writing-user-stories
description: Use when decomposing a system, feature, epic, requirement, or spec into a backlog of user stories, or whenever about to write user stories or acceptance criteria during planning. Symptoms include "break this into stories", "write the backlog", "split this epic", stories that feel too big to estimate, or technical tasks masquerading as stories.
---

# Writing User Stories

## Overview

A user story is **one thin vertical slice of user-observable value**, small enough to ship independently and concrete enough to test. Decomposition means slicing a system by _user journeys and capabilities_, not by modules, layers, or CRUD operations.

The recurring failure is horizontal thinking: an "auth" story, a "database" story, a "notifications" epic, an `As the system, I want…` task. These are components and constraints, not stories. They deliver nothing a user can observe until every layer is done.

**Core test — every story must answer both:**

1. **Who observes the value, and what can they now do?** (If the only beneficiary is "the system", it is not a story.)
2. **How do we know it's done?** (At least one testable acceptance criterion.)

## The Story Contract

Each story you write IS, in order:

1. **A title** — short, capability-named (`Book an available room`, not `Booking API`).
2. **A value statement** in one of the conventions below — names a real human role and the value, never "the system".
3. **Acceptance criteria** — testable done-conditions. Prefer Given/When/Then for behaviour.
4. **A size that fits** — deliverable in a few days. If it spans a whole journey, it is an epic; split it (see Splitting).

Anything that fails the contract is one of: an **epic** (split it), an **acceptance criterion** of another story (fold it in), a **constraint/NFR** (attach it, see below), or a **task** (it goes under a story, not in the backlog as a story).

## Vertical, Not Horizontal

```
HORIZONTAL (wrong)              VERTICAL (right)
─ UI layer        ┐             ─ Book a room end-to-end ─┐ thin slice
─ API layer       ┤ no value    ─ See room availability ──┤ each ships,
─ DB layer        ┤ until all   ─ Cancel my booking ──────┘ each observable
─ notifications   ┘ done
```

**Walking skeleton first.** The first story is the thinnest path that exercises the whole stack end-to-end and delivers something observable. For a booking tool: _"As an employee I can book one named room for a time slot and see it appears as booked"_ — no SSO (stub login), no notifications, no admin, no equipment filters. Everything else is a later, independent slice layered on top.

Decompose by walking the **user journey**: discover → act → confirm → manage. Each step that produces observable value is a candidate slice. Cross-cutting concerns (auth, audit, timezones, performance, double-booking) are **not** journey steps — see below.

## Splitting Patterns (keep stories small) — SPIDR

When a story is too big, split along one of these axes. Each split must still leave every piece independently valuable.

| Axis           | Split a big story by…                                                     | Example                                                   |
| -------------- | ------------------------------------------------------------------------- | --------------------------------------------------------- |
| **S**pike      | Carve off the unknown into a timeboxed investigation                      | "Spike: which notification channel (email/ICS/Slack)?"    |
| **P**aths      | Different routes through the workflow; happy path first, edge paths later | "Book a free room" → later "Handle booking conflict"      |
| **I**nterfaces | One interface/client at a time                                            | "Book via web" before "Book via Slack command"            |
| **D**ata       | A subset of data/variations                                               | "Book rooms in my office" before "across all 5 offices"   |
| **R**ules      | One business rule at a time; simplest first                               | "Book any duration" → later "Enforce business-hours-only" |

Anti-pattern split: by technical layer ("frontend story" / "backend story") or by CRUD verb dumped together ("Create/edit/delete rooms"). Split CRUD by _value_: an admin needs _create_ to enable bookings (high value) long before _bulk-edit_ (low value) — they are different stories with different priority.

## Where Constraints and Non-Functionals Go

Do **not** write `As the system, I want…`. Technical needs attach to the value stories they constrain:

- **Double-booking prevention** → an acceptance criterion of _Book a room_ ("Given a slot already booked, when I book it, then I'm rejected with a conflict message; concurrent requests yield exactly one winner").
- **Authorization** → an AC on each protected story ("only the organiser or an office admin can cancel"), plus one explicit NFR line.
- **Timezones, audit, latency** → an NFR list refined separately, and AC on the affected stories.

If a constraint genuinely needs standalone delivery (e.g. an SSO integration), frame it by the human it unblocks and the value: _"As an employee I sign in with my company account so I don't manage a separate password"_ — not as a system task.

## Convention Examples (pick per project; be consistent within a backlog)

Same slice, five conventions:

**Connextra (role-goal-benefit)** — the default for feature value:

> As an employee, I want to book an available room for a time slot, so that I have a guaranteed space.

**Job Story (situation-motivation-outcome)** — when the persona is fuzzy but the trigger is clear:

> When I need a room for an imminent meeting, I want to grab the first free one near me, so I can start on time.

**Gherkin / Given-When-Then** — best as the _acceptance criteria_ under any story:

> Given Room A is free 10:00–11:00, When I book Room A 10:00–11:00, Then the booking is confirmed and Room A shows busy for that slot.

**Hypothesis-driven** — for experiments where value is unproven:

> We believe showing nearest-free-room suggestions will reduce booking time. We'll know we're right if median time-to-book drops below 30s.

**Free-form / one-liner** — for tiny, obvious slices on a mature backlog:

> Cancel my own booking and free the slot immediately.

Acceptance criteria are mandatory regardless of convention; the convention only shapes the value statement.

## Worked Example — Room Booking, Decomposed Right

Contrast with a horizontal backlog (auth-epic / booking-epic / notifications-epic). Vertical slicing instead:

1. **Walking skeleton** — Book one named room for a slot and see it as booked. _(stub auth, single office, no notifications)_
   - AC: booking persists; room shows busy; slot can't be re-grabbed (conflict rejected atomically — folds in double-booking).
2. **See availability** — View free/busy rooms for a date so I can choose. _(adds discovery to the journey)_
3. **Cancel my booking** — Free the slot for others. _(P: management path)_
4. **Sign in with SSO** — Replace stubbed login with real identity. _(now valuable; real users)_
5. **Filter by capacity/equipment** — narrows discovery. _(D: data subset of "see availability")_
6. **Invite attendees** — informational invite. _(new value; notification channel is a Spike split off first)_
7. **Confirmation + reminder notifications** — per channel decided by the spike. _(P + I splits)_
8. **Admin: add a room** → later **edit**, later **retire** — three stories by value, not one CRUD lump.
9. **Across all 5 offices + timezone display** — _(D + R: was deferred from the single-office skeleton)_

Notice double-booking, auth-enforcement, atomicity, and timezones never become `As the system` stories — they are AC on the slices that need them, or one NFR list.

## Common Mistakes

| Mistake                                               | Fix                                                                                            |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `As the system, I want…`                              | Re-attach to the human who benefits, or fold into AC/NFR. The system is never a story's actor. |
| Epic-per-module ("auth", "notifications", "admin")    | Slice by journey across modules; first slice is end-to-end and observable.                     |
| CRUD lumped ("create/edit/delete X")                  | Split by value; ship create first, defer low-value edits/deletes.                              |
| Story spans a whole journey                           | It's an epic. Split with SPIDR.                                                                |
| No acceptance criteria, or only happy path            | Add testable Given/When/Then incl. at least one failure/edge path.                             |
| Building all infrastructure before any value          | Walking skeleton first: thinnest end-to-end slice, stub the rest.                              |
| NFRs (timezone, latency, audit) as standalone stories | List as NFRs + attach as AC to affected stories.                                               |

## Quick Reference

- Slice **vertical** (journey), never **horizontal** (layer).
- First story = **walking skeleton**: thinnest observable end-to-end path; stub everything else.
- Two-question test: **who sees value?** + **how is "done" tested?**
- Too big? Split by **S**pike / **P**aths / **I**nterfaces / **D**ata / **R**ules.
- Constraints (double-booking, auth, timezone) → **AC or NFR**, not `As the system` stories.
- Every story has **testable AC** regardless of convention.
