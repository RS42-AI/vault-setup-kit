---
id: 2026-07-12-morning-brief-and-evening-entry
date: 2026-07-12
description: Rename the user-facing morning workflow to Morning Brief, make morning and evening reflection optional, and move completion tracking into frontmatter-only system fields.
---

## Context

The daily loop is an executive operating rhythm, not a prescribed journaling program. `/start-day` prepares a useful Morning Brief from work evidence and current commitments. A person may optionally add spoken or written context and run `/process-morning`. `/prep-evening` prepares an Evening Entry; reflection is optional and stays free-form.

Earlier templates exposed generic habit checkboxes and prescribed reflection prompts in the page body. Even generic prompts can become awkward or private when a vault is shared with interns or collaborators. The revised templates expose no personal habit, gratitude, or journaling requirement. They keep `type: journal`, `journal_type`, the existing template filenames, and the `Journal/` storage paths only for backward compatibility.

## Detection

This update **applies** when any of these are true:

- `system-settings/Templates/Daily Note Hub Template.md` does not contain `## Morning Brief`.
- `system-settings/Templates/Journal Entry Template.md` does not contain `habit_morning_brief: false` or still references `/process-journal`.
- `system-settings/Templates/Evening Journal Template.md` does not contain `habit_evening_reflection: false`, or still contains `## Evening Habits`, `## Context`, `## Reflection`, a gratitude list, or prescribed improvement prompts.

A fresh install already has the new shape, so this update is vacuously applied there. If any required template is missing, stop and run `bash setup-vault.sh --update <vault>` before applying the structural changes.

## Changes

### File: `system-settings/Templates/Journal Entry Template.md` (edit)

Diff the user's copy against the kit's canonical template and preserve deliberate custom briefing sections. In frontmatter, add the system-owned field:

```yaml
habit_morning_brief: false
```

Remove starter personal habit fields supplied by an older kit. User-created `habit_*` fields may remain. Change `/process-journal` references to `/process-morning`, describe the person's morning input as optional, and do not rename the technical `type: journal`, `journal_type: morning`, or storage path.

### File: `system-settings/Templates/Evening Journal Template.md` (edit)

Add the system-owned field:

```yaml
habit_evening_reflection: false
```

Remove the body-level `## Evening Habits`, `## Context`, and `## Reflection` scaffold and all prescribed questions or gratitude counts. Preserve user-created frontmatter habits. Use this body shape:

```markdown
### Today's Accomplishments
*(filled by /prep-evening)*

### Tomorrow Preview
*(filled by /prep-evening)*

### Wind Down
*(filled by /prep-evening)*

---

## Evening

%% Optional free-form human input. %%

### AI Summary
*(filled by /process-evening when input exists)*

---

###### Still Open
*(filled by /prep-evening)*
```

`/process-evening` sets `habit_evening_reflection: true` only when it processes a non-empty human entry. It does not infer or update any other habit field.

### File: `system-settings/Templates/Daily Note Hub Template.md` (edit)

Rename the visible `## Morning Journal` section to `## Morning Brief`, change its link label to `Open Morning Brief`, and rename `## Evening Reflection` to `## Evening`. Keep the underlying wikilink targets unchanged for compatibility.

### Historical records and legacy compatibility

Do not rewrite existing daily notes or entries. Skills may recognize the legacy `## Morning Journal` and `## Reflection` headings when processing old files, but they must not create those headings in new files. The internal `ensure_journal.sh` filename and `journal` type/path remain valid compatibility details.

## Verification

After applying, all must be true:

- The Daily Note Hub template contains `## Morning Brief` and `Open Morning Brief`, with no `## Morning Journal` or `## Evening Reflection` heading.
- The morning template contains `habit_morning_brief: false` and `/process-morning`.
- The evening template contains `habit_evening_reflection: false`, one `## Evening` section, and a nested `### AI Summary`.
- The evening template contains no body habit checklist, `## Context`, `## Reflection`, prescribed what-went-well/improvement prompt, or required gratitude list.
- No existing file under `1. Daily/` or `5. Resources/*/Journal/` was modified.

If any check fails, do not record the update as applied. Report the failed check and leave the historical files untouched.

## Rollback

Restore the three templates from the commit immediately before this update, or run:

```bash
git checkout -- "system-settings/Templates/Journal Entry Template.md" \
  "system-settings/Templates/Evening Journal Template.md" \
  "system-settings/Templates/Daily Note Hub Template.md"
```

Rollback changes templates only; historical entries remain untouched in either direction.
