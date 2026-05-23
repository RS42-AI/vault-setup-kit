---
id: 2026-05-23-search-then-link-note-creation
date: 2026-05-23
description: Add an explicit search-then-link Note Creation Procedure to AGENTS.md so the AI weaves new notes into the existing vault graph instead of writing disconnected, unlinked notes.
related_note: "[[2026-05-22-day-one-usable-onboarding-design]]"
also_see: "[[Vault-Setup Kit Update Cycle - Prose-Driven Structure Updates for Continuous Vault Shape Evolution]]"
---

## Context

A freshly-installed vault ships the full routing rules and all 10 note-quality rules, yet new users' notes came out with **no wikilinks**. The cause is not missing rules — it's that the linking rule is *passive*: "search before creating; link, don't duplicate." Producing a link actually requires the AI to first **search the vault to discover related notes**, then link them. In a dense, established vault this happens naturally; a fresh user's AI writes the note and skips the discovery step, so it links nothing.

This update makes search-then-link an **explicit, procedural step** in `AGENTS.md` — a four-step Note Creation Procedure — so the behavior no longer depends on the AI inferring it. This is the first behavior-changing structure update (the 2026-05-16 AGENTS.md adoption was a near-no-op for vaults that already had the file), so it is also the real-world test of the v0.2 `/update-structure` channel.

## Detection

This structure update **applies** if:

1. `AGENTS.md` exists at the vault root, AND
2. It does **not** already contain a `## Note Creation Procedure` section.

Check with: `grep -q "## Note Creation Procedure" AGENTS.md`.

- If `AGENTS.md` is missing entirely → inconsistent state; stop and ask the user to run `bash setup-vault.sh --update <vault>` first.
- If the `## Note Creation Procedure` section is already present → record as **vacuously applied** and skip.

## Changes

### File: `AGENTS.md` (edit at vault root)

**Change 1 — insert a new section.** Insert the following section immediately **after** the File Routing decision tree (the line `9. Not sure → ask the user`) and **before** `## Frontmatter Taxonomy`:

```
## Note Creation Procedure

Creating a note is a **four-step procedure**, not a one-step "write the file." The routing tree above is only step 2. The reason notes feel disconnected is almost always a skipped step 1 or step 3.

1. **Search the vault first.** Before writing, search for notes on the same or adjacent topics — keyword search for exact terms and file names, semantic/vector search when the wording may differ (see Vault Search Strategy). You are looking for two things: (a) an existing canonical note you'd be duplicating, and (b) the hub note(s) and related notes this new note should connect to.
2. **Route it.** Use the File Routing decision tree above to choose the folder and set `type` / `area` / `project`.
3. **Wikilink into the graph.** Add `[[wikilinks]]` to the related notes and hub(s) you found in step 1. If the note is a child of a hub, add a `> **Parent**: [[Hub Note]]` backlink near the top. **A new note with zero outgoing links is a smell** — it means you skipped the search, or this is genuinely the first note on a brand-new topic (rare in an established vault). Do not finalize a zero-link note without consciously confirming it's the latter.
4. **Verify uniqueness.** Confirm you're not duplicating an existing canonical note (Note Quality Rules 3 and 10). If a canonical note already exists, extend or link it instead of creating a parallel one.

This procedure applies to **every** note you create — both slash-command outputs and ad-hoc "take a note about this" moments. The vault grows correctly only if the graph is woven on the way in.
```

**Change 2 — sharpen Note Quality Rule 3.** In the `## Note Quality Rules` list, replace the line:

```
3. **One canonical note per concept** — search before creating; link, don't duplicate.
```

with:

```
3. **One canonical note per concept** — *search the vault before creating* (see Note Creation Procedure), then link, don't duplicate.
```

**Change 3 — Contents list (only if the user's `AGENTS.md` has a `## Contents` list at the top).** Add a `Note Creation Procedure` entry right after the `File Routing — Decision Tree` entry and renumber. If the user's file has no Contents list, skip this change.

**Preserve user customizations.** If the user has hand-edited their routing tree, quality rules, or added a local section, do not clobber it — insert the new section and apply Change 2 in place, leaving everything else untouched. If Rule 3's wording has been locally customized and no longer matches the expected line, show the user the intended change and ask before editing.

## Verification

After applying, all must be true:

- `grep -c "## Note Creation Procedure" AGENTS.md` returns `1`.
- `grep -q "Search the vault first" AGENTS.md` succeeds.
- `grep -q "search the vault before creating" AGENTS.md` succeeds (Rule 3 was sharpened).
- `git diff --stat` shows only `AGENTS.md` changed, and `git diff AGENTS.md` shows only the additive section + the Rule 3 line edit (+ optional Contents line) — nothing else.

If any check fails, do NOT record the update as applied. Report which check failed and stop.

## Rollback

```
git checkout AGENTS.md
```

If the vault is not a git repo, manually delete the inserted `## Note Creation Procedure` section and revert Rule 3's wording to `search before creating; link, don't duplicate.`
