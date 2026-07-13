---
date: 2026-05-09
type: area-dashboard
status: active
area: personal
tags:
  - area
  - personal
---

# Personal Dashboard

#### AI Summary:

<!-- area-sync: pending first run -->

_Not yet generated — run `/area-sync personal` to populate the area pulse._

> [!note] Area Purpose
> Your personal life — planning, health, life projects, and optional reflection.

This dashboard auto-populates from the `area: personal` field on other notes. To start using the vault, open [[Vault-Setup]].

---

## Ideas

```base
filters:
  and:
    - type == "idea"
    - area == "personal"
views:
  - type: table
    name: Personal Ideas
    order:
      - file.name
      - status
      - date
    sort:
      - property: date
        direction: DESC
```

---

## Goals

```base
filters:
  and:
    - type == "goal"
    - area == "personal"
views:
  - type: table
    name: Personal Goals
    order:
      - file.name
      - status
      - horizon
      - date
    sort:
      - property: status
        direction: ASC
```

Goals live at `3. Areas/Personal/Goals/{horizon}.md`.

---

## Projects

```base
filters:
  and:
    - type == "project"
    - area == "personal"
views:
  - type: table
    name: Personal Projects
    order:
      - file.name
      - status
      - date
    sort:
      - property: status
        direction: ASC
```

---

## Active Tasks

```base
filters:
  and:
    - type == "task"
    - area == "personal"
    - status == "todo" OR status == "active"
views:
  - type: table
    name: Personal Tasks
    order:
      - file.name
      - status
      - priority
      - due_date
    sort:
      - property: priority
        direction: ASC
    filter: path != "system-settings/Templates/Task Note Template"
```

---

## Notes

```base
filters:
  and:
    - type == "note"
    - area == "personal"
views:
  - type: table
    name: Personal Notes
    order:
      - file.name
      - status
      - date
    sort:
      - property: date
        direction: DESC
```

---

## Resources

```base
filters:
  and:
    - type == "resource"
    - area == "personal"
views:
  - type: table
    name: Personal Resources
    order:
      - file.name
      - date
    sort:
      - property: date
        direction: DESC
```

---

## Dev Logs

```base
filters:
  and:
    - type == "devlog"
    - area == "personal"
views:
  - type: table
    name: Personal Dev Logs
    order:
      - date
      - file.name
      - session_topic
    sort:
      - property: date
        direction: DESC
```

---

## Reflections

Morning Briefs and optional Evening Entries live in `5. Resources/Personal/Journal/`. Reflection is available, neutral, and never required.

---

## Related Areas

- Add links here when you create another area that overlaps with personal planning.
