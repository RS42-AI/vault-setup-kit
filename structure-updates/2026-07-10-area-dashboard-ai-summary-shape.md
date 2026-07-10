---
id: 2026-07-10-area-dashboard-ai-summary-shape
date: 2026-07-10
description: Add a title line and an AI Summary block to the top of the Area Dashboard Template, populated by /area-sync, plus a minor Active Tasks filter simplification and an optional Reflections section.
---

## Context

Area dashboards used to open straight into the `> [!note] Area Purpose` callout — there was no page title and no place for a machine-generated pulse of the area. This structure update adds a title line (`# {{title}} Dashboard`) and, immediately below it, an `#### AI Summary:` block that `/area-sync` populates on each run (a `<!-- area-sync: pending first run -->` marker plus placeholder text until the first run). Two smaller changes ride along in the same template file: the Active Tasks Bases query's status filter is simplified from a nested `or:` block to an inline `OR` (equivalent behavior, terser syntax), and an optional `## Reflections` section is added near the bottom for area dashboards that track reflective/diary-style entries.

## Detection

This structure update **applies** if `system-settings/Templates/Area Dashboard Template.md` exists and does **not** contain an `#### AI Summary:` heading.

Check with: `grep -q "#### AI Summary:" "system-settings/Templates/Area Dashboard Template.md"` — applies if this fails.

- If the template doesn't exist → inconsistent state; stop and ask the user to run `bash setup-vault.sh --update <vault>` first.
- If `#### AI Summary:` is already present → record as **vacuously applied** and skip.
- A fresh kit install ships the template with the block already in place, so this structure update is **vacuously applied on every fresh install**.

## Changes

### File: `system-settings/Templates/Area Dashboard Template.md` (edit)

Diff the user's copy against the kit's canonical `vault-files/system-settings/Templates/Area Dashboard Template.md`. If customized, insert the block below at the anchor described; if it's just an older copy, replace with canonical.

**Insert** the following immediately after the frontmatter's closing `---` and before the existing `> [!note] Area Purpose` callout:

````markdown
# {{title}} Dashboard

#### AI Summary:

<!-- area-sync: pending first run -->

_Not yet generated — run `/area-sync <area>` to populate the area pulse._
````

**Simplify the Active Tasks filter** (cosmetic — same matching behavior). Replace:

```yaml
    - or:
        - status == "todo"
        - status == "active"
```

with:

```yaml
    - status == "todo" OR status == "active"
```

**Add the optional Reflections section.** Insert, near the bottom of the template (after the existing content, before `## Related Areas`):

```markdown
## Reflections

*(Optional — used by area dashboards that track reflective/diary-style entries; delete elsewhere.)*

---
```

### Existing area dashboards (each instance, not just the template)

For **every existing area dashboard note** (`type: area-dashboard`), add the title line + AI Summary block at the top, above whatever content the dashboard already has. This is purely additive and batchable — it doesn't touch any existing section, so it can be applied to all area dashboards in one pass without per-dashboard confirmation (though the user should be shown the list of dashboards being touched before proceeding). The Active Tasks filter simplification and the optional Reflections section are **template-only** — do not propagate those into existing dashboard instances (the filter change is behaviorally identical, and Reflections is opt-in per dashboard).

## Verification

After applying, all must be true:

- `system-settings/Templates/Area Dashboard Template.md` contains `# {{title}} Dashboard` and `#### AI Summary:`.
- Every existing `type: area-dashboard` note now has an `#### AI Summary:` block at its top.
- No area dashboard's pre-existing content (Area Purpose, Ideas, Active Tasks, etc.) was altered — only prepended to.

If any check fails, do NOT record the update as applied. Report which check failed and stop.

## Rollback

```
git checkout "system-settings/Templates/Area Dashboard Template.md"
```

For existing dashboards that were edited, `git checkout` the specific files that were changed (list them from the session's change log) to remove the prepended title/AI Summary block.
