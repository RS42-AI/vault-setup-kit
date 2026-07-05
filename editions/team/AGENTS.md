# AGENTS.md

## Contents

1. [Vault Structure](#vault-structure)
2. [Areas](#areas)
3. [File Routing — Decision Tree](#file-routing--decision-tree)
4. [Note Creation Procedure](#note-creation-procedure)
5. [Frontmatter Taxonomy](#frontmatter-taxonomy)
6. [Devlog Task Linking](#devlog-task-linking)
7. [Shared Knowledge Commons](#shared-knowledge-commons)
8. [Cross-System Identity](#cross-system-identity)
9. [Note Quality Rules](#note-quality-rules)
10. [Vault Search Strategy](#vault-search-strategy)
11. [Git Workflow](#git-workflow)
12. [Maintenance](#maintenance)

Canonical instruction file for this vault — read by any agent (Claude Code, Codex, and whatever comes next). `CLAUDE.md` is a one-line pointer to this file.

This is an **RS42 work vault** — a human-AI operating system for your RS42 work: project work, work logs, research, and the references the whole team shares. It is the *work edition* of the AI-OS system, built on the work core: projects, tasks, dev logs, meetings, references, and a daily work log. Frontmatter-driven routing and Obsidian Bases let humans and AI agents both navigate, search, and maintain it.

**Scope of this file — standing *rules* + non-inferable *curated config* only:**
- **Structure is derived, never enumerated.** What projects exist comes from globbing the filesystem at runtime. A hand-written project list is a stale index waiting to happen.
- **Schema lives in templates.** Frontmatter field shapes are defined by `system-settings/Templates/` — the templates are the schema source of truth. This file names note *types* and where they route; it does not restate field lists.

## Vault Structure

Hub-and-spoke architecture: an **area dashboard** in `3. Areas/` links to **project hubs**, which auto-populate via Obsidian Bases queries on the three routing properties (`type`, `area`, `project`). Top-level folders use numeric prefixes (`1. Daily/`, `2. Projects/`, `3. Areas/`, `4. Contacts/`, `5. Resources/`, `6. Main Notes/`) to keep them in a stable sidebar order; `system-settings/` sits alongside without a prefix.

Daily hubs (`1. Daily/YYYY-MM-DD.md`) are **work logs** — what you worked on, decisions made, blockers. Templates live in `system-settings/Templates/`.

Full folder roles and project-folder layout live in [[vault-structure]] (load-on-demand reference) — consult it when you need the details, not when routing a single note.

## Areas

This table is the canonical list of areas this vault knows about. A work vault ships with exactly one area — `rs42`. Project *existence* and slugs are derived from the filesystem, never listed.

| Area folder | `area` slug |
|-------------|-------------|
| `3. Areas/RS42/` | `rs42` |

## File Routing — Decision Tree

When creating a note, walk these in order:

0. Actionable work item, **project** → `2. Projects/RS42/{Project}/Tasks/` (`type: task`, set `area: rs42` + `project:`)
0a. Actionable work item, **no project yet** → `2. Projects/RS42/Tasks/` (set `area: rs42`)
1. Session / work log → `2. Projects/RS42/{Project}/Dev Log/` (Devlog Template, chain-link to previous)
2. About an active project → `2. Projects/RS42/{Project}/Notes/` (set `project:`)
3. About RS42 in general, no specific project → `6. Main Notes/` (set `area: rs42`)
4. Person or meeting note → `4. Contacts/People/` or `4. Contacts/Meetings/`
5. Fleeting thought or observation → `6. Main Notes/` (`type: thought`)
6. Idea or brainstorm → `6. Main Notes/` (`type: idea`)
7. Curated reference material → `5. Resources/RS42/`
8. General technical knowledge → `6. Main Notes/`
9. Not sure → ask the user

> **Never** write into `5. Resources/RS42-Commons/` directly — that is the shared commons (read-only here). To contribute knowledge to the team, see [Shared Knowledge Commons](#shared-knowledge-commons).

## Note Creation Procedure

Creating a note is a **four-step procedure**, not a one-step "write the file." The routing tree above is only step 2. The reason notes feel disconnected is almost always a skipped step 1 or step 3.

1. **Search the vault first.** Before writing, search for notes on the same or adjacent topics — keyword search for exact terms and file names, semantic/vector search when the wording may differ (see [Vault Search Strategy](#vault-search-strategy)). You are looking for two things: (a) an existing canonical note you'd be duplicating, and (b) the hub note(s) and related notes this new note should connect to. **Search the commons too** — the team may already have a note on it.
2. **Route it.** Use the File Routing decision tree above to choose the folder and set `type` / `area` / `project`.
3. **Wikilink into the graph.** Add `[[wikilinks]]` to the related notes and hub(s) you found in step 1 (including commons notes under `5. Resources/RS42-Commons/`). If the note is a child of a hub, add a `> **Parent**: [[Hub Note]]` backlink near the top. **A new note with zero outgoing links is a smell.**
4. **Verify uniqueness.** Confirm you're not duplicating an existing canonical note (Note Quality Rules 3 and 10). If one exists, extend or link it instead of creating a parallel one.

## Frontmatter Taxonomy

Three properties route every note: **`type`** (what kind), **`area`** (`rs42`), **`project`** (which project — optional; derived from the filesystem, never enumerated).

### `type` values

| Value | Description | Where it lives |
|-------|------------|----------------|
| `note` | General knowledge | `6. Main Notes/` or `{Project}/Notes/` |
| `resource` | Curated reference material | `5. Resources/RS42/` |
| `idea` | Idea or brainstorm | `6. Main Notes/` |
| `goal` | Quarterly/annual area outcome (Objective + KRs) | `3. Areas/RS42/Goals/` |
| `project` | Project hub with embedded Bases | `2. Projects/RS42/{Project}/` |
| `spec` | Design document for project work | `2. Projects/RS42/{Project}/Specs/` |
| `task` | Actionable work item | `*/Tasks/` |
| `meeting` | Meeting note | `4. Contacts/Meetings/` |
| `person` | Contact note | `4. Contacts/People/` |
| `devlog` | Session work log | `{Project}/Dev Log/` |
| `thought` | Fleeting observation | `6. Main Notes/` |
| `daily` | Daily work-log hub | `1. Daily/` |
| `area-dashboard` | Area dashboard hub | `3. Areas/RS42/` |

**Frontmatter shapes — read the template.** Field shapes per `type` are defined by the templates in `system-settings/Templates/`, not restated here. When creating a note, read the matching template.

## Devlog Task Linking

Every devlog must reference at least one task in `tasks:`, mirrored at the session-sized task level (not user stories). If no task exists, create one first — verb-first naming ("Wire up Bases query", not "vault stuff"). A devlog without a linked task is hard to find later — you remember the *thing you did*, not the date.

## Shared Knowledge Commons

`5. Resources/RS42-Commons/` is the **team's shared knowledge brain** — added to this vault as a git submodule during onboarding. It is **read-only here**: you read it and `[[wikilink]]` your own notes to it, but you never edit it directly.

To contribute a note to the commons: draft it in **your** vault first, then promote it through review (the founder is the write-gate — nothing lands in the team brain without approval). The promotion tooling (`/promote-to-commons`) is provided separately. Raw work — daily/work logs, dev logs, tasks, scratch — **stays in your vault** and does not go into the commons.

## Cross-System Identity

If you mirror projects across other systems (GitHub, Linear), record the mapping here — real config that can't be inferred from the filesystem. The RS42 GitHub org is **`RS42-AI`**.

- **Slug generation** — lowercase → spaces to hyphens → strip non-alphanumeric (keep hyphens) → collapse repeats → preserve version numbers (`v2` stays).
- **Do NOT create new projects** unless explicitly instructed.

## Note Quality Rules

1. **No context re-explanation** — link to previous notes, don't re-explain them.
2. **Max 500 lines per note** — split with pipe aliases: `## [[Full Name|Short Name]]`.
3. **One canonical note per concept** — *search first* (vault **and** commons), then link, don't duplicate.
4. **Corrections replace, never supplement** — update the original.
5. **Session logs ≠ knowledge notes** — devlogs in the project's `Dev Log/`, knowledge in main folders.
6. **Project notes go in project folders** — check `2. Projects/RS42/` before defaulting to `6. Main Notes/`.
7. **Pipe aliases for sub-pages** — child notes link back with `> **Parent**: [[Hub Note]]`.
8. **Superseded notes must be marked** — `status: superseded` + a callout pointing to the replacement.
9. **Shared content lives in ONE place** — prefer `![[Source#Section]]` transclusion over copy-paste.
10. **Every note passes the uniqueness test** — verify no duplication before finalizing.

## Vault Search Strategy

Reach for keyword search for exact terms and file names; reach for semantic / vector search when the wording in the question may not match the wording in the note. Exclude `Dev Log/` folders when answering "how does X work?" questions; search `Dev Log/` folders when answering "where did we leave off?" questions.

## Git Workflow

This vault is a git repo, shared with the founder only. Commit changes regularly to preserve history. Semantic commits: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`.

- **NEVER** mention AI generation or co-authoring in a commit message.
- Keep messages concise and focused on what changed.
- `git pull` the commons submodule periodically to get the latest team knowledge: `git submodule update --remote`.

## Maintenance

This is the work edition of the AI-OS system. When the kit ships improvements, run `/update-structure` in Claude Code at the vault root. Hand-edit the curated-config sections (Cross-System Identity) freely; for changes to the standing rules above, contribute back to the kit instead of diverging in isolation.
