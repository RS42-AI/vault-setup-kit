---
description: Apply outstanding vault-shape structure updates to a Personal OS vault. Reads prose update docs from the kit's structure-updates/, detects which apply to the user's current vault, and walks them through each change with confirmation. Use when the user says "update structure", "update vault", "catch up vault", or "/update-structure" — typically after pulling new kit updates that changed the canonical shape.
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash(ls:*)
  - Bash(cat:*)
  - Bash(grep:*)
  - Bash(find:*)
  - Bash(mv:*)
  - Bash(mkdir:*)
  - Bash(cp:*)
  - Bash(diff:*)
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
---

# Update Structure

Applies vault-shape structure updates to a Personal OS vault. Structure updates are **prose documents**, not bash scripts — each one describes the change, how to detect whether it applies to *this* user's vault, and the file-level edits in plain language. Claude reads the docs, inspects the user's actual vault state, and executes the changes with the user's confirmation.

This is the smart counterpart to "run an upgrade script." It works because:

- **Every user's vault is customized.** A bash script that assumes a canonical from-state breaks on real installs. Claude can reason about *this* vault.
- **Structure updates age into instructions, not code.** A prose doc written today still makes sense in two years; the bash equivalent rots.
- **The structure update becomes a teaching moment.** Claude explains each change as it happens — useful for onboarding (sister, interns), useful for self-recall later.

## Key Principles

1. **Idempotent by default.** If a structure update's detection rule says it doesn't apply, skip silently. Re-running `/update-structure` should be safe.
2. **Confirm before destructive moves.** File deletions, renames, and overwrites need explicit user OK. Read-only inspection and additive changes (new files, new sections) can be batched.
3. **One structure update at a time, in date order.** Don't interleave. Apply, verify, record, move on.
4. **Record what ran.** Append to `.vault-structure-updates-applied` in vault root after each successful structure update so future runs skip it.
5. **Never invent structure updates.** Only apply docs that exist in `structure-updates/`. If the user describes a change that isn't in a doc, tell them to author a structure update doc first.
6. **Bail loudly on conflict.** If the user's vault is in a state the structure update doc doesn't anticipate, stop and ask — don't guess.

## Invocation

```
/update-structure                    → apply all unapplied structure updates interactively
/update-structure --dry-run          → show what would apply, change nothing
/update-structure <update-id>        → apply a single structure update by id (re-runs even if applied)
/update-structure --list             → show all structure updates and their applied status
```

## Sources

| Source | Used For | Criticality |
|--------|----------|-------------|
| `structure-updates/*.md` (in the kit, located via `.vault-kit-path`) | The catalog of structure updates | REQUIRED |
| `.vault-structure-updates-applied` (vault root) | What's already been run | HIGH |
| `.vault-kit-path` (vault root) | Path to the installed kit directory | REQUIRED |
| User's vault filesystem | Detecting state, applying changes | REQUIRED |
| Git CLI | Status checks before/after | HIGH |

## Step 1 — Locate vault root

The command must run from inside the user's vault directory (where `CLAUDE.md` or `AGENTS.md` lives). If the current working directory has neither, ask the user for the vault path before continuing.

After confirming the vault root, read `.vault-kit-path` from the vault root. If the file doesn't exist, stop and tell the user to run `bash setup-vault.sh --update <vault>` from the kit before retrying.

Run `git status` from the vault root. If the vault is not a git repo, warn the user that rollback will require manual file deletion and ask whether to proceed. If there are uncommitted changes, ask the user whether to proceed (the kit's added files will mix with their pending work). Default to safer: do not proceed unless they explicitly say to.

## Step 2 — Read applied-updates log

Read `.vault-structure-updates-applied` (newline-delimited list of structure update ids). If the file doesn't exist, treat as empty (this is the user's first structure update run).

## Step 3 — List available structure updates

List `$(cat .vault-kit-path)/structure-updates/*.md` sorted by filename (date prefix sorts chronologically). For each, parse the frontmatter to get `id`, `date`, and `description`.

## Step 4 — Filter to candidates

A structure update is a **candidate** if its `id` is not in the applied log. Skip already-applied ones unless the user passed a specific id.

If `--list` was passed, print the table now (id · date · description · applied?) and exit.

## Step 5 — For each candidate, evaluate detection

Read the full structure update doc. The doc contains a **Detection** section in plain English describing how to tell whether this structure update applies to *this* user's vault. Examples:

- "Applies if `CLAUDE.md` is more than 50 lines and `AGENTS.md` does not exist."
- "Applies if any project hub has `goal:` in frontmatter pointing at a non-existent file."

Inspect the user's vault to evaluate the predicate. If detection says **does not apply**, mark this structure update as "vacuously applied" (record it in the log so it isn't re-evaluated next run) and continue to the next.

If detection says **applies**, proceed to Step 6.

## Step 6 — Present the change to the user

Output a summary of what this structure update will do, drawn from the structure update doc's **Changes** section. Format:

```
Structure Update: <id>
Why: <one-line rationale, from doc's Context section>
Will change:
  - <file 1>: <what happens>
  - <file 2>: <what happens>
  - ...
Will create:
  - <new file 1>
  - ...
```

Ask the user to confirm before applying. Accept: `yes`, `y`, `apply`, `skip`, `abort`.

- `yes` / `y` / `apply` → execute Step 7
- `skip` → record this structure update as skipped (NOT applied), move on. Skipped structure updates re-appear in future runs unless the user passes `--list` and explicitly opts out.
- `abort` → stop the whole `/update-structure` run, leave subsequent structure updates untouched.

## Step 7 — Execute the changes

If the user invoked with `--dry-run`, skip the execution below and skip Step 8 (there is nothing to verify). Instead, after Step 6's summary, print `[dry-run: no changes made]` and proceed to the next candidate.

Walk the structure update doc's **Changes** section file by file. Each change block tells Claude what to do in plain language with file paths and content snippets. Use `Read` → reason → `Edit`/`Write`/`Bash` as appropriate. After each file change, do a sanity-check Read to confirm the change took.

If a change references a file that doesn't exist in the user's vault, ask the user before creating it (the structure update may have been written against a slightly different layout).

## Step 8 — Verify

The structure update doc's **Verification** section lists invariants to check post-apply (e.g., "AGENTS.md exists and is non-empty", "CLAUDE.md contains the line `@AGENTS.md`"). Run each check. If any fail, stop the entire `/update-structure` run — do not attempt subsequent candidates. Report which check failed, list which files were changed before the failure, and point the user at the `## Rollback` section of the structure update doc. Do NOT record the structure update as applied.

## Step 9 — Record

Append the structure update `id` and timestamp to `.vault-structure-updates-applied`:

```
2026-05-16-agents-md-adoption    2026-05-16T14:32:00-05:00    applied
2026-05-XX-some-other-thing      2026-05-16T14:33:12-05:00    vacuously-applied
```

## Step 10 — Final report

After all candidates are processed, print a summary:

```
Structure updates processed: 5
  Applied:           2
  Vacuously applied: 2  (detection ruled out — recorded so they don't re-evaluate)
  Skipped:           1
  Failed:            0
```

## Structure update document format

Every file in `structure-updates/` is a markdown file named `YYYY-MM-DD-short-name.md` with this shape:

```yaml
---
id: 2026-05-16-agents-md-adoption
date: 2026-05-16
description: Adopt AGENTS.md as the canonical instruction file; collapse CLAUDE.md to a pointer.
related_note: "[[Cross-Agent Instruction-File Architecture — AGENTS.md as the Portable Source of Truth]]"
---

## Context

<Plain-English why. Link the knowledge note in the user's vault that motivated this change.>

## Detection

<How Claude should decide whether this structure update applies to the user's current vault. Be specific about files and shapes.>

## Changes

### File: <path>
<What to do — replace contents, add a section, move to a new path, etc. Include before/after snippets where the diff isn't trivial.>

### File: <path>
...

## Verification

- <Invariant 1>
- <Invariant 2>
- ...

## Rollback (optional)

<If something goes wrong, how to undo. Often "git checkout" of the affected files is enough — assume the user is in a git repo.>
```

## Failure modes

- **`.vault-kit-path` missing**: stop and ask the user to run `bash setup-vault.sh --update <vault>` from the kit. The slash command can't function without it.
- **Vault not in a git repo**: warn the user, recommend `git init` before continuing. Structure updates are easier to undo when there's a commit to roll back to.
- **Uncommitted changes in vault**: ask whether to proceed. Structure updates make file changes; mixing them with user work-in-progress complicates rollback.
- **Structure update doc references a feature not yet in the vault**: log it, continue. The doc may be aspirational or assume a later structure update runs first.
- **Detection ambiguous**: if Claude can't confidently decide whether a structure update applies, ask the user. Do not guess.

## Open questions / future work

- Should structure updates be transactional (all-or-nothing per structure update)? Currently file-by-file with a verification gate at the end.
- Should `/update-structure` ever auto-run on kit update? Probably not — too magic. Explicit invocation is safer.
- How to handle structure updates that touch the kit's own data files vs the user's vault? Out of scope for v1 — kit updates via `setup-vault.sh --update` handle kit-internal state.
