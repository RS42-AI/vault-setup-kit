---
date: {{date:YYYY-MM-DD}}
type: task
status: todo
area:
project:
priority: p3
due_date: ""
scheduled_date: ""
done_date: ""
blocked_by: []
blocked_reason: ""
unlocks: []
external_id: ""
tags:
  - task
---

# {{title}}

> **Project**: [[]]

{Description — what needs to be done and why}

## Dev Log

```base
filters:
  and:
    - type == "devlog"
    - tasks == "[[{{title}}]]"
views:
  - type: table
    name: Related Sessions
    order:
      - date
      - file.name
      - session_topic
    sort:
      - property: date
        direction: DESC
```
