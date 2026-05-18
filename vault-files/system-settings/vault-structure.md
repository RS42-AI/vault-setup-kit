# Vault Structure — Reference

Load-on-demand structural detail linked from [[AGENTS]]. `AGENTS.md` holds the routing rules and the non-inferable area / `type` tables; this file holds the descriptive structure an agent reads only when it needs the full picture.

## Hub-and-Spoke Architecture

Area dashboards in `3. Areas/` (and `Personal/` for personal life) link to project hubs, which auto-populate via Obsidian Bases queries on the three routing properties (`type`, `area`, `project`). Content routes itself into the correct dashboard views.

## Folders

Numeric prefixes order the top-level folders in the sidebar; `Personal/` and `system-settings/` sit alongside without a prefix.

| Folder | Purpose | Note types |
|--------|---------|------------|
| `1. Daily/` | Daily note hubs (one per day) | `daily` |
| `2. Projects/` | Project docs organized by area | `project` hubs + `note`/`resource`/`task`/`devlog` |
| `3. Areas/` | Per-area dashboards + `Goals/` subfolder | `area-dashboard`, `goal` |
| `3. Areas/Personal/` | Personal area dashboard + goals | `area-dashboard`, `goal` |
| `3. Areas/Personal/Goals/` | Per-goal sub-hubs for the personal area | `goal` |
| `4. Contacts/` | People and meeting notes | — |
| `4. Contacts/People/` | Contact notes | `person` |
| `4. Contacts/Meetings/` | Meeting notes | `meeting` |
| `5. Resources/` | Human-curated reference material by area | `resource` |
| `5. Resources/Personal/` | Personal reference material; holds the `Journal/` subtree (`Morning Entries/`, `Evening Entries/`) | `resource`, `journal` |
| `6. Main Notes/` | General knowledge, not project-specific | `note`/`idea`/`goal`/`thought` |
| `Personal/` | Self-contained `personal` area at the vault root, holds personal-life projects | `area-dashboard` |
| `Personal/Tasks/` | Area-level personal tasks not tied to a project | `task` |
| `system-settings/` | Vault configuration | — |
| `system-settings/Templates/` | Note templates — the schema source of truth | — |
| `system-settings/Pasted Images/` | Media assets | — |

## Project Folders

Projects use a standard four-folder layout:

```
{Project}/
├── {Project}.md       # Project hub with embedded Bases
├── Tasks/             # Actionable work items
├── Notes/             # Knowledge notes for this project
├── Resources/         # Reference material
└── Dev Log/           # Project-specific session logs
```

**Where project folders live:**

- **Work / business projects** → `2. Projects/{Area}/{Project}/`
- **Personal-life projects** → `Personal/{Project}/`

**Project folders are created on demand, not by `setup-vault.sh`.** The kit ships `2. Projects/` and `Personal/` empty (apart from `Personal/Tasks/`). When you start a new project, create `{Project}/` and its four sub-folders (`Tasks/`, `Notes/`, `Resources/`, `Dev Log/`) at that point — by hand or by asking an agent. The project hub `.md` file (`type: project`) is what makes the project discoverable to the Bases queries; the sub-folders just hold its content.

## Goals

One file per goal: `3. Areas/{Area}/Goals/{Goal Name}.md` (`type: goal`). Each goal is its own sub-hub — an Objective plus Key Results — rather than a single horizon-aggregate file per quarter. The kit pre-creates `3. Areas/Personal/Goals/`; create the parallel `Goals/` folder for any new area you add.

## Journal & Daily Paths

Journal paths follow `5. Resources/{Area}/Journal/`. The kit ships with one area (`personal`), so the concrete paths are:

| Content | Path |
|---------|------|
| Daily note hub | `1. Daily/YYYY-MM-DD.md` |
| Morning journal entry | `5. Resources/Personal/Journal/Morning Entries/YYYY-MM-DD.md` |
| Evening journal entry | `5. Resources/Personal/Journal/Evening Entries/YYYY-MM-DD.md` |

## Knowledge Notes vs Devlogs

| | Knowledge Notes | Devlogs |
|--|-----------------|---------|
| Purpose | HOW things work | WHERE you left off |
| Title | By concept (no date prefix) | By date + session topic |
| Lifespan | Permanent, updated over time | Ephemeral, archived when project completes |
| Location | `6. Main Notes/`, `{Project}/Notes/` | `{Project}/Dev Log/` |
| Search priority | First-class | Second-class — exclude from "how does X work?" queries |
| Chain-linking | No | Yes — `Previous:` / `Next:` wikilinks per project |
