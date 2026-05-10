---
date: {{date:YYYY-MM-DD}}
type: project
status: active
area:
project:
tags: []
---

## Overview

{Description of the project — what it is and why it exists}

---

## Current Status

*No status update yet.*

---

## Active Tasks

```base
filters:
  and:
    - type == "task"
    - project == "{{VALUE:project slug}}"
    - status == "todo" OR status == "active"
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

## Related Projects

- [[]] — Parent area
