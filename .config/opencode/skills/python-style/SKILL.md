---
name: python-style
description: "Use when writing or editing Python code. Enforces strict typing with basedpyright, ruff linting and formatting, modern Python 3.12+ idioms."
---

# Python Style Guide

## Strict typing rules

- All function parameters and return types must be annotated
- Use `from __future__ import annotations` at the top of every module
- Prefer `type` aliases and `TypedDict` over raw dicts
- Use `Sequence`, `Mapping` from `collections.abc`, not concrete types in signatures
- No `Any` — use `object` if truly dynamic, or narrow with `isinstance` checks
- `# type: ignore[code]` only with a comment explaining why
- Use `assert_never()` for exhaustive checks on enums/literals
- Prefer `@dataclass(frozen=True, slots=True)` or `@dataclass(slots=True)` for data structures
- Generic classes: inherit from `Generic[T]` with explicit type vars
- Use `typing.Protocol` for structural subtyping
- Use `typing.overload` for multiple call signatures

## Ruff rules

- Run `ruff check --fix` after edits
- Run `ruff format` after edits
- Key enabled rule groups: E, F, I, N, UP, ANN, B, A, SIM, TCH, RUF

## Modern Python

- Use `match` statements where appropriate
- Walrus operator `:=` for combined check+assign
- f-strings only (no `%s` or `.format`)
- `pathlib.Path` instead of `os.path`
- `from collections.abc import ...` not `from typing import ...` (except special forms like `Protocol`, `TypedDict`, `dataclass_transform`)
- Use `|` union syntax instead of `Union[...]`
- Use `list[...]` instead of `List[...]`, `dict[...]` instead of `Dict[...]`

## Error handling

- Custom exception hierarchy, never bare `raise Exception`
- Use `raise ... from err` for chaining
- Prefer `Result`-like patterns or explicit error types for recoverable errors
- Never use bare `except:` — always catch specific exceptions

## Imports

- `from __future__ import annotations` first
- stdlib
- third-party
- local
- Blank line between each group
- Use `TYPE_CHECKING` block for type-only imports
