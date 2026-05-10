---
date: {{date:YYYY-MM-DD}}
type: area-dashboard
status: active
area:
tags:
  - area
---

> [!note] Area Purpose
> **Standard to Maintain**: {Describe the ongoing standard or responsibility this area represents}

---

## Ideas

```base
filters:
  and:
    - type == "idea"
    - area == "{{VALUE:area slug}}"
views:
  - type: table
    name: Ideas
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
    - area == "{{VALUE:area slug}}"
views:
  - type: table
    name: Goals
    order:
      - file.name
      - status
      - date
    sort:
      - property: status
        direction: ASC
```

---

## Projects

```base
filters:
  and:
    - type == "project"
    - area == "{{VALUE:area slug}}"
views:
  - type: table
    name: Projects
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
    - area == "{{VALUE:area slug}}"
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
    filter: path != "system-settings/Templates/Task Note Template"
```

---

## Notes

```base
filters:
  and:
    - type == "note"
    - area == "{{VALUE:area slug}}"
views:
  - type: table
    name: Notes
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
    - area == "{{VALUE:area slug}}"
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
```

---

## Dev Logs

```base
filters:
  and:
    - type == "devlog"
    - area == "{{VALUE:area slug}}"
views:
  - type: table
    name: Dev Logs
    order:
      - date
      - file.name
      - session_topic
    sort:
      - property: date
        direction: DESC
```

---

## Meetings

```base
filters:
  and:
    - type == "meeting"
    - area == "{{VALUE:area slug}}"
views:
  - type: table
    name: Meetings
    order:
      - date
      - file.name
    sort:
      - property: date
        direction: DESC
```

---

## Related Areas

- [[]] — 
