---
name: git-workflow
description: "Use when committing, creating PRs, or managing git history. Conventional commits, pre-commit hooks with ruff and basedpyright, branching conventions."
---

# Git Workflow

## Commits

- Conventional commits format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`, `build`
- Scope: module or component name
- Subject: imperative mood, lowercase, no period, 72 chars max
- Body: explain WHY, not what

## Pre-commit

- If `.pre-commit-config.yaml` exists, hooks run automatically
- If missing, suggest adding one with: `ruff check --fix`, `ruff format`, `basedpyright` (all configured to run via `uv run` or `poetry run` inside the hook definitions)
- `pre-commit` is not installed globally; add it as a dev dependency first: `uv add --dev pre-commit`
- Run `uv run pre-commit run --all-files` to check manually

## Branching

- `main` — protected, no direct pushes
- Feature branches: `feat/<short-description>`
- Fix branches: `fix/<short-description>`
- Rebase preferred over merge commits

## Before committing

1. `uv run ruff check --fix && uv run ruff format` (or `poetry run ...`)
2. `uv run basedpyright` (or `poetry run basedpyright`)
3. `uv run pytest`
4. Review `git diff --staged`

## Safety rules

- NEVER `git push` without explicit user approval
- NEVER `git checkout`/`git switch`/`git rebase` without explicit user approval
- These are gated by permission system (ask), but also never suggest running them automatically
