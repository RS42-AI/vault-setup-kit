---
date: {{date:YYYY-MM-DD}}
type: project
status: active
area:
project:
goal:
goal_status: scored
quarter_goal:
kr:
tags: []
---

<!--
goal: single wikilink to the area Goal this project serves, e.g. "[[2026-Annual]]"
goal_status: scored | discovery | unscored
quarter_goal: optional sharper current-quarter Goal wikilink, e.g. "[[2026-Q2]]"
kr: optional key-result id or label, e.g. "KR2"

An active project with empty goal and no intentional goal_status is drift under [[AGENTS#Goal Rollup Contract]].
For projects serving secondary goals, use Obsidian backlinks rather than a list field.
-->


## Overview

{Description of the project — what it is and why it exists}

---

## Current Status

<!-- Refreshed by /project-sync -->

*No status update yet — run `/project-sync` to populate.*

---

## Bug Queue

Dispatchable defects — each entry is a `type: task` note tagged `bug` carrying a repro, a fix direction, and (when ready for autonomous handoff) a Dispatch Brief. *(Optional section — remove if this project doesn't track bugs.)*

```base
filters:
  and:
    - type == "task"
    - project == "{{VALUE:project slug}}"
    - file.hasTag("bug")
    - or:
        - status == "todo"
        - status == "active"
views:
  - type: table
    name: Bug Queue
    order:
      - priority
      - file.name
      - status
    sort:
      - property: priority
        direction: ASC
    filter: path != "system-settings/Templates/Task Note Template"
    columnSize:
      file.name: 300
      note.status: 100
      note.priority: 80
```

---

## Active Tasks

```base
filters:
  and:
    - type == "task"
    - project == "{{VALUE:project slug}}"
    - or:
        - status == "todo"
        - status == "active"
views:
  - type: table
    name: Active Tasks
    order:
      - file.name
      - status
      - priority
      - due_date
    sort:
      - property: priority
        direction: ASC
      - property: date
        direction: DESC
    filter: path != "system-settings/Templates/Task Note Template"
    columnSize:
      file.name: 300
      note.status: 100
      note.priority: 80
      note.due_date: 100
```

---

## On Hold

```base
filters:
  and:
    - type == "task"
    - project == "{{VALUE:project slug}}"
    - status == "on-hold"
views:
  - type: table
    name: On Hold
    order:
      - file.name
      - blocked_by
      - date
    sort:
      - property: date
        direction: DESC
    filter: path != "system-settings/Templates/Task Note Template"
    columnSize:
      file.name: 300
      note.blocked_by: 200
      note.date: 120
```

---

## Completed Tasks

```base
filters:
  and:
    - type == "task"
    - project == "{{VALUE:project slug}}"
    - status == "done"
views:
  - type: table
    name: Completed Tasks
    order:
      - file.name
      - done_date
      - date
    sort:
      - property: done_date
        direction: DESC
    filter: path != "system-settings/Templates/Task Note Template"
    columnSize:
      file.name: 300
      note.done_date: 120
      note.date: 120
```

---

## Resources

```base
filters:
  and:
    - type == "resource"
    - project == "{{VALUE:project slug}}"
views:
  - type: table
    name: Resources
    order:
      - file.name
      - status
      - date
    sort:
      - property: date
        direction: DESC
    columnSize:
      file.name: 400
      note.status: 120
      note.date: 120
```

---

## Knowledge Notes

```base
filters:
  and:
    - type == "note"
    - project == "{{VALUE:project slug}}"
views:
  - type: table
    name: Knowledge Notes
    order:
      - file.name
      - status
      - date
    sort:
      - property: date
        direction: DESC
    columnSize:
      file.name: 400
      note.status: 120
      note.date: 120
```

---

## Specs

```base
filters:
  and:
    - type == "spec"
    - project == "{{VALUE:project slug}}"
views:
  - type: table
    name: Specs
    order:
      - file.name
      - status
      - date
    sort:
      - property: status
        direction: ASC
      - property: date
        direction: DESC
    columnSize:
      file.name: 400
      note.status: 120
      note.date: 120
```

---

## Dev Log

```base
filters:
  and:
    - type == "devlog"
    - project == "{{VALUE:project slug}}"
views:
  - type: table
    name: Development Sessions
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

## Meetings

```base
filters:
  and:
    - type == "meeting"
    - project == "{{VALUE:project slug}}"
views:
  - type: table
    name: Meetings
    order:
      - date
      - file.name
    sort:
      - property: date
        direction: DESC
    columnSize:
      note.date: 120
      file.name: 500
```

---

## Predecessor Projects

*(Optional — lineage: what this project absorbed or replaced.)*

- [[]] — {what it was; what carried forward}

---

## Related Projects

- [[]] — Parent area
