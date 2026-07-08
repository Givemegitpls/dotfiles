---
name: git-workflow
description: "Use when committing, creating PRs, or managing git history. Conventional commits, pre-commit hooks with ruff and basedpyright, branching conventions."
---

# Git Workflow

## Agent git policy

The agent may run ONLY `git diff` and `git diff --staged` (read-only review). All
other git operations — `add`, `commit`, `push`, `checkout`, `switch`, `rebase`,
`merge`, `stash`, `reset`, `revert`, `cherry-pick` — are denied by the permission
system and must be performed by the user. When a commit is needed, the agent
prepares the message and the change summary; the user runs the git command.

## Commits

- Conventional commits format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`, `build`
- Scope: module or component name
- Subject: imperative mood, lowercase, no period, 72 chars max
- Body: explain WHY, not what

## Pre-commit

- If `.pre-commit-config.yaml` exists, hooks run automatically on the user's machine
- If missing, suggest adding one with: `ruff check --fix`, `ruff format`, `basedpyright`
- `pre-commit` is not installed globally; add it as a dev dependency: `uv add --dev pre-commit`
- Manual check (user runs): `pre-commit run --all-files`

## Branching

- `main` — protected, no direct pushes
- Feature branches: `feat/<short-description>`
- Fix branches: `fix/<short-description>`
- Rebase preferred over merge commits
- Branch creation/switching is done by the user; the agent never switches branches

## Before the user commits

The agent prepares:

1. `ruff check --fix && ruff format`
2. `basedpyright`
3. `pytest`
4. Review staged changes: `git diff --staged` (agent-run, the only git command allowed)

The agent then suggests a conventional-commit message; the user stages
(`git add`) and commits (`git commit`) themselves.

## Safety rules

- The agent is blocked from all git commands except `git diff`/`git diff --staged`.
- Never suggest the agent run `git push`, `git checkout`, `git switch`, `git rebase`,
  `git merge`, `git stash`, `git reset`, `git revert`, or `git cherry-pick`
  automatically — propose them as commands for the user to run.
- `git push` always requires explicit user action.
