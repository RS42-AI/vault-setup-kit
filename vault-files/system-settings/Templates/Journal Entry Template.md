---
date: <% tp.date.now("YYYY-MM-DD") %>
type: journal
journal_type: morning
tags:
  - journal
habit_journaled: false
habit_exercise: false
---

%% Habits are yours to define. Add or rename `habit_*` properties above — the AI skills read whatever `habit_*` fields the entry carries (the template owns the schema; no fixed set is assumed). The two above are neutral starters. %%

# Daily Hub: [[1. Daily/<% tp.date.now("YYYY-MM-DD") %>|<% tp.date.now("YYYY-MM-DD") %>]]

### Overall Read
*(filled by /start-day)*

### Movement From Yesterday +/- 1
*(filled by /start-day)*

---

### Control Queue
*(filled by /start-day)*

### Threads To Keep Visible
*(filled by /start-day)*

#### At Risk
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
