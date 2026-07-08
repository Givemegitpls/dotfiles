---
name: poetry-to-uv
description: "Use when migrating a Python project from Poetry to uv. Covers running `uvx migrate-to-uv`, fixing pyproject.toml conversion gaps, rewriting Dockerfiles (poetry install -> uv sync), updating .gitlab-ci.yml, and verifying the result. Trigger keywords: migrate poetry to uv, migrate-to-uv, poetry -> uv, switch to uv, replace poetry."
---

# Migrate Poetry to uv

Migrate APS Poetry projects to uv using `uvx migrate-to-uv`, then fix the
gaps the tool leaves behind (build-backend targets, Dockerfiles, CI).

Commands below verified against `--help` output for uv 0.11.26 and
migrate-to-uv 0.12.0.

## When to use

The project uses Poetry. Indicators:

- `pyproject.toml` has a `[tool.poetry]` table
- `poetry.lock` exists
- `pyproject.toml` `[build-system]` uses `poetry.core.masonry.api`
- Dockerfile references `harbor.apsolutions.ru/base/poetry:` and runs
  `poetry install`

If none of these are present, the project is not on Poetry — stop.

## Pre-flight checks

1. Working tree must be clean (`git status`). The migration rewrites
   `pyproject.toml`, swaps `poetry.lock` for `uv.lock`, and may edit the
   Dockerfile.
2. Confirm Poetry is actually in use (indicators above).
3. Note the Python version from `[tool.poetry.dependencies] python = "..."`.
4. Note any `[tool.poetry.extras]` — these become `[project.optional-dependencies]`
   and need `-E`/`--extra` flags in Dockerfile `uv sync`.
5. Note package sources: `[[tool.poetry.source]]` and per-package `source =`
   fields. These become `[[tool.uv.index]]` and `[tool.uv.sources]`.

## Step 1 — Convert pyproject.toml

Run a dry run first to preview the conversion:

```bash
uvx migrate-to-uv --dry-run
```

The tool auto-detects Poetry. Key flags (verified against
`uvx migrate-to-uv --help`, migrate-to-uv 0.12.0):

| Flag                              | Effect                                                        |
| --------------------------------- | ------------------------------------------------------------- |
| `--dry-run`                       | Preview without modifying files                               |
| `--build-backend hatch`           | Use `hatchling` instead of the default `uv_build`             |
| `--keep-current-build-backend`    | Keep existing `[build-system]` as-is                          |
| `--skip-lock`                     | Do not run `uv lock` after migration                           |
| `--replace-project-section`       | Overwrite existing `[project]` instead of merging             |
| `--package-manager poetry`        | Force Poetry detection (skip auto-detect)                     |
| `--dependency-groups-strategy`    | How to handle Poetry groups: `set-default-groups-all`, `set-default-groups`, `include-in-dev`, `keep-existing`, `merge-into-dev` |
| `--ignore-locked-versions`        | Ignore `poetry.lock` pins when resolving `uv.lock`            |

### APS convention: hatchling

APS projects (see negations-deleter, ml_service) use `hatchling` as the
build backend, not `uv_build`. Pass `--build-backend hatch`:

```bash
uvx migrate-to-uv --build-backend hatch
```

This produces:

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

### Conversion the tool performs

| Poetry                                  | uv                                                |
| --------------------------------------- | ------------------------------------------------- |
| `[tool.poetry] name`, `version`, `description`, `authors`, `readme` | `[project]` fields (PEP 621)        |
| `[tool.poetry.dependencies] python = "^3.12"` | `requires-python = ">=3.12,<4"` in `[project]` |
| `^1.2.3` (caret)                        | `>=1.2.3,<2` (PEP 440 range)                      |
| `~1.2.3` (tilde)                        | `>=1.2.3,<1.3`                                    |
| `==1.2.3`                               | `==1.2.3`                                         |
| `[tool.poetry.extras]` + `optional = true` deps | `[project.optional-dependencies]`         |
| `[tool.poetry.group.dev.dependencies]` | `[dependency-groups] dev = [...]`                 |
| `[[tool.poetry.source]]`                | `[[tool.uv.index]]`                               |
| `priority = "primary"`                  | `default = true`                                  |
| `priority = "explicit"`                 | `explicit = true`                                 |
| `torch = { version = "...", source = "pytorch-cpu" }` | `[tool.uv.sources] torch = { index = "pytorch-cpu" }` |
| `poetry.core.masonry.api`               | `hatchling.build` (with `--build-backend hatch`)  |

### Gap the tool does NOT fill: hatch wheel targets

`migrate-to-uv --build-backend hatch` emits `[build-system]` with
`hatchling.build` but does **not** add the `[tool.hatch.build.targets.wheel]`
section. For src-layout projects this is required so `uv sync`/`uv build`
can find the package. Add it manually:

```toml
[tool.hatch.build.targets.wheel]
packages = ["src"]
```

Negations-deleter and ml_service both have this section. Without it,
`uv sync` may fail or install the project as a namespace-less package.

### Gap: `default-groups = "all"` installs dev deps by default

`migrate-to-uv` adds `[tool.uv] default-groups = "all"` to `pyproject.toml`.
This means `uv sync` with no flags installs **all** dependency groups
including `dev`. In Dockerfiles this is rarely desired — always pass
`--no-dev` to exclude dev dependencies from production images.

### Gap: `readme` field breaks bind-mount Dockerfile builds

`migrate-to-uv` copies `readme = "README.md"` from `[tool.poetry]` into
`[project]`. The Dockerfile bind-mount pattern only mounts `uv.lock` and
`pyproject.toml` into the build stage — not `README.md`. Hatchling reads
the `readme` field at build time and fails:

```
OSError: Readme file does not exist: README.md
```

Remove `readme = "README.md"` from `[project]`. README has no place in a
runtime Docker image — do NOT add it to bind-mounts to work around this.

### Verify the converted pyproject.toml

```bash
uv lock --check     # asserts uv.lock matches pyproject.toml
```

If `uv.lock` was not generated (e.g. `--skip-lock`), run:

```bash
uv lock
```

## Step 2 — Lockfile

The migration tool deletes `poetry.lock` and writes `uv.lock` (unless
`--skip-lock`). No manual `rm poetry.lock` is needed.

Regenerate the venv to confirm the lockfile resolves:

```bash
uv sync
```

## Step 3 — Dockerfile

Poetry Dockerfiles need rewriting. The APS pattern (from ml_service,
verified working) uses a multi-stage build with uv cache mounts.

### Before (Poetry)

```dockerfile
FROM harbor.apsolutions.ru/base/poetry:2.1-python3.12 AS build

COPY pyproject.toml poetry.lock ./

RUN poetry config virtualenvs.create true && \
  poetry config virtualenvs.in-project true && \
  poetry install --without dev --no-root

FROM harbor.apsolutions.ru/dockerhub/library/python:3.12-slim-bookworm

COPY --from=build .venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY src src

ENTRYPOINT ["python", "src"]
```

### After (uv)

```dockerfile
ARG PYTHON_VERSION="3.12"

FROM harbor.apsolutions.ru/base/uv:0.9.2-python${PYTHON_VERSION} AS build

WORKDIR /opt

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv venv .venv --relocatable --no-python-downloads && \
    uv sync --no-dev --no-editable --frozen

FROM harbor.apsolutions.ru/dockerhub/library/python:${PYTHON_VERSION}-slim-bookworm

COPY --from=build /opt/.venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

COPY src src

ENTRYPOINT ["python", "src"]
```

### Changes table

| Poetry                                    | uv                                                |
| ----------------------------------------- | ------------------------------------------------- |
| `harbor.apsolutions.ru/base/poetry:<ver>` | `harbor.apsolutions.ru/base/uv:<ver>`             |
| `COPY pyproject.toml poetry.lock`         | `--mount=type=bind` for `uv.lock` + `pyproject.toml` (cache-friendly) |
| `poetry config virtualenvs.create true` + `poetry install` | `uv venv .venv --relocatable --no-python-downloads` + `uv sync` |
| `poetry install --without dev`            | `uv sync --no-dev`                                |
| `poetry install --no-root`                | `uv sync --no-editable` (no editable install)     |
| `poetry install -E tracing -E profiling`  | `uv sync --extra tracing --extra profiling`       |
| `poetry install` (no pin)                 | `uv sync --frozen` (fail if lockfile stale)       |
| `COPY --from=build .venv /opt/venv`       | `COPY --from=build /opt/.venv /opt/venv` (note `/opt/` prefix — `WORKDIR /opt` in build stage) |
| Hardcoded `python:3.12-slim-bookworm`     | `python:${PYTHON_VERSION}-slim-bookworm` (ARG-driven) |

### uv base image version

Check the latest `harbor.apsolutions.ru/base/uv:` tag before pinning.
ml_service uses `uv:0.9.2-python3.12`. If the project's `requires-python`
differs, match the tag's Python version to it.

### Extras in Dockerfile

If `pyproject.toml` has `[project.optional-dependencies]` (converted from
`[tool.poetry.extras]`), include them in `uv sync`:

```dockerfile
uv sync --no-dev --no-editable --frozen --extra tracing --extra profiling
```

Use `--all-extras` to include every optional-dependency group:

```dockerfile
uv sync --no-dev --no-editable --frozen --all-extras
```

### Flags verified

| Flag                    | Source                                  |
| ----------------------- | --------------------------------------- |
| `--relocatable`         | `uv venv --help` (uv 0.11.26)           |
| `--no-python-downloads` | `uv venv --help` (uv 0.11.26)           |
| `--frozen`              | `uv sync --help` (uv 0.11.26)           |
| `--no-dev`              | `uv sync --help` (uv 0.11.26)           |
| `--no-editable`         | `uv sync --help` (uv 0.11.26)           |
| `--extra <NAME>`        | `uv sync --help` (uv 0.11.26)           |
| `--all-extras`          | `uv sync --help` (uv 0.11.26)           |

## Step 4 — .gitlab-ci.yml

Search for Poetry references:

```bash
rg poetry .gitlab-ci.yml
```

### CI using image-build / python-linters components

If `.gitlab-ci.yml` uses the `image-build` and `python-linters` CI
components (see the `ci` skill) and contains **no** `poetry` commands, no
changes are needed — the components build the Docker image and run linters
in their own images, independent of the project's package manager.

Both reference projects (negations-deleter, ml_service) had **zero**
`.gitlab-ci.yml` changes in their migration commits. Negations-deleter uses:

```yaml
include:
  - component: git.apsolutions.ru/aps/Internal/common/ci-components/python-linters@0.9.6
  - component: git.apsolutions.ru/aps/Internal/common/ci-components/image-build@0.9.6
    inputs:
      image_name: $HARBOR_URL/fts/$CI_PROJECT_NAME
```

No Poetry-specific lines — nothing to change.

### CI with inline Poetry commands

If the CI runs Poetry directly (e.g. a custom lint/test job), replace:

| Poetry                          | uv                          |
| ------------------------------- | --------------------------- |
| `poetry run ruff check`         | `uv run ruff check`         |
| `poetry run pytest`             | `uv run pytest`             |
| `poetry install`                | `uv sync`                   |
| `poetry install --only dev`     | `uv sync --only-dev`        |
| `image: harbor.../poetry:<ver>` | `image: harbor.../uv:<ver>` |

### python-linters component

The `python-linters` CI component runs pyright and ruff in its own image
with pinned versions — it does not use the project's Poetry or uv. No
migration needed there either.

## Step 5 — Cleanup and verify

1. `poetry.lock` is already deleted by `migrate-to-uv` — no action needed.

2. Recreate the venv from scratch to confirm `uv.lock` resolves cleanly:

   ```bash
   rm -rf .venv
   uv sync
   ```

3. Run the project's tests and linters via uv:

   ```bash
   uv run pytest
   uv run ruff check
   uv run ruff format
   uv run basedpyright   # if configured
   ```

4. Search for leftover Poetry references across the repo:

   ```bash
   rg -i poetry .
   ```

   Check hits in: `README.md`, `Makefile`, `scripts/`, `*.sh`, `.github/`,
   `docs/`. Update any `poetry run ...` instructions to `uv run ...`.

5. Build the Docker image locally to confirm the Dockerfile works:

   ```bash
   docker build -t test-migration .
   ```

   Building the image validates that the Dockerfile, `uv.lock`, and
   `pyproject.toml` are consistent. Running the container is the operator's
   responsibility — most services need infrastructure (RabbitMQ, MongoDB,
   etc.) to start, so do not attempt runtime smoke tests.

## Verification checklist

- [ ] `pyproject.toml` has `[project]` table, no `[tool.poetry]`
- [ ] `[build-system]` uses `hatchling.build` (APS convention)
- [ ] `[tool.hatch.build.targets.wheel] packages = ["src"]` present (for src-layout)
- [ ] `readme = "README.md"` removed from `[project]` (must not be in the Docker build)
- [ ] `[tool.poetry.extras]` converted to `[project.optional-dependencies]`
- [ ] `[[tool.poetry.source]]` converted to `[[tool.uv.index]]`
- [ ] Per-package `source =` converted to `[tool.uv.sources]`
- [ ] `[tool.poetry.group.*.dependencies]` converted to `[dependency-groups]`
- [ ] `poetry.lock` deleted
- [ ] `uv.lock` generated and committed
- [ ] `uv sync` succeeds in a clean venv
- [ ] Dockerfile uses `base/uv:` image, `uv venv` + `uv sync`, cache mounts
- [ ] Dockerfile `uv sync` includes `--no-dev` (dev deps not in production image)
- [ ] Dockerfile `uv sync` includes `--extra` flags for any required extras
- [ ] Docker image builds: `docker build -t test-migration .`
- [ ] `.gitlab-ci.yml` has no `poetry` references (or they are replaced)
- [ ] `rg -i poetry .` returns no actionable hits
- [ ] Tests pass: `uv run pytest`
- [ ] Linters pass: `uv run ruff check`, `uv run basedpyright`

## Command provenance

All commands and flags in this skill were verified against `--help` output
on the target machine:

- `uvx migrate-to-uv --help` — migrate-to-uv 0.12.0
- `uv sync --help` — uv 0.11.26
- `uv venv --help` — uv 0.11.26
- `uv lock --help` — uv 0.11.26
- `uv add --help` — uv 0.11.26

Re-verify on uv version bumps (uv is pre-1.0 in behavior).
