---
name: diagramming
description: Use when creating any diagram — system architecture, structure, data flow, or sequence/behaviour — whether explicitly asked or while writing a design doc, spec, or plan that describes system structure.
---

# Diagramming

## Overview

Every diagram is d2, embedded as a ```d2 fenced block in the markdown doc it belongs to. Never mermaid, never graphviz, never ASCII art — including READMEs and PR bodies where GitHub won't render d2. Source is the artifact; rendered output is preview-only.

## Choosing the diagram

- **Structure** (what exists, what talks to what) → C4.
  - Default to Context (L1) or Container (L2).
  - Component (L3) only when explicitly asked. Never Code (L4).
- **Behaviour over time** (one flow or scenario, ordering matters) → sequence diagram (`shape: sequence_diagram`).

## C4 in d2

d2 has no native C4. Conventions:

- Actors: `{shape: person}`
- System/container boundaries: nesting
- External systems: `{style.stroke-dash: 3}`
- Databases: `{shape: cylinder}`
- Labels: name + short tech tag (`"API\nGo"`). No sentences, no prose descriptions.

```d2
direction: right

customer: Customer {shape: person}

shop: Shop System {
  spa: "Web App\nReact"
  api: "API\nGo"
  db: "Orders DB\nPostgres" {shape: cylinder}

  spa -> api: JSON/HTTPS
  api -> db: SQL
}

stripe: Stripe {style.stroke-dash: 3}

customer -> shop.spa
shop.api -> stripe: payments
```

Sequence:

```d2
shape: sequence_diagram
browser: Browser
api: API
db: Postgres

browser -> api: POST /login
api -> db: get user
db -> api: user + hash
api -> browser: 200 + JWT
```

## Allowed d2 features

Shapes, nesting, connections, labels, `direction:`, `shape: person | cylinder | sequence_diagram | sql_table`, `style.stroke-dash` for externals.

**Banned:** `classes:`, style blocks, colors/fills, icons/images, `near:`, grid layouts, animations, markdown in labels, tooltips, links. Theme 300 owns all color and typography.

## Preview workflow

Render to the session scratchpad only — rendered files are never committed.

```sh
d2 --layout elk --theme 300 "$SCRATCH/x.d2" "$SCRATCH/x.svg"
rsvg-convert -o "$SCRATCH/x.png" "$SCRATCH/x.svg"
```

d2's native PNG export (`d2 x.d2 x.png`) launches headless Chrome and hangs in the sandbox — always render SVG, then convert with rsvg-convert. Read the PNG to verify layout before finalizing the diagram.

## Common mistakes

| Mistake | Fix |
|---|---|
| mermaid/graphviz block | d2 fenced block |
| `d2 in.d2 out.png` directly | SVG first, then rsvg-convert |
| default layout/theme | `--layout elk --theme 300` |
| prose sentences in labels | name + tech tag only |
| per-node colors, style tweaks | delete — theme 300 owns styling |
| committing SVG/PNG output | scratchpad only; source lives in markdown |
| separate `.d2` files by default | embed in the relevant markdown doc |
