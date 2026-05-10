---
date: 2025-10-20
type: note
status: develop
area: personal
project: vault-setup
tags:
  - ai-agents
  - mcp
  - architecture-overview
---

# Comprehensive Overview of AI Agent Systems and Their Fundamental Overlap

## The Core Overlap: Agentic Automation

All these systems share a fundamental goal: moving beyond simple, single-turn LLM interactions to create **complex, multi-step, decision-making systems** where AI agents can use tools, process outputs, and make autonomous decisions to accomplish real-world tasks.

## The Critical Foundation: Model Context Protocol (MCP)

Before diving into the systems, it's essential to understand: **MCP is the universal adapter that gives agents their tools.**

### What MCP Provides

MCP is an open standard that enables AI models to interact with external tools and data sources through a standardized interface. Think of it as the "nervous system" that connects the AI "brain" to its "limbs" (tools and actions).

**Key MCP concepts:**
- **MCP Servers**: Programs that expose specific capabilities (data access, APIs, business logic)
- **MCP Clients**: Protocol clients that connect AI agents to servers
- **MCP Hosts**: Applications using AI (Claude Desktop, custom apps, n8n)

**Why this matters:** MCP is what allows all these different systems to share tools and capabilities. A tool exposed via MCP can be used by Claude, LangGraph agents, n8n workflows, or custom applications.

## Agent & Workflow Systems

### 1. Model Context Protocol (MCP) - The Tool Layer

**What it is:** The standardized communication protocol that gives agents access to tools.

**Role in agentic systems:**
- Provides the "limbs" for AI agents to execute actions in the world
- Standardizes how agents discover and use tools
- Enables tool reusability across different agent frameworks

**Two-way integration:**
- **As Server**: Exposes capabilities for agents to use
- **As Client**: Allows systems to consume external tools

### 2. n8n - The Workflow Automation Powerhouse

**What it is:** A low-code, node-based workflow automation platform with 300+ pre-built integrations.

**Core capabilities:**
- Visual workflow builder with drag-and-drop nodes
- AI Agent Node for adding intelligence to workflows
- Credential management for external services
- Can function as both MCP server and MCP client

**Critical dual role in agentic systems:**

#### n8n as MCP Server
Exposes your business workflows as tools that AI agents can call:

```
[Claude/External AI] → calls → [Your n8n Workflow as MCP Tool]
                                        ↓
                              [Complex Business Logic]
                                        ↓
                              [Returns Result to AI]
```

**Example:** Claude needs to process a customer complaint → calls your n8n workflow → workflow handles routing, CRM updates, notifications → returns status to Claude.

#### n8n as MCP Client
Your n8n workflows can call external MCP servers for enhanced capabilities:

```
[n8n Workflow] → calls → [External MCP Server]
                              ↓
                    [Gets data/capabilities]
                              ↓
                    [Continues workflow]
```

**Example:** Your n8n workflow needs web search → calls Brave Search MCP server → gets results → processes with AI → sends to Slack.

**Why n8n is powerful for agentic workflows:**
- Handles complex multi-service backend automation
- Exposes business processes as callable tools
- Bridges AI agents with existing business systems
- Self-hostable for data sovereignty

### 3. Claude Skills - The Capability Layer

**What it is:** Universal, portable task kits that work across all Claude platforms.

**Key innovation:**
- **Token efficiency through progressive disclosure** (98% reduction vs. traditional MCP loading)
- Acts as intelligent wrappers around MCP servers
- Loads detailed context only when needed
- Cross-platform compatible (Web, Desktop, Code, API, Agent SDK)

**Relationship to MCP:** Skills determine when to activate MCP tools, loading them only when relevant to the task.

### 4. Claude Code Plugins - The Distribution Layer

**What it is:** A packaging system that bundles multiple components for one-command installation.

**What plugins bundle:**
- Agents (specialized AI personalities)
- Skills (expertise modules)
- Slash Commands (user triggers)
- MCP Servers (external integrations)
- Hooks (event automation)

**Purpose:** Makes complex agentic capabilities easily shareable and installable.

### 5. Claude Agent SDK - The Application Layer

**What it is:** A production-ready programmatic framework for building custom AI agents from scratch.

**Core capabilities:**
- Full control over agent behavior, tools, and context management
- Built-in permission framework and session management
- Automatic context window optimization
- Integration with MCP for extensibility

**Use case:** Building standalone AI applications or custom business logic requiring precise programmatic control.

### 6. LangGraph - The Orchestration Layer

**What it is:** A low-level orchestration framework for building stateful, long-running AI agents.

**Key features:**
- State-based workflows with explicit transitions
- Durable execution (agents persist through failures)
- Support for diverse control flows (single-agent, multi-agent, hierarchical)
- Fine-grained control over cognitive architecture

**The agent IS the graph:** In LangGraph, the compiled graph of nodes, edges, and state definitions becomes the agent itself.

**Integration with MCP:** LangGraph agents can be exposed as MCP tools, enabling hierarchical agent systems where specialized agents delegate to other agents.

## The Two Pillars of Agentic Workflows

### Pillar 1: Tools (via MCP)

**MCP provides the "what" — the capabilities agents can use:**
- Data access (databases, knowledge graphs, vector stores)
- External services (APIs, web search, file systems)
- Business processes (n8n workflows, custom logic)
- Specialized functions (calculations, transformations)

### Pillar 2: Workflows (via Orchestration Frameworks)

**LangGraph, n8n, and Agent SDK provide the "how" — the decision-making and execution logic:**
- Multi-step reasoning and planning
- State management across interactions
- Conditional logic and branching
- Error handling and recovery
- Agent coordination and delegation

## How They Work Together: The Complete Picture

```
┌─────────────────────────────────────────────────────────┐
│              MCP (Tool Discovery & Access)              │
│         The universal protocol for agent tools          │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│          n8n (Business Process Automation)              │
│    • As MCP Server: Exposes workflows as tools          │
│    • As MCP Client: Uses external tools in workflows    │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│        LangGraph (Complex Agent Orchestration)          │
│    Stateful, multi-agent workflows with MCP tools       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│         Claude Agent SDK (Custom Applications)          │
│    Production agents leveraging MCP and workflows       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│           Claude Skills (Capability Modules)            │
│    Reusable expertise wrapping MCP servers              │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│         Claude Plugins (Distribution Bundles)           │
│    Packaged agents, skills, and MCP integrations        │
└─────────────────────────────────────────────────────────┘
```

## Real-World Integration Example

### Building a Financial Analysis System

**1. MCP Layer - Tool Foundation:**
- SEC Filings MCP Server (provides document access)
- Stock Data API MCP Server (provides market data)
- n8n workflows exposed as MCP tools (business logic)

**2. n8n Layer - Business Automation:**
- **As MCP Server:** Exposes "Generate Investment Report" workflow
- **As MCP Client:** Calls SEC Filings and Stock Data MCP servers
- Handles data processing, formatting, distribution

**3. LangGraph Layer - Agent Orchestration:**
- Main Investment Analyst agent (orchestrator)
- SEC Filings Specialist agent (fundamental analysis)
- Technical Analysis Specialist agent (market analysis)
- Agents delegate to each other via MCP

**4. Skills Layer - Reusable Expertise:**
- Financial Analysis Skill (wraps MCP servers)
- Report Generation Skill (formatting logic)
- Progressive loading of detailed financial knowledge

**5. Plugin Layer - Easy Distribution:**
- Bundle all agents, skills, and MCP configurations
- One-command installation for team members
- Standardized financial analysis workflow

**6. Agent SDK Layer - Custom Application:**
- Production-ready investment analysis app
- Integrates with internal systems
- Custom authentication and permissions

## The Fundamental Overlap

### All Systems Enable:

1. **Multi-step autonomous workflows** — Moving beyond single-turn interactions
2. **Tool-based architecture** — Agents using external capabilities via MCP
3. **Composability** — Building complex systems from modular components
4. **State management** — Maintaining context across interactions
5. **Hierarchical delegation** — Specialized agents working together

### The Key Distinction: MCP vs. Workflows

**MCP provides the TOOLS (the "what"):**
- Access to data sources
- External service integrations
- Business process capabilities
- Standardized tool discovery

**Orchestration frameworks provide the WORKFLOWS (the "how"):**
- Decision-making logic
- Multi-step planning
- State transitions
- Agent coordination
- Error handling

**Together they create agentic systems:** AI agents that can reason about what to do (workflows) and actually do it (tools via MCP).

## Why This Ecosystem is Powerful

### 1. Universal Tool Sharing
MCP means a tool built once can be used by Claude, LangGraph agents, n8n workflows, or custom applications.

### 2. Flexible Orchestration
Choose the right orchestration layer for your needs:
- **n8n**: Low-code business automation
- **LangGraph**: Complex stateful agents
- **Agent SDK**: Custom production applications

### 3. Progressive Complexity
Start simple (Skills/Plugins) and graduate to complex (LangGraph/SDK) as needs grow.

### 4. Hybrid Architectures
Combine approaches:
- LangGraph agent using n8n workflows as tools
- Agent SDK leveraging Skills for domain knowledge
- n8n workflows calling LangGraph agents via MCP

## Key Insight

**These aren't separate technologies to choose between — they're complementary layers in a unified ecosystem:**

- **MCP** = The universal tool protocol (enables capabilities)
- **n8n** = The business automation bridge (connects AI to existing systems)
- **LangGraph** = The orchestration engine (complex agent workflows)
- **Skills** = The knowledge modules (reusable expertise)
- **Plugins** = The distribution mechanism (easy sharing)
- **Agent SDK** = The application framework (production deployment)

The fundamental overlap is that **all these systems work together to enable AI agents that can autonomously execute multi-step workflows using tools**, with MCP serving as the universal connector and orchestration frameworks providing the decision-making logic.

## Related Notes

- [[Multi-Agent Architecture Patterns]] — Once you have these primitives, how do you compose them?
- [[Agentic Department Architecture Patterns]] — Department-shaped composition for AI-native operations
- [[AI-Native Architecture - Business Logic as Agent Instructions]] — Where the rules an agent follows actually live in this stack
- [[Agentic Thinking]] — The mental model that ties these layers together
