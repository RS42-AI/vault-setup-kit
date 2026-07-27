# AGENTS.md

## Contents

1. [Vault Structure](#vault-structure)
2. [Areas](#areas)
3. [File Routing — Decision Tree](#file-routing--decision-tree)
4. [Note Creation Procedure](#note-creation-procedure)
5. [Frontmatter Taxonomy](#frontmatter-taxonomy)
6. [Devlog Task Linking](#devlog-task-linking)
7. [Cross-System Identity](#cross-system-identity-optional--fill-in-if-you-use-external-systems)
8. [Privacy Inheritance](#privacy-inheritance-only-if-you-have-or-expect-private-projects--otherwise-omit)
9. [Orphan-Note Rule](#orphan-note-rule)
10. [Memory System](#memory-system--do-not-use-without-permission)
11. [Note Quality Rules](#note-quality-rules)
12. [Vault Search Strategy](#vault-search-strategy)
13. [Git Workflow](#git-workflow)
14. [Maintenance](#maintenance)

Canonical instruction file for this vault — read by any agent (Claude Code, Codex, and whatever comes next). `CLAUDE.md` is a one-line pointer to this file.

This vault is a knowledge-and-execution system designed for human-AI collaboration: reference notes, project work, an executive Morning Brief, and an optional Evening Entry. Frontmatter-driven routing and Obsidian Bases let humans and AI agents both navigate, search, and maintain it.

**Scope of this file — standing *rules* + non-inferable *curated config* only:**
- **Structure is derived, never enumerated.** What projects and (eventually) areas exist comes from globbing the filesystem at runtime. A hand-written project list is a stale index waiting to happen.
- **Schema lives in templates.** Frontmatter field shapes are defined by `system-settings/Templates/` — the templates are the schema source of truth. This file names note *types* and where they route; it does not restate field lists.

## Vault Structure

Hub-and-spoke architecture: an **area dashboard** in `3. Areas/` (or `Personal/` for personal life) links to **project hubs**, which auto-populate via Obsidian Bases queries on the three routing properties (`type`, `area`, `project`). Top-level folders use numeric prefixes (`1. Daily/`, `2. Projects/`, `3. Areas/`, `4. Contacts/`, `5. Resources/`, `6. Main Notes/`) to keep them in a stable order in the sidebar; `Personal/` and `system-settings/` sit alongside without a prefix.

Daily hubs live at `1. Daily/YYYY-MM-DD.md`. Morning Brief and Evening Entry records live under the legacy-compatible `5. Resources/{Area}/Journal/` path. Templates live in `system-settings/Templates/`.

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
6b. Design spec for an active project → `{Project}/Specs/` (`type: spec`, set `area:` + `project:`, default `status: draft`)
7. Curated reference material → `5. Resources/{Area}/`
8. General technical knowledge → `6. Main Notes/`
9. Not sure → ask the user

## Note Creation Procedure

Creating a note is a **four-step procedure**, not a one-step "write the file." The routing tree above is only step 2. The reason notes feel disconnected is almost always a skipped step 1 or step 3.

1. **Search the vault first.** Before writing, search for notes on the same or adjacent topics — keyword search for exact terms and file names, semantic/vector search when the wording may differ (see [Vault Search Strategy](#vault-search-strategy)). You are looking for two things: (a) an existing canonical note you'd be duplicating, and (b) the hub note(s) and related notes this new note should connect to.
2. **Route it.** Use the File Routing decision tree above to choose the folder and set `type` / `area` / `project`.
3. **Wikilink into the graph.** Add `[[wikilinks]]` to the related notes and hub(s) you found in step 1. If the note is a child of a hub, add a `> **Parent**: [[Hub Note]]` backlink near the top. Where a link can be stated as a sentence `A —verb→ B` using the [Relationship verbs](#relationship-verbs--closed-list-the-ontology-t-box) table, also record it as a typed frontmatter property. **A new note with zero outgoing links is a smell** — it means you skipped the search, or this is genuinely the first note on a brand-new topic (rare in an established vault). Do not finalize a zero-link note without consciously confirming it's the latter.
4. **Verify uniqueness.** Confirm you're not duplicating an existing canonical note (Note Quality Rules 3 and 10). If a canonical note already exists, extend or link it instead of creating a parallel one.

This procedure applies to **every** note you create — both slash-command outputs and ad-hoc "take a note about this" moments. The vault grows correctly only if the graph is woven on the way in.

## Frontmatter Taxonomy

Three properties route every note: **`type`** (what kind), **`area`** (which life area — the slugs in the Areas table), **`project`** (which project — optional; derived from the filesystem, never enumerated — the project tree *is* the list).

### `type` values — CLOSED LIST

These are the **only** allowed `type:` values. If a note does not obviously fit
one of these, it is `note` — never invent a new type. Do **not** create `guide`,
`architecture`, `workflow`, `combined`, or anything else; a note's *character*
belongs in `tags:`, not in `type:`.

| Value | Description | Where it lives |
|-------|------------|----------------|
| `note` | General knowledge | `6. Main Notes/` or `{Project}/Notes/` |
| `resource` | Curated reference material | `5. Resources/{Area}/` |
| `idea` | Fleeting business idea | `6. Main Notes/` |
| `goal` | Quarterly/annual area outcome (Objective + KRs) | `3. Areas/{Area}/Goals/` |
| `project` | Project hub with embedded Bases | `2. Projects/{Area}/{Project}/` or `Personal/{Project}/` |
| `spec` | Design document for project work | `{Project}/Specs/` |
| `task` | Actionable work item | `*/Tasks/` |
| `meeting` | Meeting note | `4. Contacts/Meetings/` |
| `person` | Contact note | `4. Contacts/People/` |
| `devlog` | Session work log | `{Project}/Dev Log/` |
| `thought` | Fleeting observation | `6. Main Notes/` |
| `daily` | Daily note hub | `1. Daily/` |
| `journal` | Morning Brief or Evening Entry record (compatibility type) | `5. Resources/{Area}/Journal/` |
| `area-dashboard` | Per-area dashboard hub | `3. Areas/{Area}/` or `Personal/` |

**Frontmatter shapes — read the template.** Field shapes per `type` are defined by the templates in `system-settings/Templates/`, not restated here — re-typing field lists is how they drift. When creating a note, read the matching template. Every template carries `date` + the routing properties; `status`, `tags`, and type-specific fields vary by template.

### `status` values — CLOSED LIST (per type)

`status` is a closed enum **scoped by `type`** — pick only from the row for the
note's type. Any value not in the row is forbidden; map it to the nearest
allowed one (never write `in-progress`, `complete`, `planned`, `shipped`,
`backlog`, `pending`…).

| `type` | allowed `status` (progression →) | pause / terminal |
|--------|-----------------------------------|------------------|
| `task` | `todo` → `active` → `done` | `on-hold`, `archived` |
| `spec`, `project` | `draft` → `in-review` → `active` → `done` | `on-hold`, `superseded`, `archived` |
| `goal` | `active` → `done` (achieved) *or* `passed` (horizon expired, not fully achieved) | `archived` |
| `area-dashboard` | `active` → `done` | `archived` |
| `note`, `idea`, `thought` | `capture` → `done` | `superseded` |
| `devlog`, `meeting` | `capture` | — |
| `daily`, `journal`, `person`, `resource` | *(no `status` field)* | — |

**🔒 `done` is human-only.** An AI agent may write any status *except* `done`
(and `passed`, for goals) — marking something finished is a human decision.

**`note` → `resource` on completion.** A `note` that reaches `done` is a curated
keeper — promote it to `type: resource` in `5. Resources/{Area}/`. A `resource`
carries no lifecycle `status`. (This promotion, like any `done`, is human-only.)

### Goal Rollup Contract

The vault should be able to prove goal movement from evidence, not vibes. The
canonical chain: `devlog.tasks[] → task (area, project, status) → project hub
(goal, optional quarter_goal/kr) → goal note (objective, KRs)`.

Every `type: project`, `status: active` hub must be scoreable or intentionally
unscored:

1. **Goal-aligned** — `goal: "[[Goal Note]]"` points to the area goal it serves.
2. **Exploratory** — `goal_status: discovery`: visible, not counted as progress yet.
3. **Intentionally unscored** — `goal_status: unscored`: active operational
   pressure that should appear in reviews without pretending to move a goal.
4. **Inactive** — `status: on-hold` / `superseded` / `archived` / `done` removes
   weekly active pressure.

Allowed `goal_status` values are `scored`, `discovery`, and `unscored`. An
active project with empty `goal:` and no `goal_status:` is drift.

### Relationship verbs — CLOSED LIST (the ontology T-box)

Typed relationships between notes are a **closed enum**, same species as `type`/`status`. A typed link is an assertion — it must be sayable as a sentence `A —verb→ B`; **no sentence, no link**. Plain prose wikilinks remain allowed as untyped ambience, but agents may only *rely* on typed edges. Storage: **frontmatter list properties on the subject note**, values are wikilinks — never inline body fields (Bases reads properties).

| Verb | Meaning (A —verb→ B) | Written as |
|---|---|---|
| `blocks` / `unlocks` | B waits on A / completing A enables B | `blocked_by:` (on the blocked note) / `unlocks:` |
| `serves_goal` | work advances goal G | `goal:` / `quarter_goal:` (plus `kr` — a plain label, not a link field) |
| `supersedes` | A replaces B as canonical | `status: superseded` + callout on B |
| `evidences` | A is proof-of-work for B | devlog `tasks:` |
| `part_of` | containment | `project:` / `area:` (+ folder placement) — **never a separate field** |
| `uses_system` | process/project runs on this tool/system | `uses_system:` |
| `informs` | knowledge input to a decision (weaker than `evidences`) | `informs:` |
| `owned_by` | accountability rests with this person | `owned_by:` |

**🔒 Propose, don't invent.** AI must never write a verb outside this table. A candidate verb is *proposed* to the human with one example sentence, and the rule of three applies: formalize a verb only on its third real occurrence. Proposals accumulate in `6. Main Notes/Ontology Proposal Ledger.md` (created on first use) so counting occurrences is a grep. Like the Areas table, this list is yours to grow — ratifying a new verb (adding a row here) is a human decision, same ceremony as extending the `type` enum.

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

## Privacy Inheritance (only if you have or expect private projects — otherwise omit)

Privacy is a **project-level** property. When a project hub (`type: project`) has `private: true`, every file with `project: <same-slug>` inherits it — all devlogs, knowledge notes, tasks, and the hub itself. Privatized files are excluded from any "recent activity" rollup, daily recap, or Morning Brief priority extraction. Override on a single file with `private: false`.

## Orphan-Note Rule

A knowledge note is "orphan" when it has `date: X` but no devlog from the same project covers date X. This is a **smell signal, not an error** — respond by (1) writing a retroactive devlog if it was a real session, (2) accepting it (spontaneous capture during another session), or (3) ignoring a persistent marker. Don't suppress orphan flags by adding empty devlogs.

## Memory System — DO NOT USE WITHOUT PERMISSION

**Do NOT create, update, or delete files in an agent memory system (`~/.claude/projects/*/memory/`, `~/.codex/…`, and equivalents) without explicit user approval.** All documentation, insights, and knowledge belong in the vault as knowledge notes or devlogs — never as memory files. If you believe something belongs in memory, ask first and wait for explicit approval. The vault is the documentation home.

## Note Quality Rules

1. **No context re-explanation** — link to previous notes, don't re-explain them.
2. **Max 500 lines per note** — split with pipe aliases: `## [[Full Name|Short Name]]`.
3. **One canonical note per concept** — *search the vault before creating* (see [Note Creation Procedure](#note-creation-procedure)), then link, don't duplicate.
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

On first install, run the `Set up my AGENTS.md` onboarding task to tailor this file to your life. When the kit ships improvements, run `/update-structure` in Claude Code at the vault root — it reads the kit's `structure-updates/` and walks you through applicable changes interactively. Hand-edit the curated-config sections (Areas, Cross-System Identity, Privacy Inheritance) freely; for changes to the standing rules above, contribute back to the kit instead of diverging in isolation.
