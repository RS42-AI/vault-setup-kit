# AGENTS.md

Canonical instruction file for this vault — read by any agent (Claude Code, Codex, and whatever comes next). `CLAUDE.md` is a one-line pointer to this file.

This vault is a personal knowledge-management system designed for human-AI collaboration: reference notes, project work, daily journaling. Frontmatter-driven routing and Obsidian Bases let humans and AI agents both navigate, search, and maintain it.

**Scope of this file — standing *rules* + non-inferable *curated config* only:**
- **Structure is derived, never enumerated.** What projects and (eventually) areas exist comes from globbing the filesystem at runtime. A hand-written project list is a stale index waiting to happen.
- **Schema lives in templates.** Frontmatter field shapes are defined by `system-settings/Templates/` — the templates are the schema source of truth. This file names note *types* and where they route; it does not restate field lists.

## Vault Structure

Hub-and-spoke architecture: an **area dashboard** in `3. Areas/` (or `Personal/` for personal life) links to **project hubs**, which auto-populate via Obsidian Bases queries on the three routing properties (`type`, `area`, `project`). Top-level folders use numeric prefixes (`1. Daily/`, `2. Projects/`, `3. Areas/`, `4. Contacts/`, `5. Resources/`, `6. Main Notes/`) to keep them in a stable order in the sidebar; `Personal/` and `system-settings/` sit alongside without a prefix.

Daily hubs live at `1. Daily/YYYY-MM-DD.md`. Journal entries live under `5. Resources/{Area}/Journal/`. Templates live in `system-settings/Templates/`.

Full folder roles, project-folder layout, and the daily/journal paths live in [[vault-structure]] (load-on-demand reference) — consult it when you need the details, not when routing a single note.

## Areas

This table is the canonical list of life areas the vault knows about. The starter kit ships with exactly one area — `personal` — because a fresh vault doesn't yet need more. As your life grows, add new areas by creating a folder under `3. Areas/{Area}/` (with a `{Area}.md` hub + `Goals/` subfolder) and appending a row here. Examples a new user might add: `health`, `career`, `personal-finance`, `work`.

Project *existence* and slugs are still derived from the filesystem, never listed.

| Area folder | `area` slug |
|-------------|-------------|
| `Personal/` (vault root) | `personal` |

## File Routing — Decision Tree

When creating a note, walk these in order:

0. Actionable work item, **work/business project** → `2. Projects/{Area}/{Project}/Tasks/` (`type: task`, set `area:` + `project:`)
0a. Actionable work item, **personal-life project** → `Personal/{Project}/Tasks/` (set `area:` + `project:`)
0b. Actionable work item, **area-level, no project** → `Personal/Tasks/` (set `area:`)
1. Session / work log → `{Project}/Dev Log/` (Devlog Template, chain-link to previous)
2. About an active project → `{Project}/Notes/` (set `project:`)
3. About an area, no specific project → `6. Main Notes/` (set `area:`)
4. Person or meeting note → `4. Contacts/People/` or `4. Contacts/Meetings/`
5. Fleeting thought or observation → `6. Main Notes/` (`type: thought`)
6. Business idea or brainstorm → `6. Main Notes/` (`type: idea`)
7. Curated reference material → `5. Resources/{Area}/`
8. General technical knowledge → `6. Main Notes/`
9. Not sure → ask the user

## Frontmatter Taxonomy

Three properties route every note: **`type`** (what kind), **`area`** (which life area — the slugs in the Areas table), **`project`** (which project — optional; derived from the filesystem, never enumerated — the project tree *is* the list).

### `type` values

| Value | Description | Where it lives |
|-------|------------|----------------|
| `note` | General knowledge | `6. Main Notes/` or `{Project}/Notes/` |
| `resource` | Curated reference material | `5. Resources/{Area}/` |
| `idea` | Fleeting business idea | `6. Main Notes/` |
| `goal` | Quarterly/annual area outcome (Objective + KRs) | `3. Areas/{Area}/Goals/` |
| `project` | Project hub with embedded Bases | `2. Projects/{Area}/{Project}/` or `Personal/{Project}/` |
| `task` | Actionable work item | `*/Tasks/` |
| `meeting` | Meeting note | `4. Contacts/Meetings/` |
| `person` | Contact note | `4. Contacts/People/` |
| `devlog` | Session work log | `{Project}/Dev Log/` |
| `thought` | Fleeting observation | `6. Main Notes/` |
| `daily` | Daily note hub | `1. Daily/` |
| `journal` | Journal entry | `5. Resources/{Area}/Journal/` |
| `area-dashboard` | Per-area dashboard hub | `3. Areas/{Area}/` or `Personal/` |

**Frontmatter shapes — read the template.** Field shapes per `type` are defined by the templates in `system-settings/Templates/`, not restated here — re-typing field lists is how they drift. When creating a note, read the matching template. Every template carries `date` + the routing properties; `status`, `tags`, and type-specific fields vary by template.

## Devlog Task Linking

Every devlog must reference at least one task in `tasks:`, mirrored at the session-sized task level (not user stories). If no task exists, create one first — verb-first naming ("Wire up Bases query", not "vault stuff"). Unlinked devlogs are flagged as incomplete.

The rationale: a devlog without a linked task is hard to find later — you remember the *thing you did*, not the date. The task is the durable handle; the devlog is the session evidence beneath it.

## Cross-System Identity (optional — fill in if you use external systems)

If you mirror projects across other systems (GitHub, Linear, Azure DevOps, Notion), record the mapping here — this is real config that cannot be inferred from the vault filesystem, so this file is its single home. Leave this stub empty until you actually have an org or external tool to map.

| Component | Format | Example |
|-----------|--------|---------|
| Display name | Title Case | `My Project` |
| Slug | lowercase-with-hyphens | `my-project` |
| External repo / project | tool-specific | — |
| Obsidian hub | `{path}/{Project}/` | `Personal/My Project/` |

- **Slug generation** — lowercase → spaces to hyphens → strip non-alphanumeric (keep hyphens) → collapse repeats → preserve version numbers (`v2` stays).
- **Identity resolution** (partial input → project) — exact slug match → slug contained in project name → ask the user.
- **Do NOT create new projects** unless explicitly instructed.

## Privacy Inheritance

Privacy is a **project-level** property. When a project hub (`type: project`) has `private: true`, every file with `project: <same-slug>` inherits it — all devlogs, knowledge notes, tasks, and the hub itself. Privatized files are excluded from any "recent activity" rollup, daily recap, or journal-priority extraction. Override on a single file with `private: false`.

## Orphan-Note Rule

A knowledge note is "orphan" when it has `date: X` but no devlog from the same project covers date X. This is a **smell signal, not an error** — respond by (1) writing a retroactive devlog if it was a real session, (2) accepting it (spontaneous capture during another session), or (3) ignoring a persistent marker. Don't suppress orphan flags by adding empty devlogs.

## Memory System — DO NOT USE WITHOUT PERMISSION

**Do NOT create, update, or delete files in an agent memory system (`~/.claude/projects/*/memory/`, `~/.codex/…`, and equivalents) without explicit user approval.** All documentation, insights, and knowledge belong in the vault as knowledge notes or devlogs — never as memory files. If you believe something belongs in memory, ask first and wait for explicit approval. The vault is the documentation home.

## Note Quality Rules

1. **No context re-explanation** — link to previous notes, don't re-explain them.
2. **Max 500 lines per note** — split with pipe aliases: `## [[Full Name|Short Name]]`.
3. **One canonical note per concept** — search before creating; link, don't duplicate.
4. **Corrections replace, never supplement** — update the original, don't add a parallel note.
5. **Session logs ≠ knowledge notes** — devlogs in the project's `Dev Log/`, knowledge in main folders.
6. **Project notes go in project folders** — check `2. Projects/` and `Personal/` before defaulting to `6. Main Notes/`.
7. **Pipe aliases for sub-pages** — child notes link back with `> **Parent**: [[Hub Note]]`.
8. **Superseded notes must be marked** — `status: superseded` + a callout pointing to the replacement.
9. **Shared content lives in ONE place** — prefer `![[Source#Section]]` transclusion over copy-paste.
10. **Every AI note passes the uniqueness test** — verify no duplication before finalizing.

## Vault Search Strategy

Reach for keyword search for exact terms and file names; reach for semantic / vector search when the wording in the question may not match the wording in the note. Scope by folder when the question is folder-shaped ("what's in my Resources?").

Exclude `Dev Log/` folders when answering "how does X work?" questions — devlogs are temporal session logs, not reference material. Search project `Dev Log/` folders when answering "where did we leave off?" questions — that *is* what devlogs are for.

## Git Workflow

This vault is a git repo. Commit changes regularly to preserve history. Semantic commits: `feat:` (new feature/doc), `fix:` (correction), `docs:` (docs-only change), `refactor:` (restructure, no behavior change), `chore:` (maintenance).

- **NEVER** mention AI generation or co-authoring in a commit message; no "Generated with…" attribution.
- Keep messages concise and focused on what changed. This is a knowledge vault, not a codebase.

## Maintenance

This file is generated and kept current by the AI from [[agents-md-spec]] — see the onboarding task `Set up my AGENTS.md` for the walkthrough. When the vault's shape or rules change, update the spec and regenerate; don't hand-edit this file in isolation.
