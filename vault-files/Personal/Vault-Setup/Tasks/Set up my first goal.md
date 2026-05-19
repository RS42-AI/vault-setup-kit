---
date: 2026-05-09
type: task
status: todo
area: personal
project: vault-setup
priority: p3
due_date: ""
scheduled_date: ""
done_date: ""
blocked_by:
  - "[[Add my first project]]"
blocked_reason: "Best done after you have one real project to anchor the goal to"
unlocks:
  - "[[Set up my AGENTS.md]]"
external_id: ""
tags:
  - task
  - onboarding
---

# Set up my first goal

## Why

A project without a goal is just a list of activity. Goals give projects a *reason* — an outcome you're trying to reach by a specific date — and let the system surface what actually matters when you're triaging tasks.

The Goals system uses the **Objective + 3 Key Results** pattern (often called OKRs). One sentence describing what you want to be true; three measurable signals that say whether it happened.

## Steps

### 1. Pick the area and the time horizon

Goals live at `3. Areas/{Area}/Goals/{horizon}.md`. Two common horizons:

- **Quarterly** — `2026-Q2.md`, `2026-Q3.md`, etc. — what you want to accomplish in the next 90 days. Best for active work areas.
- **Annual** — `2026-Annual.md` — bigger-picture outcomes for the year. Best for life areas (health, finances, career).

For your first goal, pick the area where the project you just created lives. If it's a personal-life project, use `3. Areas/Personal/Goals/`. If it's a work project, use the matching work area.

### 2. Create the goals file

If the file doesn't exist yet (e.g. `3. Areas/Personal/Goals/2026-Q2.md`), create it. Use the `Goal Template` from `system-settings/Templates/`. The minimum frontmatter:

```yaml
---
date: <today's date>
type: goal
status: active
area: <your area>
period: quarterly
horizon: 2026-Q2
tags:
  - goal
---
```

### 3. Write the Objective

One sentence. Aspirational but bounded by the horizon. It should answer: *what does success look like at the end of this quarter / year?*

Examples (these are illustrative — yours will be specific to you):

- *"Have a working rhythm of three workouts per week and feel physically stronger than I did at the start of the quarter."*
- *"Move from job-searching to a signed offer in a role I'm excited about."*
- *"Complete the first phase of the home-buying process — pre-approved, agent chosen, two offers made."*

### 4. Write 3 Key Results

Three measurable signals that say the Objective happened. Each KR should be either a *number* or a *binary outcome* — vague KRs are useless.

Bad: *"Make progress on home buying"*
Good: *"Submit at least 2 offers by end of Q2"*

Three is the sweet spot. One is too few (the Objective could happen by accident); five is too many (you stop tracking). Three forces you to pick what actually matters.

### 5. Link the goal from your project hub

Open your project hub and update the frontmatter:

```yaml
goal: "[[2026-Q2]]"
```

This wikilink lets the area dashboard show your project as "linked to this goal" automatically.

It's also fine to leave `goal: ` empty — that's a valid state ("latent project," not yet aligned to a goal). But for an onboarding goal, the whole point is to feel the link.

## Done when

- [ ] Goal file exists at `3. Areas/{Area}/Goals/{horizon}.md`
- [ ] Frontmatter has `type: goal`, `area`, `period`, `horizon`
- [ ] Objective is one clear sentence
- [ ] Exactly 3 Key Results, each measurable
- [ ] Your project hub's `goal:` frontmatter links to the goal file

## See also

- `AGENTS.md` (vault root) — Goal frontmatter spec (field shapes live in `system-settings/Templates/`)
- [[Add my first project]] — the project this goal anchors to
- [[Vault-Setup]] — back to the orientation hub
