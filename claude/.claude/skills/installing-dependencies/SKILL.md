---
name: installing-dependencies
description: Use when adding, installing, upgrading, or pinning a package/library in any language, choosing which version to use, or when install commands fail with externally-managed-environment, SSL/certificate, DNS (gaierror), or connection errors inside a sandbox.
---

# Installing Dependencies

## Overview

Your training data has a cutoff; package registries have moved past it. The version in your head is stale. Two rules follow: let the package manager resolve versions from the live registry (never hand-write them), and recognize when a sandbox has no network egress so you escalate instead of debugging a phantom bug.

## Getting the latest version

**Run the package manager's add command.** It resolves the latest stable from the live registry and writes both the manifest and the lockfile. Do NOT type a version string into the manifest from memory.

| Ecosystem         | Add latest stable                                         |
| ----------------- | --------------------------------------------------------- |
| npm / pnpm / yarn | `npm install <pkg>` · `pnpm add <pkg>` · `yarn add <pkg>` |
| python            | `uv add <pkg>` · or `pip install <pkg>` (into a venv)     |
| rust              | `cargo add <pkg>`                                         |
| go                | `go get <pkg>@latest`                                     |

**To pin or compare versions, query the registry — don't guess:**

- `npm view <pkg> version` · `npm view <pkg> versions --json`
- `pip index versions <pkg>` · `uv pip index <pkg>`
- `cargo search <pkg>` · `go list -m -versions <pkg>`

**Verify what landed.** After install, read the manifest/lockfile. The installed version is the source of truth, not your recollection.

## Sandbox / network failures

Installs and version queries require network egress. A no-egress sandbox fails them. These error signatures all mean **no network**, not a real bug — stop diagnosing, don't retry:

- SSL cert errors: `CERTIFICATE_VERIFY_FAILED`, `OSStatus -26276`
- DNS: `gaierror`, `nodename nor servname provided`
- `Connection refused` / timeout, or `Permission ... denied` on `curl`

On a network block, escalate immediately: give the user the exact command(s) to run. They can run it inline with the `! <command>` prompt prefix so output lands in the session.

**`externally-managed-environment` is different** — that's PEP 668, a policy block, not a network block. Fix with a venv (`python3 -m venv`). Never `pip install --break-system-packages`.

**Don't pollute the repo.** Create venvs / scratch installs under `$TMPDIR`, not the project root, unless the project owns that environment.

## Common mistakes

| Mistake                                                   | Do instead                                        |
| --------------------------------------------------------- | ------------------------------------------------- |
| Writing `"pkg": "^3.x.x"` into manifest from memory       | Run the add command; registry resolves latest     |
| Retrying a failing install 5× against SSL/DNS errors      | Recognize no-egress → escalate with exact command |
| `pip install --break-system-packages`                     | Use a venv                                        |
| `.venv` / `node_modules` in project root for scratch work | Put scratch envs in `$TMPDIR`                     |
| Trusting the version in your head                         | Read the lockfile after install                   |
