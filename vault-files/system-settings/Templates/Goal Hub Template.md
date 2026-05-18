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

# {Area} — {Horizon} Goal

> **Area**: [[]]

## Objective

{One-sentence outcome statement. What is the desired state at the end of the horizon?}

## Key Results

- **KR1** — {measurable outcome that proves the Objective is being met}
- **KR2** — {measurable outcome}
- **KR3** — {measurable outcome}

## Linked Projects

```base
filters:
  and:
    - type == "project"
    - area == "{{VALUE:area slug}}"
    - status == "active"
views:
  - type: table
    name: Active Projects
    order:
      - file.name
      - status
      - date
    sort:
      - property: date
        direction: DESC
```

## Open Tasks (Cross-Project, This Area)

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

## Why this Goal exists

{Context: what's driving this Objective? What constraint or opportunity is it responding to?}

## Why these KRs (not other ones)

- **KR1** — {why this measure proves the objective}
- **KR2** — {why this measure}
- **KR3** — {why this measure}

## Open

- {Outstanding decisions, dependencies, or known unknowns}

---

## Frontmatter reference

| Field | Values |
|---|---|
| `type` | `goal` (locked) |
| `status` | `active` \| `complete` \| `missed` |
| `area` | One of the slugs from the Areas table in `AGENTS.md` (baseline ships only `personal`) |
| `period` | `quarterly` \| `annual` \| `multi-year` |
| `horizon` | The actual time window — `2026-Q2`, `2026-Annual`, `2026-2028`, etc. |
