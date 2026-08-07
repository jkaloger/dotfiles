---
name: problematising
description: Use when a brief, plan or OKR states its problem as a judgement about people or an organisation held against a norm nobody wrote down — "engineers aren't shipping enough", "deploys are too slow", "ramp time is three months", "the team isn't aligned" — especially when that judgement is fenced from discussion. Also use mid-interview when an answer only makes sense because of an assumption nobody has stated. Not for a failure against a threshold someone can point at.
---

# Problematising

## Overview

A problem is not found, it is made. Something has to already be in place — a practice, a measure, a review cycle, an industry common sense — before a state of affairs registers as a problem at all.

Problematising asks how this came to be a problem, here, now, for these people, and what that framing forecloses. You are not hunting the real problem behind the stated one. You are showing the stated problem has a history, and that the same facts support a rival problem.

## Does it apply

One test on the problem statement: **the norm inside it — did somebody choose it, or did somebody write it down?**

| Problem statement                                 | The norm                                  | Fires |
| ------------------------------------------------- | ----------------------------------------- | ----- |
| "Engineers aren't shipping enough"                | Enough against what? Nobody set it        | yes   |
| "New hires take 3 months to be productive"        | Long against what? Nobody set it          | yes   |
| "Deploys are too slow"                            | Slow against what? Nobody set it          | yes   |
| "Handler 500s, provider gives up after 3 retries" | The provider's retry budget, written down | no    |
| "8M rows won't render inside the 30s timeout"     | A number in a config file                 | no    |

It fires on a judgement about people or an organisation, held against a norm nobody wrote down. It does not fire on a failure against a threshold someone outside the room can point at — that problem is a fact, and a fact has nothing to problematise. Most tickets are facts.

**Scope fencing is not framing fencing.** "Product has agreed the feature", "this is the build design", "the ticket lists three candidate fixes" are ordinary scoping and do not fire it. What fires it is the _judgement_ being fenced: "the why is settled", "don't relitigate", "leadership signed off on the problem".

Also fires mid-interview, when an answer's rationale rests on something nobody has stated. When it fires at all, fire it before laying the interview tree out — the framing decides what all the other questions are about.

## The five moves

Produce all five, in order, in one turn. One or two sentences each, in the user's own nouns.

1. **Name the object.** What does this framing treat as a thing that existed before anyone measured it? Quote the brief's word for it.
2. **Date it.** When did this become sayable here, and what changed just before — a round, a hire, a board deck, a practice that arrived from elsewhere? Every problem has an arrival date.
3. **Name what produces it.** What has to already be running for this to register as a problem at all? Sprint boards produce velocity. Review cycles produce comparable individuals. The practice comes first; the problem is its residue.
4. **Name who it distributes.** Whose problem is this and whose is it not? Who becomes visible, to whom, and accountable for what?
5. **Name what it forecloses.** With this framing in force, what can no longer be said in the room? Say that thing out loud.

Then **one rival problematisation**: the same facts, redescribed so a different problem is the obvious one. A different problem, not a better solution.

Close with one question — **which problem are we in?** — and stop.

## What the turn is

Exactly three parts, in order: the five moves, the rival, the question. The turn ends at the question mark.

Options, tradeoffs and a recommendation belong to the **next** turn, on whichever problem the user picks. A turn carrying both the five moves and an option list has already absorbed the problematisation into the frame it was meant to interrogate: the rival becomes option B, collects a tradeoff paragraph and a rank, and the interview proceeds exactly as it would have. When the surrounding process asks for options and a recommendation, this is the turn that defers them — say so in one line and defer them.

The user picks which problem. If they pick the original, the interview proceeds with its framing now explicit — a complete and successful outcome, not a failure to persuade.

## The rival is not a hypothesis

Both problematisations are true of the facts. They are not rival claims about the world, so no measurement decides between them — "let's spend two weeks finding out which problem it really is" is the original framing reasserting itself under cover of rigour. The user is choosing which problem to be in. That is a decision, not a finding.

Diagnostic work is often worth doing. It belongs after the choice, inside whichever problem got picked.

## Signs it got absorbed

- The rival appears as "Option B"
- The turn ends on a recommendation rather than a question
- The rival has turned into "let's measure which one it is"
- The five moves appear under a heading like "concerns", as preamble to the plan you were always going to give
- It arrived as branch 7 of 12

## Vocabulary

Use the user's nouns. Never "genealogy", "discourse", "power/knowledge", "regime of truth", "episteme", "problematisation", "Foucault". If a line could not be said out loud at sprint planning, rewrite it.

## Not to be confused with

| Neighbour         | It asks                     | Problematising asks                                             |
| ----------------- | --------------------------- | --------------------------------------------------------------- |
| Evidence critique | Is n=2 enough?              | What makes a 30-day survey count as evidence at all?            |
| Goodhart's law    | Will the metric be gamed?   | What does the metric bring into being that wasn't there before? |
| Root cause        | What's the real cause?      | What had to be in place for that to count as a cause?           |
| Five whys         | Why — going down            | Where from — going backwards and sideways                       |
| Ethics            | Is this right?              | How did this become the kind of thing judged right or wrong?    |
| Devil's advocate  | What's wrong with the plan? | What is the problem statement made of?                          |

Every neighbour accepts the problem and disputes the answer. Problematising disputes the problem. A metric that is accurate, ungamed, and well-evidenced is still worth problematising, because it still constitutes what it counts.

## In an interview

Fire before laying the tree out, not after. The result becomes the root: either the intent gets rewritten, or one root head — "which problem are we in?" — that everything else is `blocked_by`.

Mid-interview, the result is a reopened parent, not a new leaf. A problematisation that arrives as branch 7 of 12 has already been absorbed by the frame it was meant to interrogate.

## Cost

One turn, made entirely of facts the user already gave you. Against "don't get philosophical": this is the cheapest turn in the interview, because it decides what the other twenty questions are about.
