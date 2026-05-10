---
date: 2026-05-09
type: area-dashboard
status: active
area: personal
tags:
  - area
  - personal
---

> [!note] Area Purpose
> Your personal life — reflections, planning, health, journaling, life projects.

This is a dashboard. It auto-populates from frontmatter properties on every other note. As you create notes with `area: personal`, they appear in the right section below.

To start using your vault, see [[Vault-Setup]] — the orientation project.

---

## Active Projects

```base
filters:
  and:
    - type == "project"
    - area == "personal"
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
    columnSize:
      file.name: 300
      note.status: 100
      note.date: 120
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
    columnSize:
      file.name: 350
      note.status: 100
      note.horizon: 120
```

Goals live at `3. Areas/Personal/Goals/{horizon}.md`.

---

## Recent Devlogs

```base
filters:
  and:
    - type == "devlog"
    - area == "personal"
views:
  - type: table
    name: Recent Devlogs
    order:
      - date
      - file.name
      - session_topic
    sort:
      - property: date
        direction: DESC
    columnSize:
      note.date: 120
      file.name: 350
      note.session_topic: 250
```

---

## Knowledge Notes

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
    columnSize:
      file.name: 400
      note.status: 100
      note.date: 120
```

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

## Journal

> Morning and evening reflections.
> Location: `5. Resources/Personal/Journal/`
