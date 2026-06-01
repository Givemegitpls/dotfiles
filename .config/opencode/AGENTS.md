# Global OpenCode Config

## Plugin development

`@opencode-ai/plugin` exports three entry points:

| Import                     | Purpose          |
| -------------------------- | ---------------- |
| `@opencode-ai/plugin`      | Main plugin API  |
| `@opencode-ai/plugin/tool` | Tool definitions |
| `@opencode-ai/plugin/tui`  | TUI components   |

Plugin dependencies: `effect` (4.0.0-beta), `zod` (4.x). Peer deps
`@opentui/core` and `@opentui/solid` are optional (TUI only).

## Config reference

The authoritative schema is at <https://opencode.ai/config.json>. If unsure
about a field shape, fetch that URL rather than guessing — opencode hard-fails
on invalid config.

## Python conventions

- **Package manager**: prefer `uv`. If a project uses `poetry` (has
  `poetry.lock`), use `poetry` instead. Never mix both in one project.
- **Type checking**: `basedpyright` in strict mode
  (`"typeCheckingMode": "strict"` in pyrightconfig.json). All public functions
  must have full type annotations. No `Any`, no `# type: ignore` without
  explanation.
- **Linting/formatting**: `ruff check --fix` for linting, `ruff format` for
  formatting. Follow ruff's defaults.
- **Testing**: `pytest`. Look for `pyproject.toml` → `[tool.pytest.ini_options]`
  for project-specific config.
- **Debugger**: `debugpy` is available if needed for attaching to running
  processes.
- **Pre-commit**: if `.pre-commit-config.yaml` exists, respect its hooks
  (typically ruff + basedpyright). Suggest adding one if missing.
- **Virtual env**: always check for `.venv/` or `uv sync` status before running
  Python. Use `uv run` to ensure correct environment.
- **Dependencies**: check `pyproject.toml` before adding new deps. Use
  `uv add <pkg>` (or `poetry add <pkg>`).

### MANDATORY: ruff and basedpyright

Before running ruff or basedpyright, determine the correct command prefix:

1. If `uv.lock` exists → use `uv run` prefix:
   `uv run ruff check --fix <file> && uv run ruff format <file> && uv run basedpyright <file>`
2. If `poetry.lock` exists → use `poetry run` prefix:
   `poetry run ruff check --fix <file> && poetry run ruff format <file> && poetry run basedpyright <file>`
3. Otherwise → use system tools directly:
   `ruff check --fix <file> && ruff format <file> && basedpyright <file>`

Do NOT skip these steps even if:

- The project has no `[tool.ruff]` or `[tool.pyright]` section in
  `pyproject.toml`
- No `pyrightconfig.json` exists (create one with `"typeCheckingMode": "strict"`
  if missing)
- The project uses a different linter or type checker
- You think the edit is trivial

These tools are non-negotiable quality gates. Fix all errors they report before
considering the edit complete.

## Preferred CLI tools

- Use `rg` (ripgrep) instead of `grep` for searching file contents
- Use `fd` instead of `find` for locating files by name/pattern
- Use `ls` only when `fd` isn't suitable (e.g., listing directory contents
  without pattern matching)

## CI (GitLab)

For GitLab CI pipelines in APS projects, load the **ci** skill — it covers CI
components registry (`git.apsolutions.ru/aps/Internal/common/ci-components`),
image-build, release, docs, and pipeline conventions.

Key points:

- Components: `image-build`, `release`, `docs`, `push_archrepo_golang`,
  `python-linters`
- Base images: use `harbor.apsolutions.ru/dockerhub/` mirror prefix
- Always pin component versions to a specific tag from the ci-components repo

## Scope and secrets

- NEVER read `.env` or `.env.*` files without explicit user approval — they
  contain secrets
- Stay within the project directory where opencode was opened. Avoid reading or
  writing outside the worktree unless explicitly asked
- If you need context from outside (e.g., global config), ask the user first

## Git safety

- NEVER `git push` without explicit user approval
- NEVER `git checkout`/`git switch`/`git rebase` without explicit user approval
- These are gated by permission system (ask), but also never suggest running
  them automatically
