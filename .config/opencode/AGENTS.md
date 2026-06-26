# OpenCode Configuration Guide

This document explains the architecture of this opencode configuration.
It is intended for AI agents that need to modify, extend, or troubleshoot the opencode setup.

## Golden Rule

`config.json` is **auto-generated**. Never edit it by hand. Always edit `base.json` or `provider.json`, then run `merge-config.sh`.

## Architecture

The configuration is split into three layers:

| File           | Purpose                                         | Editable by hand |
|----------------|-------------------------------------------------|------------------|
| `base.json`    | Shared settings: LSP, compaction, agent prompts & permissions | Yes |
| `provider.json`| Provider-specific: providers, models, agent mapping            | Yes |
| `config.json`  | Merged output consumed by opencode                           | **No** |
| `merge-config.sh` | Bash script that merges `base.json` + `provider.json` into `config.json` | Yes |

### `base.json`

Contains everything that is **provider-independent**:
- `$schema`, `default_agent`
- `lsp` (e.g. `basedpyright-langserver`)
- `compaction` settings
- `agent` definitions with `system_prompt` and `permission`
  - **Important:** `base.json` agents do **not** contain the `model` field.

### `provider.json`

Contains everything that changes between devices (home vs office):
- `provider` — object where each key is a provider name and value is the provider definition
  - `npm` — npm package name for the provider
  - `name` — human-readable display name
  - `options` — provider-specific settings (e.g. `baseURL`)
  - `models` — full model definitions (name, limits, thinking, etc.)
- `agent_mapping` — maps agent names to model keys (without the provider prefix)
  - The provider name is auto-prefixed by `merge-config.sh`
  - Example: `"build": "opencode-go/kimi-k2.7-code-go"` becomes `model: "litellm/opencode-go/kimi-k2.7-code-go"` in the merged `config.json`

## How To

### Add a new agent

1. Edit `base.json`:
   - Add an entry under `"agent"` with `system_prompt` and `permission`.
   - Do **not** add a `model` field.
2. Edit `provider.json`:
   - Add the agent to `"agent_mapping"` pointing to an existing model key (without provider prefix).
3. Run `./merge-config.sh` to regenerate `config.json`.

### Add a new model

1. Edit `provider.json`:
   - Add the model definition under the appropriate `"provider".<name>."models"`.
2. If needed, update `"agent_mapping"` to use the new model (without provider prefix).
3. Run `./merge-config.sh`.

### Change an agent's model

1. Edit `provider.json` → `"agent_mapping"`.
2. Change the value for the agent to another model key (without provider prefix).
3. Run `./merge-config.sh`.

### Add a new provider

1. Edit `provider.json`:
   - Add a new entry under `"provider"` with `npm`, `name`, `options`, and `models`.
2. Update `"agent_mapping"` to reference models from the new provider (without provider prefix).
3. Run `./merge-config.sh`.

### Add a new skill

1. Create a directory: `skills/<skill-name>/`
2. Write `SKILL.md` inside it with the skill definition.
3. Symlink the skill into `~/.config/opencode/skills/`:
   ```bash
   ln -s /path/to/your/skills/<skill-name> ~/.config/opencode/skills/<skill-name>
   ```

## What is shared vs per-device

- **Shared** (same on all devices, lives in dotfiles):
  - `base.json`
  - `merge-config.sh`
  - `skills/` (symlinked to dotfiles)
  - This `AGENTS.md`

- **Per-device** (do not commit to shared repo):
  - `provider.json`
  - `config.json` (already ignored via `.gitignore`)

## Context for modifications

When editing any of these files, keep the following context in mind:
- The user works mainly with **Python backend** code (FastAPI, plain Python). Flask and Django are not used.
- Projects are often **legacy or poorly typed**; skills for gradual typing and safe refactoring exist.
- Package managers vary per project: **uv** or **poetry**. The configuration accounts for both.
- `rg` (ripgrep) and `fd` are available for codebase navigation.

## Plan Mode Behavior

The following agents are strictly read-only and must NEVER modify files or execute commands:
- `plan`, `explore`, `title`, `summary`, `compaction`

### Transition rules
1. `plan` agent collects requirements and produces a structured plan.
2. The user must explicitly approve the plan (e.g., "execute", "go ahead", "implement").
3. Only then may the `build` or `general` agent execute the plan.
4. If a user asks a read-only agent to write code, the agent must refuse and wait for explicit approval.

## Quick validation

After any change to `base.json` or `provider.json`, run:
```bash
~/.config/opencode/merge-config.sh
```
The script validates the generated JSON and prints a confirmation line.
