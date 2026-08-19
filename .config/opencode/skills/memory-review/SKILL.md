---
name: memory-review
description: "Use at the start of a session or before a non-trivial task, when the user asks to remember/forget/review facts, or at the end of a task to consolidate durable knowledge. Manages ~/.local/share/opencode/memory/NOTES.md and project .opencode/NOTES.md."
---

# Memory Review

## When to use

- Start of a session or before a non-trivial task.
- User says: remember this, forget that, review memory, update notes.
- End of any task where you learned something durable.

## Workflow

1. Read relevant memory files:
   - `~/.local/share/opencode/memory/NOTES.md` — global notes.
   - `.opencode/NOTES.md` in the project root — project notes.
2. Search existing notes (Grep, or just read the small notes files) to avoid duplicates.
3. Surface relevant facts silently; do not dump them to the user.
4. After the task, decide if any durable fact was learned.
5. Write one fact per note, concise.
6. Choose the right place:
   - Cross-project fact → `~/.local/share/opencode/memory/NOTES.md`.
   - Project-specific fact → `.opencode/NOTES.md`.
   - Reusable multi-step workflow → skill in `~/.config/opencode/skills/` or `.opencode/skills/`.
   - Repo-level convention → `./AGENTS.md`.

## Rules

- Never write secrets, API keys, tokens, internal URLs/hostnames, PII, or NDA-bound info.
- No duplicates; edit existing notes if the fact changes.
- Keep notes scannable: one bullet per fact.
- If notes grow too long, propose a compact review/rewrite.

## Anti-patterns

- Appending without reading first.
- Writing long paragraphs instead of concise facts.
- Putting project-specific facts in global notes.
