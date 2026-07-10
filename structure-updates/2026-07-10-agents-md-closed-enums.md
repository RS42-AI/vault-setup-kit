---
id: 2026-07-10-agents-md-closed-enums
date: 2026-07-10
description: Merge AGENTS.md's closed type/status enums, the spec routing rule, and the Goal Rollup Contract section into vaults installed before this catalog existed.
---

## Context

`AGENTS.md` gained four related upgrades to its Frontmatter Taxonomy section since the last structure update in this catalog:

1. **Spec routing** — a new routing rule `6b` was inserted into the File Routing decision tree, between rule `6` (business idea) and rule `7` (curated reference material).
2. **Closed `type` list** — the `### \`type\` values` heading gained a `— CLOSED LIST` suffix plus an intro paragraph forbidding invented types, and the table gained a `spec` row (see [[2026-07-10-spec-type-and-template]] for the template that backs it).
3. **Closed `status` list, scoped per type** — a wholly new `### \`status\` values — CLOSED LIST (per type)` subsection: a table mapping each `type` to its allowed progression, a rule that `done` (and `passed`, for goals) is human-only, and a rule that a `note` reaching `done` is promoted to `type: resource`.
4. **Goal Rollup Contract** — a wholly new `### Goal Rollup Contract` subsection describing the evidence chain (`devlog → task → project hub → goal`) and requiring every active project hub to be goal-aligned, exploratory, or intentionally unscored.

This is a rulebook change, not a template change — it edits `AGENTS.md` itself, which the vault owner may have customized. The vault-audit skill parses this file's tables at runtime, so three header lines are **load-bearing** and must survive the merge byte-for-byte:

```
| Area folder | `area` slug |
| Value | Description | Where it lives |
| `type` | allowed `status` (progression →) | pause / terminal |
```

## Detection

This structure update **applies** if:

1. `AGENTS.md` exists at the vault root, AND
2. It does **not** already contain the status-table header line.

Check with: `grep -qF '| \`type\` | allowed \`status\` (progression →) | pause / terminal |' AGENTS.md`

- If `AGENTS.md` is missing entirely → inconsistent state (an earlier structure update already requires it); stop and ask the user to run `bash setup-vault.sh --update <vault>` first.
- If the header line is already present → record as **vacuously applied** and skip. A fresh install from this kit ships `vault-files/AGENTS.md` with the header already in place, so this structure update is **vacuously applied on every fresh install** — it only fires on instances installed from an older kit.

## Changes

### File: `AGENTS.md` (edit at vault root — merge section-by-section, do NOT replace the whole file)

Locate each anchor in the user's `AGENTS.md` and apply the corresponding edit in place. If an anchor doesn't match (the user has hand-edited that exact spot), stop and ask rather than guessing where to splice.

**Change 1 — insert routing rule `6b`.** In the File Routing decision tree, immediately after the line beginning `6. Business idea or brainstorm →` and before the line beginning `7. Curated reference material →`, insert:

```
6b. Design spec for an active project → `{Project}/Specs/` (`type: spec`, set `area:` + `project:`, default `status: draft`)
```

**Change 2 — upgrade the `type` values heading and table.** Replace the heading line `### \`type\` values` with:

```
### `type` values — CLOSED LIST

These are the **only** allowed `type:` values. If a note does not obviously fit
one of these, it is `note` — never invent a new type. Do **not** create `guide`,
`architecture`, `workflow`, `combined`, or anything else; a note's *character*
belongs in `tags:`, not in `type:`.
```

In the table immediately below, insert a `spec` row after the `project` row and before the `task` row:

```
| `spec` | Design document for project work | `{Project}/Specs/` |
```

**Change 3 — add the `status` values subsection.** Immediately after the `type` values table (and its "Frontmatter shapes — read the template" paragraph) and before `### Goal Rollup Contract` (or, if that subsection doesn't exist yet in the user's file, before whatever follows the `type` table), insert the full subsection:

```
### `status` values — CLOSED LIST (per type)

`status` is a closed enum **scoped by `type`** — pick only from the row for the
note's type. Any value not in the row is forbidden; map it to the nearest
allowed one (never write `in-progress`, `complete`, `planned`, `shipped`,
`backlog`, `pending`…).

| `type` | allowed `status` (progression →) | pause / terminal |
|--------|-----------------------------------|------------------|
| `task` | `todo` → `active` → `done` | `on-hold`, `archived` |
| `spec`, `project` | `draft` → `in-review` → `active` → `done` | `on-hold`, `superseded`, `archived` |
| `goal` | `active` → `done` (achieved) *or* `passed` (horizon expired, not fully achieved) | `archived` |
| `area-dashboard` | `active` → `done` | `archived` |
| `note`, `idea`, `thought` | `capture` → `done` | `superseded` |
| `devlog`, `meeting` | `capture` | — |
| `daily`, `journal`, `person`, `resource` | *(no `status` field)* | — |

**🔒 `done` is human-only.** An AI agent may write any status *except* `done`
(and `passed`, for goals) — marking something finished is a human decision.

**`note` → `resource` on completion.** A `note` that reaches `done` is a curated
keeper — promote it to `type: resource` in `5. Resources/{Area}/`. A `resource`
carries no lifecycle `status`. (This promotion, like any `done`, is human-only.)
```

**Change 4 — add the Goal Rollup Contract subsection.** Immediately after the `status` values subsection just inserted, add:

```
### Goal Rollup Contract

The vault should be able to prove goal movement from evidence, not vibes. The
canonical chain: `devlog.tasks[] → task (area, project, status) → project hub
(goal, optional quarter_goal/kr) → goal note (objective, KRs)`.

Every `type: project`, `status: active` hub must be scoreable or intentionally
unscored:

1. **Goal-aligned** — `goal: "[[Goal Note]]"` points to the area goal it serves.
2. **Exploratory** — `goal_status: discovery`: visible, not counted as progress yet.
3. **Intentionally unscored** — `goal_status: unscored`: active operational
   pressure that should appear in reviews without pretending to move a goal.
4. **Inactive** — `status: on-hold` / `superseded` / `archived` / `done` removes
   weekly active pressure.

Allowed `goal_status` values are `scored`, `discovery`, and `unscored`. An
active project with empty `goal:` and no `goal_status:` is drift.
```

(The `goal_status` mechanics themselves — the Project Hub / Goal Hub template changes that give this contract somewhere to write to — are a separate structure update: [[2026-07-10-goal-rollup-fields]]. This doc only lands the rulebook text.)

**Preserve user customizations.** This is a section-by-section merge, not a file replace. Leave the Areas table, Cross-System Identity, Privacy Inheritance, and any locally-added sections untouched. If the user has renamed or reworded the `type`/`status` tables such that the anchors above don't match cleanly, show them the intended change and ask before editing rather than guessing at a splice point.

## Verification

After applying, all must be true:

- `grep -cF '| Area folder | \`area\` slug |' AGENTS.md` returns `1` (unchanged, not duplicated).
- `grep -cF '| Value | Description | Where it lives |' AGENTS.md` returns `1`.
- `grep -cF '| \`type\` | allowed \`status\` (progression →) | pause / terminal |' AGENTS.md` returns `1`.
- `grep -q '\`spec\`' AGENTS.md` succeeds (the type table gained its row).
- `grep -q '6b\. Design spec' AGENTS.md` succeeds (the routing rule landed).
- `grep -q '### Goal Rollup Contract' AGENTS.md` succeeds.
- The user's Areas table rows (everything under `## Areas`) are byte-identical to before the edit (`git diff AGENTS.md` touches only the Frontmatter Taxonomy section and the one routing-tree line).

If any check fails, do NOT record the update as applied. Report which check failed and stop.

## Rollback

```
git checkout AGENTS.md
```

If the vault is not a git repo, manually remove the `6b.` routing line, revert the `### \`type\` values` heading and intro paragraph, remove the `spec` table row, and delete the `### \`status\` values` and `### Goal Rollup Contract` subsections.
