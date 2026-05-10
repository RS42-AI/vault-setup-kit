---
date: <% tp.date.now("YYYY-MM-DD") %>
type: daily
tags:
  - daily
---

# <% tp.date.now("dddd, MMMM D") %>

> [[1. Daily/<% tp.date.now("YYYY-MM-DD", -1) %>|← Yesterday]] | [[1. Daily/<% tp.date.now("YYYY-MM-DD", 1) %>|Tomorrow →]]

---
## Morning Journal

> [[5. Resources/Personal/Journal/Morning Entries/<% tp.date.now("YYYY-MM-DD") %>|Open Morning Entry]]

**Today's priorities:**
- [ ] ...

---

## Active Work

```base
filters:
  and:
    - type == "task"
    - status == "active"
views:
  - type: table
    name: Active Work
    order:
      - file.name
      - project
      - priority
    sort:
      - property: priority
        direction: ASC
    columnSize:
      file.name: 350
      note.project: 130
      note.priority: 80
```

---

## Today's Meetings

```base
filters:
  and:
    - type == "meeting"
    - date == "<% tp.date.now("YYYY-MM-DD") %>"
views:
  - type: table
    name: Meetings
    order:
      - file.name
    sort:
      - property: file.name
        direction: ASC
    columnSize:
      file.name: 500
```

---

## Notes Created Today

```base
filters:
  and:
    - date == "<% tp.date.now("YYYY-MM-DD") %>"
    - type != "meeting"
    - type != "daily"
    - type != "journal"
    - type != "task"
views:
  - type: table
    name: Notes
    order:
      - file.name
      - area
      - project
    sort:
      - property: file.name
        direction: ASC
    columnSize:
      file.name: 400
      note.area: 120
      note.project: 120
```

---
## Evening Reflection

> [[5. Resources/Personal/Journal/Evening Entries/<% tp.date.now("YYYY-MM-DD") %>|Open Evening Entry]]
