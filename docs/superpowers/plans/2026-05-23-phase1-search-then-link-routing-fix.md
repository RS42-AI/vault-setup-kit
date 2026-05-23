# Phase 1 — Search-Then-Link Routing Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make a freshly-onboarded user's AI wikilink new notes into the existing vault graph by adding an explicit, procedural search-then-link step to the kit's `AGENTS.md`, and ship it to already-installed users (mom, sister) via a `/update-structure` prose doc.

**Architecture:** Two coordinated deliverables. (1) Add a new **Note Creation Procedure** section to `vault-files/AGENTS.md` that makes "search the vault → route → wikilink into hubs → verify uniqueness" an explicit four-step procedure, and sharpen passive Note Quality Rule 3 to point at it. New users get this directly via `setup.sh`. (2) Because `setup-vault.sh --update` copies `AGENTS.md` **non-clobber** (existing users already have the file, so the copy is skipped for them), the *only* delivery channel to mom/sister is a self-contained `structure-updates/` prose doc carrying the exact insert text — authored in the established 2026-05-16 pattern and applied through `/update-structure`.

**Tech Stack:** Markdown (vault instruction files + prose structure-update docs), Bash (`setup-vault.sh`, existing `bats` test harness in `test/harness.bats`).

---

## Scope

This plan implements **Phase 1 only** of [[2026-05-22-day-one-usable-onboarding-design]] (`docs` path: `Vault-Setup/Specs/2026-05-22-day-one-usable-onboarding-design.md`). Phase 2 (plugin bundling) and Phase 3 (onboarding self-test) are independently shippable per the spec's phase-independence constraint and get their own plans. Do not expand scope into them.

## Root Cause (settled — do not re-diagnose)

From the 2026-05-23 diagnosis devlog: the kit's `AGENTS.md` **already** contains the routing tree, taxonomy, and all 10 quality rules. Notes come out unlinked because the linking rule is **passive** — Rule 3: *"search before creating; link, don't duplicate."* Producing a link requires the AI to first **search the vault to discover related notes**, then link them. The founder vault does this naturally (dense graph + habitual search); a fresh user's AI writes the note and skips discovery, so it links nothing. **Even the canonical `AGENTS.md` has no explicit search-then-link step** — so this is a genuinely *new* behavioral instruction, not a restoration of dropped content.

Verified during planning against `/Users/yandifarinango/Claude/ObsidianVault/AGENTS.md`:
- Canonical Rule 3 is identical passive wording (`search before creating; link, don't duplicate`). No procedural search-then-link step exists to restore.
- **Path deltas are intentionally NOT changed in this plan** (decisions locked in the devlog):
  - Personal-project task path: kit uses `Personal/{Project}/Tasks/` (flattened); canonical uses `Personal/2. Projects/{Project}/Tasks/`. **Decision: keep the kit's flattened form** — it's internally consistent and simpler for a single-area starter.
  - Work-area-level task rule (canonical `0b → 2. Projects/{Area}/Tasks/`): kit has no equivalent. **Decision: leave out** — fine for the single-area `personal` starter; a later structure update adds it when a work area is first introduced.
  - `spec`/`tech-radar`/`playbook` types, real Cross-System Identity mappings, the `/start-day` privacy mechanism: **correctly omitted — do NOT add** (re-leaks founder instance content into the kit).

The single load-bearing change is making search-then-link explicit. Resist adding anything else.

## File Structure

- **Modify:** `vault-files/AGENTS.md` — add `## Note Creation Procedure` section after the File Routing decision tree; sharpen Rule 3 to cross-reference it. This is the canonical content new users receive.
- **Create:** `structure-updates/2026-05-23-search-then-link-note-creation.md` — self-contained prose update doc (Context / Detection / Changes / Verification / Rollback) carrying the exact insert text inline, following the `2026-05-16-agents-md-adoption.md` pattern. This is the **primary** delivery vehicle for already-installed users.
- **Modify:** `test/harness.bats` — add a content-guard test asserting the shipped `vault-files/AGENTS.md` contains the procedure, so a future regeneration can't silently drop it.

No changes to `setup-vault.sh`, `commands/update-structure.md`, `CLAUDE.md`, or `vault-files/system-settings/vault-structure.md` — the existing `--update` non-clobber copy and the existing `/update-structure` engine already do what Phase 1 needs.

---

### Task 1: Add the Note Creation Procedure to the kit's AGENTS.md

**Files:**
- Modify: `vault-files/AGENTS.md` (insert a section after the File Routing decision tree, which currently ends at the line `9. Not sure → ask the user`, before `## Frontmatter Taxonomy`)
- Modify: `vault-files/AGENTS.md` (sharpen Note Quality Rule 3)
- Modify: `vault-files/AGENTS.md` (add the new section to the Contents list at top)

- [ ] **Step 1: Read the current file to confirm exact anchor text**

Run: `grep -n "9. Not sure\|## Frontmatter Taxonomy\|One canonical note per concept\|## Contents\|^4. \[Frontmatter" vault-files/AGENTS.md`
Expected: confirms the decision tree ends with `9. Not sure → ask the user`, that `## Frontmatter Taxonomy` immediately follows, that Rule 3 reads `**One canonical note per concept** — search before creating; link, don't duplicate.`, and the Contents numbered list.

- [ ] **Step 2: Insert the Note Creation Procedure section**

Insert this block **between** the end of the File Routing decision tree (`9. Not sure → ask the user`) and `## Frontmatter Taxonomy`:

```markdown
## Note Creation Procedure

Creating a note is a **four-step procedure**, not a one-step "write the file." The routing tree above is only step 2. The reason notes feel disconnected is almost always a skipped step 1 or step 3.

1. **Search the vault first.** Before writing, search for notes on the same or adjacent topics — keyword search for exact terms and file names, semantic/vector search when the wording may differ (see [Vault Search Strategy](#vault-search-strategy)). You are looking for two things: (a) an existing canonical note you'd be duplicating, and (b) the hub note(s) and related notes this new note should connect to.
2. **Route it.** Use the File Routing decision tree above to choose the folder and set `type` / `area` / `project`.
3. **Wikilink into the graph.** Add `[[wikilinks]]` to the related notes and hub(s) you found in step 1. If the note is a child of a hub, add a `> **Parent**: [[Hub Note]]` backlink near the top. **A new note with zero outgoing links is a smell** — it means you skipped the search, or this is genuinely the first note on a brand-new topic (rare in an established vault). Do not finalize a zero-link note without consciously confirming it's the latter.
4. **Verify uniqueness.** Confirm you're not duplicating an existing canonical note (Note Quality Rules 3 and 10). If a canonical note already exists, extend or link it instead of creating a parallel one.

This procedure applies to **every** note you create — both slash-command outputs and ad-hoc "take a note about this" moments. The vault grows correctly only if the graph is woven on the way in.
```

- [ ] **Step 3: Sharpen Note Quality Rule 3 to point at the procedure**

Replace:
```
3. **One canonical note per concept** — search before creating; link, don't duplicate.
```
with:
```
3. **One canonical note per concept** — *search the vault before creating* (see [Note Creation Procedure](#note-creation-procedure)), then link, don't duplicate.
```

- [ ] **Step 4: Add the new section to the Contents list**

In the `## Contents` numbered list at the top of the file, insert `Note Creation Procedure` as a new entry immediately after `File Routing — Decision Tree` and renumber the subsequent entries. The anchor is `#note-creation-procedure`.

- [ ] **Step 5: Verify the edits landed and are internally consistent**

Run: `grep -n "## Note Creation Procedure\|#note-creation-procedure\|search the vault before creating" vault-files/AGENTS.md`
Expected: the section heading exists once, Rule 3 references the anchor, and the Contents entry links to `#note-creation-procedure`.
Run: `grep -c "^## " vault-files/AGENTS.md` and eyeball that section order reads Routing → Note Creation Procedure → Frontmatter Taxonomy.

- [ ] **Step 6: Commit**

```bash
git add vault-files/AGENTS.md
git commit -m "feat(agents-md): add explicit search-then-link Note Creation Procedure"
```

---

### Task 2: Add a content-guard test for the procedure

**Files:**
- Modify: `test/harness.bats` (add one `@test` mirroring the existing `vault-files/AGENTS.md` assertions around line 39–45)

> Note: `bats` is not currently on PATH. Install with `brew install bats-core` before running. If install isn't possible in this environment, still write the test and verify the assertion manually with the `grep` in Step 3 — the test documents the invariant for CI/future runs.

- [ ] **Step 1: Read the existing AGENTS.md-related test for style**

Run: `grep -n "AGENTS.md\|vault-files" test/harness.bats`
Expected: shows how the harness references the shipped `vault-files/` tree so the new test matches existing conventions (path resolution, `run grep`, status assertions).

- [ ] **Step 2: Write the failing test**

Add to `test/harness.bats` (the harness `load`s `test_helper.bash`, which exports `$KIT_ROOT` — use it, matching the existing AGENTS.md test):
```bash
@test "vault-files/AGENTS.md ships the search-then-link Note Creation Procedure" {
  run grep -q "## Note Creation Procedure" "$KIT_ROOT/vault-files/AGENTS.md"
  [ "$status" -eq 0 ]
  run grep -q "Search the vault first" "$KIT_ROOT/vault-files/AGENTS.md"
  [ "$status" -eq 0 ]
}
```
(Step 1's grep confirms the existing AGENTS.md test's path style; if it differs from `$KIT_ROOT`, match whatever it uses.)

- [ ] **Step 3: Run the test to verify it passes (content already added in Task 1)**

Run: `bats test/harness.bats -f "Note Creation Procedure"`
Expected: PASS. (If Task 2 were done before Task 1 it would FAIL with the grep returning non-zero — confirming the guard is real.)
If `bats` is unavailable: run `grep -q "## Note Creation Procedure" vault-files/AGENTS.md && grep -q "Search the vault first" vault-files/AGENTS.md && echo OK` → expect `OK`.

- [ ] **Step 4: Run the full harness to confirm nothing else broke**

Run: `bats test/harness.bats`
Expected: all tests PASS (the pre-existing `--update copies new canonical files (AGENTS.md)` test still passes — content change doesn't affect existence checks).

- [ ] **Step 5: Commit**

```bash
git add test/harness.bats
git commit -m "test(harness): guard AGENTS.md Note Creation Procedure content"
```

---

### Task 3: Author the structure-update prose doc (primary delivery to installed users)

**Files:**
- Create: `structure-updates/2026-05-23-search-then-link-note-creation.md`

This doc must be **self-contained**: `setup-vault.sh --update` copies `vault-files/AGENTS.md` non-clobber, so mom's and sister's existing `AGENTS.md` is *not* overwritten. The structure update is therefore the only channel that delivers the new content to them — it must carry the exact insert text inline (mirroring how `2026-05-16-agents-md-adoption.md` carried full instructions), not say "copy from the kit."

- [ ] **Step 1: Re-read the pattern doc**

Run: `cat structure-updates/2026-05-16-agents-md-adoption.md | head -40`
Expected: confirms frontmatter shape (`id`, `date`, `description`, `related_note`) and the Context / Detection / Changes / Verification / Rollback section structure the `/update-structure` engine expects (see `commands/update-structure.md` Steps 5–8).

- [ ] **Step 2: Write the structure-update doc**

Create `structure-updates/2026-05-23-search-then-link-note-creation.md` with this content:

````markdown
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
````

- [ ] **Step 3: Verify the doc parses against the engine's expectations**

Run: `grep -n "^## Context\|^## Detection\|^## Changes\|^## Verification\|^## Rollback\|^id:\|^date:\|^description:" structure-updates/2026-05-23-search-then-link-note-creation.md`
Expected: frontmatter `id`/`date`/`description` present and all five required sections present, in order — matching what `commands/update-structure.md` Steps 5–9 read.

- [ ] **Step 4: Commit**

```bash
git add structure-updates/2026-05-23-search-then-link-note-creation.md
git commit -m "feat(structure-updates): ship search-then-link Note Creation Procedure for installed vaults"
```

---

### Task 4: Dry-run the update channel against a throwaway copy (primary acceptance gate)

The spec names the **update path** (not fresh install) as the primary acceptance test, because the users who hit the bug are already installed. This task rehearses it safely without touching mom's or sister's real vaults.

**Files:** none modified — verification only.

- [ ] **Step 1: Create a throwaway "old install" vault**

```bash
TMP_VAULT="$TMPDIR/phase1-oldvault"
rm -rf "$TMP_VAULT" && mkdir -p "$TMP_VAULT" && cd "$TMP_VAULT"
git init -q
```
Copy in an `AGENTS.md` representing a *pre-Phase-1* install — the `v0.2` tagged version, which is exactly "what an already-installed user has." Using the tag (not `HEAD~N`) is immune to commit-count drift:
```bash
git -C /Users/yandifarinango/RS42/projects/vault-setup-kit show v0.2:vault-files/AGENTS.md > AGENTS.md
grep -c "## Note Creation Procedure" AGENTS.md   # expect 0 — confirms it's a pre-Phase-1 baseline
```
Also write `.vault-kit-path` pointing at the kit, and commit the clean baseline:
```bash
echo "/Users/yandifarinango/RS42/projects/vault-setup-kit" > .vault-kit-path
git add -A && git commit -qm "baseline: pre-phase1 vault"
```

- [ ] **Step 2: Confirm detection fires (update applies to this vault)**

Run: `grep -q "## Note Creation Procedure" "$TMP_VAULT/AGENTS.md" && echo "ALREADY-HAS (wrong)" || echo "APPLIES (correct)"`
Expected: `APPLIES (correct)` — detection predicate is true for an old install.

- [ ] **Step 3: Apply the structure update by hand following the doc's Changes section**

Following `structure-updates/2026-05-23-search-then-link-note-creation.md` exactly (this is what `/update-structure` will do), insert the section after the routing tree and sharpen Rule 3 in `$TMP_VAULT/AGENTS.md`. Then run the doc's **Verification** block:
```bash
cd "$TMP_VAULT"
[ "$(grep -c '## Note Creation Procedure' AGENTS.md)" = "1" ] && \
grep -q "Search the vault first" AGENTS.md && \
grep -q "search the vault before creating" AGENTS.md && \
git diff --stat && echo "VERIFY-OK"
```
Expected: `VERIFY-OK` and `git diff --stat` shows only `AGENTS.md` changed.

- [ ] **Step 4: Confirm idempotency (re-running detection now skips)**

Run: `grep -q "## Note Creation Procedure" "$TMP_VAULT/AGENTS.md" && echo "VACUOUS-ON-RERUN (correct)"`
Expected: `VACUOUS-ON-RERUN (correct)` — a second `/update-structure` would record this as vacuously-applied.

- [ ] **Step 5: Clean up the throwaway vault**

```bash
rm -rf "$TMP_VAULT"
```

No commit — this task changes nothing in the repo.

---

### Task 5: Ship and tag Phase 1

**Files:** none — release step.

- [ ] **Step 1: Final review of the diff**

Run: `git log --oneline -4` and `git diff v0.2 --stat`
Expected: exactly `vault-files/AGENTS.md`, `test/harness.bats`, and `structure-updates/2026-05-23-search-then-link-note-creation.md` changed since v0.2. Nothing unexpected (no founder instance content leaked in).

- [ ] **Step 2: Confirm the version number with the user before tagging**

Spec Open Q2 leaves numbering open (suggested `v0.3` for the routing phase). This is not load-bearing — **ask the user** which tag to use rather than guessing. Default proposal: `v0.3`.

- [ ] **Step 3: Tag and push (only after user confirms the version)**

```bash
git tag v0.3 -m "Phase 1: search-then-link Note Creation Procedure (routing fix)"
git push && git push --tags
```

- [ ] **Step 4: Hand off the real-world test to the user**

The live acceptance test runs on mom's (and sister's) machine, not here. Hand the user this sequence to relay:
```
cd <kit>; git pull
bash setup-vault.sh --update <vault>
cd <vault>; claude
/update-structure        # applies 2026-05-23-search-then-link-note-creation
# then, in the same session:
"Take a note about what I just learned about closed-loop systems"
"Add a project for my apartment search"
```
**Pass criteria:** the resulting notes land in the correct folders AND contain `[[wikilinks]]` to existing hub/related notes (not zero-link notes). Capture the outcome in a follow-up devlog.

---

## Out of Scope (do not drift into these)

- **Phase 2** (bundle/install Personal OS via the kit installer) and **Phase 3** (onboarding self-test prompts) — separate plans.
- Changing the personal-project task path or adding the work-area task rule — decided against for the single-area starter (see Root Cause).
- Adding `spec`/`tech-radar`/`playbook` types, Cross-System Identity mappings, or the privacy mechanism to the kit — these are founder instance content and must stay out.
- Modifying the founder's own canonical `AGENTS.md` — it's an instance, not a kit deliverable. (Optional, separate: the founder may later adopt the same procedure in their own vault, but that's not this plan.)
- Touching `commands/update-structure.md`, `setup-vault.sh`, or `vault-structure.md` — the existing engine and non-clobber copy already suffice.
- QMD index reliability (`qmd embed`) — only revisit if linking still fails *after* this fix; do not turn Phase 1 into an install-reliability project.
