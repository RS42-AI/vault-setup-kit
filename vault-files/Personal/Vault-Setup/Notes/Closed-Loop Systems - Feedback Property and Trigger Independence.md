---
date: 2026-05-07
type: note
status: develop
area: personal
project: vault-setup
tags:
  - architecture
  - systems
  - closed-loop
  - feedback
  - ai-agents
---

# Closed-Loop Systems - Feedback Property and Trigger Independence

> **Why this note exists**: To name a concept that gets routinely conflated with three other things — autonomy, scheduling, and "self-driving" — when designing AI-assisted workstreams. A common framing error is to assume a cron trigger is what makes a system "truly closed-loop." It isn't. The feedback architecture is.

## The single idea

A **closed-loop system** is one where each action is informed by *sensing the current state*, and the action's effect is sensed in the next iteration. Feedback drives behavior.

```
sense → decide → act → sense → decide → act → …
        ↑___________________|
```

**Open-loop** is the absence of this property: blind action, no feedback.
- "Set the oven to 350" with no thermometer → open-loop
- A bash script that runs ten commands in sequence regardless of outcomes → open-loop
- A cron job that fires a workflow without checking what's already been done → open-loop

## Closed-loop is NOT the same as

It's commonly confused with three orthogonal properties:

| Property | What it actually means | Example of closed-loop *without* this property |
|---|---|---|
| **Autonomous** | Runs without human invocation each iteration | A closed-loop project where the human says "let's pick up where we left off" each session — the loop is closed, but it doesn't iterate on its own |
| **Scheduled** | Iterations happen on a timer | A while-loop agent in a tight `while not done:` loop — closed-loop, autonomous, but not scheduled (loops as fast as it can) |
| **Self-correcting** | The system fixes errors on its own | A closed-loop that flags errors and waits for human input to resolve — feedback exists, intervention is required |

A system can mix and match these:

| Configuration | Example |
|---|---|
| Closed-loop + autonomous + scheduled | Cron-driven AI agent that picks one task per iteration |
| Closed-loop + autonomous + not scheduled | While-loop agent (`while not done: do_next()`) |
| Closed-loop + human-invoked | A vault project that's properly architected but waits for "let's work on X" |
| Open-loop + scheduled | Any "fire and forget" cron that runs blindly without observing outcomes |

## Why the trigger axis is separate

The trigger is *how iterations get invoked*. The feedback architecture is *what makes the system coherent across iterations*. They're independent:

- A closed-loop system without a trigger sits idle but stays correct when invoked
- An open-loop system with a fast trigger drifts faster

Wiring a cron to an open-loop process doesn't produce a closed-loop system. It produces a fast-drifting open-loop process. Conversely, removing the cron from a closed-loop system doesn't make it open-loop — it just makes it manually invoked.

## Worked examples

| System | Closed-loop? | Autonomous? | Scheduled? |
|---|---|---|---|
| Thermostat | ✅ (reads temp, acts, reads new temp) | ✅ | continuous |
| Daily journaling system that reads yesterday's state before writing today's prompts | ✅ | ✅ | ✅ (cron-driven) |
| While-loop agent (`while not done: do_next()`) | ✅ | ✅ | ❌ (loops as fast as possible) |
| Ingestion workflow with a broken dedup query that silently caps at 100 records | ❌ — *tried* to read state but the query was wrong, so it acted on bad observations. Effectively open-loop despite intent. | ✅ (cron-driven) | ✅ |
| One-off `bash deploy.sh` | ❌ | ❌ | ❌ |
| A vault project hub + Tasks folder + devlogs that you pick up manually each time | ✅ | ❌ | ❌ |

The broken-dedup row is the most instructive: the system *intended* feedback (it had a "fetch existing records" step before each ingestion), but the query had a hardcoded `limit=100` that silently capped the dedup window. After ~100 records, the system stopped seeing new state and started acting on stale observations. **Closed-loop in form, open-loop in effect.** This is the most common failure mode — the architecture is right, but the feedback channel is broken.

## Why this matters for AI-assisted work

Stateless agents (Claude, any LLM) can drive closed-loop workstreams *as long as the state lives in files* rather than the agent's memory. The vault is the state.

The misconception this note prevents: "We need cron jobs to make this autonomous." Wrong direction. **First** you need closed-loop architecture — sense → act → re-sense — for the system to be coherent at all. **Then** the trigger choice (cron, on-demand, while-loop) determines how iterations get invoked. Skipping the first step and going straight to scheduling produces fast-drifting nonsense.

## When to design something as closed-loop

When any of these are true:
- The work is long-running (multi-session)
- State changes between iterations
- Multiple agents (or you-now and you-later) might pick it up
- Outcomes vary based on what's already happened
- The work would benefit from being resumable cold by anyone who reads the state

When NOT to bother:
- One-shot tasks (no next iteration to inform)
- Tasks where state doesn't matter (purely additive logging)
- Exploratory work where the goal isn't yet defined
- Anything that fits in a single session

## The "while-loop" agent reference

The simplest possible AI agent loop is:

```python
while not done():
    next_action = read_state()
    do(next_action)
```

It's both an *existence proof* (you don't need a complex framework — just a loop and a state-reader) and a *sanity check* (if your fancy framework can't beat this on a given task, the framework is overhead). It illustrates that closed-loop and autonomous can both be true with no scheduling involved at all — the while-loop *is* the trigger.

## Failure modes

Things that look closed-loop but aren't:

1. **Broken feedback channel** — the system reads state, but reads the wrong state
2. **Stale state document** — the canonical "current truth" gets out of date because no agent updates it after acting
3. **Unrecorded actions** — actions happen but aren't logged, so the next iteration can't see them
4. **State across systems** — the source of truth lives in someone's memory or a DM thread, not in a place the next agent can read

All four are common. All four turn closed-loop architecture into open-loop behavior.

## Related notes

- [[Agentic Thinking]] — The mental model for designing what an agent should do, sense, and act on
- [[AI-Native Architecture - Business Logic as Agent Instructions]] — Where the rules that drive the loop live
