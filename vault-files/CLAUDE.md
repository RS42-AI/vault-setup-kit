# CLAUDE.md

This file provides guidance to Claude Code (and any AI assistant) when working in this Obsidian vault. **Customize it for your life** — see `Personal/Vault-Setup/Tasks/Customize my CLAUDE.md.md` for the walkthrough.

## Vault Context

This is a personal knowledge management vault designed for **human-AI collaboration**. It uses a **hub-and-spoke architecture**: area dashboards link to project hubs, which auto-populate via Obsidian Bases queries on frontmatter properties.

Content routes itself to the correct views based on three properties: `type`, `area`, and `project`.

> New here? Start with `Personal/Vault-Setup/Vault-Setup.md` — the orientation project that ships with this vault.

## Vault Structure

### Folders

| # | Folder | Purpose | Note types |
|---|--------|---------|------------|
| 1 | `1. Daily/` | Daily note hubs (one per day) | `daily` |
| 2 | `2. Projects/` | Work / business projects organized by area | `project` hubs + project-specific `note`, `task`, `devlog`, `resource` |
| 3 | `3. Areas/` | Per-area folders containing `{Area}.md` hub + `Goals/` subfolder | Area dashboards, `goal` |
| 4 | `4. Contacts/` | People and meetings | `meeting`, `person` |
| 5 | `5. Resources/` | Curated reference material, journal entries | `resource`, `journal` |
| 6 | `6. Main Notes/` | General knowledge notes (cross-cutting) | `note`, `idea`, `thought` |
| — | `Personal/` | **Personal-life projects** at vault root (NOT under `2. Projects/`) | `project` hubs + project-specific notes |
| — | `system-settings/Templates/` | Note templates | — |
| — | `system-settings/Pasted Images/` | Media assets | — |

### Project Folder Structure

**Work / business projects** live at `2. Projects/{Area}/{Project}/`:

```
2. Projects/{Area}/{Project}/
├── {Project}.md     # Project hub
├── Tasks/           # Actionable work items
├── Notes/           # Knowledge notes for this project
├── Resources/       # Reference material
└── Dev Log/         # Session work logs
```

**Personal-life projects** live at the vault root under `Personal/{Project}/` — same structure, different parent folder. This separates personal life from work without forcing both into the same hierarchy.

### Area Dashboards

Each area lives at `3. Areas/{Area}/` with a hub note + Goals subfolder:

```
3. Areas/Personal/
├── Personal.md       # Area dashboard
└── Goals/
    └── 2026-Q2.md    # type: goal
```

The starter kit ships with one area: **Personal**. Add more (e.g. `Health`, `Career`, `{Your-Business}`) by creating new folders in `3. Areas/`.

### Daily Note System

- Daily hubs live at `1. Daily/YYYY-MM-DD.md`
- Use the `Daily Note Hub Template` — auto-populates with Bases queries
- Morning Journal: `5. Resources/Personal/Journal/Morning Entries/YYYY-MM-DD.md`
- Evening Journal: `5. Resources/Personal/Journal/Evening Entries/YYYY-MM-DD.md`

## Frontmatter Taxonomy

### `type` — What kind of note is this?

| Value | Description | Where it lives |
|-------|-------------|----------------|
| `note` | General knowledge | `6. Main Notes/` or `{Project}/Notes/` |
| `resource` | Curated reference material | `5. Resources/` |
| `idea` | Fleeting business idea | `6. Main Notes/` |
| `goal` | Quarterly / annual outcome (Objective + KRs) | `3. Areas/{Area}/Goals/{horizon}.md` |
| `project` | Project hub page | `2. Projects/{Area}/{Project}/` or `Personal/{Project}/` |
| `task` | Actionable work item | `*/Tasks/` |
| `meeting` | Meeting note | `4. Contacts/Meetings/` |
| `devlog` | Session work log | `*/Dev Log/` |
| `thought` | Fleeting observation | `6. Main Notes/` |
| `daily` | Daily note hub | `1. Daily/` |
| `journal` | Journal entry | `5. Resources/Personal/Journal/` |

### `area` — Which area does it belong to?

The starter kit ships with one area:
- `personal` — your personal life

**Add your own areas** by creating folders in `3. Areas/` and adding the slug here. Examples a new user might add: `health`, `career`, `personal-finance`, `{your-business-slug}`.

### `project` — Which project? (optional)

Only set when a note belongs to a specific project. Notes without `project` are area-level knowledge and appear in the area dashboard's general sections.

**Personal slugs**: `vault-setup` (ships with the kit; add your own as you create projects)

### Frontmatter Templates

**Knowledge note:**
```yaml
---
date: YYYY-MM-DD
type: note
status: capture|develop|refine|complete
area: personal
project: slug          # optional
---
```

**Project hub:**
```yaml
---
date: YYYY-MM-DD
type: project
status: planned|active|paused|complete|archived
area: personal
goal: "[[2026-Q2]]"   # optional — wikilink to area Goal
---
```

**Task note:**
```yaml
---
date: YYYY-MM-DD
type: task
status: todo|active|done|on-hold
area: personal
project: slug              # optional
priority: p1|p2|p3|p4
due_date: ""
scheduled_date: ""
done_date: ""
blocked_by: []
unlocks: []
external_id: ""
tags:
  - task
---
```

**Devlog:**
```yaml
---
date: YYYY-MM-DD
type: devlog
status: capture
area: personal
project: slug
session_topic: Short verb-first description
tasks:
  - "[[Task Name]]"
tags:
  - devlog
---
```

**Goal:**
```yaml
---
date: YYYY-MM-DD
type: goal
status: active|complete|missed
area: personal
period: quarterly|annual|multi-year
horizon: 2026-Q2
tags:
  - goal
---
```

## File Operations — Decision Tree

When the user asks to create or save a note:

0. **Actionable work item for a work/business project?** → `2. Projects/{Area}/{Project}/Tasks/`
0a. **Actionable work item for a personal-life project?** → `Personal/{Project}/Tasks/`
0b. **Actionable work item for an area (no project)?** → `Personal/Tasks/` (or area-level Tasks folder)
1. **Session log / work log?** → `*/Dev Log/`
2. **About an active project?** → `{Project}/Notes/`
3. **About an area (no specific project)?** → `6. Main Notes/` with `area:` set
4. **A person or meeting?** → `4. Contacts/People/` or `4. Contacts/Meetings/`
5. **A fleeting thought?** → `6. Main Notes/` with `type: thought`
6. **A business idea?** → `6. Main Notes/` with `type: idea`
7. **Curated reference material?** → `5. Resources/{Area}/`
8. **General knowledge?** → `6. Main Notes/`
9. **Not sure?** → Ask the user

## Note Quality Rules

1. **No context re-explanation** — Link to previous notes, don't re-explain them
2. **Max 500 lines per note** — Split with pipe aliases: `## [[Full Name|Short Name]]`
3. **One canonical note per concept** — Search before creating; link, don't duplicate
4. **Corrections replace, never supplement** — Update the original, don't just add a new note
5. **Session logs ≠ knowledge notes** — Devlogs in `Dev Log/`, knowledge in main folders
6. **Project notes go in project folders** — Check `2. Projects/` and `Personal/` before defaulting to `6. Main Notes/`

## Search Tools (if installed)

- **QMD `search`** — Fast keyword search (~30ms)
- **QMD `vector_search`** — Semantic / concept search (~2s)
- **QMD `deep_search`** — Auto-expanded multi-query search (~10s)
- **Obsidian MCP `search_vault_smart`** — Semantic search with folder filtering

Exclude `Dev Log/` folders when answering "how does X work?" questions; search `Dev Log/` folders when answering "where did we leave off?" questions.

## Git Workflow

This vault is a git repo. Commit changes regularly to preserve history.

### Commit Standards

Follow semantic commit conventions:
- `feat:` New feature or content
- `fix:` Corrections
- `docs:` Documentation changes
- `chore:` Maintenance

### Commit Message Requirements

- Keep messages clean and focused on the actual changes
- Concise, descriptive language about what changed and why
- **Never** mention AI generation, co-authoring, or "Generated with Claude"

## Customization

This file is a **starting point**, not a finished spec. As your vault grows, edit `CLAUDE.md` to:

- Add new areas to the `area` taxonomy
- Document project slugs as you create projects
- Encode your own routing rules in the Decision Tree
- Add personal preferences (e.g. "always ask before committing", "prefer concise responses")

The AI's behavior is downstream of what's written here — when something feels off, the fix is usually a `CLAUDE.md` edit.
