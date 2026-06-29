---
name: verify-cli
description: "Use when writing or editing a SKILL.md, agent system_prompt, command template, or docs that reference CLI commands (uv, poetry, ruff, git, docker, etc.). Enforces verifying every command example and flag against actual --help or man output on the target machine before writing it. Also use when a skill starts producing wrong commands."
---

# Verify CLI commands before documenting them

## Why

CLI tools evolve. Subcommands and flags change between versions, and training-time
memory of a tool's interface is frequently stale or invented. Documenting a command
from memory that does not exist, has been renamed, or belongs to a different tool
is worse than documenting nothing — it teaches the agent to run broken commands.

Real examples caught during verification of this very config:

- `uv add --dev` and `poetry add --group dev` are the correct project-aware
  commands; `pip install` / `uv pip install` do NOT update `pyproject.toml`.
- `poetry add --dev` was assumed removed in Poetry 2.x — `poetry add --help`
  proved it is still supported as a `-G dev` shortcut. The assumption was wrong.
- `uv check` runs Astral's `ty` type checker; `poetry check` validates
  `pyproject.toml`. Same name, unrelated behavior.

## Core rule

Before writing any CLI command (with flags) into a SKILL.md, agent prompt,
command template, or project documentation, verify it against the tool's own help
output. Do not cite a flag or subcommand you have not seen in `--help` / `man`
during this session.

## How to verify

1. Run the help for the exact command and subcommand on the target machine:
   - `uv <cmd> --help` (e.g. `uv add --help`, `uv pip --help`)
   - `poetry <cmd> --help`
   - `git <cmd> --help` or `man git-<cmd>`
   - `<tool> --help` / `man <tool>`
2. Confirm against the output:
   - the subcommand exists (listed under "Commands:" or in the "Usage:" line)
   - every flag you cite is listed and spelled exactly
   - argument syntax matches the "Usage:" line
3. If the command or flag is absent, do NOT invent it. Find the real equivalent in
   the help output, or omit the example and describe the intent in prose.
4. Record provenance inline, e.g. a one-line note under a command table:
   `(verified against uv add --help, uv 0.11.25)`. This tells future editors the
   source and the version at verification time.

## Discovery commands

| Tool   | List all commands      | Inspect one command        |
|--------|------------------------|----------------------------|
| uv     | `uv --help`            | `uv <cmd> --help`          |
| poetry | `poetry list`          | `poetry <cmd> --help`      |
| git    | `git --help -a`        | `git <cmd> --help` / `man git-<cmd>` |
| ruff   | `ruff --help`          | `ruff <cmd> --help`        |
| docker | `docker --help`        | `docker <cmd> --help`      |

For pip-installed tools, `<tool> --help` is the usual surface; `man` is available
for system packages.

## When to re-verify

- After a major or minor version bump of the tool.
- When a skill starts producing wrong commands (symptom of drift).
- uv is pre-1.0 in behavior — re-check on version bumps.

## Anti-patterns

- Citing a flag from memory, e.g. assuming `poetry add --dev` was removed without
  running `poetry add --help`.
- Assuming two tools share a subcommand's behavior because they share its name
  (`uv check` vs `poetry check`).
- Writing `pip install` / `uv pip install` to add a dependency to a uv or poetry
  project — it bypasses the manifest and the dependency is lost on next sync.
- Copying a command from a sibling skill without re-verifying.
