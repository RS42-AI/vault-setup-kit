---
id: 2026-07-10-spec-type-and-template
date: 2026-07-10
description: Add the spec note type and Spec Template so design docs get a canonical home in {Project}/Specs/ instead of drifting into Notes/ or ad-hoc files.
also_see: "[[2026-07-10-agents-md-closed-enums]]"
---

## Context

Design/architecture write-ups for a project used to have no dedicated home — they landed in `{Project}/Notes/` as `type: note`, indistinguishable from ordinary working notes, or as standalone files outside the routing scheme entirely. This structure update adds a fourth kind of project artifact alongside tasks, notes, and dev logs: `type: spec`, routed to `{Project}/Specs/`, for the purposeful design-document shape (Purpose / Scope / Architecture / Decisions Made / Open Questions) that a plan or a Dispatch Brief can consume.

This is purely **additive** — a new template and a new routing rule. It does not touch any existing note. [[2026-07-10-agents-md-closed-enums]] is what actually adds `spec` to the `AGENTS.md` closed `type` list and the `6b` routing rule; this structure update is what makes that rule executable by shipping the template it points to. Apply this one either alongside or after that one — order between the two doesn't matter for correctness, though the AGENTS.md doc explains the routing rule this template exists to serve.

## Detection

This structure update **applies** if `system-settings/Templates/Spec Template.md` does not exist.

Check with: `test -f "system-settings/Templates/Spec Template.md"` — applies if this fails (file absent).

- If the file already exists → record as **vacuously applied** and skip, regardless of its exact contents (don't clobber a user's customized spec template — see Changes).
- A fresh kit install ships `vault-files/system-settings/Templates/Spec Template.md` directly, so this structure update is **vacuously applied on every fresh install**.

## Changes

### File: `system-settings/Templates/Spec Template.md` (new file)

Copy verbatim from the kit's canonical copy: `cp "$(cat .vault-kit-path)/vault-files/system-settings/Templates/Spec Template.md" "system-settings/Templates/Spec Template.md"`. If for some reason the kit copy is unavailable, create it with this content:

````markdown
---
date: {{date}}
type: spec
status: draft
area: 
project: 
---

# [Topic] — Design Spec

**Date**: {{date}}
**Status**: Draft (pending review)
**Owner**: 
**Related tasks**: 
**Related notes**: 

## Purpose

*One paragraph: what is this design for, what problem does it solve, what observable change does it produce in the system or workflow.*

## Scope

**In scope:**
- 

**Out of scope (explicit non-goals):**
- 

## Non-Functional Constraints

*Performance, idempotency, backward-compatibility, read-only invariants, security, anything that constrains HOW the work is done independently of WHAT it does.*

- 

---

## Architecture

*The chosen approach. Diagrams, pipelines, data flow, file layout. Concrete enough that a planner can decompose it.*

## Decisions Made

*Key choices locked during brainstorming. Each: what was decided, what was rejected, why. These are the points a future reader will want to know didn't get re-litigated.*

- **[Decision]:** [What was chosen] — chosen over [alternative] because [reason].

## Open Questions

*Things that don't block planning but should be answered eventually. Number them so they can be referenced in the plan.*

1. 

## Related

- 

---

## Status Lifecycle Reference

| Status | Meaning |
|---|---|
| `draft` | Still iterating with the human |
| `in-review` | Locked design; under spec-reviewer / human review |
| `active` | Approved; implementation in progress |
| `done` | Implemented and merged — **human-stamped only** |
| `on-hold` | Paused |
| `superseded` | Replaced by a newer spec (see `superseded_by:`) |
| `archived` | Decided not to do |
````

If the file already exists (a user may have added it by hand before this catalog caught up), do not overwrite it — show the diff against canonical and ask before touching anything.

### Folder: `{Project}/Specs/` (created on demand)

No folder needs to be pre-created. The routing rule (`6b` in `AGENTS.md`'s File Routing decision tree, landed by [[2026-07-10-agents-md-closed-enums]]) sends new design specs to `{Project}/Specs/`; Obsidian creates the folder the first time a note is saved there. Do not batch-create empty `Specs/` folders across every existing project — that's clutter with no content.

This is additive only — no existing project, note, or template is modified by this structure update.

## Verification

After applying, all must be true:

- `system-settings/Templates/Spec Template.md` exists.
- Its frontmatter contains `type: spec` and `status: draft`.
- No other file in the vault was changed (`git diff --stat` shows only the one new file).

If any check fails, do NOT record the update as applied. Report which check failed and stop.

## Rollback

```
rm "system-settings/Templates/Spec Template.md"
```

If the vault is a git repo and the file was tracked, `git checkout` restores the prior state (its absence) after `git rm`.
