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
  - "[[Set up my first goal]]"
blocked_reason: "Best done after you've used the system enough to know what to customize"
unlocks: []
external_id: ""
tags:
  - task
  - onboarding
---

# Customize my CLAUDE.md

## Why

`CLAUDE.md` at the vault root is the **AI's instruction manual for your vault**. Every time Claude Code (or any AI assistant working with your vault) starts a conversation here, it reads this file. The file tells it:

- What kinds of notes exist (the `type` taxonomy)
- Which areas you have (the `area` values)
- Which projects you have (the `project` slugs)
- Where each kind of content lives (the Decision Tree)
- How to commit changes (your git conventions)

The kit ships with a **generic CLAUDE.md** as a starting point. It documents the universal structure but uses placeholder area and project lists. Your job is to make it match *your* life.

This is also where you teach the AI your preferences. Don't like emoji in commit messages? Add it. Want every devlog to include a "Next session" section? Add it. The AI will respect what's written here.

## Steps

### 1. Open `CLAUDE.md` at the vault root

It's the file at the top of the vault folder. Read it through once, end to end. ~10 minutes. You'll absorb the taxonomy and decision tree just by reading.

### 2. Update the Areas list

Find the section that lists areas (under "Frontmatter Taxonomy" → `area`). The shipped values are a generic starting point. Strip any that don't apply to you and add any that do.

Common starting set for a new vault:
- `personal` — your personal life
- `health` — health & fitness
- `personal-finance` — money, taxes, investments

Add work/business areas as they apply (e.g. `career` if job-searching, a specific company name if employed, an `{your-business}` slug if you run something).

### 3. Update the Project slugs list

Find the section that lists project slugs per area. Your real first project (from [[Add my first project]]) belongs here. Add it under its area.

Don't try to predict every future project — you'll add slugs as you create projects. The list is just a reference for the AI to know what's a valid `project:` value.

### 4. (Optional) Adjust the Decision Tree

The Decision Tree (steps 0 through 9) tells the AI where to file new notes. The shipped version covers the common cases, but if you have a routing rule that's specific to your work (e.g. "all client-related notes go to `2. Projects/{Client}/`"), add a step.

### 5. (Optional) Add a "Workflow Patterns" section

If you have specific habits — e.g. "always ask me before committing," "never push to main without a PR," "I prefer concise answers without preamble" — write them down. The AI will follow them.

### 6. Commit the change

```bash
git add CLAUDE.md
git commit -m "docs: customize CLAUDE.md for my vault"
```

This locks in the customization. From now on, every AI session in your vault will read your version.

## Done when

- [ ] Areas list reflects only the areas in *your* life
- [ ] Project slugs list reflects your real projects (at minimum, the first one you created)
- [ ] You've read the Decision Tree and either accepted it or added your own steps
- [ ] CLAUDE.md is committed to git

## A note on iteration

CLAUDE.md is not write-once. As your system grows — new projects, new patterns, new preferences — come back and update it. Treat it like a living constitution for your vault. The AI's behavior is downstream of what's written here; if the AI is doing something you don't like, the fix is usually a CLAUDE.md edit, not a prompt rewrite.

## See also

- [[Vault-Setup]] — back to the orientation hub
- [[AI-Native Architecture - Business Logic as Agent Instructions]] — *why* an instruction file is the right architecture, not a hack
