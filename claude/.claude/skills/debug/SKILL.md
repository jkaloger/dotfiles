---
name: debug
description: You MUST use this skill any time you are investigating a bug/unintended behaviour, before proposing fixes
---

# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
NO CODE CHANGES WITHOUT REPRODUCING THE FAILURE FIRST
NO EDITS AFTER DIAGNOSIS WITHOUT USER GO-AHEAD
```

If you haven't completed Phase 1, you cannot propose fixes. If you haven't reproduced the failure, you cannot change code — you have no oracle to tell a fix from a coincidence. When the evidence forces a single root cause, STOP and hand back before editing (see "The Diagnosis Gate").

## When to Use

Use for ANY technical issue:

- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Use this ESPECIALLY when:**

- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**

- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Manager wants it fixed NOW (systematic is faster than thrashing)

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Don't skip past errors or warnings
   - They often contain the exact solution
   - Read stack traces completely
   - Note line numbers, file paths, error codes

2. **Reproduce Consistently — this is your measurement instrument**
   - Can you trigger it reliably?
   - What are the exact steps?
   - Does it happen every time?
   - If not reproducible → gather more data, don't guess
   - The repro is the oracle. Without it you cannot tell a fix from a fluke, cannot bisect (bisection needs a verdict at each step), and cannot know when you're done.
   - Drive it toward **deterministic** — pin down nondeterminism (clock, randomness, concurrency, uninitialized memory, hash-map iteration order, network) with fixed seed, fixed clock, single thread, recorded fixture. An intermittent bug is a reproduction problem; solve that first.
   - Drive it toward **minimal** — strip the scenario until removing anything more makes the bug vanish. A 3-line repro localizes the cause better than an end-to-end run, and it becomes the regression test you commit with the fix.
   - **If it only reproduces in production:** the immediate goal is not the fix — it's importing enough of production's state (input, data, config, timing) into a place you control until it reproduces there.

3. **Check Recent Changes**
   - What changed that could cause this?
   - Git diff, recent commits
   - New dependencies, config changes
   - Environmental differences

4. **Gather Evidence in Multi-Component Systems**

   **WHEN system has multiple components (CI → build → signing, API → service → database):**

   **BEFORE proposing fixes, add diagnostic instrumentation:**

   ```
   For EACH component boundary:
     - Log what data enters component
     - Log what data exits component
     - Verify environment/config propagation
     - Check state at each layer

   Run once to gather evidence showing WHERE it breaks
   THEN analyze evidence to identify failing component
   THEN investigate that specific component
   ```

   **Example (multi-layer system):**

   ```bash
   # Layer 1: Workflow
   echo "=== Secrets available in workflow: ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # Layer 2: Build script
   echo "=== Env vars in build script: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 3: Signing script
   echo "=== Keychain state: ==="
   security list-keychains
   security find-identity -v

   # Layer 4: Actual signing
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

   **This reveals:** Which layer fails (secrets → workflow ✓, workflow → build ✗)

5. **Trace Data Flow**

   **WHEN error is deep in call stack:**

   See `root-cause-tracing.md` in this directory for the complete backward tracing technique.

   **Quick version:**
   - Where does bad value originate?
   - What called this with bad value?
   - Keep tracing up until you find the source
   - Fix at source, not at symptom

6. **Narrow by Bisection — turn linear search into logarithmic**

   Let `n` be the size of the space the defect could live in: commits since it last worked, lines along the failing path, elements of an input, events in a log. Checking candidates one by one is `O(n)`. Splitting the space and asking "is the bug in this half?" is `O(log n)` — for 1,000 commits, ~10 questions instead of 1,000.
   - **History** — `git bisect run <test>` finds the introducing commit automatically given a script that exits 0/non-zero. First thing to reach for on a regression with a known-good past.
   - **Code path** — probe the midpoint of the suspect path. Is the value already wrong here? Yes → defect is upstream; no → downstream. Recurse on the surviving half.
   - **Input** — halve the failing input (delta-debugging `ddmin`). Which half still triggers it? Recurse. Also how you reach a minimal repro.
   - **Config / environment** — bisect the delta between working and broken setup: dependencies, env vars, feature flags. Toggle half at a time.

   Bisection needs two things: a reliable verdict at each step (your repro) and a monotone space (a known-good and known-bad end). Establish both before splitting.

### Phase 2: Pattern Analysis

**Find the pattern before fixing:**

1. **Find Working Examples**
   - Locate similar working code in same codebase
   - What works that's similar to what's broken?

2. **Compare Against References**
   - If implementing pattern, read reference implementation COMPLETELY
   - Don't skim - read every line
   - Understand the pattern fully before applying

3. **Identify Differences**
   - What's different between working and broken?
   - List every difference, however small
   - Don't assume "that can't matter"

4. **Understand Dependencies**
   - What other components does this need?
   - What settings, config, environment?
   - What assumptions does it make?

### Phase 3: Hypothesis and Testing

**Scientific method:**

1. **Form Single Hypothesis**
   - State clearly: "I think X is the root cause because Y"
   - Write it down
   - Be specific, not vague

2. **Predict Before You Run**
   - Before running anything, write down what you'll observe **if the hypothesis is true** and **if it's false**
   - If the two predictions look the same, the experiment is worthless — design a different one
   - This converts a random edit into an experiment, and exposes worthless experiments before you waste a run
   - A good experiment roughly halves the cause-set whether it confirms or refutes

3. **Test Minimally**
   - Make the SMALLEST possible change to test hypothesis
   - One variable at a time
   - Don't fix multiple things at once
   - A probe with no prediction yields no information regardless of outcome

4. **Verify Before Continuing**
   - Did it work? Yes → the Diagnosis Gate, then Phase 4
   - Didn't work? Form NEW hypothesis
   - DON'T add more fixes on top

5. **When You Don't Know**
   - Say "I don't understand X"
   - Don't pretend to know
   - Ask for help
   - Research more

### The Diagnosis Gate (between Phase 3 and Phase 4)

**Isolating the root cause and choosing the repair are different acts. Gate the change.**

The diagnosis is forced — the evidence converges on one mechanism and you don't get a vote. The fix is not: a single defect usually admits several valid repairs (patch the source, change the contract, redesign the path that allowed the bad state, fix the instance vs. the whole class), differing in scope, risk, and blast radius. That choice belongs to the user.

When the loop reaches a diagnosis, **STOP and hand back before editing.** Report:

- **The root cause** — the first violated invariant, stated as one mechanism, with the evidence that forces it.
- **How it explains the symptom** — the causal chain from cause to the observed failure. The test of a true root cause: you can explain every symptom you saw as a consequence of it.
- **The proposed fix** — where you'd change the code and why that point, plus the obvious alternatives if more than one repair is reasonable.

Then wait for go-ahead. Two payoffs: a wrong diagnosis is caught here, on paper, before any code churn (orders of magnitude cheaper than after a fix that didn't take); and the user may hold context you don't (fix belongs elsewhere, the class matters more than the instance, this path is being rewritten anyway).

**This is a checkpoint, not a reason to stop investigating early.** The gate is the moment the evidence forces a single mechanism — not the first plausible hypothesis, not an untested hunch. Reach a real diagnosis, then pause. If the user said "diagnose and fix in one go," honor that; absent that, default to stopping.

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

1. **Create Failing Test Case**
   - Simplest possible reproduction
   - Automated test if possible
   - One-off test script if no framework
   - MUST have before fixing
   - Use the `superpowers:test-driven-development` skill for writing proper failing tests

2. **Implement Single Fix**
   - Address the root cause identified
   - ONE change at a time
   - No "while I'm here" improvements
   - No bundled refactoring

3. **Verify Fix**
   - Test passes now?
   - No other tests broken?
   - Issue actually resolved?

4. **If Fix Doesn't Work**
   - STOP
   - Count: How many fixes have you tried?
   - If < 3: Return to Phase 1, re-analyze with new information
   - **If ≥ 3: STOP and question the architecture (step 5 below)**
   - DON'T attempt Fix #4 without architectural discussion

5. **If 3+ Fixes Failed: Question Architecture**

   **Pattern indicating architectural problem:**
   - Each fix reveals new shared state/coupling/problem in different place
   - Fixes require "massive refactoring" to implement
   - Each fix creates new symptoms elsewhere

   **STOP and question fundamentals:**
   - Is this pattern fundamentally sound?
   - Are we "sticking with it through sheer inertia"?
   - Should we refactor architecture vs. continue fixing symptoms?

   **Discuss with your human partner before attempting more fixes**

   This is NOT a failed hypothesis - this is a wrong architecture.

## Red Flags - STOP and Follow Process

If you catch yourself thinking:

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**
- **Each fix reveals new problem in different place**
- **Editing code you haven't seen fail** (reproduce first — no oracle, no fix)
- **Reached a root cause and went straight to editing** (the diagnosis is a gate — report it, get go-ahead)
- **"It can't be that"** — the thing you're sure is correct is the thing you haven't checked. Check it.
- Running an experiment whose outcomes you can't tell apart (no prediction written)

**ALL of these mean: STOP. Return to Phase 1.**

**If 3+ fixes failed:** Question the architecture (see Phase 4.5)

## your human partner's Signals You're Doing It Wrong

**Watch for these redirections:**

- "Is that not happening?" - You assumed without verifying
- "Will it show us...?" - You should have added evidence gathering
- "Stop guessing" - You're proposing fixes without understanding
- "Ultra-think this" - Question fundamentals, not just symptoms
- "We're stuck?" (frustrated) - Your approach isn't working

**When you see these:** STOP. Return to Phase 1.

## Common Rationalizations

| Excuse                                        | Reality                                                                                        |
| --------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| "Issue is simple, don't need process"         | Simple issues have root causes too. Process is fast for simple bugs.                           |
| "Emergency, no time for process"              | Systematic debugging is FASTER than guess-and-check thrashing.                                 |
| "Just try this first, then investigate"       | First fix sets the pattern. Do it right from the start.                                        |
| "I'll write test after confirming fix works"  | Untested fixes don't stick. Test first proves it.                                              |
| "Multiple fixes at once saves time"           | Can't isolate what worked. Causes new bugs.                                                    |
| "Reference too long, I'll adapt the pattern"  | Partial understanding guarantees bugs. Read it completely.                                     |
| "I see the problem, let me fix it"            | Seeing symptoms ≠ understanding root cause.                                                    |
| "I'll just edit and see if the bug goes away" | No repro = no oracle. You can't tell a fix from a coincidence. Reproduce first.                |
| "Diagnosis is obvious, I'll fix it now"       | The fix is the user's call — scope/risk/blast radius differ. Report at the gate, get go-ahead. |
| "One more fix attempt" (after 2+ failures)    | 3+ failures = architectural problem. Question pattern, don't fix again.                        |

## Quick Reference

| Phase                 | Key Activities                                                                           | Success Criteria            |
| --------------------- | ---------------------------------------------------------------------------------------- | --------------------------- |
| **1. Root Cause**     | Read errors, reproduce (deterministic + minimal), check changes, gather evidence, bisect | Understand WHAT and WHY     |
| **2. Pattern**        | Find working examples, compare                                                           | Identify differences        |
| **3. Hypothesis**     | Form theory, predict outcomes, test minimally                                            | Confirmed or new hypothesis |
| **Diagnosis Gate**    | Report root cause + proposed fix, get go-ahead                                           | User approves before edits  |
| **4. Implementation** | Create test, fix, verify                                                                 | Bug resolved, tests pass    |

## When Process Reveals "No Root Cause"

If systematic investigation reveals issue is truly environmental, timing-dependent, or external:

1. You've completed the process
2. Document what you investigated
3. Implement appropriate handling (retry, timeout, error message)
4. Add monitoring/logging for future investigation

**But:** 95% of "no root cause" cases are incomplete investigation.

## Supporting Techniques

These techniques are part of systematic debugging and available in this directory:

- **`root-cause-tracing.md`** - Trace bugs backward through call stack to find original trigger
- **`defense-in-depth.md`** - Add validation at multiple layers after finding root cause
- **`condition-based-waiting.md`** - Replace arbitrary timeouts with condition polling

**Related skills:**

- **superpowers:test-driven-development** - For creating failing test case (Phase 4, Step 1)
- **superpowers:verification-before-completion** - Verify fix worked before claiming success

## Real-World Impact

From debugging sessions:

- Systematic approach: 15-30 minutes to fix
- Random fixes approach: 2-3 hours of thrashing
- First-time fix rate: 95% vs 40%
- New bugs introduced: Near zero vs common
