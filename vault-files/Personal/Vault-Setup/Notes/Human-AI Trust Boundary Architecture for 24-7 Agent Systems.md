---
date: 2025-12-11
type: note
status: develop
area: personal
project: vault-setup
tags:
  - human-ai-trust
  - agent-architecture
  - 24-7-automation
---

# Human-AI Trust Boundary Architecture for 24/7 Agent Systems

## Overview

This note captures the architectural pattern for safely running AI agents 24/7 against issue trackers, codebases, and other systems while maintaining human control over critical decisions. The core principle: **AI is powerful at gathering, synthesizing, and proposing — but humans make the final call on anything that becomes "official."**

## Key Points

- AI agents should NEVER be able to mark issues as "Done" — they can only comment
- Work should be broken into "AI-sized" tasks that are small, testable, and reversible
- The trust boundary is enforced at the MCP server (or tool-permission) level by restricting available tools
- A long-term memory layer (knowledge graph, vector store, or structured notes) enhances this by remembering the "why" behind decisions, making agents smarter over time

## The Comment-Only Restriction Pattern

A hard architectural constraint that makes the trust boundary enforceable:

```
┌─────────────────────────────────────────────────────────────┐
│                 AI AGENT PERMISSIONS                        │
├─────────────────────────────────────────────────────────────┤
│  CAN DO:                                                    │
│     - Read issues                                           │
│     - Add comments                                          │
│     - Create branches                                       │
│     - Open PRs                                              │
│     - Add labels (like "needs-review")                      │
│     - Update internal subtasks                              │
│                                                             │
│  CANNOT DO:                                                 │
│     - Change issue status                                   │
│     - Mark issues as "Done"                                 │
│     - Close issues                                          │
│     - Delete anything                                       │
│     - Merge PRs (configurable)                              │
└─────────────────────────────────────────────────────────────┘
```

This is enforced at the **tool-permission level** — you simply don't give the agent the tool to update status. Most issue-tracker MCP servers can be filtered to only expose read + comment operations.

## The Spectrum of Trust

Not everything needs the same level of gate:

| Action | Risk Level | Gate Needed? |
|--------|------------|--------------|
| Read from tracker | Low | No gate |
| Add comment to issue | Low | No gate |
| Update issue status | Medium | **Batch approval** |
| Close/archive issue | High | **Explicit approval** |
| Create new issues | Medium | **Batch approval** |
| Delete anything | High | **Never auto-delete** |

## Trust Boundary Examples

### Example 1: Evening Sync Session

**Without Trust Boundary (Bad)**:
```
You: "Sync my day's work to the tracker"
AI: *automatically updates 15 issues*
AI: "Done! I updated all your tasks."
You: "Wait... you marked ABC-123 as done but I only did half of it!"
```

**With Trust Boundary (Good)**:
```
You: "Sync my day's work to the tracker"
AI: "Based on your git commits and files touched today, here's what I propose:

  PROPOSED UPDATES:
  ┌─────────────────────────────────────────────────────┐
  │ ABC-123: "Implement auth flow"                      │
  │   Current: In Progress                              │
  │   Proposed: In Progress (add comment about progress)│
  │   Evidence: 3 commits to auth/ folder              │
  ├─────────────────────────────────────────────────────┤
  │ ABC-124: "Fix header bug"                           │
  │   Current: In Progress                              │
  │   Proposed: Done                                    │
  │   Evidence: PR #42 merged, tests passing           │
  └─────────────────────────────────────────────────────┘

  Approve all? [Y/n] Or type issue IDs to modify."

You: "ABC-123 is actually blocked, not in progress. Approve the rest."
AI: *updates only ABC-124*
```

### Example 2: Morning Brief with Memory

The AI proposes what's important based on memory:

```
You: "/morning-brief"
AI: "Good morning. Here's what I've synthesized:

  FROM TRACKER:
  - 3 issues assigned to you, 1 is urgent (ABC-130)
  - Sprint ends in 2 days, 5 story points remaining

  FROM MEMORY:
  - Yesterday you decided to defer the caching refactor
  - Last week you noted ABC-130 depends on the API team's deploy
  - You mentioned wanting to finish auth before Friday

  FROM VAULT:
  - Your PRD for 'User Dashboard' is still in 'planned' status

  SUGGESTED PRIORITIES:
  1. Check with API team on ABC-130 blocker
  2. Continue auth work (2 commits away from done based on PR)

  Want me to update any tracker statuses or create tasks?"
```

### Example 3: 24/7 Agent Processing an Issue

**With Trust Boundary (Safe)**:
```python
while True:
    issue = tracker.get_next_issue(label="agent-ready")
    result = agent.process(issue)

    # Agent proposes, doesn't execute
    tracker.add_comment(issue, f"""
        Agent completed work. Proposed changes:
        - PR created: {result.pr_url}
        - Tests: {result.test_status}
        - Suggested status: Ready for Review

        @human Please review and update status manually.
    """)

    tracker.update_label(issue, "agent-ready", "needs-human-review")
```

## What Makes a Task "AI-Sized"?

The goal is to break work into chunks that are:

| Characteristic | Why It Matters |
|----------------|----------------|
| **Small** | AI can complete in one session without losing context |
| **Well-defined** | Clear inputs, clear expected outputs |
| **Testable** | AI can verify its own work (tests pass, linting clean) |
| **Reversible** | If AI messes up, easy to undo (it's just one small piece) |
| **Repeatable** | Similar to work AI has done before |

**Good AI tasks**:
- "Add endpoint GET /users/{id}"
- "Write unit tests for AuthService"
- "Create migration for adding `email_verified` column"
- "Fix lint errors in src/components/"

**Bad AI tasks** (too big/ambiguous):
- "Build the user dashboard" (too large)
- "Improve performance" (too vague)
- "Refactor the codebase" (too broad)

## The Two-Tier Breakdown Pattern

```
TRACKER (High-Level)             SUBTASKS (AI-Sized Chunks)
┌─────────────────────┐         ┌─────────────────────────────┐
│ USER STORY ABC-200  │         │ Task 1: Create migration    │
│ "Add user dashboard"│         │ Task 2: Add API endpoint    │
│                     │  ───►   │ Task 3: Write component     │
│ Status: In Progress │         │ Task 4: Add unit tests      │
│ (Human controls)    │         │ Task 5: Update docs         │
└─────────────────────┘         └─────────────────────────────┘
                                         │
                                         ▼
                                ┌─────────────────────────────┐
                                │ AI AGENT WORKS HERE         │
                                │                             │
                                │ - Picks up Task 2           │
                                │ - Writes the code           │
                                │ - Runs tests                │
                                │ - Opens PR                  │
                                │ - Comments on ABC-200:      │
                                │   "Completed Task 2,        │
                                │    PR #45 ready for review" │
                                └─────────────────────────────┘
```

**Key insight**: The AI works at the **subtask level**, but only the human can mark the **tracked issue** as done.

## The Complete 24/7 Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    HARNESS (24/7 Running)                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  while True:                                         │   │
│  │    1. Poll tracker for "agent-ready" issues          │   │
│  │    2. Reconstruct context (tracker + memory + PRD)   │   │
│  │    3. Spin up agent session with MCP servers         │   │
│  │    4. Agent works on issue                           │   │
│  │    5. Agent PROPOSES changes (doesn't auto-commit)   │   │
│  │    6. Notifies human (Slack/Telegram/comment)        │   │
│  │    7. Labels issue "needs-human-review"              │   │
│  │    8. Loop                                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    HUMAN (Async Review)                     │
│  - Reviews agent's work when convenient                     │
│  - Approves/rejects proposed changes                        │
│  - Updates tracker status manually                          │
│  - Agent learns from rejections (stored in memory layer)    │
└─────────────────────────────────────────────────────────────┘
```

**Key insight**: Agents work autonomously but propose; humans review asynchronously and confirm.

## How a Memory Layer Enhances This

A persistent memory layer (knowledge graph, vector store, structured notes) remembers the **why** behind decisions:

```
You (last week): "I'm deferring the caching refactor because
                  the API isn't stable yet"

Memory stores: {
  fact: "caching refactor deferred",
  reason: "API not stable",
  timestamp: "2024-12-03",
  related_to: ["ABC-120", "API stability"]
}

Agent (this week): *about to propose working on caching*
Agent: *queries memory* → "Oh, there's a reason this was deferred"
Agent: "I see you deferred caching last week due to API stability.
        Has that changed? Should I still skip this?"
```

The agent uses memory to **make smarter proposals** rather than blindly suggesting work you already decided against.

## Alert System Pattern

Since AI can only comment, your alert system becomes simple:

```
Tracker Comment Webhook → Slack/Telegram
   │
   └── "Agent commented on ABC-200:
        'Completed Task 2: Add API endpoint
         PR: github.com/repo/pull/45
         Tests: Passing
         Ready for human review'"
```

You review when convenient, not in real-time. The AI keeps working on other tasks while you review asynchronously.

## Why This Architecture Works

1. **AI handles volume** — Can work through 20 small tasks overnight
2. **Human handles judgment** — You decide what's actually "done"
3. **Trust is earned** — You can audit every AI action via comments
4. **Mistakes are contained** — One bad PR doesn't corrupt your tracker state
5. **Memory learns** — Rejected PRs become context for future agents

## Source of Truth by Phase

There is NO single "God" source of truth — it depends on the PHASE:

| Phase | Source of Truth | Why |
|-------|-----------------|-----|
| **Planning / Brainstorming** | Vault PRD / design notes | Humans decide what to build |
| **Confirmed Work** | Issue tracker | External stakeholder visibility |
| **Implementation Details** | Subtask breakdown | Local execution detail |
| **AI Memory / Context** | Memory layer (graph or vector store) | Facts extracted for agent continuity |

## Related Notes

- [[AI-Native Architecture - Business Logic as Agent Instructions]] — How permission callbacks and schemas enforce these rules in code
- [[Multi-Agent Architecture Patterns]] — Splitting work across specialist agents while preserving the trust boundary
- [[Agentic Department Architecture Patterns]] — Org-level shape of human-in-the-loop systems
- [[Closed-Loop Systems - Feedback Property and Trigger Independence]] — Why "the agent reviews its own state" is the foundation that lets humans review asynchronously
