# AGENTS.md Spec — How to Generate and Revise a Vault's `AGENTS.md`

You are an AI assistant working inside a user's vault. This spec is the **pattern + reasoning** you follow to (a) **generate** the user's `AGENTS.md` on first-time setup, and (b) **revise** it after a kit update refreshes this spec. Treat this document as authoritative. The shipped baseline `AGENTS.md` in the vault root is a worked example of a file that conforms to this spec.

## Contents

1. [What `AGENTS.md` is, and why](#1-what-agentsmd-is-and-why)
2. [Scope discipline — what belongs, what does not](#2-scope-discipline--what-belongs-what-does-not)
3. [Salience rules — keep it noticed, not just present](#3-salience-rules--keep-it-noticed-not-just-present)
4. [Section template](#4-section-template)
5. [GENERATION — first-time setup](#5-generation--first-time-setup)
6. [REVISION — applying a kit update](#6-revision--applying-a-kit-update)
7. [The shipped baseline is the worked example](#7-the-shipped-baseline-is-the-worked-example)

## 1. What `AGENTS.md` is, and why

`AGENTS.md` at the vault root is **the one canonical, agent-agnostic instruction file** for this vault. Codex reads it natively. Claude Code reads `CLAUDE.md`, which is a one-line `@AGENTS.md` import — never a second copy. Any future agent (Gemini, Cursor, whatever comes next) reads the same plain markdown.

The load-bearing principle: **truth lives in the universal substrate — the filesystem and plain markdown. Agent-specific mechanisms (a Claude skill, `CLAUDE.md`, `.cursorrules`) are thin pointers, never homes for vault truth.** The moment canonical truth lives inside an agent-specific mechanism, the system is coupled to that agent.

Two consequences follow:
- `AGENTS.md` is the *single source of truth* for vault rules and non-inferable curated config. There is no second copy anywhere.
- Schema and structure that live elsewhere (templates, the filesystem) are **referenced**, never restated. A second copy is a drift bug waiting to happen.

## 2. Scope discipline — what belongs, what does not

`AGENTS.md` holds **standing rules + non-inferable curated config only.** Nothing else. Three sub-rules govern this, each with its *why*:

### 2a. Structure is derived, never enumerated

What projects exist, what their slugs are, what subprojects sit where — all of it comes from globbing `2. Projects/{Area}/{Project}/` and `Personal/{Project}/` at runtime. **Never write a project list into `AGENTS.md`.**

*Why:* a hand-maintained list is a stale index waiting to happen. The portfolio changes every time the user starts or archives a project; the file is updated only when the user remembers. The filesystem is the only artifact that is correct by construction — read it, don't restate it. The same reasoning extends to area enums once the vault has matured beyond the starter set: the `3. Areas/{Area}/` tree *is* the list.

### 2b. Schema lives in templates

Frontmatter field shapes per note `type` are defined by the files in `system-settings/Templates/`. **`AGENTS.md` names note types and where they route; it does not restate field lists.**

*Why:* the templates are what notes are actually generated from. If `AGENTS.md` carries a parallel field list, the two will drift the moment a template changes. Pointing at the templates keeps the schema's home unambiguous.

### 2c. Curated config is the exception — and only the exception

A small set of facts genuinely *cannot* be inferred from the filesystem: the user's area list, cross-system identity mappings (vault project ⇄ GitHub repo ⇄ Linear project), privacy rules. These belong in `AGENTS.md` because there is nowhere else for them to live.

*Why:* the test for whether something belongs is mechanical — *can an agent derive this from the filesystem or templates at runtime?* If yes, leave it out. If no, it goes here. The exception list is short by design; resist the urge to add to it.

## 3. Salience rules — keep it noticed, not just present

Getting content into the agent's context does not make the agent *act on it*. The variable that governs whether instructions are followed is **salience** — whether content registers as relevant and actionable at the decision point where it matters. A bloated or stale `AGENTS.md` does not just waste tokens: it **actively misleads**, lowering the salience of every rule still in it.

The controls to apply:

- **Keep the root file lean.** Hard ceiling ~200 lines / 32 KiB (Codex truncates at `project_doc_max_bytes`). Every token competes; bloat lowers attention to everything.
- **References one level deep.** Long detail (full folder roles, project-folder layout) lives in `system-settings/vault-structure.md` and similar — linked, not nested through multiple hops. The agent reads a direct child in full; nested references get partial `head -100` reads.
- **Pointer lines name *content + trigger*.** Not "see [[vault-structure]]" — write "consult [[vault-structure]] when you need full folder roles, not when routing a single note." A bare link signals nothing.
- **Table of contents on files over ~100 lines.** Survives partial reads. (This file has one. The user's `AGENTS.md` should too, once it crosses ~100 lines.)
- **Imperative phrasing, prominent placement.** "Do NOT create memory files without approval." Must-obey rules go in their own headed sections, never buried in mixed-content tables.

**The consequence to internalize:** removing a structural catalogue while keeping rules produces the same agent behaviour at lower cost. Empirical evidence (ETH Zurich context-files study): bloated or LLM-generated context files *reduce* task success. Lean, human-curated, rules-focused files raise it. Cut anything that doesn't pass the test *would removing this line cause an agent mistake?*

## 4. Section template

A complete `AGENTS.md` has the following sections, in this order. Always-present unless marked **conditional**.

1. **Scope statement** (intro paragraph + scope-of-this-file bullet). States what the vault is, that `AGENTS.md` is the canonical agent-agnostic file, and that scope is *standing rules + non-inferable curated config only*. Restates the "structure is derived" and "schema lives in templates" disciplines so an agent reading top-down meets them before any rule.
2. **Vault Structure.** Brief — hub-and-spoke summary, top-level folder names, where daily/journal/templates live. **Points to `system-settings/vault-structure.md`** for full folder roles (load-on-demand). Never enumerate projects.
3. **Areas.** Canonical table of the user's life areas — `Area folder` → `area` slug. The one place areas are listed. Includes the instruction for adding new areas (create `3. Areas/{Area}/` with hub + `Goals/`, append a row).
4. **File Routing — Decision Tree.** Numbered list, walked in order, mapping note kind → destination folder + required frontmatter properties.
5. **Frontmatter Taxonomy.** Names the three routing properties (`type`, `area`, `project`) and the `type` table (value → description → where it lives). Closes with the **"frontmatter shapes — read the template"** rule pointing at `system-settings/Templates/`. Never restate field lists.
6. **Cross-System Identity.** **Conditional — include only if the user has external systems** (GitHub, Linear, Jira, Azure DevOps, Notion). When present: the mapping table, the slug-generation rule, the identity-resolution rule, and the "do NOT create new external projects unless instructed" rule. If the user has no external systems, ship a brief stub explaining when to fill it in, or omit entirely.
7. **Privacy Inheritance.** **Conditional — include only if the user has any private projects or expects to.** When present: privacy is a project-level property; `private: true` on a project hub propagates to every file with that `project:` slug; override on a single file with `private: false`; privatized files are excluded from rollups, recaps, and journal extractions.
8. **Note Quality Rules.** Standing rules about note hygiene — no context re-explanation, max lines per note, one canonical note per concept, corrections replace not supplement, session logs ≠ knowledge notes, etc.
9. **Git Workflow.** Commit cadence, semantic-commit prefixes, "never mention AI generation or co-authoring in a commit message."

**Additional standing-rule sections may also appear** when the user's workflow needs them: Devlog Task Linking, Orphan-Note Rule, Memory System rules, Vault Search Strategy, Maintenance pointer. Include each only when it encodes a real standing rule the user follows — they pass the same scope test as everything else.

**Closing pointer.** End with a one-paragraph Maintenance note: this file is generated from `system-settings/agents-md-spec.md`; when rules or shape change, update the spec and re-run the onboarding task — don't hand-edit in isolation.

## 5. GENERATION — first-time setup

The user has run the onboarding task on a fresh vault. The vault already contains the kit's shipped `vault-files/AGENTS.md` as a baseline. Your job is to produce a `AGENTS.md` tailored to the user.

Procedure:

1. **Read the shipped baseline `AGENTS.md`** at the vault root. It is a conforming example of this spec — your output will look structurally similar.
2. **Read this spec end-to-end.** The section template (§4) and the scope discipline (§2) govern what you keep, drop, or fill in.
3. **Interview the user (or read their vault) for the non-inferable curated config:**
   - **Areas.** What life areas do they want the vault to know about? The baseline ships with one (`personal`). Ask what they want to add now — common starters: `work`, `health`, `career`, `personal-finance`. Resist over-listing; areas can be added later by creating the folder and appending a row.
   - **External systems.** Do they mirror projects across GitHub, Linear, Jira, ADO, or Notion? If yes, fill in the Cross-System Identity section with their tools' conventions. If no, omit the section entirely (or leave a one-line stub explaining when to add it).
   - **Private projects.** Do they have, or expect, any private projects? If yes, include the Privacy Inheritance section verbatim from the baseline. If no, omit.
   - **Custom routing.** Does any folder of theirs need a routing rule the baseline doesn't cover? Add it to the decision tree only if it's a *standing* rule, not a one-off.
4. **Leave everything derivable out.** Do not enumerate projects. Do not list every template's frontmatter fields. Do not restate the folder tree — point at `system-settings/vault-structure.md`.
5. **Apply the salience rules (§3).** Target ≤ ~200 lines. Add a table of contents if the file crosses ~100 lines. Use imperative phrasing for must-obey rules.
6. **Write the file** to the vault root as `AGENTS.md`. Confirm `CLAUDE.md` exists as a one-line `@AGENTS.md` import (the kit ships it; if missing, create it).
7. **Report back to the user** with what you filled in, what you omitted (and why), and any open questions you parked for later.

## 6. REVISION — applying a kit update

The user has re-run the onboarding task after `update.sh` refreshed this spec (and possibly the baseline `AGENTS.md`). Their existing `AGENTS.md` has their curated config in it. You must update the *rules and shape* without destroying the *config*.

**This is a revise-in-place, not a regenerate-from-scratch.** Read the user's file first; preserve what they've built.

Procedure:

1. **Read the user's current `AGENTS.md` first** (at the vault root). This is your starting point, not a blank page.
2. **Read this (updated) spec.** Note what's changed since the version their file was generated against — new sections, renamed sections, new salience rules, deprecated rules.
3. **Read the updated baseline `vault-files/AGENTS.md`** in the kit (or whatever the user points you at). It shows the new shape concretely.
4. **Classify every block of the user's current file as either *rule* or *curated config*:**
   - **Rule** (kit-managed): prose that describes how *any* vault works — the decision tree skeleton, frontmatter property names, the type table, salience rules, git-workflow conventions, note-quality rules. **Update these** to match the new spec.
   - **Curated config** (user-managed): the user's specific Area table rows, their Cross-System Identity rows, their privacy choices, any custom routing steps they added, their org-specific commit-message rules. **Preserve these verbatim** unless the user explicitly asks otherwise.
5. **When in doubt, keep it and tell the user.** A line that *looks* like a rule but might be the user's deliberate tweak (e.g., an extra step in the decision tree) is preserved by default, and you call it out in the report. Better to over-preserve and ask than silently overwrite their choices.
6. **Apply structural changes from the spec.** If §4's section template added a new section, insert it. If a section was renamed, rename it in the user's file. If salience rules tightened (e.g., a new ToC threshold), apply the change.
7. **Re-check scope discipline.** If the user (or a prior generation) drifted — added a project list, restated template fields, enumerated areas in prose — this is the moment to surface it. Don't silently delete; flag it: "Your Areas section now includes per-area project lists. Per §2a these are derived, not enumerated. Remove?"
8. **Re-check the salience rules.** Did the file cross ~100 lines without a ToC? Add one. Cross ~200 lines? Identify what can move to a linked `system-settings/` file.
9. **Write the revised file** back to the vault root.
10. **Report back** with a diff-style summary: rules updated (list them), config preserved (confirm what was kept), structural changes (sections added/renamed), open questions (anything you flagged but didn't auto-change).

## 7. The shipped baseline is the worked example

Point the user (and yourself) at the vault's root `AGENTS.md` — that file, as shipped by the kit, is a conforming example of this spec. Every section §4 names appears there. Every scope-discipline rule from §2 is reflected. Every salience control from §3 is applied. When this spec is ambiguous about *what something should look like in prose*, look at how the baseline says it and follow that style. When the baseline and this spec disagree, the spec wins — and that disagreement is a bug to flag.
