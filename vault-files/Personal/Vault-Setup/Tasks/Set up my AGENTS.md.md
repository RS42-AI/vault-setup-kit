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

Unlike a free-form hand-edit, this is **AI-assisted from a versioned spec**. `system-settings/agents-md-spec.md` describes exactly how the AI should generate and revise `AGENTS.md`. You don't edit the file directly — you run an AI session that follows the spec.

**This is also the vault's update mechanism for the instruction layer.** When the kit ships an improvement to the baseline (a new section, a sharper rule, a renamed routing step), `update.sh` refreshes the spec. Re-running this task is how you pull those improvements into *your* `AGENTS.md` without losing the customizations you've already made. Same task, two modes: first time it generates; every time after, it revises.

## Steps (first-time setup)

### 1. Open a Claude Code (or other AI assistant) session in your vault

Working directory must be the vault root — the AI needs to read `system-settings/agents-md-spec.md` and write to `AGENTS.md`.

### 2. Paste this prompt

```
Set up my AGENTS.md by following the GENERATION procedure in
system-settings/agents-md-spec.md.

Read the spec end-to-end first, then run the procedure: interview me
about my areas, my external systems (if any), and whether I have or
expect private projects. Use my answers to fill in the curated-config
sections of AGENTS.md. Leave the standing rules untouched unless the
spec says otherwise. Show me the diff before writing.
```

The AI will read the spec, ask you a handful of questions (what areas you have, whether you mirror projects to GitHub/Linear/ADO/Notion, whether you use private projects), and produce a tailored `AGENTS.md`. Review the diff before accepting.

### 3. Commit

```bash
git add AGENTS.md
git commit -m "docs: set up AGENTS.md for my vault"
```

From now on, every AI session in your vault reads *your* version.

## Updating later

When `update.sh` reports that `system-settings/agents-md-spec.md` has changed (the kit shipped an improvement), re-run this task — but in **revision** mode, not generation. Your customizations stay; the kit's improvements get layered in.

### Paste this prompt instead

```
Revise my AGENTS.md by following the REVISION procedure in
system-settings/agents-md-spec.md.

The spec was just updated. Diff the spec against my current AGENTS.md,
identify what the spec now says that my file doesn't reflect, and
propose targeted edits. Preserve my curated config — areas, external-
system identity, privacy settings, any conventions I've added. Show me
the diff before writing.
```

The AI will flag anything ambiguous and ask before changing it — that's expected, not an error.

The REVISION procedure in the spec is explicit about what to preserve and what to update: standing rules track the spec, curated config stays yours.

## Done when

- [ ] An AI session has been run against `system-settings/agents-md-spec.md`
- [ ] `AGENTS.md` reflects your real areas (not just the shipped `personal` placeholder)
- [ ] External-system identity captured if you use one (GitHub / Linear / ADO / Notion mapping)
- [ ] Privacy section filled in or omitted, per the spec's guidance
- [ ] Reviewed the AI's report (what was filled in, what was omitted, any flagged questions)
- [ ] `AGENTS.md` is committed to git

## See also

- [[Vault-Setup]] — back to the orientation hub
- [[AI-Native Architecture - Business Logic as Agent Instructions]] — *why* an instruction file is the right architecture, not a hack
- `system-settings/agents-md-spec.md` — the spec the AI follows
