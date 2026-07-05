---
date: 2026-06-29
type: project
status: active
area: rs42
project: rs42-onboarding
tags:
  - onboarding
  - rs42
---

## Welcome to your RS42 work vault

This vault is a **human-AI operating system** for your RS42 work. You and an AI assistant collaborate on the same files, with the same structure and shared context. Read `AGENTS.md` (the canonical instruction file) to see how routing works — then do the first-step tasks below.

## How the system works (the 90-second version)

- **Every note has three routing properties:** `type` (what kind), `area` (`rs42`), `project` (which project). Hubs like this one auto-populate from them — you never hand-maintain a dashboard.
- **Daily hubs (`1. Daily/`) are work logs** — what you worked on, decisions, blockers.
- **The shared commons** (`5. Resources/RS42-Commons/`) is the team's knowledge brain. You read it and link to it; you contribute by promoting finished notes through review.
- **The AI is your collaborator, not just autocomplete** — it routes notes, keeps the graph linked, and helps you find prior work.

## First steps

```base
filters:
  and:
    - type == "task"
    - project == "rs42-onboarding"
views:
  - type: table
    name: Onboarding Tasks
    order:
      - file.name
      - status
    sort:
      - property: status
        direction: ASC
```
