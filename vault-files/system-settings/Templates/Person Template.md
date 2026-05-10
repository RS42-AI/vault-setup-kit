---
type: person
tags:
organization:
role:
relationship: new
---
## Meeting History
```base
filters:
  and:
    - file.inFolder("4. Contacts/Meetings")
    - attendees.contains(link(this.file.name))
views:
  - type: table
    name: Meeting History
    order:
      - date
      - file.name
      - source
    sort:
      - property: date
        direction: DESC
```

## Context


## Open Commitments


## Notes

