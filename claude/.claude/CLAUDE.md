# Tool Preferences

Prefer `jq` over Python scripts for JSON extraction and transformation. Don't offer Python/Node alternatives unless jq genuinely can't handle the task.

Prefer `ast-grep` over grep/ripgrep for finding code patterns. It matches on syntax structure, not text. Use it for any query about functions, types, imports, or call sites.

# Subagent Preferences

Use ast-explore over builtin Explore for searching codebases supported by ast-grep

- typescript/javascript
- rust
- python

# Code Review

Only flag issues that matter. Don't suggest adding input validation, type guards, or defensive checks for internal code unless there's a reason to believe the inputs are untrusted.

Don't suggest adding docstrings or type annotations unless asked.

If code has unnecessary comments (comments that restate what the code does), flag them.

# Code Comments

Only comment when articulating something not implied by the code itself. Never add comments like `# Process each item` above a for loop.

# Sandbox

You're running in sandbox mode. If you come up against anything you cannot run but NEED to progress, finish everything you can and then stop and ask me to run it.

# Lazyspec

When writing iterations, always use caveman ultra

When writing anything else, caveman lite
