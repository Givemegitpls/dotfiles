---
name: python-testing
description: "Use when writing tests for Python code. Covers pytest conventions, fixtures, mocking, strict type-checked tests, and uv-based test running."
---

# Python Testing

## Running tests

- `uv run pytest` (or `pytest` if inside activated venv)
- `uv run pytest -x` to stop on first failure
- `uv run pytest --tb=short` for concise tracebacks
- Look for `pyproject.toml` → `[tool.pytest.ini_options]` for project config

## Installing test dependencies

Never use `pip install` to add test deps — they will not be recorded in `pyproject.toml`.
- Add a test tool: `uv add --dev pytest` / `poetry add --group dev pytest`
- Add a test group (uv): `uv add --group test pytest pytest-cov`

## Test structure

- Mirror source structure: `src/module.py` → `tests/test_module.py`
- One test class per class, one test file per module
- Test names: `test_<method>_<scenario>_<expected_result>`
- Use `@pytest.mark.parametrize` for data-driven tests

## Fixtures

- Shared fixtures in `conftest.py`
- Use `@pytest.fixture` with return type annotations
- Scope: default to `function`, use `session`/`module` only when expensive setup
- Fixture names should describe what they provide, not how they create it

## Mocking

- `pytest-mock` (`mocker` fixture) preferred over manual `unittest.mock`
- Never mock what you own — mock external dependencies only
- Use `mocker.spy()` for assertions on internal calls
- Prefer real implementations over mocks when fast enough

## Type checking in tests

- Test files are also type-checked by basedpyright strict
- Annotate fixture return types
- Use `typing.Protocol` for mock interfaces

## Coverage

- `uv run pytest --cov` if `pytest-cov` installed
- Target high coverage for new code
- Use `--cov-fail-under` in CI

## Debugging

- `debugpy` for attaching to running test processes
- `pytest --pdb` for interactive debugging
- `breakpoint()` works with debugpy attached
