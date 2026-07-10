---
id: 2026-07-10-journal-daily-cockpit-shape
date: 2026-07-10
description: Reshape the Journal Entry Template's morning header into a cockpit (Daily Hub title, Overall Read, Movement, Control Queue, Threads To Keep Visible, At Risk) and land two small Daily Note Hub Template cleanups.
---

## Context

The morning `## Recent Accomplishments` / `### Last Night's Reflection` header on the Journal Entry Template was a two-field summary. `/start-day` now writes a richer cockpit instead: an "Overall Read" of where things stand, "Movement From Yesterday +/- 1" (what actually changed), a "Control Queue" (what needs the human's attention now), "Threads To Keep Visible" (open loops that shouldn't silently drop), and an "At Risk" callout. The page title also changes from a bare date link to an explicit `Daily Hub:` label, matching how the daily note itself is described elsewhere in the vault.

Two small, unrelated cleanups ride along in the Daily Note Hub Template in the same kit sync: the `## Active Work` Bases block drops a stale `filter: path != ".../Task Note Template"` line that Active Work's own filters already made redundant (an active-work view can't match the template file, which carries `status: active` only as a placeholder, not by design — the extra filter was leftover caution), and the `## Notes Created Today` block gains a one-line `%%` comment documenting how to exclude an area from that view.

## Detection

This structure update **applies** if `system-settings/Templates/Journal Entry Template.md` exists and does **not** contain a `### Overall Read` heading.

Check with: `grep -q "### Overall Read" "system-settings/Templates/Journal Entry Template.md"` — applies if this fails.

- If the template doesn't exist → inconsistent state; stop and ask the user to run `bash setup-vault.sh --update <vault>` first.
- If `### Overall Read` is already present → record as **vacuously applied** and skip.
- A fresh kit install ships the template with the cockpit shape already in place, so this structure update is **vacuously applied on every fresh install**.

## Changes

### File: `system-settings/Templates/Journal Entry Template.md` (edit)

Diff the user's copy against the kit's canonical `vault-files/system-settings/Templates/Journal Entry Template.md`. If customized, apply the two changes below at their anchors; if it's just an older copy, replace with canonical.

**Change 1 — title line.** Replace:

```
# [[1. Daily/<% tp.date.now("YYYY-MM-DD") %>|<% tp.date.now("YYYY-MM-DD") %>]]
```

with:

```
# Daily Hub: [[1. Daily/<% tp.date.now("YYYY-MM-DD") %>|<% tp.date.now("YYYY-MM-DD") %>]]
```

**Change 2 — cockpit sections.** Replace the block:

```
## Recent Accomplishments
*(filled by /start-day)*

### Last Night's Reflection
*(filled by /start-day)*
```

with:

```
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
```

**Past journal entries are historical records — never rewritten.** This structure update only changes the *template*. Every journal entry already written under `5. Resources/{Area}/Journal/` keeps its original header shape exactly as `/process-journal` and `/start-day` left it at the time. Do not walk existing journal entries to retrofit the cockpit shape — there is no backfill step for this doc.

### File: `system-settings/Templates/Daily Note Hub Template.md` (edit)

Diff the user's copy against the kit's canonical `vault-files/system-settings/Templates/Daily Note Hub Template.md`. Two independent, additive-safe deltas:

**Change 1 — drop the stale filter line** from the `## Active Work` Bases block. Remove this line from that block's `filters:`/query body (it sits directly under the `sort:` clause, above `columnSize:`):

```
    filter: path != "system-settings/Templates/Task Note Template"
```

**Change 2 — add the exclusion-comment.** Insert immediately above the `## Notes Created Today` block's ` ```base ` fence:

```
%% To exclude an area from this view, add a line: - area != "<slug>" %%
```

**Existing daily-hub notes are NOT backfilled.** Like the journal template, this only changes the *template* used for future daily hubs — already-created daily notes (`1. Daily/YYYY-MM-DD.md`) are left exactly as they are.

## Verification

After applying, all must be true:

- `system-settings/Templates/Journal Entry Template.md` contains `# Daily Hub:` and `### Overall Read`, and no longer contains `## Recent Accomplishments`.
- `system-settings/Templates/Daily Note Hub Template.md`'s `## Active Work` block no longer contains the `filter: path != ".../Task Note Template"` line, and the file contains the new `%%` comment above `## Notes Created Today`.
- No existing file under `1. Daily/` or any `Journal/` folder was modified (`git diff --stat` touches only the two template files).

If any check fails, do NOT record the update as applied. Report which check failed and stop.

## Rollback

```
git checkout "system-settings/Templates/Journal Entry Template.md" "system-settings/Templates/Daily Note Hub Template.md"
```
