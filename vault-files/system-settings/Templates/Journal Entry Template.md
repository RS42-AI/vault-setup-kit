---
date: <% tp.date.now("YYYY-MM-DD") %>
type: journal
journal_type: morning
tags:
  - journal
habit_workout: false
habit_meditation: false
habit_gratitude: false
habit_vitamins: false
---

# [[1. Daily/<% tp.date.now("YYYY-MM-DD") %>|<% tp.date.now("YYYY-MM-DD") %>]]

## Recent Accomplishments
*(filled by /start-day)*

### Last Night's Reflection
*(filled by /start-day)*

---

## Tasks Overview

#### To Do

```base
filters:
  and:
    - type == "task"
    - status == "todo"
views:
  - type: table
    name: To Do
    order:
      - priority
      - area
      - project
      - file.name
      - due_date
    sort:
      - property: priority
        direction: ASC
      - property: area
        direction: ASC
    filter: path != "system-settings/Templates/Task Note Template"
    columnSize:
      note.priority: 60
      note.area: 100
      note.project: 120
      file.name: 300
      note.due_date: 100
```

#### On Hold / Blocked

```base
filters:
  and:
    - type == "task"
    - status == "on-hold"
views:
  - type: table
    name: On Hold
    order:
      - priority
      - area
      - project
      - file.name
      - blocked_by
    sort:
      - property: priority
        direction: ASC
    filter: path != "system-settings/Templates/Task Note Template"
    columnSize:
      note.priority: 60
      note.area: 100
      note.project: 120
      file.name: 300
      note.blocked_by: 200
```

#### Recently Completed

```base
filters:
  and:
    - type == "task"
    - status == "done"
views:
  - type: table
    name: Completed
    order:
      - done_date
      - area
      - project
      - file.name
    sort:
      - property: done_date
        direction: DESC
    filter: path != "system-settings/Templates/Task Note Template"
    columnSize:
      note.done_date: 100
      note.area: 100
      note.project: 120
      file.name: 300
```

---

## Morning


### AI Summary
*(filled by /process-journal)*
