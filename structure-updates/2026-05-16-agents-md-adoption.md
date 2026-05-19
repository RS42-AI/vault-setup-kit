---
id: 2026-05-16-agents-md-adoption
date: 2026-05-16
description: Adopt AGENTS.md as the canonical instruction file; collapse CLAUDE.md to a 5-line pointer; externalize folder/template detail to system-settings/vault-structure.md.
related_note: "[[Cross-Agent Instruction-File Architecture — AGENTS.md as the Portable Source of Truth]]"
also_see: "[[Agentic System Configuration — Single Source of Truth and the Instruction-File Drift Failure Mode]]"
---

## Context

The vault used to keep a single `CLAUDE.md` at the root holding both standing rules and a complete enumeration of folder structure, templates, and conventions. Two problems emerged:

1. **Single-agent coupling.** `CLAUDE.md` is read by Claude Code only. Codex reads `AGENTS.md`. As we use more than one agent against the same vault, instructions duplicated across files drift.
2. **Drift-prone enumeration.** Listing every folder, template, and field shape inside the rules file meant every structural change required editing the rules file. They drifted apart.

The fix:

- **`AGENTS.md`** becomes the canonical instruction file — agent-agnostic, holds standing rules and curated config that can't be inferred from the filesystem (area→slug mapping, project identity table, taxonomy of `type` values).
- **`CLAUDE.md`** becomes a 5-line pointer that imports `AGENTS.md` via the `@AGENTS.md` syntax, with a note that Claude-specific overrides go below the import.
- **`system-settings/vault-structure.md`** holds the verbose folder/structure detail that used to live inside `CLAUDE.md`. Load-on-demand reference, not loaded into every session.
- **Templates remain the source of truth for frontmatter shapes** — `AGENTS.md` names types and routing, doesn't restate fields.

## Detection

This structure update applies if **both**:

1. `CLAUDE.md` exists at vault root AND is more than 50 lines (i.e., still in the old monolithic shape).
2. `AGENTS.md` does NOT exist at vault root.

If `AGENTS.md` already exists, this structure update has effectively been done by hand — record as vacuously-applied.

If `CLAUDE.md` is already a short pointer (5–10 lines containing `@AGENTS.md`) but `AGENTS.md` is missing, that's an inconsistent state — stop and ask the user before guessing.

## Changes

### File: `AGENTS.md` (new file at vault root)

Create this file with the canonical Personal OS instruction content. Kit v0.2 ships the canonical AGENTS.md at `vault-files/AGENTS.md` — the user has already received it via the non-clobber copy in `setup-vault.sh --update`. If for some reason it didn't arrive, copy from kit's `vault-files/AGENTS.md`.

Key sections the new `AGENTS.md` must contain:
- Vault Structure overview (with pointer to `system-settings/vault-structure.md` for detail)
- The six-area table (folder → slug mapping)
- File Routing Decision Tree (the numbered 0–9 walk)
- Frontmatter Taxonomy (the `type` values table; do NOT restate field shapes — point at templates)
- Cross-System Identity table (display name / slug / org dir / repo / Linear / hub)
- Privacy Inheritance rule
- Orphan-Note Rule
- Memory System safety rule
- Note Quality Rules (the 10 numbered)
- Vault Search Strategy pointer
- Git Workflow conventions
- Note Relationships guidance

If the user's vault has customizations to the old `CLAUDE.md` that aren't covered by the canonical `AGENTS.md` (e.g., a personal section, a project they added a custom rule for), preserve those — append them to the new `AGENTS.md` under a clearly-labeled "Local customizations" section at the bottom. Ask the user before discarding anything from the old file.

### File: `CLAUDE.md` (rewrite at vault root)

Replace the entire contents with this 5-line pointer:

```markdown
# CLAUDE.md

This vault's canonical instruction file is `AGENTS.md` — agent-agnostic, read by Claude Code, Codex, and others. Claude Code reads `CLAUDE.md`, so this file imports it. Add Claude-specific instructions below the import if ever needed.

@AGENTS.md
```

Before overwriting, **back up the old `CLAUDE.md`** to `CLAUDE.md.pre-agents-md-update` so the user can recover anything that was lost in the rewrite. (Not deleted automatically — the user can `rm` it once they're satisfied.)

### File: `system-settings/vault-structure.md` (new file)

Create this load-on-demand reference. Pull content from kit v0.2's copy at `vault-files/system-settings/vault-structure.md`. It holds:

- The full folder role table (numbered prefixes, what each folder is for)
- Project folder layout (`Tasks/`, `Notes/`, `Resources/`, `Dev Log/`)
- Journal paths and structure
- The Personal-life-projects-at-vault-root convention
- Goals structure history (for context on the goal sub-hub pattern)

If this file already exists with non-trivial content, ask the user before overwriting.

### File: `system-settings/Templates/*` (sync drifted templates)

Compare each template in the user's `system-settings/Templates/` against the kit's canonical copy at `vault-files/system-settings/Templates/`. For each that differs:

- Diff the user's version against canonical
- If the user's version has clear local customizations (extra fields, a personal preamble), preserve those and merge in the canonical updates
- If the user's version is just an older copy, replace with canonical

Templates most likely to need updating in vaults installed before 2026-05-16:
- `Journal Entry Template.md` — retired `habit_sober` / `habit_no_pmo` / `habit_workout_type` fields
- `Devlog Template.md` — added `tasks:` field requirement
- `Project Hub Template.md` — added goal sub-hub linking pattern

Always show the diff to the user before replacing a template.

## Verification

After applying, all of these must be true:

- `AGENTS.md` exists at vault root and is at least 100 lines (the canonical version is ~140 lines).
- `CLAUDE.md` exists at vault root, is between 4 and 8 lines, and contains the literal string `@AGENTS.md`.
- `system-settings/vault-structure.md` exists.
- `CLAUDE.md.pre-agents-md-update` exists at vault root (the backup).
- A `git status` shows the new/changed files as expected modifications, nothing unexpected.

If any verification fails, do NOT record the structure update as applied. Report which check failed and stop.

## Rollback

Every change in this structure update is recoverable from git (assuming the vault is a git repo and was clean before starting):

```
git checkout CLAUDE.md
rm AGENTS.md system-settings/vault-structure.md CLAUDE.md.pre-agents-md-update
```

If the vault is not in a git repo, the backup `CLAUDE.md.pre-agents-md-update` is the manual recovery path for the old `CLAUDE.md`. The new files (`AGENTS.md`, `vault-structure.md`) can simply be deleted.

## Notes for the human running this

This is the first structure update — it establishes the pattern for future ones. Don't be surprised if Claude pauses to ask clarifying questions; that's the design. Future structure updates will be tighter as the pattern matures.
