---
date: 2026-05-09
type: project
status: active
area: personal
project: vault-setup
goal_status: unscored
tags:
  - onboarding
  - vault
  - agentic-systems
---

## Overview

### Welcome — This Is Your Operating System

This vault is a **human-AI operating system**: a place where you and an AI assistant collaborate on work, projects, and life using the same files, structure, and shared context.

You can use it as a regular notes app and get value. As you add structure, the AI becomes better able to help because every note has a place and every place has a meaning.

### The One-Sentence Idea

> A vault where **business logic lives in instructions** the AI reads — not in code — so one person and a group of AI agents can run projects and organizations together.

### How This Is Structured

The vault uses a **hub-and-spoke** layout. Hubs are dashboard pages that auto-populate from frontmatter properties on every other note.

Three properties route every note:

- **`type`** — what kind of note (`note`, `task`, `project`, `devlog`, `meeting`, `goal`, and so on)
- **`area`** — which responsibility it belongs to (`personal`, `health`, `personal-finance`, and so on)
- **`project`** — which project, if any (a slug such as `home-buying` or `vault-setup`)

The full taxonomy and decision tree live in `AGENTS.md` at the vault root. That is also the file AI coding agents read to understand how to work inside the vault. `CLAUDE.md` imports it for Claude Code.

### Curriculum

Read these in order. They take about 5–10 minutes each.

#### 1. The Thesis — Why This Exists

- [[AI-Native Architecture - Business Logic as Agent Instructions]] — why instructions in Markdown are a real architecture.
- [[Human-AI Trust Boundary Architecture for 24-7 Agent Systems]] — where humans approve, where AI acts, and how to design that boundary.

#### 2. The Architecture — How Agents Are Organized

- [[Multi-Agent Architecture Patterns]] — manager, handoff, and specialist patterns.
- [[Agentic Department Architecture Patterns - Reusable Framework for AI-Native Operations]] — how to structure agents like a real organization.
- [[Overview of AI Agent Systems and Their Fundamental Overlap]] — how common agent frameworks relate.

#### 3. Where It Lives — The Vault as OS

- [[AI Workstation Organization - Filesystem and Vault Mapping Architecture]] — how the filesystem layout supports agents.
- [[Personal OS Daily Lifecycle Architecture - The Executive Meeting Model]] — the Morning Brief, workday, and optional Evening Entry loop.

#### 4. The Implementation Patterns

- [[Closed-Loop Systems - Feedback Property and Trigger Independence]] — the design rule that makes autonomous loops reliable.
- [[Agentic Thinking]] — the shift from writing prompts to designing agent capabilities and expectations.

#### 5. Deeper Dive (Optional)

- [[Agentic Startup Systems - Deep Research]] — a long-form research survey for when you want more depth.

### First Steps

- [[Add my first project]] — practice the project-creation flow with something real.
- [[Set up my first goal]] — anchor a project to an outcome.
- [[Set up my AGENTS.md]] — tailor the vault instructions to your areas, systems, and conventions.

### What "Done" Looks Like

Onboarding is complete when you have read the curriculum, added one real project with a task and devlog, set one goal, and tailored `AGENTS.md`. This project then remains available as reference material.

---

## Current Status

The starter vault is installed. Work through the active onboarding tasks below, then replace the examples with your own areas and projects.

---

## Active Tasks

```base
filters:
  and:
    - type == "task"
    - project == "vault-setup"
    - status == "todo" OR status == "active"
views:
  - type: table
    name: Onboarding Tasks
    order:
      - file.name
      - status
      - priority
    sort:
      - property: priority
        direction: ASC
```

---

## On Hold

```base
filters:
  and:
    - type == "task"
    - project == "vault-setup"
    - status == "on-hold"
views:
  - type: table
    name: On-Hold Onboarding Tasks
```

---

## Completed Tasks

```base
filters:
  and:
    - type == "task"
    - project == "vault-setup"
    - status == "done"
views:
  - type: table
    name: Completed Onboarding Tasks
```

---

## Resources

```base
filters:
  and:
    - type == "resource"
    - project == "vault-setup"
views:
  - type: table
    name: Onboarding Resources
    order:
      - file.name
      - date
```

---

## Knowledge Notes

```base
filters:
  and:
    - type == "note"
    - project == "vault-setup"
views:
  - type: table
    name: Onboarding Knowledge Notes
    order:
      - file.name
      - status
      - date
```

---

## Dev Log

```base
filters:
  and:
    - type == "devlog"
    - project == "vault-setup"
views:
  - type: table
    name: Onboarding Sessions
    order:
      - date
      - file.name
      - session_topic
    sort:
      - property: date
        direction: DESC
```

---

## Meetings

```base
filters:
  and:
    - type == "meeting"
    - project == "vault-setup"
views:
  - type: table
    name: Onboarding Meetings
```

---

## Related Projects

- [[Personal]] — the starter personal-area dashboard.
