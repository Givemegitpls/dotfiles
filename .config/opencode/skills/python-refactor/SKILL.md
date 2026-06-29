---
name: python-refactor
description: "Use when refactoring Python code safely. Covers extract method/class/module, dependency inversion, constants extraction, and test-protected changes."
---

# Python Refactoring Guide

## Safety first

- Run existing tests before starting: `uv run pytest` or `poetry run pytest`
- If no tests exist, write a minimal smoke test that exercises the target code
- Make one logical change per step; run tests after each step
- If tests fail, revert and rethink before proceeding

## Extract operations

- **Extract method**: identify a block with clear inputs/outputs, create `def _<name>(...)`, replace block with call
- **Extract class**: group related methods and state, create new class, inject via constructor
- **Extract module**: move cohesive functions/classes to new file, update imports, run `uv run ruff check --fix` (or `poetry run ruff check --fix`)
- After extraction, verify no circular imports were introduced

## Dependency inversion

- Replace direct imports of concrete implementations with `Protocol`
- Inject dependencies via constructor or FastAPI `Depends()`
- Keep default implementations in factory functions, not in class constructors
- Avoid importing modules at runtime inside functions unless breaking a cycle

## Replace magic values

- Find magic strings/numbers in a target file: `rg '"[^"]{3,}"' path/to/file.py` (quoted strings 3+ chars) or `rg '\b\d{2,}\b' path/to/file.py` (multi-digit numbers). Drop `--type py` when passing a file path — it's only needed for project-wide searches.
- Extract to module-level `CONSTANT_NAME: Final[<type>] = <value>`
- If value used across modules, create `constants.py` or `config.py`

## Testing during refactor

- After each extraction, run `uv run pytest -x` or `poetry run pytest -x`
- Use `pytest --tb=short` for concise tracebacks
- If a test requires mocking after refactor, prefer `mocker.spy()` over full mocks

## Package manager awareness

- When moving files, update package metadata if needed (`pyproject.toml` `[tool.setuptools.packages.find]` etc.)
- Run `uv sync` or `poetry sync` (not `pip install`) after structural changes to ensure imports resolve from the lockfile

## Rollback rule

- If a refactor step takes more than 15 minutes to make tests pass, revert to previous working state and decompose the step further
