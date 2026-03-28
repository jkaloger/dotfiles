---
name: ast-grep-search
description: Use when searching for structural code patterns - function signatures, struct/class definitions, trait implementations, specific argument patterns, or any query where text grep would require complex regex or produce false positives. Prefer over Grep when the search target has syntactic structure.
---

# AST-Aware Code Search with ast-grep

## Overview

Use `ast-grep` instead of text-based grep when searching for **structural code patterns**. ast-grep understands syntax trees, so it matches code by structure rather than text — eliminating false positives from comments, strings, and similarly-named-but-different constructs.

## When to Use

**Use ast-grep when:**
- Finding struct/class/interface definitions with specific fields or shapes
- Finding function signatures matching a pattern (return type, parameter shape)
- Finding trait/interface implementations
- Finding specific call patterns (e.g., all `.unwrap()` calls, all `println!` with format args)
- Any search where grep would need complex regex or return too many false positives

**Use Grep when:**
- Searching for string literals, comments, or config values
- Simple keyword/identifier lookup
- Searching non-code files (markdown, TOML, YAML)

## Pattern Syntax Quick Reference

| Pattern Element | Meaning | Example |
|----------------|---------|---------|
| `$NAME` | Single AST node (captures as metavariable) | `fn $NAME()` |
| `$$$` | Zero or more AST nodes (ellipsis) | `fn $F($$$)` matches any params |
| Literal code | Exact structural match | `Vec<String>` |

## Common Patterns by Language

### Rust

```bash
# Find structs with a specific field type
ast-grep run -p 'struct $NAME { $$$ $FIELD: Vec<$TYPE>, $$$ }' -l rust

# Find trait implementations
ast-grep run -p 'impl $TRAIT for $TYPE { $$$ }' -l rust

# Find functions returning Result
ast-grep run -p 'fn $NAME($$$) -> Result<$$$>' -l rust

# Find .unwrap() calls
ast-grep run -p '$EXPR.unwrap()' -l rust

# Find specific macro invocations
ast-grep run -p 'println!($$$)' -l rust
```

### TypeScript / JavaScript

```bash
# Find exported function declarations
ast-grep run -p 'export function $NAME($$$) { $$$ }' -l typescript

# Find React components with specific props
ast-grep run -p '<$COMPONENT $$$props={$$$} $$$>' -l tsx

# Find async functions
ast-grep run -p 'async function $NAME($$$) { $$$ }' -l typescript

# Find specific method calls
ast-grep run -p '$OBJ.addEventListener($$$)' -l typescript
```

### Python

```bash
# Find class definitions with inheritance
ast-grep run -p 'class $NAME($PARENT): $$$' -l python

# Find decorated functions
ast-grep run -p '@$DECORATOR
def $NAME($$$): $$$' -l python
```

## Output Modes

```bash
# Default: colored terminal output with context
ast-grep run -p 'PATTERN' -l LANG

# JSON output (best for programmatic use)
ast-grep run -p 'PATTERN' -l LANG --json=compact

# Files only (like grep -l)
ast-grep run -p 'PATTERN' -l LANG --files-with-matches

# With context lines
ast-grep run -p 'PATTERN' -l LANG -C 3
```

**Always use `--json=compact`** when you need to process results programmatically. The JSON includes file paths, line numbers, matched text, and captured metavariables. **Pipe to `jq`** for filtering and formatting.

## JSON + jq Patterns

```bash
# Count matches
ast-grep run -p 'PATTERN' -l rust --json=compact | jq 'length'

# Extract file:line and captured name
ast-grep run -p 'struct $NAME { $$$ }' -l rust --json=compact | \
  jq -r '.[] | "\(.file):\(.range.start.line) \(.metaVariables.single.NAME.text)"'

# Broad AST match + jq text filter (best for exhaustive searches)
ast-grep run -p 'struct $NAME { $$$ }' -l rust --json=compact | \
  jq -r '[.[] | select(.text | test("Vec<"))] | .[] | "\(.file):\(.range.start.line) \(.metaVariables.single.NAME.text)"'
```

The "broad match + jq filter" pattern is the most reliable approach for exhaustive searches. ast-grep matches structurally, then jq narrows by text content.

## Visibility Modifiers Split the AST (Critical)

**`struct Foo` and `pub struct Foo` are DIFFERENT AST trees.** A pattern matching one will NOT match the other. This is the #1 source of missed results.

**For exhaustive searches, ALWAYS run both and combine:**

```bash
# Combine non-pub and pub results with jq -s 'add'
(ast-grep run -p 'struct $NAME { $$$ }' -l rust --json=compact; \
 ast-grep run -p 'pub struct $NAME { $$$ }' -l rust --json=compact) | \
  jq -s 'add | [.[] | select(.text | test("Vec<"))] | .[] | "\(.file):\(.range.start.line) \(.metaVariables.single.NAME.text)"'
```

This applies to all visibility-modified items: `fn`/`pub fn`, `impl`/`pub impl`, `enum`/`pub enum`, `type`/`pub type`, etc. In TypeScript: `function`/`export function`, `class`/`export class`.

## Common Mistakes

- **Forgetting `-l`/`--lang`**: ast-grep infers language from file extension, but being explicit avoids surprises
- **Using `$VAR` for multiple nodes**: `$VAR` matches exactly one node; use `$$$` for zero-or-more
- **Over-specifying patterns**: `fn $NAME($$$)` is often better than trying to match exact parameter types — start broad, narrow if needed
- **Assuming one pattern catches all visibilities**: It does NOT. `struct $NAME` misses `pub struct $NAME`. Always run both patterns and combine results (see above)
- **Not using `--json` + `jq`**: Terminal output is for eyeballing. For analysis, always use `--json=compact | jq`
