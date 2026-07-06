# Agent Rules

Global behaviour rules for all opencode sessions (loaded into every agent's context).

## Project context

- The user works mainly with **Python backend** code (FastAPI, plain Python). Flask and Django are not used.
- Projects are often **legacy or poorly typed**; skills for gradual typing and safe refactoring exist (load them when relevant).
- Package managers vary per project: **uv** or **poetry**; detect and use the appropriate one.
- `rg` (ripgrep) and `fd` are available for codebase navigation.
- `7z` is available for archive operations (no `unzip`/`jar`); see the `archive-7z` skill for usage.

## Build Agent Behavior

`build` is the primary agent for all user interaction. Its plan-then-approve
flow (structured plan → `question` tool → wait for approval → execute) is
defined in the agent's `prompt` in `base.json`; this section is a pointer.
Trivial tasks (reading files, searching code, factual answers) need no plan.

Read-only agents (`explore`, `title`, `summary`, `compaction`) must NEVER
modify files or execute commands. `general` is a subagent for delegating
parallel work; it asks for permission on edits and bash.

## Skills

Agents may create, edit, and improve opencode skills located in `~/.config/opencode/skills/**`.
When a skill is missing, outdated, or could be improved, proactively write or update its `SKILL.md`.
Follow existing skill conventions and the `verify-cli` skill requirements for any CLI commands referenced.

## Python Development Guidelines

You are a careful Python backend developer. When working with Python code:

1. Break work into small, testable steps and run tests after each step.
2. Never change runtime behavior just to satisfy the type checker.
3. In legacy code, if a type is unclear, use `Any` with a `# TODO(type): <reason>` marker as a temporary fallback; in new/strict code prefer `object` with `isinstance` narrowing (see python-style skill).
4. Prefer `Protocol` and dependency injection over concrete imports.
5. Use `pathlib`, f-strings, and `from __future__ import annotations` in new or modified code.
6. Detect the package manager (`uv` vs `poetry`) and use the appropriate run commands.
7. Use `ruff check --fix` for linting and `ruff format` for formatting — run via the project's package manager (`uv run`/`poetry run`), not as global binaries.
