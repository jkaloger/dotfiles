---
name: design-review
description: Use when comparing a running web UI against its intended design (Figma mockups or reference screenshots), reviewing visual/layout/spacing/typography fidelity of a page, component, or interaction, or when a design-vs-build diff is needed before shipping or to feed a fix loop.
---

# Design Review

## Overview

Compare a locally-running web UI against its intended design and produce a steppable HTML report plus structured findings. This is the **light** path: agent + human eyeball comparison from paired screenshots, findings recorded in lazyspec Audit form so a build loop can act on them. (A future heavy path adds pixel/token diffing and iterate-until-threshold; not covered here.)

Captured shots live under `<repo>/review/`. Two shipped tools do the mechanical work: `capture.mjs` (sandboxed browser capture) and `report.html` (step-through viewer). Do not reinvent them.

## When to use

- Reviewing whether a built page/component matches a Figma design.
- Producing a design-vs-build artifact a human can step through and annotate.
- Generating fix findings that feed an implementation loop.

Not for: pure accessibility audits, functional/E2E testing, or design work with no reference to compare against.

## Workflow

1. **Build the manifest.** Copy `manifest.example.json` to `<repo>/review/manifest.json`. One `set` per thing reviewed, tagged `level: page | component | interaction`. Component sets use `clip` (a selector); interaction sets use `steps` (hover/fill/click/press/waitFor). Optional per-set fields: `fullPage` (override the default, which is on for page shots and off once `steps` run), `mask` (selectors for nondeterministic regions like dates/avatars, excluded from the shot so re-runs don't churn). `baseUrl` must be loopback.

2. **Capture the intended design (Figma MCP).** For each set, `mcp__claude_ai_Figma__get_screenshot` on the node, save PNG under `review/shots/figma/`, and set the set's `intended` path. Prefer 2x scale to match app `deviceScaleFactor`. If the user supplies exported PNGs instead of a Figma URL, drop them in the same folder and point `intended` at them.

3. **Capture the running app (sandboxed).** `node capture.mjs review/manifest.json`. Requires Playwright (`npm i -D playwright && npx playwright install chromium` — see installing-dependencies if it fails). The script writes `actual` paths back into the manifest and refuses non-loopback targets. It **blocks every request whose origin is not on the allowlist** — the printed "blocked N off-allowlist request(s)" line is expected for pages with external assets, not an error. Pass `--tag=<run>` to write shots under a per-run subdir so a re-run keeps the prior capture for before/after.

4. **Compare and record findings.** For each set, view actual vs intended and record concrete deltas into the set's `findings[]`: `{severity, kind, message, expected, actual}`. `severity` is `critical | high | medium | low | info` (matches the audit template). `kind` is one of spacing/color/typography/layout/presence. Be specific (`expected: "24px", actual: "16px"`), not "looks off". The comparison of record is side-by-side plus these findings; the viewer's overlay/diff toggle is a `mix-blend-mode` visual aid (not a pixel diff) and is only meaningful when the two shots share dimensions.

5. **Generate the viewer.** Inline the manifest into a self-contained report:
   ```
   node -e 'const fs=require("fs");const m=fs.readFileSync("review/manifest.json","utf8");const t=fs.readFileSync(".claude/skills/design-review/report.html","utf8");fs.writeFileSync("review/report.html",t.replace("/*__REVIEW_DATA__*/",m))'
   ```
   Open `review/report.html` (arrow keys step; side/overlay/diff toggle). The human annotates per set and clicks **Export all feedback** for a markdown block in audit-finding form.

6. **Write the audit + feed the loop.** Merge agent `findings[]` and the human's exported feedback into a design-review audit using **lazyspec:create-audit** (it handles where the file goes per project config). Each finding maps to a fix; after fixing, re-run steps 3–5 to confirm the delta closed.

## Sandbox

`capture.mjs` is the enforcement point, not prose. It aborts off-allowlist requests and refuses non-loopback `baseUrl` unless `--allow-remote` is passed with the host in `allowOrigins`. If you must review a staging URL, add it to `allowOrigins` and pass the flag — never disable the interception.

## Common mistakes

- Eyeballing without paired screenshots → non-reproducible, no artifact. Always capture both sides.
- Vague findings ("spacing is off"). Give expected vs actual values.
- Bare `sleep` in steps. Use `waitFor` selectors; the script already waits on `networkidle` + `document.fonts.ready`.
- Mismatched scale (Figma 1x vs app 2x) → false diffs. Match `scale` to the Figma export.
- Writing findings somewhere ad-hoc. Use lazyspec:create-audit so the loop and the human triage read the same file.
