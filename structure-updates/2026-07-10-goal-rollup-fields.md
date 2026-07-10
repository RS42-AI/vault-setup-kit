---
id: 2026-07-10-goal-rollup-fields
date: 2026-07-10
description: Sync the Project Hub and Goal Hub templates to the goal-rollup shape (goal_status/quarter_goal/kr frontmatter, Bug Queue/Specs/Predecessor Projects sections, reshaped Goal Hub body) and correct the goal status vocabulary.
also_see: "[[2026-07-10-agents-md-closed-enums]]"
---

## Context

[[2026-07-10-agents-md-closed-enums]] lands the *rulebook* text for the Goal Rollup Contract (`devlog → task → project hub → goal`, and the requirement that every active project hub be goal-aligned, exploratory, or intentionally unscored). This structure update lands **both ends of the chain the contract depends on** — the Project Hub Template and the Goal Hub Template — so hubs and goals actually have somewhere to write the fields the contract requires.

**Project Hub Template** gains `goal_status` / `quarter_goal` / `kr` frontmatter (alongside the existing `goal:` field) plus three new optional body sections: `## Bug Queue` (a dispatchable-defects Bases view), `## Specs` (a Bases view over the project's `type: spec` notes — see [[2026-07-10-spec-type-and-template]]), and `## Predecessor Projects` (lineage notes).

**Goal Hub Template** is reshaped to the consensus form: a `Sibling goals` / `Hierarchy` header pair under the title, a bolded one-line Objective, named KRs, new `## Why this Objective and not another` / `## Why these KRs` / `## What's intentionally NOT in this goal` sections, a `## Linked Projects — How Each Contributes` contribution table plus a goal-linked Bases query (`goal.contains(...)` instead of a bare `status == "active"` filter), a `## Quarterly checkpoints` section, and a `## Related` section.

**The goal status vocabulary is corrected.** The old frontmatter reference documented `status: active | complete | missed`. `complete` and `missed` were never valid Obsidian-safe closure terms once the `status` enum was formalized ([[2026-07-10-agents-md-closed-enums]]) — the corrected, closed vocabulary is `active | done | passed | archived`, where `done` (achieved) and `passed` (horizon expired, not fully achieved) are human-only closure stamps, matching the `task`/`spec`/`project` precedent.

## Detection

This structure update **applies** if **any** of the following is true:

1. `system-settings/Templates/Project Hub Template.md` is missing `goal_status` in its frontmatter. Check: `grep -qF 'goal_status' "system-settings/Templates/Project Hub Template.md"` — applies if this fails.
2. `system-settings/Templates/Goal Hub Template.md` still documents the old vocabulary in its frontmatter reference table. Check: `grep -q "complete" "system-settings/Templates/Goal Hub Template.md"` — applies if this succeeds (the corrected template never contains the word `complete`).
3. Any note with `type: project` and `status: active` has **neither** a non-empty `goal:` value **nor** a `goal_status:` value set (drift per the Goal Rollup Contract).

If none of the three apply → record as **vacuously applied**. On a fresh kit install: both templates already ship the new shape, and the starter `Personal/Vault-Setup/Vault-Setup.md` hub is pre-stamped `goal_status: unscored` (this catalog's own branch-fix step) — so all three arms are false, and this structure update is **vacuously applied on every fresh install**.

## Changes

### File: `system-settings/Templates/Project Hub Template.md` (sync from kit)

Diff the user's copy against the kit's canonical `vault-files/system-settings/Templates/Project Hub Template.md`. If the user's copy has local customizations (extra fields, reworded sections), merge the deltas below in place; if it's just an older copy, replace with canonical.

**Frontmatter** — add two new keys after `goal:`, and update the explanatory HTML comment:

```yaml
goal_status: scored
quarter_goal:
kr:
```

```html
<!--
goal: single wikilink to the area Goal this project serves, e.g. "[[2026-Annual]]"
goal_status: scored | discovery | unscored
quarter_goal: optional sharper current-quarter Goal wikilink, e.g. "[[2026-Q2]]"
kr: optional key-result id or label, e.g. "KR2"

An active project with empty goal and no intentional goal_status is drift under [[AGENTS#Goal Rollup Contract]].
For projects serving secondary goals, use Obsidian backlinks rather than a list field.
-->
```

**New section — `## Bug Queue`** (insert after the project's opening description, before `## Active Tasks`):

````markdown
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
````

**New section — `## Specs`** (insert after `## Active Tasks` and its surrounding sections, before `## Dev Log`):

````markdown
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
````

**New section — `## Predecessor Projects`** (insert after `## Dev Log`, before `## Related Projects`):

```markdown
## Predecessor Projects

*(Optional — lineage: what this project absorbed or replaced.)*

- [[]] — {what it was; what carried forward}
```

**Existing project hub notes are NOT backfilled.** These three sections apply to hubs created from the template going forward. Do not retroactively insert `## Bug Queue` or `## Predecessor Projects` into hubs that already exist — mirrors the no-backfill precedent in [[2026-07-10-task-template-current-state-and-brief]]. **Exception:** since [[2026-07-10-spec-type-and-template]] introduces `Specs/` folders that an existing hub would otherwise never surface, offer the `## Specs` block as a single additive edit per existing active hub — ask the user hub-by-hub before inserting it; skip on decline.

### File: `system-settings/Templates/Goal Hub Template.md` (sync from kit)

Diff the user's copy against the kit's canonical `vault-files/system-settings/Templates/Goal Hub Template.md`. If the user's copy has local customizations, merge in place; if it's just an older copy, replace with canonical. Key deltas the merge must land:

- Title line `# {Area} — {Horizon} Goal` → `# {Goal Name}`, and a header block gaining `> **Sibling goals**: [[]]` and `> **Hierarchy**: goal → project → task` under the existing `> **Area**: [[]]` line.
- `## Objective` body bolded as a one-line outcome statement (identity/position-shift framing where possible).
- `## Key Results` entries gain a `— {name}` label per KR (`**KR1 — {name}**: ...`).
- New sections `## Why this Objective and not another` and `## Why these KRs` replace the old single `## Why this Goal exists` / `## Why these KRs (not other ones)` pair, and a new `## What's intentionally NOT in this goal` section is added.
- `## Linked Projects` becomes `## Linked Projects — How Each Contributes`, gaining a contribution table (`| Project | Role | Notes |`) above the existing Bases query; the query's filter changes from `status == "active"` to `goal.contains("{{VALUE:goal note name}}")` (so it reflects goal-linkage rather than mere activity), with a reminder line: `> Set \`goal: "[[{goal note name}]]"\` on each project hub frontmatter to wire it up.`
- `## Open Tasks` and `## Recent Dev Logs` each gain an `*(Optional live view — delete if not needed.)*` annotation.
- New `## Quarterly checkpoints` section with `### Q1 (Jan–Mar)` through `### Q4 (Oct–Dec)` subheadings (annual goals: one filled per quarter at quarter boundaries; quarterly goals: mid-quarter checkpoints).
- New `## Related` section (`- [[]] — area dashboard`) added before the closing frontmatter-reference divider.
- **Frontmatter reference table correction (the vocabulary fix):** the `status` row changes from

  ```
  | `status` | `active` | `complete` | `missed` |
  ```

  to

  ```
  | `status` | `active` \| `done` (achieved) \| `passed` (horizon expired, not fully achieved) \| `archived` — `done`/`passed` are human-only stamps |
  ```

  and the `area` row's wording changes from naming a specific baseline slug to `your area slugs — see the Areas table in AGENTS.md`.

**Existing goal notes are NOT backfilled** with the new body sections (`Why this Objective and not another`, `What's intentionally NOT in this goal`, `Quarterly checkpoints`, etc.) — they keep their existing content untouched.

**The one exception that is NOT optional:** any existing goal note whose frontmatter carries the now-forbidden `status: complete` or `status: missed` must be corrected, since those values no longer exist in the closed enum. For each such note found (`grep -rl 'status: complete\|status: missed' "3. Areas"` or wherever goal notes live), show the user the note and propose the mapping — `complete` → `done`, `missed` → `passed` — and apply only on explicit per-note confirmation. Both are human closure stamps, so this is not a batchable edit even though it looks mechanical.

### Goal-wiring walk (existing project hubs, not a template edit)

For each note with `type: project` and `status: active` that has neither a `goal:` value nor a `goal_status:` value (detection arm 3), walk the user through it one hub at a time: show the area's existing goal notes and ask whether this hub should (a) link to one (`goal: "[[...]]"`), (b) be marked `goal_status: discovery` (exploratory, not yet counted), or (c) be marked `goal_status: unscored` (intentional operational work). This doc only walks the judgment — it never decides which of the three applies; if the user is unsure, leave the hub unresolved and move to the next one rather than guessing.

## Verification

After applying, all must be true:

- `system-settings/Templates/Project Hub Template.md` frontmatter contains `goal_status`, `quarter_goal`, and `kr`.
- `system-settings/Templates/Goal Hub Template.md` frontmatter reference table no longer contains `complete` or `missed`, and does contain `done` and `passed`.
- No note in the vault has `type: goal` with `status: complete` or `status: missed` remaining (`grep -rl 'type: goal' . | xargs grep -l 'status: complete\|status: missed'` returns nothing).
- No note has `type: project`, `status: active`, empty `goal:`, and no `goal_status:` (the drift state from detection arm 3) unless the user explicitly deferred it during the walk — in which case it's reported as still-open, not silently marked applied.

If any check fails, do NOT record the update as applied. Report which check failed and stop.

## Rollback

```
git checkout "system-settings/Templates/Project Hub Template.md" "system-settings/Templates/Goal Hub Template.md"
```

For per-note goal-status corrections, `git checkout` the specific goal notes that were changed (list them from the session's change log) rather than reverting the whole vault.
