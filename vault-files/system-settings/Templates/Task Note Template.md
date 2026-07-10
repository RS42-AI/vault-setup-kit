---
date: {{date:YYYY-MM-DD}}
type: task
status: todo
area:
project:
priority: p3
due_date: ""
scheduled_date: ""
done_date: ""
blocked_by: []
blocked_reason: ""
unlocks: []
external_id: ""
tags:
  - task
---

# {{title}}

> **Project**: [[]]

{Description — what needs to be done and why}

## Current State

%% A short "where this stands now", rolled up from the linked dev logs below and freshness-stamped (`*Rolled up from dev logs · as of YYYY-MM-DD*`). Refreshed by the task rollup pass or by hand — not a static field. The rollup may PROPOSE completion (a 🔎 review flag) but a human owns the `done` stamp. Omit this section for a quick single-session task that won't span dev logs. This is the rollup contract: dev-log evidence feeds the task's Current State, which feeds the project hub. %%
_No sessions rolled up yet._

%% Dispatch Brief — required when tags include ai-handoff or ai-pending-decision; delete this whole section for human-only tasks. A dispatch brief is self-contained: it names where the output lands (Deliverable contract), the absolute paths/repos/configs the session needs (Repo/system pointers), the open forks the agent must resolve or leave open (Decision points), and what's explicitly out of bounds (Scope boundaries). %%
## Dispatch Brief

**Deliverable contract**: {where output lands — a branch in `<repo>` / a `type: spec, status: draft` note in `Specs/` / a knowledge note in `Notes/`. Never live external state. The session must write a devlog linking this task.}

**Repo / system pointers**: {absolute paths, repos, scripts, configs the session needs — the brief is self-contained; the agent should not have to hunt}

**Decision points**: {each open fork on its own line, marked `(ask at kickoff)` or `(leave open in draft)` — write `none` if there are no forks}

**Scope boundaries**:
- In scope: {…}
- Out of scope: {explicitly close the doors — scope expansion is the #1 autonomous-agent failure}

## Dev Log

```base
filters:
  and:
    - type == "devlog"
    - tasks == "[[{{title}}]]"
views:
  - type: table
    name: Related Sessions
    order:
      - date
      - file.name
      - session_topic
    sort:
      - property: date
        direction: DESC
```
