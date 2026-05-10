---
date: 2025-12-15
type: note
status: develop
area: personal
project: vault-setup
tags:
  - ai-native
  - agent-architecture
  - business-logic
  - llm-patterns
  - claude-agent-sdk
---

# AI-Native Architecture: Business Logic as Agent Instructions

## Overview

This note captures a fundamental architectural insight that surfaces whenever you try to replace a traditional backend with an AI-native one. The core realization: **business logic in traditional applications is equivalent to agent prompts, schemas, and permissions in AI-native applications**.

This insight resolves a key architectural question: when moving from a conventional backend to an AI-native approach, you don't lose business logic — you transform it.

---

## The Core Insight

### Traditional Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                   TRADITIONAL BACKEND                        │
├─────────────────────────────────────────────────────────────┤
│  UI → API → Business Logic Layer → Database                 │
│                    ↓                                         │
│         [Compiled Code]                                      │
│         - Validation rules                                   │
│         - Calculation logic                                  │
│         - Permission checks                                  │
│         - State transitions                                  │
└─────────────────────────────────────────────────────────────┘
```

### AI-Native Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    AI-NATIVE SYSTEM                          │
├─────────────────────────────────────────────────────────────┤
│  Human → Agent → Tools/MCP → Database                       │
│             ↓                                                │
│    [Agent Instructions]                                      │
│    - System prompt rules                                     │
│    - Tool schemas with validation                            │
│    - Permission callbacks                                    │
│    - Structured output constraints                           │
└─────────────────────────────────────────────────────────────┘
```

### The Equivalence

| Traditional Backend | AI-Native Equivalent |
|---------------------|----------------------|
| Validation rules in code | Zod/Pydantic schemas |
| Business logic functions | Agent system prompt + tools |
| Permission checks | `canUseTool` callbacks |
| API endpoints | Tool definitions |
| State machine transitions | Agent workflow instructions |
| Error handling | Structured error responses |

---

## Critical Finding: NOT One File Per Function

A key concern when designing AI-native systems: do you need to create a separate `.agent.md` file or prompt file for every business function?

**Answer: NO.** Research from authoritative sources confirms the correct pattern:

### What Works
- **ONE agent** with a comprehensive system prompt encoding all business rules
- **Structured schemas** (Zod/Pydantic) for typed inputs/outputs
- **Tool definitions** with validation built into the schema
- **Permission callbacks** for RBAC at runtime

### What Doesn't Work
- 100 separate prompt files for each business function
- One agent per validation rule
- Untyped, free-form tool definitions

---

## Research Validation

### Source 1: Martin Fowler - Action Classes Pattern

From [martinfowler.com/articles/function-call-LLM.html](https://martinfowler.com/articles/function-call-LLM.html):

The "Action Classes" pattern demonstrates how to structure LLM function calling. Key insight: business logic lives in the `execute()` method of action classes, NOT in separate files.

```python
class ShoppingAgent:
    def run(self, user_message: str, conversation_history: List[dict]) -> str:
        # Business rule: check for malicious intent
        if self.is_intent_malicious(user_message):
            return "Sorry! I cannot process this request."

        # Agent decides which action to take
        action = self.decide_next_action(user_message, conversation_history)
        return action.execute()

    def decide_next_action(self, user_message: str, conversation_history: List[dict]):
        response = self.client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=[...],
            tools=[
                {"type": "function", "function": SEARCH_SCHEMA},
                {"type": "function", "function": PRODUCT_DETAILS_SCHEMA},
                {"type": "function", "function": CLARIFY_SCHEMA}
            ]
        )

        # Deserialize to typed action class
        if tool_call.function.name == "search_products":
            return Search(**function_args)
        elif tool_call.function.name == "get_product_details":
            return GetProductDetails(**function_args)
```

**Key takeaway**: All tools are defined in ONE agent class. Business logic is in the action's `execute()` method.

### Source 2: LLM Function Design Pattern

The LLM Function design pattern shows ONE class per logical capability:

```java
public class transform_content extends LlmFunction<
    transform_content.Request, transform_content.Response> {

  // Typed request schema - NOT a separate file
  public record Request(
      String user_instructions,
      String original_content,
      String content_type) {}

  // Typed response schema - NOT a separate file
  public record Response(
      String transformation_summary,
      String transformed_content) {}

  // Tools available to this function - defined inline
  public static final List<ToolDefn> TOOLS = List.of(
      ContentTools.textValidatorTool,
      ContentTools.readabilityScorerTool
  );

  // System prompt - ONE template, not 100 files
  public static final String TEMPLATE = """
    systemMessage: |
      You are a professional content transformer...
    userMessage: |
      Follow the user instructions...
  """;
}
```

**Key takeaway**: Request, Response, Tools, and Template are all in ONE class definition.

### Source 3: Claude Agent SDK

The Claude Agent SDK provides the canonical pattern for AI-native business logic:

#### Permission Callbacks (RBAC)
```typescript
const agent = await createAgent({
  canUseTool: async (toolName, input) => {
    // Business rule: block destructive commands
    if (toolName === 'Bash') {
      const dangerousPatterns = ['rm -rf', 'dd if=', 'mkfs'];
      if (dangerousPatterns.some(pattern => input.command.includes(pattern))) {
        return {
          behavior: "deny",
          message: "Destructive command blocked for safety"
        };
      }
    }
    return { behavior: "allow" };
  }
});
```

#### Specialized Subagents (NOT Separate Files)
```typescript
agents: {
  "security-reviewer": {
    description: "Expert in security auditing",
    prompt: `You are a security expert. Review code for:
      - SQL injection vulnerabilities
      - XSS attack vectors
      - Authentication weaknesses`,
    tools: ["Read", "Grep", "Glob", "Bash"],
    model: "sonnet"
  },
  "performance-analyst": {
    description: "Performance optimization expert",
    prompt: `You are a performance optimization specialist...`,
    tools: ["Read", "Grep", "Glob", "Bash"],
    model: "sonnet"
  }
}
```

**Key takeaway**: Subagents are defined in ONE configuration object, not separate files.

---

## Key Principles for AI-Native Business Logic

### 1. Centralize Rules in System Prompts
Don't scatter business rules across 100 files. Put them in ONE comprehensive system prompt that the agent follows.

### 2. Use Typed Schemas for Validation
Zod/Pydantic schemas replace backend validation code. Invalid inputs are caught before the agent processes them.

### 3. Implement RBAC via Callbacks
`canUseTool` callbacks replace middleware permission checks. They run at the tool invocation boundary.

### 4. Structure Outputs Constrain Behavior
When an agent must output structured data (JSON matching a schema), it's constrained to valid outputs.

### 5. Human Approval Layer for High-Stakes Actions
For actions with real-world consequences (money movement, irreversible writes, public publishing), route through an explicit human approval step — a ticket, a draft, or a callback that pauses for confirmation. See [[Human-AI Trust Boundary Architecture for 24-7 Agent Systems]].

---

## Why This Matters

The architectural shift this note names is not "we replaced code with prompts." It's that **the locus of business logic moves from compiled, statically-checked code into natural-language instructions that an LLM interprets at runtime**. That has consequences:

- **Versioning matters more, not less.** A prompt change is a behavior change. Treat system prompts like code: review, diff, version.
- **Schemas are the safety net.** When the rule lives in prose, the typed input/output schema is what keeps a hallucinated tool call from corrupting state.
- **Permission callbacks are the last line of defense.** The agent might decide to do something the prompt forbids. `canUseTool` is the deterministic gate.
- **The agent IS the interface.** You may not need a UI for everything — a well-instructed agent with the right tools can replace a substantial fraction of CRUD screens.

---

## Related Notes

- [[Human-AI Trust Boundary Architecture for 24-7 Agent Systems]] — Where in this architecture humans must remain in the loop
- [[Multi-Agent Architecture Patterns]] — When ONE agent isn't enough and how to split it
- [[Agentic Department Architecture Patterns]] — Applying these ideas at the org/department level
- [[Closed-Loop Systems - Feedback Property and Trigger Independence]] — How agent-driven business logic stays coherent across iterations

---

## Questions for Further Research

1. How to handle complex multi-step workflows (e.g., tax-loss harvesting, multi-leg trades, refund flows)?
2. What's the right granularity for subagents vs. tools?
3. How to version/audit changes to system prompts (business rule changes)?
4. How to handle degraded mode when the agent can't reach the LLM?
