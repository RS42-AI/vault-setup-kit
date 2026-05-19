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
blocked_reason: "Best done after you have one real area + project in mind — gives the AI concrete answers to interview you about"
unlocks: []
external_id: ""
tags:
  - task
  - onboarding
---

# Set up my AGENTS.md

## Why

`AGENTS.md` at the vault root is the **AI's instruction manual for your vault**. Every AI session in the vault — Claude Code, Codex, anything that follows the agent-instructions convention — reads it before doing anything. It tells the AI:

- What areas exist in *your* life (the `area` slugs)
- Which external systems you mirror projects into (GitHub, Linear, ADO, Notion — if any)
- Whether you use private projects (and how privacy inherits)
- Your conventions, preferences, workflow rules

The kit ships with a **generic AGENTS.md baseline** — universal structure, one placeholder `personal` area, optional sections stubbed but unfilled. Your job is to make it match *your* life.

This is the *first-time customization* task. For ongoing updates when the kit ships improvements, the vault has a separate mechanism — see [Updating later](#updating-later).

## Steps (first-time setup)

### 1. Open a Claude Code (or other AI assistant) session in your vault

Working directory must be the vault root — the AI needs to read your existing `AGENTS.md` and edit it in place.

### 2. Paste this prompt

```
Read AGENTS.md at the vault root. It is the shipped generic baseline.
I want to tailor it to my life.

Interview me about:
- What areas I actually have (the kit ships only `personal` — what
  else? work, health, finances, side projects, etc.)
- Whether I mirror projects to any external system (GitHub, Linear,
  ADO, Notion); if so, build the Cross-System Identity table
- Whether I have or expect private projects; if not, omit the Privacy
  Inheritance section
- Any vault-specific conventions or routing rules I want to add

When you have my answers, propose targeted edits to AGENTS.md.
Preserve the shipped standing rules verbatim — only modify the
curated-config sections (Areas, Cross-System Identity, Privacy
Inheritance, anything custom I add). Show me the diff before writing.
```

The AI will ask you a handful of questions and propose targeted edits. Review the diff before accepting.

### 3. Commit

```bash
git add AGENTS.md
git commit -m "docs: set up AGENTS.md for my vault"
```

From now on, every AI session in your vault reads *your* version.

## Updating later

When the kit ships improvements to the canonical vault shape — a new section in `AGENTS.md`, a refreshed template, a renamed file — the kit's `structure-updates/` folder gets a new dated migration doc describing the change.

To apply outstanding updates, run the `/update-structure` slash command in Claude Code inside your vault:

```
/update-structure
```

It reads `structure-updates/` from the kit, detects which migrations apply to your current vault state, and walks you through each change with confirmation. Your customizations stay; the kit's improvements layer in. Re-runs are safe (idempotent).

For an inventory of what's applied vs. pending:

```
/update-structure --list
```

For a dry-run preview without changing anything:

```
/update-structure --dry-run
```

The AI will flag anything ambiguous and ask before changing it — that's expected, not an error.

## Done when

- [ ] An AI session has tailored `AGENTS.md` to your real areas (not just the shipped `personal` placeholder)
- [ ] External-system identity captured if you use one (GitHub / Linear / ADO / Notion mapping)
- [ ] Privacy section filled in or omitted, based on whether you have private projects
- [ ] Reviewed the AI's report (what was added, what was omitted, any flagged questions)
- [ ] `AGENTS.md` is committed to git

## See also

- [[Vault-Setup]] — back to the orientation hub
- [[AI-Native Architecture - Business Logic as Agent Instructions]] — *why* an instruction file is the right architecture, not a hack
- `commands/update-structure.md` (in the kit) — the slash-command runner used for ongoing updates
