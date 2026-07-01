---
name: pr
description: Use when opening a pull request with gh, writing a PR title/body, or pushing finished work for review
---

# Creating Pull Requests

## Overview

The reviewer reads the diff for _what_ changed. The body exists for what the diff cannot show: _why_ the change was made and _what is now possible_ because of it. A body that re-narrates the diff file-by-file wastes the one channel the diff doesn't already cover.

A PR body is a contract derived from two sources: the **spec/issue chain** (why) and the **diff** (what you can now claim). It is not a summary of your session, not a restatement of the prompt, not a tour of the files touched, and not a description of how the subsystem works in general.

**Read the diff before writing a single claim about it.** Then write about the reasons and consequences, not the lines.

## Procedure

1. **Land the work on a branch off updated main.** Never open a PR from commits sitting on `main`/`master`.
2. **Read the actual diff.** `git diff origin/main...HEAD --stat` then read the substantive hunks.
3. **Resolve the spec chain.** In a lazyspec repo: `lazyspec context <ID> --json` (or `lazyspec status` to find the ID) to get the linked iteration/story/RFC and any GitHub issue refs. Use the real links, not numbers from the prompt.
4. **Detect the template.** Check `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, and `.github/PULL_REQUEST_TEMPLATE/`. If one exists, fill ITS sections. Do not invent your own.
5. **Write title + body** (see contracts below). Write the body to a file, submit with `--body-file`.
6. **Create:** `gh pr create --base main --head <branch> --title "<title>" --body-file "$TMPDIR/pr-body.md"`

## Git hygiene (discipline — no exceptions)

- **On `main`/`master`? STOP.** Branch first: `git switch -c <type>/<slug>`, then commit there. Never push WIP commits to the default branch.
- **Rebase onto updated base** before opening: `git fetch origin && git rebase origin/main`. A PR diffed against a stale base shows phantom changes.
- **Stage only files belonging to this change.** Run `git status` and confirm. A stray `nvim.log`, debug print, or unrelated config under a feature label is a defect, not a convenience.
- **Push with upstream:** `git push -u origin <branch>`.

## Title contract

`<type>: <imperative summary>` — Conventional Commits prefix (`feat`, `fix`, `chore`, `refactor`, `docs`, `test`). One line, ≤ 72 chars, lowercase after the colon, no trailing period. Describes the change, not the files touched.

## Body contract

If the repo has a template, fill its sections with the content below mapped in. Otherwise produce exactly these parts, in order. Keep the whole body short — a reviewer should read it in under thirty seconds.

1. **Why** — 1-3 sentences: the problem, limitation, or trigger that motivated the change. The bug and its symptom, the capability that was missing, the dependency that was stale. This is the grounding a reviewer cannot reconstruct from the diff.
2. **What this enables** — 1-3 sentences: the behaviour or capability that exists now and did not before. Phrase it as an outcome for a user or the system ("permission checks no longer hit the DB on repeat lookups"), not as a mechanism walkthrough ("added a Map keyed by userId").
3. **Related** — the resolved spec + issue links. `Closes #N` only if this PR fully resolves the issue; `Refs #N` if it is partial or the issue is an epic. Reference the lazyspec doc (`Implements ITERATION-014`).
4. End with the trailer:
   ```
   🤖 PR Description generated using an LLM: <model name> / <agent harness>
   ```

**Notes** is optional and goes before Related. Include it only when the diff contains a decision a reviewer cannot infer from the code itself: a deliberate tradeoff, a known limitation, something left out of scope. It is for judgement calls, never a per-file inventory of the change.

The diff is the list of files and lines. The body never restates it. Every claim in Why and What this enables must trace to a hunk in the diff — if you cannot point to the line, delete the claim.

## Quick reference

| Step                | Command                                                                     |
| ------------------- | --------------------------------------------------------------------------- |
| Confirm not on main | `git branch --show-current`                                                 |
| Update base         | `git fetch origin && git rebase origin/main`                                |
| Read diff           | `git diff origin/main...HEAD --stat` then read hunks                        |
| Spec chain          | `lazyspec context <ID> --json`                                              |
| Find template       | `ls .github/PULL_REQUEST_TEMPLATE* .github/pull_request_template*`          |
| Create PR           | `gh pr create --base main --head <branch> --body-file "$TMPDIR/pr-body.md"` |

## Common mistakes

| Mistake                                                                           | Fix                                                                 |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| Body describes the algorithm from memory ("token-bucket, 429...")                 | Read the diff; describe why it changed and what it enables          |
| Per-file walkthrough restating the diff ("`cache.ts`: new class with get/set...") | Delete it. The diff is the file list; write Why + What this enables |
| Invented section structure                                                        | Fill the repo's `.github` template if present                       |
| Took issue number from the prompt                                                 | Resolve via `lazyspec context`; verify the issue exists             |
| `Closes #N` on a partial fix                                                      | Use `Refs #N`; reserve `Closes` for full resolution                 |
| Committed on `main`                                                               | Branch off updated `origin/main`, move commits there                |
| Staged unrelated files                                                            | `git status`; stage only this change's files                        |
| Wrote a passing-tests checkmark without running                                   | Run them, or state what you didn't run                              |

## Red flags — STOP

- About to write a claim about the diff you haven't read
- Writing a section that lists files or restates what each hunk does — the diff already shows that; say why and what it enables instead
- On `main`/`master` and about to commit or push
- Typing an issue number that came from the prompt, not from `lazyspec`/`gh`
- Writing your own PR sections without checking for `.github` template
- A `[x] tests pass` you didn't actually run
