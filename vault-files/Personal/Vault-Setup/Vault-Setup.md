---
date: 2026-05-09
type: project
status: active
area: personal
project: vault-setup
tags:
  - onboarding
  - vault
  - agentic-systems
---

## Welcome — This Is Your Operating System

This vault is more than a notes app. It's a **human-AI operating system**: a place where you and an AI assistant collaborate on your work, your projects, your life — using the same files, the same structure, the same shared context.

You can use it as a regular notes app and get value. But the design rewards going further: as you add structure, the AI gets smarter about helping you, because every note has a place and every place has a meaning.

This project page is your orientation. Read the notes in [[#Curriculum]] in order, do the [[#First Steps]] tasks, and you'll have a working understanding of the system in under an hour.

---

## The One-Sentence Idea

> A vault where **business logic lives in instructions** the AI reads — not in code — so a single human and a small army of AI agents can run an organization, a business, or a life together.

If that sentence raises questions, the curriculum below answers them.

---

## How This Is Structured

The vault uses a **hub-and-spoke** layout. Hubs are dashboard pages that auto-populate from frontmatter properties on every other note. You don't manually maintain dashboards — they update themselves as you write.

Three properties on every note do the routing:

- **`type`** — what kind of note (`note`, `task`, `project`, `devlog`, `meeting`, `goal`, etc.)
- **`area`** — which life area it belongs to (`personal`, `health`, `personal-finance`, etc.)
- **`project`** — which project, if any (slug like `home-buying` or `vault-setup`)

Set those three properties and the note shows up where it should — on the area dashboard, on the project hub, in your daily note. No manual filing.

The full taxonomy and decision tree live in `CLAUDE.md` at the vault root — that's also the file the AI reads to understand how to behave inside your vault.

---

## Curriculum

Read these in order. They take ~5–10 minutes each. Together they give you the model for what this system is and why it works.

### 1. The Thesis — Why This Exists

- [[AI-Native Architecture - Business Logic as Agent Instructions]] — the headline idea. Why instructions in markdown are a real architecture, not a hack.
- [[Human-AI Trust Boundary Architecture for 24-7 Agent Systems]] — where humans approve, where AI acts, and how to design the line between them.

### 2. The Architecture — How Agents Are Organized

- [[Multi-Agent Architecture Patterns]] — the building blocks (manager, handoff, specialist) and when each applies.
- [[Agentic Department Architecture Patterns]] — how to structure agents like a real org: departments, roles, escalation paths.
- [[Overview of AI Agent Systems and Their Fundamental Overlap]] — the lay-of-the-land map of agent frameworks and how they relate.

### 3. Where It Lives — The Vault as OS

- [[AI Workstation Organization - Filesystem and Vault Mapping Architecture]] — why hub-and-spoke works for AI, and how the filesystem layout matches it.
- [[Personal OS Daily Lifecycle Architecture - The Executive Meeting Model]] — a worked example of the full daily loop: morning prep, journal, work, evening reflection.

### 4. The Implementation Patterns

- [[Closed-Loop Systems - Feedback Property and Trigger Independence]] — the design rule that makes autonomous loops actually work.
- [[Agentic Thinking]] — the mental shift: stop writing prompts, start designing for an agent that has expectations and capabilities.

### 5. Deeper Dive (Optional)

- [[Agentic Startup Systems - Deep Research]] — long-form research survey of how agentic businesses are actually being built today. Read when you want depth, not on day one.

---

## First Steps

Three concrete tasks to do once you've read the curriculum. Each is a real `type: task` note in your vault — opening it gives you the steps.

- [[Add my first project]] — practice the project-creation flow with something real
- [[Set up my first goal]] — anchor a project to an outcome, learn the goals system
- [[Set up my AGENTS.md]] — run an AI-assisted session that tailors the vault's instruction file to your areas, your external systems, and your conventions

---

## What "Done" Looks Like

You're done with onboarding when:
- You've read the 9 curriculum notes
- You have one real project of your own with a hub, at least one task, and at least one devlog
- You've set at least one quarterly goal
- You've edited `CLAUDE.md` to reflect your areas, projects, and conventions

After that, this `Vault-Setup` project becomes reference material — keep it around, but it stops being active work.

---

## Related

- [[Personal]] — your personal area dashboard
- `CLAUDE.md` (vault root) — the AI's instruction manual for this vault
