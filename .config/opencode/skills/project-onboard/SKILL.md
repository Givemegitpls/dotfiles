---
name: project-onboard
description: "Use when first opening an unfamiliar Python project. Quick analysis of project structure, dependencies, entry points, test setup, and tooling."
---

# Project Onboarding

## Step 1: Identify project type and package manager

- Check for `pyproject.toml`, `setup.cfg`, `setup.py`, `requirements.txt`
- Determine package manager by lockfile: `uv.lock` → uv, `poetry.lock` → poetry. If only `requirements.txt` exists, warn the user and suggest migrating to uv. Do NOT infer the manager from the presence of `uv pip` or `pip` — those are subcommands, not detection signals.
- Check Python version requirement in `pyproject.toml` → `[project] requires-python`
- For backend projects: identify framework (FastAPI, Django, Flask) from dependencies; FastAPI is common

## Step 2: Map structure

- Entry points: `pyproject.toml` → `[project.scripts]` or `[tool.hatch.build.targets.wheel.scripts]`
- Source layout: `src/` vs flat layout
- Test directory: `tests/`, `test/`, or inline
- Config files: `.env`, `conftest.py`, `alembic.ini`, `docker-compose.yml`

## Step 3: Check tooling

- `ruff`: check `[tool.ruff]` in `pyproject.toml` or `ruff.toml`
- `basedpyright`: check `[tool.basedpyright]` or `pyrightconfig.json`
- `pre-commit`: check `.pre-commit-config.yaml`
- `pytest`: check `[tool.pytest.ini_options]`

## Step 4: Dependencies

- Read `[project.dependencies]` and `[project.optional-dependencies]`
- Identify framework: FastAPI, Django, Flask, etc.
- Note key libraries for context

## Step 5: Verify environment

- Check `.venv/` exists, suggest `uv sync` (uv) or `poetry sync` (poetry) if not
- Verify `uv run python -c "import <main_pkg>"` or `poetry run python -c "import <main_pkg>"` works
- Run `uv run pytest --co -q` or `poetry run pytest --co -q` to list collected tests
- For backend/FastAPI: note if lifespan, routers, or `Depends()` patterns exist

## Output format

Summarize findings as:

- **Stack**: framework + key libraries
- **Structure**: source layout + entry points
- **Tooling**: ruff/basedpyright/pytest config status
- **Environment**: venv status, missing deps
- **Quick start**: commands to run/lint/test
