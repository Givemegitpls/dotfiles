---
name: architecture-map
description: "Use when analyzing messy or unclear project architecture. Covers dependency graphs, layer mapping, cyclic import detection, FastAPI specifics, and god-object identification."
---

# Architecture Mapping Guide

## Project topology

- Identify layers: API (routers/endpoints) → Service (business logic) → Repository/DAO (data access) → Domain (models/entities)
- Draw ASCII diagrams showing imports between layers and major modules
- Flag arrows that violate intended direction (e.g., Repository importing API)

## Dependency analysis

- Find cyclic imports with: `python -c "import sys; sys.path.insert(0, '.'); import <module>"` or `rg '^from \.|^import \.' --type py`
- Build a quick import graph using `rg '^from ([\w.]+) import' -or '^import ([\w.]+)' --type py -o -N | sort | uniq -c | sort -rn`
- Highlight modules imported by many others — they are coupling hotspots

## Heuristics for problematic code

- God class: >20 methods or >500 lines of class body
- Spaghetti function: >50 lines, >10 parameters, >5 local variables named `data` / `result` / `tmp`
- Hidden coupling: modules sharing global state, `os.environ` reads scattered across code, `Singleton` anti-pattern
- FastAPI-specific: routers with >20 endpoints, `Depends()` chains >3 levels deep, `BackgroundTasks` mixed with sync DB calls

## FastAPI specifics

- Map routers → tags → endpoints
- Identify lifespan events vs startup/shutdown decorators
- Check middleware order and whether it blocks the event loop
- Flag endpoints that do not use `Depends()` for DB/session — manual resource management is error-prone

## Output format

Summarize as:

- **Layer diagram**: ASCII boxes with arrows
- **Coupling hotspots**: top 5 most-imported modules
- **Cycles**: list of cyclic import chains found
- **Problem objects**: god classes / spaghetti functions with file paths
- **FastAPI smells**: router bloat, deep dependency chains, blocking middleware
- **Recommended order**: which module to refactor first (least dependents → most dependents)
