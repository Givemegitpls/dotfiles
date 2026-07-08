---
name: python-legacy
description: "Use when working with poorly typed or legacy Python code. Covers gradual typing, safe annotation strategies, dynamic attributes, and monkeypatching without breaking behavior."
---

# Python Legacy Code Guide

## Gradual typing strategy

- Never break runtime behavior to add types
- If a type is unclear, use `Any` with a `# TODO(type): <reason>` marker — do not guess
- Prefer `Protocol` over concrete types for duck-typed interfaces
- Use `typing.cast` only when you know the runtime type but the static checker disagrees
- Add `from __future__ import annotations` before introducing annotations in legacy modules
- Type public APIs first (modules/functions imported by others), internals later

## Dynamic attributes

- For `__getattr__` / `setattr` / `getattr` patterns, prefer `TypedDict` or `dataclass` if possible
- If truly dynamic, annotate with `object` and narrow with `isinstance` at use sites
- Document dynamic attribute names in docstrings for human readers

## Monkeypatching legacy code

- Monkeypatch only in test fixtures, never in production code
- Use `pytest-mock` (`mocker.patch`) or `unittest.mock.patch`
- Always restore original state in fixture teardown
- Prefer `mocker.spy()` over `mocker.patch()` when you only need assertions

## Package manager awareness

Detect the manager by lockfile, not by guessing:
- `uv.lock` → uv
- `poetry.lock` → poetry
- neither + only `requirements.txt` → warn the user and suggest migrating to uv

### CRITICAL: never use pip to add project dependencies

`pip install` / `uv pip install` must NEVER be used to add dependencies to a project.
They manage a bare environment without updating `pyproject.toml`, so the dependency
is invisible to the lockfile and will be lost on the next `uv sync`.

Correct commands (verified against `uv add --help` and `poetry add --help`):

| Action                  | uv                          | poetry                        |
|-------------------------|-----------------------------|-------------------------------|
| Add runtime dep         | `uv add <pkg>`              | `poetry add <pkg>`            |
| Add dev dep             | `uv add --dev <pkg>`        | `poetry add --group dev <pkg>`|
| Add to a named group    | `uv add --group <g> <pkg>`  | `poetry add --group <g> <pkg>`|
| Add optional/extra dep  | `uv add --optional <e> <p>` | `poetry add <pkg>` (edit toml)|
| Remove a dep            | `uv remove <pkg>`           | `poetry remove <pkg>`         |
| Sync env from lockfile  | `uv sync`                   | `poetry sync` / `poetry install`|

`uv pip <subcommand>` is a low-level pip-compatible interface for environments
WITHOUT project metadata. Do not reach for it in normal project work.

Run the type checker after each batch of annotations: `basedpyright`.

## Testing legacy changes

- Write a minimal smoke test before refactoring untyped code
- Use `assert isinstance(result, expected_type)` in tests as runtime type guards
- If no tests exist, create one that calls the function and checks it does not crash

## Markers

- Use consistent markers in comments:
  - `# TODO(type): <what and why>` — unknown or complex type
  - `# LEGACY: <explanation>` — explaining a weird pattern that should not be replicated
  - `# REFACTOR: <idea>` — safe improvement to do later
