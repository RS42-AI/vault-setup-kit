---
id: 2026-07-26-relationship-verbs-ontology
date: 2026-07-26
description: Add the "Relationship verbs — CLOSED LIST" ontology section to AGENTS.md so typed links between notes come from a ratified verb vocabulary, and wire it into the Note Creation Procedure.
---

## Context

`AGENTS.md` gained a third closed enum alongside `type` and `status`: **relationship verbs**. Typed links between notes (`blocked_by:`, `goal:`, `uses_system:`, `informs:`, `owned_by:`, …) are now a closed vocabulary — an AI agent may only write a verb field that appears in the table, and must *propose* (never invent) new verbs. This is the contract the `write-note` skill (AI-OS Lite ≥ 0.5.0) lints against, and the vault-audit contract loader parses the table at runtime.

Two edits land:

1. **A new `### Relationship verbs — CLOSED LIST (the ontology T-box)` subsection** at the end of the Frontmatter Taxonomy section (after the Goal Rollup Contract, before `## Devlog Task Linking`).
2. **One sentence appended to step 3 of the Note Creation Procedure**, pointing note authors at the verb table when a link can be stated as a sentence.

This is a rulebook change, not a template change — it edits `AGENTS.md` itself, which the vault owner may have customized. The vault-audit and write-note skills parse this table at runtime, so its header line is **load-bearing** and must survive the merge byte-for-byte:

```
| Verb | Meaning (A —verb→ B) | Written as |
```

## Detection

This structure update **applies** if:

1. `AGENTS.md` exists at the vault root, AND
2. It does **not** already contain the verbs-table header line.

Check with: `grep -qF '| Verb | Meaning (A —verb→ B) | Written as |' AGENTS.md`

- If `AGENTS.md` is missing entirely → inconsistent state (an earlier structure update already requires it); stop and ask the user to run `bash setup-vault.sh --update <vault>` first.
- If the header line is already present → record as **vacuously applied** and skip. A fresh install from this kit ships `vault-files/AGENTS.md` with the section in place, so this update is **vacuously applied on every fresh install** — it only fires on instances installed from an older kit.
- This update assumes [[2026-07-10-agents-md-closed-enums]] has been applied (it splices after the Goal Rollup Contract). If that update is still pending, apply it first.

## Changes

### File: `AGENTS.md` (edit at vault root — merge section-by-section, do NOT replace the whole file)

**Change 1 — add the Relationship verbs subsection.** Immediately after the `### Goal Rollup Contract` subsection (its last line begins `active project with empty`) — or, in a vault whose `AGENTS.md` has no Goal Rollup Contract (team edition), after the `### \`status\` values` subsection — and before the next `##`-level heading, insert:

```
### Relationship verbs — CLOSED LIST (the ontology T-box)

Typed relationships between notes are a **closed enum**, same species as `type`/`status`. A typed link is an assertion — it must be sayable as a sentence `A —verb→ B`; **no sentence, no link**. Plain prose wikilinks remain allowed as untyped ambience, but agents may only *rely* on typed edges. Storage: **frontmatter list properties on the subject note**, values are wikilinks — never inline body fields (Bases reads properties).

| Verb | Meaning (A —verb→ B) | Written as |
|---|---|---|
| `blocks` / `unlocks` | B waits on A / completing A enables B | `blocked_by:` (on the blocked note) / `unlocks:` |
| `serves_goal` | work advances goal G | `goal:` / `quarter_goal:` (plus `kr` — a plain label, not a link field) |
| `supersedes` | A replaces B as canonical | `status: superseded` + callout on B |
| `evidences` | A is proof-of-work for B | devlog `tasks:` |
| `part_of` | containment | `project:` / `area:` (+ folder placement) — **never a separate field** |
| `uses_system` | process/project runs on this tool/system | `uses_system:` |
| `informs` | knowledge input to a decision (weaker than `evidences`) | `informs:` |
| `owned_by` | accountability rests with this person | `owned_by:` |

**🔒 Propose, don't invent.** AI must never write a verb outside this table. A candidate verb is *proposed* to the human with one example sentence, and the rule of three applies: formalize a verb only on its third real occurrence. Proposals accumulate in `6. Main Notes/Ontology Proposal Ledger.md` (created on first use) so counting occurrences is a grep. Like the Areas table, this list is yours to grow — ratifying a new verb (adding a row here) is a human decision, same ceremony as extending the `type` enum.
```

**Change 2 — wire the verb table into the Note Creation Procedure.** In step 3 of the `## Note Creation Procedure` section, after the sentence ending `backlink near the top.`, append:

```
Where a link can be stated as a sentence `A —verb→ B` using the [Relationship verbs](#relationship-verbs--closed-list-the-ontology-t-box) table, also record it as a typed frontmatter property.
```

If the vault's `AGENTS.md` has no `## Note Creation Procedure` section (pre-[[2026-05-23-search-then-link-note-creation]] instance), skip Change 2 — Change 1 alone is a valid application.

**Preserve user customizations.** This is a section-by-section merge, not a file replace. Leave the Areas table, Cross-System Identity, Privacy Inheritance, and any locally-added sections untouched. If the user has already ratified verbs of their own in a hand-built table, **merge rows, never delete theirs** — show them the union and confirm before editing. If the splice anchors don't match cleanly, show the intended change and ask rather than guessing.

## Verification

After applying, all must be true:

- `grep -cF '| Verb | Meaning (A —verb→ B) | Written as |' AGENTS.md` returns `1` (present, not duplicated).
- `grep -q '### Relationship verbs — CLOSED LIST' AGENTS.md` succeeds.
- `grep -q 'Propose, don'"'"'t invent' AGENTS.md` succeeds.
- `grep -cF '| Area folder | \`area\` slug |' AGENTS.md` returns `1` (untouched).
- `grep -cF '| \`type\` | allowed \`status\` (progression →) | pause / terminal |' AGENTS.md` returns `1` (untouched).
- The AI-OS Lite vault-audit contract loader (≥ 0.5.0) reports no `relationship-verbs table not found` warning when run against the vault.

If any check fails, do NOT record the update as applied. Report which check failed and stop.

## Rollback

```
git checkout AGENTS.md
```

If the vault is not a git repo, delete the `### Relationship verbs — CLOSED LIST (the ontology T-box)` subsection and remove the appended sentence from Note Creation Procedure step 3.
