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

<PRIORITYRULE>
Only comment when articulating something not implied by the code itself. Never add comments like `# Process each item` above a for loop.
</PRIORITYRULE>

# Sandbox

You're running in sandbox mode. If you come up against anything you cannot run but NEED to progress, finish everything you can and then stop and ask me to run it.

# Lazyspec

Always use lazyspec to write documentation,plans,etc. Development is always spec driven.

Always run `lazyspec help` before writing specs, plans, etc. using lazyspec.

When writing iterations, always use caveman ultra

When writing anything else, caveman lite

No work without a plan. Don't just jump into coding without writing an appropriate plan in a lazyspec backed repo.

# Context Discipline

Batch repeated CLI invocations. If the same command runs more than ~3 times with different args, write one bash loop or heredoc-driven script instead of one call per item. Never spend one turn per item on `lazyspec link`, `lazyspec create`, `gh issue`, or similar.

Delegate bulk generation and mechanical wiring to subagents. Doc drafting, link graphs, repetitive edits belong in a sidechain, not main context.

Fire independent tool calls in the same block. Serial round-trips on independent reads are waste.

Don't hold large MCP payloads in context. Dump `clickup_get_task`, `get_workspace_hierarchy`, `get_custom_fields` and friends to a scratchpad file, then reference the path.

Tell me to `/clear` when context passes ~100k and the next chunk of work doesn't depend on the earlier turns.

# Team, Org etc

see ~/workspace/engineering-management/context/team-structure.md
see ~/workspace/engineering-management/context/technology-landscape.md

# Self Improvement

You're an improving LLM agent. Always observe whether I am correcting you, and recommend new agent skills based on repeated instances of unwanted behaviours.
