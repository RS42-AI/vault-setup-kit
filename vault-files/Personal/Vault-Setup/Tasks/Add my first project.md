---
date: 2026-05-09
type: task
status: todo
area: personal
project: vault-setup
priority: p2
due_date: ""
scheduled_date: ""
done_date: ""
blocked_by: []
blocked_reason: ""
unlocks:
  - "[[Set up my first goal]]"
external_id: ""
tags:
  - task
  - onboarding
---

# Add my first project

## Why

The fastest way to learn the hub-and-spoke architecture is to use it. Pick something you're already working on — a side project, a trip, a job hunt, a course, a renovation — and stand up a real project hub for it. By the end, you'll know how `type`, `area`, and `project` route content, and your area dashboard will start auto-populating.

## Steps

### 1. Pick a project

Choose something concrete that has more than one task and will run for at least a few weeks. Examples that work well as a first project:

- A trip you're planning
- A learning goal (e.g. learn Spanish, finish a course)
- A side project (e.g. build a website, write a book)
- A life project (e.g. find a new apartment, train for a 5K)

Avoid: anything that fits in one sitting (just make a task instead) or anything purely exploratory with no defined outcome.

### 2. Decide which area it belongs to

Areas are stable life domains: `personal`, `health`, `personal-finance`, `career`, etc. (See `AGENTS.md` at the vault root for the canonical list.) Pick the one that fits.

If your project is a personal-life project, the folder lives at the vault root: `Personal/{Project-Name}/`. If it's a work or business project, it lives at `2. Projects/{Area}/{Project-Name}/`.

### 3. Create the project folder structure

```
{Area-Folder}/{Project-Name}/
├── {Project-Name}.md          ← project hub
├── Notes/                     ← knowledge notes for this project
├── Tasks/                     ← actionable work items
├── Resources/                 ← reference material
└── Dev Log/                   ← session-by-session work logs
```

### 4. Create the project hub

Open the `{Project-Name}.md` file at the project root. Use the `Project Hub Template` (in `system-settings/Templates/`) as a starting point. The minimum frontmatter:

```yaml
---
date: <today's date>
type: project
status: active
area: <your area>
project: <your-project-slug>
---
```

The project slug should be lowercase-with-hyphens, e.g. `home-buying`, `apac-trip`, `learn-spanish`.

### 5. Add one task and one devlog

Open the project for real:

- Create one task in `{Project-Name}/Tasks/` — pick the very next thing to do
- Create one devlog in `{Project-Name}/Dev Log/` — capture today's session, even if it was just "set up the project"

Once you have those, the project hub's embedded queries will populate with your task and devlog. That's the whole magic — you don't update the hub manually, you just add things with the right frontmatter and they appear.

## Done when

- [ ] Project folder exists at the right path for its area
- [ ] Project hub `.md` file has correct frontmatter
- [ ] At least one task exists in `Tasks/`
- [ ] At least one devlog exists in `Dev Log/`
- [ ] Opening the project hub shows the task and devlog auto-populated in their sections

## See also

- `AGENTS.md` (vault root) — Decision Tree and frontmatter taxonomy
- [[AI Workstation Organization - Filesystem and Vault Mapping Architecture]]
- [[Vault-Setup]] — back to the orientation hub
