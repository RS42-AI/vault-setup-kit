---
date: 2026-03-21
type: note
status: develop
area: personal
project: vault-setup
tags:
  - personal-os
  - daily-lifecycle
  - ai-workflow
---

# Personal OS Daily Lifecycle Architecture — The Executive Meeting Model

## The Core Idea

The Personal OS daily lifecycle is built on a simple metaphor: **the AI is your executive — a world-class chief of staff who preps for meetings with you, then takes notes and action items during those meetings.**

The system prepares two daily touchpoints:
- **Morning Brief** — the executive briefs you on yesterday's movement, today's commitments, risks, and next decisions. You can optionally add spoken or written thoughts and have the agent turn them into outcomes.
- **Evening Entry** — the executive reviews today's accomplishments and tomorrow's shape. If reflection would help, you can add it in your own words and ask the agent to process it.

> **Scheduling is optional.** The Setup Kit installs these commands for manual use; it does not install a scheduler. An external scheduler can invoke `/start-day` and `/prep-evening` later without changing the workflow.

The executive does the preparation when invoked—manually or by an optional scheduler. The Morning Brief remains useful even if you never add a personal entry, and the Evening Entry is explicitly optional. When you do contribute, you bring the part only a human can bring: judgment, context, and decisions about what matters.

---

## The Two Meeting Types

### Morning Meeting

```
BEFORE THE MEETING                    THE MEETING                        AFTER THE MEETING
──────────────────                    ───────────                        ─────────────────
/start-day (scheduled, ~6:30am)       You open the Morning Brief         /process-morning (when useful)
                                      and optionally add thoughts
Executive preps:                                                         Executive records:
• Creates daily hub                   You see:                           • AI Summary of your input
• Creates Morning Brief               • Yesterday's devlog recap         • Extracts priorities
• Writes yesterday's recap            • Evening reflection insights      • Creates tasks in tracker
• Writes today's tasks                • Today's task list                • Writes work priorities
  (from your task tracker(s))         • Risks and open decisions            to daily hub
• Syncs external trackers → primary                                      • Updates frontmatter

                                      You may bring:
                                      • What's on your mind
                                      • What you want to focus on
                                      • Decisions or reflection
```

### Evening Meeting

```
BEFORE THE MEETING                    THE MEETING                        AFTER THE MEETING
──────────────────                    ───────────                        ─────────────────
/prep-evening (scheduled, ~8pm)       You open the Evening Entry         /process-evening (when useful)
                                      and optionally add your own words
Executive preps:                                                         Executive records:
• Creates Evening Entry               You see:                           • AI Summary of your input
• Writes today's accomplishments      • What you accomplished today      • Triages Still Open tasks
  (from devlogs + tasks)              • What's still open                  (close, defer, keep)
• Shows remaining/carry-forward       • Tomorrow's calendar              • Surfaces supported patterns
  tasks with devlog annotations       • Gentle wind-down prompt          • Flags decision loops
• Shows tomorrow's calendar                                              • Pattern awareness
• Crosses off completed priorities    You bring:                         • Proposes tomorrow's tasks
  on daily hub                        • How the day went
                                      • Anything worth preserving
                                      • Or nothing; the entry is optional
```

---

## Prep vs Process — Two Fundamentally Different Skill Types

This is the most important architectural distinction in the system.

### Prep Skills (Scheduled — The Executive's Homework)

| Skill | When | What It Creates |
|-------|------|----------------|
| `/start-day` | ~6:30am via cron | Daily hub, Morning Brief, context sections |
| `/prep-evening` | ~8:00pm via cron | Evening entry, accomplishments, still-open tasks |

**Characteristics:**
- Run **without any human input** — the executive doesn't need you to do their homework
- **Create all infrastructure files** — hub, Morning Brief, Evening Entry. If a file doesn't exist, the script creates it
- **Write context for the human to review** — this is the briefing material
- **Must be bulletproof** — if the prep doesn't run, the meeting can't happen as designed. Use a redundancy pattern (run at 6:00, check at 6:20, retry at 6:40)
- **No judgment calls about content** — the executive gathers facts, not opinions (opinions come during the meeting)

### Process Skills (Human-Triggered — Meeting Notes)

| Skill | When | What It Produces |
|-------|------|-----------------|
| `/process-morning` | After you add optional Morning Brief input | AI Summary, priorities, tasks in tracker, daily hub update |
| `/process-evening` | After you add optional Evening Entry input | AI Summary, task triage, supported patterns, tomorrow prep |

**Characteristics:**
- Run **only after the human has added content** — you trigger these, never cron
- **Expect prep to have happened** — the daily hub and Morning Brief should already exist with context. If they don't, something broke upstream
- **Extract structure from unstructured human input** — this is the meeting notes, the action items, the follow-ups
- **Require LLM judgment** — summarization, mood detection, priority classification, pattern recognition
- **Always use batch approval for external actions** — never create tracker tasks without showing you the list first

### Why Prep Is a Prerequisite, Not Optional

Think of it this way: your executive wouldn't walk into a meeting with you empty-handed. If they did, you'd say "go prep first." The prep skills create the conditions for a productive meeting:

- `/start-day` creates the daily hub so you can see yesterday's work and today's priorities at a glance
- `/start-day` creates the Morning Brief with context so any input you add is informed, not blind
- `/prep-evening` shows your accomplishments whether or not you choose to reflect

If `/process-morning` discovers that no daily hub exists, that means the executive didn't prep. The correct response is to flag the failure — not to silently create a bare-bones hub and pretend everything is fine. That would hide system problems.

> **Design rule**: Process skills stop and report when prep hasn't happened. The fix is upstream — make the prep skills more reliable, not make the process skills more forgiving.

---

## How the Thin Dispatcher Pattern Powers This

The daily lifecycle skills have two kinds of work:

| Work Type | Who Does It | Examples |
|-----------|------------|---------|
| **Deterministic** — same input, same output every time | Bash scripts | Date math, file creation, task-tracker API calls, devlog discovery, JSON assembly |
| **Judgment** — requires interpretation and reasoning | The agent (LLM) via SKILL.md | Summarizing devlogs, prioritizing tasks, detecting mood, composing natural language |

The **Thin Dispatcher Pattern** says: put deterministic work in scripts, keep only judgment calls in the SKILL.md. The SKILL.md becomes a thin router that says "run this script, read the output, apply your judgment, write the result."

### Why This Matters for Cron Automation

When the agent runs a skill, the entire SKILL.md loads into the context window. Above ~50k tokens, the agent starts forgetting later steps in multi-step skills. A 300-line SKILL.md with inline date math, API calls, and formatting rules easily hits that ceiling — especially in cron automation where the context fills up fast.

Scripts don't have this problem. A bash script executes deterministically regardless of how full the agent's context window is. So the architecture is:

```
SKILL.md (thin — routing + judgment)
  │
  ├── Step 1: Run gather_morning_context.sh → parse JSON
  │            (script handles: date resolution, devlog glob,
  │             task-tracker CLIs, evening lookup)
  │
  ├── Step 2: Supplement with MCP tools the agent calls directly
  │            (issue trackers, vault search — can't be scripted from bash)
  │
  ├── Step 3: Ensure files exist
  │            ensure_daily_hub.sh → creates hub from template
  │            ensure_journal.sh  → creates Morning Brief from the compatibility template
  │
  ├── Step 4: JUDGMENT — summarize, prioritize, compose
  │            (this is what the LLM is good at)
  │
  ├── Step 5: JUDGMENT — sync tasks to tracker
  │            (deciding what to sync requires interpretation)
  │
  └── Step 6: Report results with source manifest
```

### The Three Scripts for `/start-day`

**`gather_morning_context.sh`** — The data collector. Runs first, outputs one big JSON object with everything the agent needs:
- What date is "yesterday" (walks backwards to find most recent daily hub — handles weekends)
- Which files exist (Morning Brief, daily hub, yesterday's hub)
- Yesterday's devlogs (found via filesystem glob, with frontmatter extracted)
- Open tasks from your tracker(s) — overdue + today
- Work items from any external systems (e.g. an issue tracker, gracefully handling VPN/auth failures)
- Evening Entry (searches backwards up to 3 days, checks multiple file locations)
- Source manifest (what succeeded, what failed)

Every section outputs valid JSON even on failure — `{available: false, error: "..."}` instead of crashing. The script never stops the show; it just reports what it couldn't get.

**`ensure_daily_hub.sh`** — Creates the daily hub from a template if it doesn't exist. Pure template rendering — date substitution, nav links, embedded queries. Returns `{created: true}` or `{created: false}` (idempotent — safe to re-run).

**`ensure_journal.sh`** — Creates the Morning Brief from the legacy-compatible journal template if it doesn't exist. Renders frontmatter and the briefing structure. The filename is retained as an internal compatibility detail. The script is idempotent.

### What Scripts Can't Do

Scripts can't call MCP tools directly. MCP is a feature of the agent runtime — it lives inside the agent's process, not in bash. So the SKILL.md supplements the script output with MCP calls:
- **Issue tracker** — list assigned issues for active projects
- **Vault search** — backup devlog discovery if the filesystem glob missed something
- **Vault MCP patches** — writing the composed context to Morning Brief and daily hub files

This is a clean split: scripts handle CLI tools and filesystem; the agent handles MCP tools.

---

## What Happens When Life Doesn't Follow the Ideal Flow

The system is designed for real human behavior: the brief should still serve you when you add no personal notes, and the evening flow should degrade gracefully when you skip it.

### Scenario: Normal Day (Everything Works)

```
6:30am   /start-day runs via cron
           → gather script collects data
           → ensure scripts create hub + Morning Brief
           → agent writes context to both files
7:30am   You open the Morning Brief and optionally add a voice/text entry
8:00am   If you added input, you say "/process-morning"
           → agent extracts insights, creates tracker tasks
           → Daily hub gets work priorities
         ... you work all day, create devlogs ...
8:00pm   /prep-evening runs via cron
           → Finds today's devlogs, shows accomplishments
           → Shows remaining tasks with progress annotations
9:00pm   You optionally add anything worth preserving
9:30pm   If you added input, you say "/process-evening"
           → agent triages tasks, detects patterns
           → Proposes tomorrow's tasks
```

### Scenario: You Use the Brief Without Adding Notes

```
6:30am   /start-day runs (hub + Morning Brief created, context written)
         You read the brief or go straight to work without adding anything.
         /process-morning never runs — nothing to process. That's fine.
         ... you work all day ...
8:00pm   /prep-evening runs (still finds devlogs and task data)
         You may or may not reflect tonight.
```

**Impact**: The Daily hub still has yesterday's summary and today's priorities from `/start-day`. The system has less human-authored context, but nothing breaks. Tomorrow's `/start-day` picks up from devlogs and the tracker.

### Scenario: Cron Fails — `/start-day` Didn't Run

```
6:30am   Schedule fails silently. No hub, no Morning Brief, no context.
7:30am   You open the vault — no daily hub for today. Something's wrong.
         You say "/process-morning" → STOPS: "No daily note found."
         This is a system failure alert, not a bug. The executive didn't prep.
```

**Fix**: Make cron reliable with redundant scheduling (run, check, retry). Investigate why the primary run failed.

### Scenario: You Skip Evening Reflection

```
8:00pm   /prep-evening runs (evening entry created with context)
         You don't reflect tonight.
         /process-evening never runs. That's fine.
6:30am   Tomorrow's /start-day looks for an Evening Entry
           → Finds /prep-evening's context (accomplishments, still-open)
           → Finds no human-added reflection
           → System degrades gracefully — less human context, but still functional
```

### Scenario: You Add a Quick Text Entry

```
         You open the Morning Brief and type a few lines instead of speaking.
         "/process-morning" reads whatever is under ## Morning.
         Less content = less extraction, but the process is the same.
```

---

## How This Connects to the Broader System

### The Six-Layer Hierarchy

The daily lifecycle is **Layer 0** — the operational foundation that everything else builds on:

```
Layer 5 — VISION         (annual)
Layer 4 — GOALS          (quarterly OKRs)
Layer 3 — PROJECTS       (multi-week efforts)
Layer 2 — WEEKLY REVIEW  (reflection + planning)
Layer 1 — TASKS          (daily execution in your tracker)
Layer 0 — DAILY LIFECYCLE (this system — the meetings that keep everything moving)
```

Without the daily lifecycle, tasks accumulate without review, projects stall without session logs, and patterns go undetected. The morning and evening meetings are the heartbeat.

### The Task System

A primary task tracker is the shared task layer between you and the executive:
- **Morning Brief**: `/start-day` syncs external trackers INTO the primary tracker. `/process-morning` can create new tasks from optional human input.
- **Evening meeting**: `/prep-evening` shows remaining tasks. `/process-evening` triages them (close, defer, keep) and proposes tomorrow's tasks.
- **Rule**: The primary tracker leads, external systems follow. The executive never auto-closes external items — only mirrors and flags.

### The Quick-Link Format

Every skill writes task displays in the same format — checked/unchecked checkboxes with area wikilinks, project hub links, and task source references:

```markdown
- [x] [[{Area}]] / [[{Project}]] — Wired trigger to server.py *(Tracker #332178)*
- [ ] [[{Area}]] / [[{Project}]] — Set up cron jobs *(Tracker, p3, 3d overdue)*
```

This consistency means yesterday's accomplishments (in `/start-day`), today's priorities (in `/process-morning`), evening accomplishments (in `/prep-evening`), and still-open tasks (in `/process-evening`) all look the same and can be read the same way.

---

## Related Notes

- [[Closed-Loop Systems - Feedback Property and Trigger Independence]] — Why this lifecycle is closed-loop, and why prep being scheduled is a trigger choice (not the source of coherence)
- [[AI Workstation Organization - Filesystem and Vault Mapping Architecture]] — The filesystem + vault layout this lifecycle runs on
- [[Human-AI Trust Boundary Architecture for 24-7 Agent Systems]] — Why every external action (task creation, status changes) goes through batch approval
- [[Multi-Agent Architecture Patterns]] — When and how to split prep/process into multiple specialized agents
- [[AI-Native Architecture - Business Logic as Agent Instructions]] — Where the rules each skill follows actually live
