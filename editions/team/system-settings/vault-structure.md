# Vault Structure — Reference

> Load-on-demand reference: folder roles and project layout for this work vault. For routing a single note, use the decision tree in AGENTS.md instead.

## Hub-and-Spoke Architecture

The **area dashboard** (`3. Areas/RS42/RS42.md`) links to **project hubs** (`2. Projects/RS42/{Project}/{Project}.md`), which auto-populate via Obsidian Bases queries on the three routing properties (`type`, `area`, `project`).

## Folders

| Folder | Role |
|---|---|
| `1. Daily/` | Daily work logs (`YYYY-MM-DD.md`) — what you worked on, decisions made, blockers |
| `2. Projects/RS42/` | One folder per project (see Project Folders below) |
| `2. Projects/RS42/Tasks/` | Work items not yet tied to a specific project |
| `3. Areas/RS42/` | The RS42 area dashboard + `Goals/` |
| `4. Contacts/People/` | One note per person |
| `4. Contacts/Meetings/` | One note per meeting |
| `5. Resources/RS42/` | Curated reference material |
| `5. Resources/RS42-Commons/` | The shared team knowledge commons (mounted as a git submodule; read-only here) |
| `6. Main Notes/` | General knowledge, thoughts, and ideas not tied to one project |
| `system-settings/Templates/` | The note templates — the schema source of truth |

Top-level folders use numeric prefixes to keep a stable sidebar order; `system-settings/` sits alongside without a prefix.

## Project Folders

Each project under `2. Projects/RS42/{Project}/` contains:

- `{Project}.md` — the hub note (`type: project`) with embedded Bases views
- `Tasks/` — actionable work items (`type: task`)
- `Notes/` — knowledge notes about the project (`type: note`)
- `Dev Log/` — session work logs (`type: devlog`), chain-linked previous ↔ next
- `Specs/` — design documents (`type: spec`)

## Daily Paths

The daily hub is `1. Daily/YYYY-MM-DD.md`, created from the Daily Note Hub Template. It is a **work log**: priorities up top, auto-populated views of active tasks, today's meetings, dev sessions, and notes created today, and a wrap-up section at the end of the day.

## Knowledge Notes vs Devlogs

Devlogs record *sessions* (what happened, in `Dev Log/`); knowledge notes record *understanding* (how things work, in `Notes/` or `6. Main Notes/`). Never mix the two in one note: a session that produced understanding gets a devlog **and** a knowledge note, linked to each other.
