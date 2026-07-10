---
date: {{date:YYYY-MM-DD}}
type: goal
status: active
area:
period: quarterly
horizon:
tags:
  - goal
---

# {Goal Name}

> **Area**: [[]]
> **Sibling goals**: [[]]
> **Hierarchy**: goal → project → task

## Objective

**{One-sentence outcome statement — the desired state at the end of the horizon, framed as an identity/position shift where possible.}**

## Key Results

- **KR1 — {name}**: {measurable outcome that proves the Objective is being met}
- **KR2 — {name}**: {measurable outcome}
- **KR3 — {name}**: {measurable outcome}

## Why this Objective and not another

{What makes this the load-bearing goal — what alternatives were considered, and why this one wins}

## Why these KRs

{Per KR: why this measure and this number prove the Objective, vs. other measures}

## What's intentionally NOT in this goal

{Explicit exclusions — nearby work that does NOT count toward this goal}

## Linked Projects — How Each Contributes

| Project | Role | Notes |
|---|---|---|
| [[]] | {primary / platform / secondary} | |

### Auto-rendered project list

```base
filters:
  and:
    - type == "project"
    - area == "{{VALUE:area slug}}"
    - goal.contains("{{VALUE:goal note name}}")
views:
  - type: table
    name: Projects linked to this goal
    order:
      - file.name
      - status
      - project
    sort:
      - property: file.name
        direction: ASC
```

> Set `goal: "[[{goal note name}]]"` on each project hub frontmatter to wire it up.

## Open Tasks (Cross-Project, This Area)

*(Optional live view — most useful on the current-quarter goal. Delete if not needed.)*

```base
filters:
  and:
    - type == "task"
    - area == "{{VALUE:area slug}}"
    - status != "done"
views:
  - type: table
    name: Open Tasks
    order:
      - file.name
      - priority
      - status
      - due_date
      - project
    sort:
      - property: priority
        direction: ASC
      - property: due_date
        direction: ASC
```

## Recent Dev Logs

*(Optional live view — delete if not needed.)*

```base
filters:
  and:
    - type == "devlog"
    - area == "{{VALUE:area slug}}"
    - date >= "{{VALUE:horizon start YYYY-MM-DD}}"
    - date <= "{{VALUE:horizon end YYYY-MM-DD}}"
views:
  - type: table
    name: Dev Logs
    order:
      - date
      - file.name
      - session_topic
      - project
    sort:
      - property: date
        direction: DESC
```

## Quarterly checkpoints

*(Annual goals: one `###` per quarter, written at quarter boundaries. Quarterly goals: use mid-quarter checkpoints.)*

### Q1 (Jan–Mar)

### Q2 (Apr–Jun)

### Q3 (Jul–Sep)

### Q4 (Oct–Dec)

## Open

- {Outstanding decisions, dependencies, or known unknowns}

## Related

- [[]] — area dashboard

---

## Frontmatter reference

*(Template documentation — delete this section from real goal notes.)*

| Field | Values |
|---|---|
| `type` | `goal` (locked) |
| `status` | `active` \| `done` (achieved) \| `passed` (horizon expired, not fully achieved) \| `archived` — `done`/`passed` are human-only stamps |
| `area` | your area slugs — see the Areas table in AGENTS.md |
| `period` | `quarterly` \| `annual` \| `multi-year` |
| `horizon` | The actual time window — `2026-Q2`, `2026-Annual`, `2026-2028`, etc. |
