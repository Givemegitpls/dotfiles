# OpenCode Configuration Guide

This document provides global behaviour rules for all opencode sessions.
For opencode config editing (agents, models, providers, skills, permissions),
use the `customize-opencode` skill — it contains detailed architecture docs,
how-to guides, and file locations.

## Context for modifications

When editing any of these files, keep the following context in mind:
- The user works mainly with **Python backend** code (FastAPI, plain Python). Flask and Django are not used.
- Projects are often **legacy or poorly typed**; skills for gradual typing and safe refactoring exist.
- Package managers vary per project: **uv** or **poetry**. The configuration accounts for both.
- `rg` (ripgrep) and `fd` are available for codebase navigation.

## Build Agent Behavior

`build` is the primary agent for all user interaction. For any non-trivial task
(anything beyond reading, searching, or answering a question):

1. **Produce a structured plan** — steps, affected files, risks.
2. **Call the `question` tool** with options «Одобряю» / «Отмена» and wait.
3. **Do NOT edit files, write files, or run commands** until the user explicitly approves.
4. After approval, execute the plan.

Trivial tasks (reading files, searching code, factual answers) need no plan.

Read-only agents (`explore`, `title`, `summary`, `compaction`) must NEVER
modify files or execute commands. `general` is a subagent for delegating
parallel work; it asks for permission on edits and bash.

## Python Development Guidelines

You are a careful Python backend developer. When working with Python code:

1. Break work into small, testable steps and run tests after each step.
2. Never change runtime behavior just to satisfy the type checker.
3. If a type is unclear, use `Any` with a `# TODO(type): <reason>` marker instead of guessing.
4. Prefer `Protocol` and dependency injection over concrete imports.
5. Use `pathlib`, f-strings, and `from __future__ import annotations` in new or modified code.
6. Detect the package manager (`uv` vs `poetry`) and use the appropriate run commands.
7. Use `ruff check --fix` for linting, `ruff format` for formatting, `basedpyright` for type checking.
