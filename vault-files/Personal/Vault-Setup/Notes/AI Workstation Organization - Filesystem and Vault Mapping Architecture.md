---
date: 2026-03-22
type: note
status: develop
area: personal
project: vault-setup
tags:
  - organization
  - filesystem
  - knowledge-management
  - ai-workflow
---

# AI Workstation Organization - Filesystem and Vault Mapping Architecture

## Overview

Every machine set up for AI-assisted work follows a two-layer architecture: a **filesystem layer** (Finder/terminal) that holds the actual work artifacts, and a **knowledge layer** (Obsidian vault) that provides structure, routing, and context for both humans and AI agents. These two layers mirror each other through a consistent mapping pattern.

This is the foundational design principle behind how to organize any machine — whether it's a developer's primary laptop or a small-business operator's MacBook. The pattern is the same; only the content differs.

## Core Design Principle

> **The filesystem `projects/` directory is the AI workspace — where human-AI collaboration happens.** Every project directory on disk maps 1:1 to a project hub in the Obsidian vault. The `docs/` directory holds area-level content that maps to area-level vault notes. People and relationships live in Obsidian contacts, not the filesystem.

The insight: **this isn't a developer-specific pattern.** A small-business operator's machine uses the same architecture as a software development machine because the organizing principle is about AI-assisted work, not code specifically.

## The Two-Layer Architecture

### Layer 1: Filesystem (Finder/Terminal)

The filesystem follows one rule: **every directory at a given level is a category, not a mix of categories and items.**

```
~/{Workspace}/
├── projects/          ← AI workspaces (git repos, Claude Code projects)
│   ├── {project-a}/   ← One directory per active project
│   ├── {project-b}/
│   └── ...
├── docs/              ← Area-level business documents (not tied to a project)
│   ├── {category}/    ← Organized by document type (legal, finances, etc.)
│   └── ...
└── credentials/       ← API keys, service credentials (sensitive)
```

**What lives in `projects/`**: Any directory where AI-assisted work happens — git repos, Claude Code workspaces, automation projects, tool configurations. These are active workplaces, not document storage.

**What lives in `docs/`**: Business documents that belong to the area but not a specific project — legal paperwork, financial records, marketing assets, reference material. The filesystem equivalent of area-level vault notes (notes with `area:` set but no `project:` slug).

**What lives in `credentials/`**: API keys, service account files, backup codes. No vault equivalent — sensitive material stays off the knowledge layer.

### Layer 2: Obsidian Vault (Knowledge)

The vault follows the **hub-and-spoke architecture** with three routing properties (`type`, `area`, `project`) that determine where content appears:

```
~/{vault-root}/
├── 1. Daily/                          ← Daily hubs
├── 2. Projects/{Area}/{Project}/      ← Project hubs with Notes/, Dev Log/
├── 3. Areas/                          ← Area dashboards (auto-populate via Bases)
├── 4. Contacts/                       ← People (vendors, colleagues, partners)
│   ├── People/
│   └── Meetings/
├── 5. Resources/                      ← Curated reference material
├── 6. Main Notes/                     ← General knowledge (cross-cutting)
└── system-settings/                   ← Templates, images
```

### The Mapping

| Filesystem | Obsidian Vault | What Lives Here |
|---|---|---|
| `~/{Workspace}/projects/{name}/` | `2. Projects/{Area}/{Name}/` | AI workspace ↔ project documentation (hub, notes, devlogs) |
| `~/{Workspace}/docs/{category}/` | Area-level notes (`area:` set, no `project:`) | Business documents ↔ area dashboard content |
| `~/{Workspace}/credentials/` | (no vault equivalent) | Sensitive material — filesystem only |
| (no filesystem equivalent) | `4. Contacts/People/` | People, vendors, suppliers — knowledge layer only |
| (no filesystem equivalent) | `1. Daily/`, `6. Main Notes/` | Daily hubs, cross-cutting knowledge — knowledge layer only |
| `~/cloned-repos/` (if applicable) | (no vault equivalent) | Third-party reference repos — filesystem only |
| `~/archive/` (if applicable) | Projects with `status: archived` | Preserved inactive work |

**Key insight**: Not everything maps 1:1. Some things exist only on the filesystem (credentials, cloned repos). Some things exist only in the vault (contacts, daily notes, general knowledge). The mapping covers the intersection: **projects** and **area-level content**.

## How This Applies Per Machine

### Single-Area Workstation

A machine that serves one business or area gets one workspace directory. Example: a small-business operator's MacBook.

```
~/
├── {AreaName}/              ← Primary workspace
│   ├── projects/
│   │   ├── online-store/    ← e-commerce — AI-assisted work
│   │   ├── season-planning/ ← applications, planning, scheduling
│   │   └── machine-setup/   ← Machine setup project
│   ├── docs/
│   │   ├── legal/           ← EIN, LLC paperwork
│   │   ├── inventory/       ← Product catalog, pricing, photos
│   │   ├── finances/        ← Revenue, expenses, receipts
│   │   ├── marketing/       ← Flyers, social content, design exports
│   │   └── events/          ← Event applications, schedules
│   └── credentials/         ← API keys, etc.
└── {vault-root}/            ← Vault with this area + a personal area
```

The vault on this machine still has **multiple area dashboards** even though only one area is "primary," because Personal is always present and other areas may be assisted from this machine occasionally.

### Multi-Area Workstation

A machine that serves multiple business entities gets one workspace directory per entity:

```
~/
├── {AreaA}/                  ← e.g., a startup workspace
│   ├── projects/             ← active project repos
│   └── docs/                 ← area-level docs (legal, business, content, credentials)
├── {AreaB}/                  ← e.g., a family-business workspace
│   ├── projects/
│   └── docs/
├── cloned-repos/             ← Third-party reference repos (shared across areas)
├── archive/                  ← Stale personal repos (shared across areas)
└── {vault-root}/             ← Single vault serves ALL areas
```

The Obsidian vault on this machine has **multiple area dashboards** because it's the knowledge layer for all work done on this machine.

## Contacts as the People Layer

Vendors, suppliers, organizers, and business contacts live in Obsidian's `4. Contacts/People/` — NOT the filesystem. This is because:

1. **People are relationships, not documents** — a vendor isn't a file to store, they're a person with context, meeting history, and evolving relationships
2. **The Bases query pattern works perfectly** — each person note has `type: person`, `organization`, `role`, `relationship` properties, and a Bases query that auto-populates their interaction history
3. **Cross-referencing is native** — wikilinks connect vendors to meeting notes, project notes, and devlogs naturally

Example vendor contact:

```yaml
---
type: person
organization: "{Vendor / Business Name}"
role: Supplier
relationship: active
area: {area-slug}
---
```

With sections for: Meeting History (Bases query), Context (what they supply, pricing, order patterns), and Open Commitments.

## Why This Matters for AI

This architecture isn't just for human organization — it's what makes AI agents effective:

1. **Predictable paths** — an AI agent knows that project work lives in `~/{Workspace}/projects/{name}/` and project documentation lives in `2. Projects/{Area}/{Name}/`. No guessing.
2. **Frontmatter routing** — the three properties (`type`, `area`, `project`) tell AI exactly where to file new content and where to search for existing content.
3. **Clear boundaries** — AI knows not to look for vendor info in the filesystem (it's in contacts), not to store credentials in the vault (they're in the filesystem), and not to confuse area-level docs with project-specific work.
4. **Machine-portable** — the same pattern works on any machine. An AI agent trained on this architecture can operate on a developer laptop or a small-business operator's MacBook with the same mental model.

## Related Notes

- [[Personal OS Daily Lifecycle Architecture - The Executive Meeting Model]] — Daily lifecycle that runs on top of this filesystem + vault layout
- [[Closed-Loop Systems - Feedback Property and Trigger Independence]] — Why state-on-disk (this layout) is what lets stateless agents drive coherent loops
- [[AI-Native Architecture - Business Logic as Agent Instructions]] — Where the rules an agent follows on this layout actually live
