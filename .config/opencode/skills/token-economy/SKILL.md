---
name: token-economy
description: "Use when planning a task, choosing which agent to delegate to, or deciding how to interact with the codebase to minimize token spend and context pressure. Covers agent selection, model tiers, context discipline, and subagent caching behavior."
---

# Token Economy

## Core constraints in OpenCode

- Agents cannot switch modes (plan/build/explore) autonomously.
- Agents cannot request a specific model; models are configured per agent in `provider.json` / `agent_mapping`.
- A subagent call does not reset the caller's cache, but the subagent starts with no context and no cache.

## Agent model tiers

Use the project's model tier list when choosing where to route work:

- **Build** — strongest coding model (e.g., `kimi-k2.7-code` or `glm-5.2`).
- **Plan** — best reasoning model (e.g., `glm-5.2`, or `qwen3.7-max` for complex architecture if cost is justified).
- **General** — cheap but capable model for parallel work (e.g., `minimax-m3`).
- **Explore** — cheap read-only model for search/analysis (e.g., `minimax-m3`).
- **Title / Summary / Compaction** — cheapest adequate model (e.g., `deepseek-v4-flash`, or a local/free model like `glm-4.7-flash` if tested).

Avoid deprecated or overpriced models per the project's "Do not use" list.

## Minimizing token spend

- Stay in the current agent when possible.
- Delegate to a subagent only for self-contained, short tasks where the fresh context is acceptable.
- Use `rg` and `fd` to locate symbols; read only the fragments you need.
- Do not re-send unchanged files in later turns.
- Batch related edits instead of making many tiny changes.
- Use skills and `CONVENTIONS.md` as read-only context instead of restating rules.
- Keep sessions compact; use compaction when history grows.

## When not to save tokens

- Safety-critical changes.
- Complex architecture decisions.
- Tasks where errors are expensive.

In those cases, use the best model and do not skip plan-then-approve.
