---
date: 2026-02-23
type: note
status: develop
area: personal
project: vault-setup
tags:
  - multi-agent
  - architecture-patterns
  - ai-agents
  - business-automation
  - system-design
---

# Agentic Department Architecture Patterns - Reusable Framework for AI-Native Operations

## Core Idea

Organizing AI agents into **departments** (not flat task lists) creates clear ownership boundaries, natural information flow, and manageable complexity. This pattern mirrors real-world business structure — departments own domains, produce outputs, and hand off work to each other. The key insight: departments are not just folders, they are **pipeline stages** where one department's output feeds the next.

This note is framework-agnostic. Whether you use CrewAI, LangGraph, the Claude Agent SDK, or any other system, the department pattern applies.

---

## Why Departments, Not Flat Agents

A flat list of 7-10 agents (website-agent, social-agent, email-agent, research-agent...) creates two problems:

1. **No ownership boundaries** — Who decides the brand voice? The website agent? The social agent? Both? Neither?
2. **No information flow model** — How does market research reach the content creator? Through a shared database? A message? Magic?

Departments solve both by creating **bounded contexts** with explicit interfaces:

```
┌─ DEPARTMENT A ─────┐     output/     ┌─ DEPARTMENT B ─────┐
│                     │ ──────────────► │                     │
│  Owns: domain X     │                 │  Reads: A's output  │
│  Writes: output/    │ ◄────────────── │  Owns: domain Y     │
│  Reads: B's output  │     feedback    │  Writes: output/    │
└─────────────────────┘                 └─────────────────────┘
```

Each department can **read** other departments' outputs but only **write** to its own. This prevents conflicts and makes data flow explicit and auditable.

---

## The 3-5 Agent Sweet Spot

Production data from LangGraph shows that **over 75% of multi-agent systems become increasingly difficult to manage once they exceed 5 agents per group**. CrewAI's production experience confirms this — their recommended crew size is 3–5 agents.

This means:
- **3 departments** with 2–3 focused areas each is the sweet spot
- If a department grows beyond 5 sub-areas, split it into two departments
- A meta-agent or orchestrator can coordinate across departments without counting against department size

### The Three Universal Departments

Most businesses (not just startups) map to three core functions:

| Department | What It Owns | Output Type |
|-----------|-------------|-------------|
| **Build** (Product) | Everything the customer sees — website, product, brand, design | Assets, code, specifications |
| **Grow** (Growth/Marketing) | Getting in front of people — content, social, email, community | Content, campaigns, outreach |
| **Know** (Intelligence/Research) | Understanding the market — research, analysis, investor materials | Reports, databases, models |

These names are flexible. A SaaS company might call them Engineering, Marketing, and Analytics. A consulting firm might call them Delivery, Business Development, and Research. The pattern is the same.

---

## The Pipeline Cycle

Departments don't work in isolation — they form a cycle where outputs feed forward and feedback loops back.

```
        ┌──────────┐
        │   KNOW   │
        │ Research │
        │ Analysis │
        └────┬─────┘
   findings  │        ▲ traction data
   & data    │        │ & market feedback
             ▼        │
        ┌──────────┐  │  ┌──────────┐
        │   GROW   │──┘  │  BUILD   │
        │ Content  │◄────│ Product  │
        │ Marketing│     │ Design   │
        │ Outreach │────►│ Brand    │
        └──────────┘     └──────────┘
         brand assets      audience
         & copy            feedback
```

### Concrete Flow Examples

**Know → Grow**: Research finds that 78% of target consumers also look for "clean label" products. Growth uses this in a TikTok script: "Did you know 78% of [target audience] also want clean ingredients?"

**Build → Grow**: Brand department outputs the color palette (#FF6B35, #2E8B57). Growth uses these exact hex codes in Instagram stories and email headers.

**Grow → Know**: Email campaign hits 150 signups in week 2. Intelligence updates the pitch deck traction slide and customer acquisition assumptions.

**Know → Build**: Competitor analysis shows all existing products use similar packaging. Product positions with a differentiated design that appeals to a broader market.

---

## Department Anatomy

Each department needs four components:

### 1. Agent Persona (AGENT.md / agents.yaml)

Defines WHO the agent is when working in this department. Follows the **role + goal + backstory + constraints** pattern from CrewAI.

```markdown
# [Department] Lead

## Role
[Professional title — e.g., "Senior Growth Marketing Strategist"]

## Goal
[Measurable objective — e.g., "Build digital presence from 0 to 1000 followers in 4 weeks using $0 ad spend"]

## Backstory
[Experience narrative that shapes decision-making style]

## Constraints
- NEVER [dangerous action] — flag for human review
- ALWAYS [required check] before [action]
- [Domain-specific rules]

## Tools Available
- [What this agent can use]
- Read-only access to [other department]/output/

## Output Standards
- [Where outputs go]
- [What format]
- Always include REVIEW.md for human approval items
```

### 2. Task Tracking (TASKS.md / tracker issues)

What needs to be done, linked to external project management.

```markdown
- [ ] Draft homepage hero copy <!-- Tracker: WS-101 -->
- [ ] Build landing page HTML/CSS <!-- Tracker: WS-102 -->
- [x] Define brand color palette <!-- Tracker: WS-103, completed 2026-02-20 -->
```

### 3. Output Directory

Where the department writes its work products. Other departments read from here.

```
department/
├── sub-area-1/
│   ├── TASKS.md
│   └── output/          ← Generated artifacts go here
├── sub-area-2/
│   ├── TASKS.md
│   └── output/
└── output/              ← Cross-project department-level artifacts
```

### 4. Cross-Department Access Rules

Explicit read/write boundaries:

```
# In growth/AGENT.md:
- Read-only: build/branding/output/ (for brand assets)
- Read-only: know/market-research/output/ (for data)
- Write: growth/**

# In know/AGENT.md:
- Read-only: grow/output/ (for traction data)
- Write: know/**

# In build/AGENT.md:
- Read-only: know/output/ (for competitive positioning)
- Write: build/**
```

---

## Automation Layer

Departments need an automation layer (n8n, Zapier, Make, or code) for three categories of work:

### Category 1: Deterministic Pipelines (No Brain Needed)
- Signup → CRM → welcome email
- Tracker issue closed → update TASKS.md
- Social media post approved → schedule via Buffer

### Category 2: Agent-Triggered Execution
- Agent finishes research → automation routes brief to Growth agent
- Agent drafts content → automation sends for human approval → automation publishes

### Category 3: Scheduled Synthesis
- Monday 8 AM: collect all department outputs → AI synthesizes weekly report
- Friday: competitor monitoring → agent analyzes changes
- Daily: collect metrics → update dashboards

---

## Scaling Patterns

### Starting Small (Solo Founder + One Agent)
- One agent with persona switching (read AGENT.md per department)
- Manual handoffs (human moves information between departments)
- Shared memory, single context

### Growing (Solo Founder + Multiple Agents)
- Separate agents per department with isolated workspaces
- Automation handles handoffs and approval gates
- Inter-agent communication for quick messages

### Scaling (Small Team + Agent Fleet)
- Department leads (humans) review agent work per domain
- Meta-agent synthesizes cross-department activity
- Full automation pipeline with QA validators between handoffs
- Different models per department (cheap for routine, expensive for analysis)

---

## Real-World Validation

### Jacob Bank / Relay.app — 40+ Agents, 6 Departments
Most cited example. Former Director of PM at Gmail runs a million-dollar business with himself + 40 AI agents organized into Social Media, Blog & Website, Email, Lead Qualification, Community, and Partners departments. Key patterns: split by function AND platform, meta-agent for daily synthesis, scheduled cadence (competitive research Fridays, content ideas Saturdays).

**Source**: [Aakash Gupta - Million-Dollar Founder with 40 AI Agents](https://aakashgupta.medium.com/this-million-dollar-founder-has-no-marketing-team-just-40-ai-agents-083be103c8fd)

### CrewAI Flows — Cross-Department Pipelines
CrewAI's Flows feature connects multiple crews into business pipelines. `@start()` marks entry points, `@listen()` triggers on completion, `and_()` waits for ALL to complete (join pattern). 12M+ executions/day in production.

**Source**: [CrewAI Flows Docs](https://docs.crewai.com/en/concepts/flows)

### Rocketable (YC W25) — AI Replaces Full Org Chart
Acquires profitable SaaS companies and replaces the entire team with AI agents. Validates that a single operator + AI agents can run a real business.

### The Broader Trend
Solo founders using AI complete tasks 55% faster with 22% lower capital requirements. Solo-founder startups climbed from 22.2% (2015) to 38% (2024).

**Source**: [TechCrunch - AI agents and the one-person unicorn](https://techcrunch.com/2025/02/01/ai-agents-could-birth-the-first-one-person-unicorn-but-at-what-societal-cost/)

---

## Implementation Checklist

For any new project using the department pattern:

- [ ] Define 3 departments (Build/Grow/Know or your equivalents)
- [ ] Write AGENT.md persona for each department
- [ ] Create workspace directory structure with output/ directories
- [ ] Define cross-department read/write access rules
- [ ] Map the pipeline cycle (which department feeds which)
- [ ] Set up project management (tracker / GitHub Issues) with department labels
- [ ] Create TASKS.md files linked to external tracking
- [ ] Decide: one agent with personas or multiple agents
- [ ] Set up automation layer for handoffs
- [ ] Create a meta-agent or weekly synthesis for cross-department visibility

---

## Related Notes

- [[Agentic Startup Systems - Deep Research]] — Research survey on CrewAI, MetaGPT, LangGraph, Jacob Bank, production patterns
- [[Multi-Agent Architecture Patterns]] — The orchestration patterns each department uses internally
- [[AI-Native Architecture - Business Logic as Agent Instructions]] — How each department's rules are encoded in agent instructions
- [[Human-AI Trust Boundary Architecture for 24-7 Agent Systems]] — Where humans gate department outputs

### Sources

- [Anthropic - Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)
- [LangGraph Production Data - State of Agent Engineering](https://www.langchain.com/state-of-agent-engineering)
- [CrewAI Flows Docs](https://docs.crewai.com/en/concepts/flows)
- [Jacob Bank / Relay.app - Agent-First GTM](https://www.productgrowth.blog/p/agent-first-gtm-jacob-bank-relay-app)
- [Rocketable (YC W25)](https://www.ycombinator.com/companies/rocketable)
- [2026 Playbook for Reliable Agentic Workflows](https://promptengineering.org/agents-at-work-the-2026-playbook-for-building-reliable-agentic-workflows/)
