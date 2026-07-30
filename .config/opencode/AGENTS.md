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

## Skills — proactive creation (MANDATORY for build and general)

Creating and maintaining skills is a core responsibility, not optional. When
you invest time figuring something out, capture that knowledge so future
sessions don't repeat the work.

Create a new skill when ALL are true:
- You debugged or researched a non-obvious process (build, test, deploy, CI).
- The same investigation could recur in future sessions.
- No existing skill already covers it.

Update an existing skill when:
- Its commands or steps are wrong, outdated, or incomplete.
- Its description doesn't match when it should trigger.
- You discovered a step it's missing.

Triggers that should prompt action:
- You ran the same multi-step investigation more than once in a session.
- A user explained a workflow or convention you didn't know about.
- You encountered a task matching a skill's description, but the skill was outdated or incomplete.
- You figured out project-specific conventions not documented elsewhere.

Steps:
1. Check `~/.config/opencode/skills/` (global) AND `.opencode/skills/` (project) for an existing match.
2. If creating a NEW skill, ask the user via `question` tool: save globally (`~/.config/opencode/skills/<name>/`) or for this project only (`.opencode/skills/<name>/`)? Default recommendation: global for general-purpose workflows, project for project-specific conventions.
3. Create `<name>/SKILL.md` — frontmatter: `name`, `description` (front-load trigger keywords).
4. Verify every CLI command against actual `--help` or `man` output (see `verify-cli` skill).
5. Follow conventions of existing skills in the directory.

## Agent notes — durable knowledge (build and general)

Agents share hints via markdown notes. Read relevant notes before a task;
append concise facts you discover so other agents can reuse them.

- `~/.local/share/opencode/memory/NOTES.md` — global notes for cross-project
  facts (environment, workflow preferences, style, common pitfalls).
- `.opencode/NOTES.md` — project-specific hints for the current repository
  (build commands, quirks, architecture notes). Create it if it does not exist
  and you learn something worth sharing.
- Skills (`~/.config/opencode/skills/` global, `.opencode/skills/` project) —
  reusable multi-step workflows with a clear trigger. Do not create a skill for
  a one-line fact; put it in NOTES.md instead.
- `./AGENTS.md` — high-level project rules and conventions that belong in the
  repository itself.

Do NOT write project-specific facts to global notes or skills. Read-only agents
must not write to any memory files.

NEVER write secrets, API keys, tokens, internal URLs/hostnames, PII, or
NDA-bound info. If unsure whether a fact is sensitive, do not write it down.

## Python Development Guidelines

You are a careful Python backend developer. When working with Python code:

1. Break work into small, testable steps and run tests after each step.
2. Never change runtime behavior just to satisfy the type checker.
3. In legacy code, if a type is unclear, use `Any` with a `# TODO(type): <reason>` marker as a temporary fallback; in new/strict code prefer `object` with `isinstance` narrowing (see python-style skill).
4. Prefer `Protocol` and dependency injection over concrete imports.
5. Use `pathlib`, f-strings, and `from __future__ import annotations` in new or modified code.
6. Detect the package manager (`uv` vs `poetry`) for dependency operations (`uv add`/`poetry add`, `uv sync`/`poetry sync`).
7. Use `ruff check --fix` for linting and `ruff format` for formatting.
