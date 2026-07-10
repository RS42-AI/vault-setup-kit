---
id: 2026-07-10-task-template-current-state-and-brief
date: 2026-07-10
description: Add the Current State rollup section and the conditional Dispatch Brief section to the Task Note Template, so tasks can carry rolled-up status and self-contained autonomous-handoff instructions.
---

## Context

Task notes used to go straight from a one-line description to the `## Dev Log` Bases view — there was no place on the task itself to hold a human-readable rollup of "where this stands now" (readers had to open every linked dev log), and no standard shape for handing a task off to an autonomous agent session.

Two additive sections close both gaps:

- **`## Current State`** — a short, freshness-stamped rollup of the task's status, meant to be refreshed from the linked dev logs (by a rollup pass or by hand). It may propose completion but a human owns the `done` stamp — consistent with the closed `status` enum's "done is human-only" rule.
- **`## Dispatch Brief`** — a self-contained handoff brief (Deliverable contract / Repo-system pointers / Decision points / Scope boundaries), required only when the task is tagged `ai-handoff` or `ai-pending-decision`; deleted entirely for human-only tasks.

Both sections ship wrapped in `%% ... %%` Obsidian comments explaining their own contract, so they double as inline documentation once copied into a real task note.

## Detection

This structure update **applies** if `system-settings/Templates/Task Note Template.md` exists and does **not** contain a `## Current State` heading.

Check with: `grep -q "## Current State" "system-settings/Templates/Task Note Template.md"` — applies if this fails.

- If the template doesn't exist at all → inconsistent state (a vault with no task template predates this kit's baseline); stop and ask the user to run `bash setup-vault.sh --update <vault>` first.
- If `## Current State` is already present → record as **vacuously applied** and skip.
- A fresh kit install ships the template with both sections already in place, so this structure update is **vacuously applied on every fresh install**.

## Changes

### File: `system-settings/Templates/Task Note Template.md` (edit)

Diff the user's copy against the kit's canonical `vault-files/system-settings/Templates/Task Note Template.md`. If the user's copy is customized, insert the two sections below at the anchor described; if it's just an older copy, replace with canonical.

**Insert** the following, immediately after the task's opening description line (`{Description — what needs to be done and why}`) and before `## Dev Log`:

````markdown
## Current State

%% A short "where this stands now", rolled up from the linked dev logs below and freshness-stamped (`*Rolled up from dev logs · as of YYYY-MM-DD*`). Refreshed by the task rollup pass or by hand — not a static field. The rollup may PROPOSE completion (a 🔎 review flag) but a human owns the `done` stamp. Omit this section for a quick single-session task that won't span dev logs. This is the rollup contract: dev-log evidence feeds the task's Current State, which feeds the project hub. %%
_No sessions rolled up yet._

%% Dispatch Brief — required when tags include ai-handoff or ai-pending-decision; delete this whole section for human-only tasks. A dispatch brief is self-contained: it names where the output lands (Deliverable contract), the absolute paths/repos/configs the session needs (Repo/system pointers), the open forks the agent must resolve or leave open (Decision points), and what's explicitly out of bounds (Scope boundaries). %%
## Dispatch Brief

**Deliverable contract**: {where output lands — a branch in `<repo>` / a `type: spec, status: draft` note in `Specs/` / a knowledge note in `Notes/`. Never live external state. The session must write a devlog linking this task.}

**Repo / system pointers**: {absolute paths, repos, scripts, configs the session needs — the brief is self-contained; the agent should not have to hunt}

**Decision points**: {each open fork on its own line, marked `(ask at kickoff)` or `(leave open in draft)` — write `none` if there are no forks}

**Scope boundaries**:
- In scope: {…}
- Out of scope: {explicitly close the doors — scope expansion is the #1 autonomous-agent failure}
````

**Preserve user customizations.** If the user has added their own fields or sections to the template (e.g. a personal `## Notes` block, extra frontmatter), leave them untouched — this is an insertion at a named anchor, not a file replace.

**Existing task notes are NOT backfilled.** This structure update only changes the *template*. Task notes already created from the old template keep their current shape — do not retroactively insert `## Current State` or `## Dispatch Brief` into them. The new sections apply to tasks created after this structure update runs. (A user who wants a specific existing task upgraded can copy the section manually; that's a one-off editorial choice, not something this structure update automates.)

## Verification

After applying, all must be true:

- `system-settings/Templates/Task Note Template.md` contains `## Current State`.
- It also contains `## Dispatch Brief`.
- `git diff --stat` shows only `system-settings/Templates/Task Note Template.md` changed — no existing task note under any `Tasks/` folder was touched.

If any check fails, do NOT record the update as applied. Report which check failed and stop.

## Rollback

```
git checkout "system-settings/Templates/Task Note Template.md"
```

If the vault is not a git repo, manually delete the `## Current State` and `## Dispatch Brief` sections (and their `%% ... %%` comments) from the template, restoring the direct jump from the description line to `## Dev Log`.
