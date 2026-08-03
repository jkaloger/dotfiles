---
name: writing-reference-docs
description: Use when writing or editing a README, man page, `--help` text, API reference, or other user-facing documentation prose, including when asked to strip marketing tone, hype, or "AI slop" from existing docs.
---

# Writing Reference Docs

## Overview

Reference documentation is written in man-page register: the program or the artifact is the grammatical subject, and every sentence states behaviour. The reader is not addressed and the design is not justified.

Rationale belongs in the spec or design doc, and is linked from the reference — never mixed into it.

## The register

1. **Subject is the program or the thing described.** "Hydra refuses any write that would violate an invariant." "The store is created within the repository."
2. **State behaviour, then stop.** Drop purpose clauses: "so diffs stay small", "so the interview survives the process", "by intent".
3. **Never address the reader.** No "you", no advice. Turn advice into consequence: "Use it for typos, not decisions" → "`--keep-subtree` suppresses the cascade. Descendants are left unchanged."
4. **Enumerate cases as conditionals.** One case per sentence: "If no operands are given, the contents of the current directory are displayed." Semicolons and em-dash asides collapse cases that should be separate sentences.
5. **Define a term once in bold, then use it flat.** No synonyms for variety, no loaded verbs where a plain one exists.
6. **Present tense indicative, complete sentences.** Passive is correct when the object is what the sentence is about.

## Rewrites

| Source | Rewrite |
|---|---|
| "Hydra holds no opinion about what to ask" | "Hydra does not select which question is put next" |
| "stored on disk, so the interview survives the process conducting it" | "stored on disk. Each invocation reads the store and exits" |
| "The on-disk format is `jq`-native by intent" | "The on-disk format is JSON with sorted keys" |
| "ASCII render. The one command whose output is for eyes" | "ASCII rendering, formatted for reading rather than parsing" |
| "Kill a question a sibling's answer made moot" | "Answer a head that another head's answer has made unnecessary" |
| "Trees are mutable documents, not event logs — sorted keys, pretty-printed, atomic rename, so diffs stay minimal" | "A tree file is a mutable document rather than an event log: keys are sorted, output is pretty-printed one field per line, and each write is renamed into place" |
| "Read straight off disk instead of shelling a subcommand" | "The tree file can also be read directly" |

## Section order

Synopsis → Description → Options/commands → Exit status → Files → Examples → See also. A README keeps this order as `##` headings; install and development sections go after Examples.

Headings take the capitalization of the document they sit in: `## Description` in a markdown README, `DESCRIPTION` only in roff. Tables stand in for the indented option list, and for Files entries; their cells may be fragments. Markdown definition-list syntax (`: text`) does not render on GitHub.

An example shows an invocation. Sample output appears only where the output is known; invented records, timings and transcripts are not written.

## Slop markers to delete on sight

- Evaluative adjectives: powerful, simple, seamless, robust, blazing, elegant, lightweight
- Filler: just, simply, basically, note that, it's worth noting
- First and second person: you, your, we, let's, our
- Sales framing: "Why X?" sections, feature bullets with benefit clauses, taglines inside prose
- Emoji in prose, and rhetorical questions anywhere
- Em-dash asides mid-sentence. Use a full stop or a colon
- Bold for emphasis (bold marks a term definition only)
- A closing paragraph that restates the document

## When not to use

Design docs, specs, plans, ADRs and PR bodies exist to record reasoning; they keep their rationale. This register applies to the reference surface only.

## Common mistakes

| Mistake | Fix |
|---|---|
| Deleting hype but keeping "Use this when…" advice | Restate as what the program does |
| Justifying a design choice in the DESCRIPTION | Move to the spec, link it |
| One long sentence with three semicolons | One sentence per case |
| Table cells written as advice | Table cells state effect |
| Personifying the tool (holds, believes, wants, cares) | Plain verbs: reads, writes, refuses, reports |
| Rewriting the whole doc when only prose was asked for | Leave the synopsis, tables and code blocks alone |
