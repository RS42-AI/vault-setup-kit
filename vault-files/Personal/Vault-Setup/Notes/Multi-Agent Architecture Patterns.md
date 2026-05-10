---
date: 2024-12-24
type: note
status: develop
area: personal
project: vault-setup
tags:
  - multi-agent
  - architecture-patterns
  - claude-code
  - agent-development
---

# Multi-Agent Architecture Patterns

## Overview

Comprehensive reference for multi-agent architecture patterns in AI agent development. Synthesizes insights from the Claude Agent SDK documentation, Microsoft Azure AI design patterns, and Anthropic's production multi-agent research system. Worked example: a "morning brief" assistant that pulls from several work and personal data sources in parallel and synthesizes a daily summary.

## Pattern 1: Skill-Centric Architecture

Skills are knowledge modules loaded into the agent's context. The agent reads skill instructions and uses MCP tools directly without spawning separate agents.

### Token Flow

```
User → Command → Loads Skill → Agent uses tools directly → Response
```

### Characteristics

| Aspect | Description |
|--------|-------------|
| **Execution** | Single context, no agent spawning |
| **Token Usage** | Efficient — no agent overhead |
| **Context Sharing** | Full — skill sees entire conversation |
| **Isolation** | None — all operations in main thread |

### When to Use

- Single data source operations
- Simple, straightforward queries
- Token efficiency is critical
- Need full conversation context
- Quick one-off lookups

### Example

A "vault reader" skill loads search patterns into context, then the agent searches the vault directly using MCP tools.

---

## Pattern 2: Agent-Centric (Orchestrator-Worker)

An orchestrator agent coordinates the workflow by spawning specialized worker agents. Workers return structured data; the orchestrator synthesizes the final output.

### Token Flow

```
User → Command → Orchestrator → [Worker1, Worker2, Worker3] → Synthesize → Response
```

### Characteristics

| Aspect | Description |
|--------|-------------|
| **Execution** | Distributed across multiple agents |
| **Token Usage** | Higher — ~15× more than single context |
| **Context Sharing** | Isolated — each agent has own context |
| **Isolation** | Strong — failures don't cascade |

### When to Use

- Multiple data sources requiring synthesis
- Complex multi-step reasoning
- Tasks that can run in parallel
- When isolation prevents context pollution
- Structured, repeatable workflows

### Example

A morning-brief assistant: an orchestrator (Sonnet) spawns 4 Haiku gatherers in parallel, each pulling from a specific data source (issue tracker, calendar/meeting notes, vault, personal task system), then synthesizes the results into one digest.

---

## Microsoft's 5 Orchestration Patterns

From Microsoft Azure AI Agent Design Patterns documentation.

### 1. Sequential Pattern

Linear pipeline where each agent processes the previous agent's output.

```
Agent A → Agent B → Agent C → Final Output
```

**Use Cases**: Document processing, approval workflows, multi-stage transformations

**Strengths**: Simple flow, easy to debug, clear data lineage

**Weaknesses**: No parallelization, bottleneck at each stage

### 2. Concurrent Pattern

Parallel execution where multiple agents work simultaneously, results aggregated.

```
         ┌→ Agent A ─┐
Request ─┼→ Agent B ─┼→ Aggregator → Response
         └→ Agent C ─┘
```

**Use Cases**: Multi-source data gathering, parallel analysis, speed-critical operations

**Strengths**: Fast execution, fault isolation per agent, scalable

**Weaknesses**: Complex aggregation logic, potential for inconsistent results

The morning-brief example uses this pattern — 4 gatherers run in parallel, the orchestrator aggregates.

### 3. Group Chat Pattern

Shared conversation thread with a chat manager coordinating multiple agents.

```
┌─────────────────────────────┐
│     Shared Conversation     │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │Agt A│ │Agt B│ │Agt C│   │
│  └─────┘ └─────┘ └─────┘   │
│         Chat Manager        │
└─────────────────────────────┘
```

**Use Cases**: Collaborative problem-solving, debates, creative brainstorming

**Strengths**: Rich collaboration, emergent solutions, diverse perspectives

**Weaknesses**: Coordination overhead, potential for circular discussions

### 4. Handoff Pattern

Dynamic delegation between specialized agents based on task requirements.

```
Request → Router Agent → Specialist A (or B or C) → Response
```

**Use Cases**: Customer service escalation, triage systems, expertise routing

**Strengths**: Efficient resource use, deep specialization, flexible routing

**Weaknesses**: Routing complexity, potential for loops

### 5. Magentic Pattern

Open-ended exploration with a dynamic task ledger for complex problem-solving.

```
┌─────────────────────────────────┐
│         Task Ledger             │
│  [ ] Task 1  [x] Task 2         │
│  [ ] Task 3  [ ] Task 4...      │
├─────────────────────────────────┤
│   Agents dynamically claim      │
│   and complete tasks            │
└─────────────────────────────────┘
```

**Use Cases**: Research, exploration, complex problem decomposition

**Strengths**: Adaptive, handles unknown scope, emergent task discovery

**Weaknesses**: Less predictable, harder to monitor progress

---

## Anthropic's Production Lessons

From Anthropic's engineering blog on their multi-agent research system.

### Key Insights

| Lesson | Detail |
|--------|--------|
| **Token Economics** | Multi-agent uses ~15× more tokens than chat interactions |
| **Orchestrator-Worker Preferred** | Lead agent coordinates, workers execute specific tasks |
| **Parallel Subagents** | Spawn multiple agents simultaneously for speed |
| **Structured Handoffs** | Clear input/output contracts between agents (JSON schemas) |
| **Model Tiering** | Expensive model (Sonnet) for orchestration, cheap model (Haiku) for workers |

### Model Tiering Strategy

```
┌────────────────────────────────────────┐
│  Orchestrator (Sonnet)                 │
│  - Complex reasoning                   │
│  - Synthesis and judgment              │
│  - Final output generation             │
└─────────────────┬──────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    ▼             ▼             ▼
┌────────┐   ┌────────┐   ┌────────┐
│Worker 1│   │Worker 2│   │Worker 3│
│(Haiku) │   │(Haiku) │   │(Haiku) │
│Fast    │   │Fast    │   │Fast    │
│Focused │   │Focused │   │Focused │
└────────┘   └────────┘   └────────┘
```

**Rationale**: Haiku workers are 10–20× cheaper and faster than Sonnet. Use expensive models only where complex reasoning is required.

---

## Architecture Decision Framework

```
┌─────────────────────────────────────────────────────────────────┐
│                    WHEN TO USE EACH PATTERN                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Use SKILL-CENTRIC when:          Use AGENT-CENTRIC when:       │
│  ─────────────────────            ──────────────────────        │
│  • Single data source             • Multiple data sources       │
│  • Simple operations              • Complex synthesis           │
│  • Token efficiency critical      • Parallelization needed      │
│  • Need conversation context      • Isolation preferred         │
│  • Quick one-off queries          • Structured workflows        │
│                                                                  │
│  Examples:                        Examples:                     │
│  • Quick vault search             • Morning brief / digest      │
│  • Single tracker update          • Project analysis            │
│  • Memory fact lookup             • Cross-system reporting      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Decision Tree

```
                    ┌─────────────────┐
                    │ How many data   │
                    │ sources?        │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              │              ▼
         Single              │          Multiple
              │              │              │
              ▼              │              ▼
    ┌─────────────────┐      │    ┌─────────────────┐
    │ Skill-Centric   │      │    │ Can tasks run   │
    │ Pattern         │      │    │ in parallel?    │
    └─────────────────┘      │    └────────┬────────┘
                             │             │
                             │    ┌────────┼────────┐
                             │    ▼                 ▼
                             │   Yes               No
                             │    │                 │
                             │    ▼                 ▼
                             │ Concurrent      Sequential
                             │ Pattern         Pattern
                             │
                             │    Need dynamic routing?
                             │    → Handoff Pattern
                             │
                             │    Open-ended exploration?
                             │    → Magentic Pattern
```

---

## Worked Example: Morning Brief Assistant

A practical implementation that combines multiple patterns.

### Architecture

```
/morning-brief (command)
       │
       ▼
┌─────────────────────────────────────┐
│  brief-orchestrator (Sonnet)        │  ← Orchestrator-Worker
│  - Concurrent orchestration         │  ← Microsoft's Concurrent Pattern
│  - Token-efficient workers (Haiku)  │  ← Model tiering
└──────────────┬──────────────────────┘
               │
    ┌──────────┼──────────┬──────────┐    ← Parallel spawning
    ▼          ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Issue   │ │Meeting │ │ Vault  │ │Personal│
│Tracker │ │ Notes  │ │  +     │ │ Task   │
│(Haiku) │ │(Haiku) │ │ Memory │ │Tracker │
│        │ │        │ │(Haiku) │ │(Haiku) │
└────────┘ └────────┘ └────────┘ └────────┘
```

### Source of Truth Hierarchy

```
PRIMARY:    Issue tracker + meeting notes (defines work)
CONTEXT:    Vault + memory layer (enriches understanding)
TRACKING:   Personal task tracker (personal reflection only)
```

### Key Implementation Decisions

| Decision | Rationale |
|----------|-----------|
| Sonnet orchestrator | Complex synthesis requires strong reasoning |
| Haiku gatherers | Simple data retrieval, cost-effective |
| JSON output contracts | Structured handoffs prevent miscommunication |
| Parallel spawning | All gatherers in single dispatch call |
| Source hierarchy | Clear priority when data conflicts |

---

## Skill vs Agent Role Clarification

In an agent-centric architecture, skills can still serve purposes:

| Role | Description |
|------|-------------|
| **Developer Reference** | Documentation for humans building/maintaining agents |
| **Hybrid Entry Point** | Allow both skill-based and agent-based invocation |
| **Tool Consolidation** | Central registry of MCP tools and patterns |
| **Fallback Mode** | Simpler execution when full orchestration not needed |

**Recommendation**: In purely agent-centric implementations, consider converting SKILL.md to README.md or removing if agents are fully self-contained.

---

## Related Notes

- [[AI-Native Architecture - Business Logic as Agent Instructions]] — Where the rules each agent follows are encoded
- [[Human-AI Trust Boundary Architecture for 24-7 Agent Systems]] — Trust boundaries between orchestrator, workers, and humans
- [[Agentic Department Architecture Patterns]] — Multi-agent patterns scaled to org/department-shaped systems
- [[Overview of AI Agent Systems and Their Fundamental Overlap]] — Why these patterns recur across personal, professional, and product agent systems

---

## Sources

- Claude Agent SDK Documentation
- Microsoft Azure AI Agent Design Patterns
- Anthropic Engineering Blog: "How we built our multi-agent research system"
