# Vault-Setup Kit v0.2 — Structure-Update Cycle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship vault-setup-kit v0.2 — the structure-update infrastructure that lets existing kit users (sister at v0.1, future interns) catch up to current vault shape via `git pull && /update-structure`, without losing their customizations.

**Architecture:** Add three new pieces to the kit — (1) `structure-updates/` folder of prose docs, (2) `commands/update-structure.md` slash-command runner shipped into the user's vault, (3) `setup-vault.sh --update` mode that installs the slash command and records the kit path. The runner is invoked in Claude Code inside the user's vault; it reads `.vault-kit-path` to locate the kit's `structure-updates/`, evaluates each unapplied update against the user's actual vault state, and walks them through the changes interactively. The personal-os plugin gets nothing — vault-shape concerns stay entirely in the kit.

**Tech Stack:** Bash (setup script + minor wrappers), bats (existing test harness), markdown (prose docs, slash-command runner content, kit-canonical vault files). No new runtime dependencies.

**Spec:** [Vault-Setup Kit Update Cycle — Prose-Driven Structure Updates for Continuous Vault Shape Evolution](../../../../../Claude/ObsidianVault/2.%20Projects/2.%20RS42/Vault-Setup/Notes/Vault-Setup%20Kit%20Update%20Cycle%20-%20Prose-Driven%20Structure%20Updates%20for%20Continuous%20Vault%20Shape%20Evolution.md) (in founder's vault — agent should read it directly from `~/Claude/ObsidianVault/2. Projects/2. RS42/Vault-Setup/Notes/`)

---

## Pre-Flight

Before starting any task: confirm a clean working tree on `main` in `~/RS42/projects/vault-setup-kit/`. The plan assumes `cd ~/RS42/projects/vault-setup-kit` as the working directory unless otherwise noted.

```bash
cd ~/RS42/projects/vault-setup-kit
git status   # should show clean
git log --oneline -3
# Expected last commit: f7c21d0 fix(lint): satisfy shellcheck SC2162 and SC2295
```

---

## Stage A — Canonical vault-files/ snapshot for v0.2

This stage updates the canonical content the kit ships. The new files (`AGENTS.md`, `vault-structure.md`) and the rewritten `CLAUDE.md` are what *fresh* v0.2 installs receive directly. *Existing* v0.1 installs receive these same files through the structure-update authored in Stage B.

**Important:** The kit's `vault-files/AGENTS.md` is a *templated beginner version* — single `personal` area, "customize as you grow" tone — NOT a verbatim copy of the founder's vault `AGENTS.md`. The founder's vault has six areas and project-specific identity tables; the kit should ship a clean starting point.

### Task A1: Author `vault-files/AGENTS.md`

**Files:**
- Create: `~/RS42/projects/vault-setup-kit/vault-files/AGENTS.md`

**Source material:**
- Current kit `vault-files/CLAUDE.md` (read it for the kit's beginner tone and area taxonomy)
- Founder's `~/Claude/ObsidianVault/AGENTS.md` (read it for the structural shape — section order, headings, decision-tree format)

- [ ] **Step 1: Read both source files** to understand kit-beginner content vs canonical-AGENTS-shape

```bash
cat vault-files/CLAUDE.md | wc -l
# Expected: ~231 lines

cat ~/Claude/ObsidianVault/AGENTS.md | wc -l
# Expected: ~140 lines
```

- [ ] **Step 2: Write `vault-files/AGENTS.md`** combining the founder's structural shape with the kit's beginner-friendly content

Required sections (in order):
1. One-paragraph intro — what AGENTS.md is, why it exists, that CLAUDE.md imports it
2. **Vault Structure** — short overview + pointer to `system-settings/vault-structure.md` for detail
3. **Areas** — one-area starter table (`personal` → `Personal/`) + instructions to add areas
4. **File Routing — Decision Tree** — the numbered 0–9 walk, adapted for the kit's simpler shape (no Evonik/RS42-specific routes)
5. **Frontmatter Taxonomy** — the `type` values table (drop kit-irrelevant types like `tech-radar`, `playbook`)
6. **Privacy Inheritance** — same rule as founder's vault, but with the beginner caveat ("you probably won't need this until you have multiple projects")
7. **Memory System safety rule** — same warning as founder's vault
8. **Note Quality Rules** — the 10 numbered rules from founder's vault
9. **Git Workflow** — semantic commits, no AI attribution
10. **Customization** — short pointer to "edit AGENTS.md as your vault grows"

Skip these founder-vault sections (kit-irrelevant):
- Six-area table
- Cross-System Identity table (sister doesn't have orgs/Linear/ADO)
- Orphan-Note Rule (advanced)
- Vault Search Strategy pointer (depends on QMD which is install-conditional)

- [ ] **Step 3: Verify file is between 100 and 200 lines**

```bash
wc -l vault-files/AGENTS.md
# Expected: 100-200 lines
```

- [ ] **Step 4: Commit**

```bash
git add vault-files/AGENTS.md
git commit -m "feat: add canonical AGENTS.md for v0.2 (beginner-templated)"
```

---

### Task A2: Rewrite `vault-files/CLAUDE.md` as 5-line pointer

**Files:**
- Modify: `~/RS42/projects/vault-setup-kit/vault-files/CLAUDE.md` (currently 231 lines, becomes ~5 lines)

- [ ] **Step 1: Verify current state**

```bash
wc -l vault-files/CLAUDE.md
# Expected: ~231 lines (the v0.1 starter)
```

- [ ] **Step 2: Replace entire contents with**:

```markdown
# CLAUDE.md

This vault's canonical instruction file is `AGENTS.md` — agent-agnostic, read by Claude Code, Codex, and others. Claude Code reads `CLAUDE.md`, so this file imports it. Add Claude-specific instructions below the import if ever needed.

@AGENTS.md
```

- [ ] **Step 3: Verify**

```bash
wc -l vault-files/CLAUDE.md
# Expected: 5-6 lines
grep -c "@AGENTS.md" vault-files/CLAUDE.md
# Expected: 1
```

- [ ] **Step 4: Commit**

```bash
git add vault-files/CLAUDE.md
git commit -m "refactor: collapse CLAUDE.md to AGENTS.md pointer"
```

---

### Task A3: Author `vault-files/system-settings/vault-structure.md`

**Files:**
- Create: `~/RS42/projects/vault-setup-kit/vault-files/system-settings/vault-structure.md`

**Source material:**
- Founder's `~/Claude/ObsidianVault/system-settings/vault-structure.md` (read for shape)
- Current kit `vault-files/CLAUDE.md` (read for the kit's folder taxonomy — slightly simpler than founder's)

- [ ] **Step 1: Read both source files**

- [ ] **Step 2: Write the kit-templated version**

Required sections:
1. One-paragraph intro — "Load-on-demand structural detail referenced from AGENTS.md"
2. **Hub-and-Spoke Architecture** — short explanation
3. **Folders** — the numbered-prefix table (drop `7. Dev Log/` DEPRECATED row — kit-fresh users never had it; drop `Excalidraw/`, `iPhone Notes/` rows — install-conditional)
4. **Project Folders** — standard layout block, NO Evonik-specific nesting note
5. **Goals** — kit ships only the per-goal sub-hub pattern (no legacy horizon-aggregate migration content)
6. **Journal & Daily Paths** — same table as founder's
7. **Knowledge Notes vs Devlogs** — same table as founder's

- [ ] **Step 3: Verify**

```bash
test -f vault-files/system-settings/vault-structure.md && echo "exists"
wc -l vault-files/system-settings/vault-structure.md
# Expected: 50-100 lines
```

- [ ] **Step 4: Commit**

```bash
git add vault-files/system-settings/vault-structure.md
git commit -m "feat: add load-on-demand vault-structure reference"
```

---

### Task A4: Template-drift audit (read-only; no edits in v0.2)

**Goal:** Confirm whether any of the 12 shipped templates in `vault-files/system-settings/Templates/` have drifted from the founder's versions in a way that should ship in v0.2. **Decision rule for v0.2 scope:** if a template difference is purely cosmetic or adds non-essential fields, defer. v0.2's structure-update authored in Stage B does NOT include template syncing — that becomes a future structure update if drift becomes an issue.

- [ ] **Step 1: For each of the 12 templates, diff against founder's version**

```bash
for tmpl in vault-files/system-settings/Templates/*.md; do
  name=$(basename "$tmpl")
  founder="$HOME/Claude/ObsidianVault/system-settings/Templates/$name"
  if [ -f "$founder" ]; then
    echo "=== $name ==="
    diff "$tmpl" "$founder" | head -30
  else
    echo "=== $name (no founder counterpart, skip) ==="
  fi
done
```

- [ ] **Step 2: Record findings**

Write a short note to `docs/superpowers/plans/2026-05-18-vault-setup-kit-v0.2-template-drift-notes.md` listing which templates drifted and a one-line "ship-in-v0.2 or defer" decision per template. **Default verdict: defer.** Only ship a template update in v0.2 if leaving it stale would break the AGENTS.md adoption flow.

- [ ] **Step 3: Commit the notes file**

```bash
git add docs/superpowers/plans/2026-05-18-vault-setup-kit-v0.2-template-drift-notes.md
git commit -m "docs: record template-drift audit for v0.2"
```

---

## Stage B — Structure-updates infrastructure

### Task B1: Create `structure-updates/` and `commands/` directories

**Files:**
- Create: `~/RS42/projects/vault-setup-kit/structure-updates/.gitkeep`
- Create: `~/RS42/projects/vault-setup-kit/commands/.gitkeep`

- [ ] **Step 1: Create both directories with `.gitkeep` placeholders**

```bash
mkdir -p structure-updates commands
touch structure-updates/.gitkeep commands/.gitkeep
```

- [ ] **Step 2: Verify**

```bash
test -d structure-updates && test -d commands && echo "ok"
```

- [ ] **Step 3: Commit**

```bash
git add structure-updates/.gitkeep commands/.gitkeep
git commit -m "chore: scaffold structure-updates/ and commands/ directories"
```

---

### Task B2: Author `structure-updates/2026-05-16-agents-md-adoption.md`

Port the existing draft from the personal-os plugin, fully renaming "migration" → "structure update" and updating filename/path references.

**Files:**
- Create: `~/RS42/projects/vault-setup-kit/structure-updates/2026-05-16-agents-md-adoption.md`
- Source: `~/RS42/projects/personal-os/plugins/personal-os/skills/migrate-vault/migrations/2026-05-16-agents-md-adoption.md` (190 lines, read for reference)

- [ ] **Step 1: Read the source draft**

```bash
cat ~/RS42/projects/personal-os/plugins/personal-os/skills/migrate-vault/migrations/2026-05-16-agents-md-adoption.md
```

- [ ] **Step 2: Write the new file with these changes from the source**

| Source | New |
|---|---|
| Frontmatter `id:` value `2026-05-16-agents-md-adoption` | unchanged |
| Body uses "migration" | replace with "structure update" |
| Backup filename `CLAUDE.md.pre-agents-md-migration` | rename to `CLAUDE.md.pre-agents-md-update` |
| Reference to founder's vault as canonical source | update to "kit v0.2 ships the canonical AGENTS.md at `vault-files/AGENTS.md` — the user has already received it via the non-clobber copy in `setup-vault.sh --update`. If for some reason it didn't arrive, copy from kit's `vault-files/AGENTS.md`." |
| Detection rule | unchanged (`CLAUDE.md > 50 lines && AGENTS.md missing`) |
| "Notes for the human running this" final section | keep, but rephrase "first one — establishes the pattern" to "first structure update — establishes the pattern for future ones" |

- [ ] **Step 3: Verify file structure**

```bash
test -f structure-updates/2026-05-16-agents-md-adoption.md
grep -c "^## Context$" structure-updates/2026-05-16-agents-md-adoption.md
# Expected: 1
grep -c "^## Detection$" structure-updates/2026-05-16-agents-md-adoption.md
# Expected: 1
grep -c "^## Changes$" structure-updates/2026-05-16-agents-md-adoption.md
# Expected: 1
grep -c "^## Verification$" structure-updates/2026-05-16-agents-md-adoption.md
# Expected: 1
# Confirm "migration" terminology is rare — only acceptable in SE-pattern explanations:
grep -in "migration" structure-updates/2026-05-16-agents-md-adoption.md
# Expected: 0–2 occurrences. Any matches should be inside phrases like "this pattern is
# sometimes called a 'migration' in software" — i.e. explaining the term, not naming the
# feature. User-facing surfaces (filenames, slash command, applied log) must NOT use it.
# If you see lines naming the *operation* with "migration," replace with "structure update."
```

- [ ] **Step 4: Commit**

```bash
git add structure-updates/2026-05-16-agents-md-adoption.md
git commit -m "feat: first structure update — AGENTS.md adoption"
```

---

### Task B3: Author `commands/update-structure.md` (the slash-command runner)

Port the existing draft from the personal-os plugin's `SKILL.md`, reframing it as a Claude Code project-scoped slash command. The frontmatter changes from a skill-style header to slash-command form; the body keeps most of its structure but rewrites pathing from `${CLAUDE_PLUGIN_ROOT}/skills/migrate-vault/migrations/` to `$(cat .vault-kit-path)/structure-updates/`.

**Files:**
- Create: `~/RS42/projects/vault-setup-kit/commands/update-structure.md`
- Source: `~/RS42/projects/personal-os/plugins/personal-os/skills/migrate-vault/SKILL.md` (read for reference)

- [ ] **Step 1: Read the source draft**

```bash
cat ~/RS42/projects/personal-os/plugins/personal-os/skills/migrate-vault/SKILL.md | wc -l
# Expected: ~190 lines
```

- [ ] **Step 2: Write the new file with the following frontmatter**

```yaml
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
  - Bash(diff:*)
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
---
```

(Note: no `name:` or `user-invocable:` fields — Claude Code slash commands derive their `/name` from the filename.)

- [ ] **Step 3: Write the body**

Adapt the source SKILL.md body with these changes throughout:
- "migration" → "structure update"
- "migrate-vault" → "update-structure"
- "migrations/" → "structure-updates/"
- "`.vault-migrations-applied`" → "`.vault-structure-updates-applied`"
- "vacuously applied" / "vacuously-applied" → keep (term is fine)

**Key structural changes from the source:**

In Step 1 (Locate vault root):
- Add: "After confirming the vault root, read `.vault-kit-path` from the vault root. If the file doesn't exist, stop and tell the user to run `bash setup-vault.sh --update <vault>` from the kit before retrying."

In Step 3 (List available migrations):
- Replace `${CLAUDE_PLUGIN_ROOT}/skills/migrate-vault/migrations/*.md` with `$(cat .vault-kit-path)/structure-updates/*.md`

In Sources table:
- Replace "`migrations/*.md` (in this skill)" with "`structure-updates/*.md` (in the kit, located via `.vault-kit-path`)"

In Step 9 (Record):
- Replace `.vault-migrations-applied` references with `.vault-structure-updates-applied`

In "Failure modes":
- Add a new bullet: "**`.vault-kit-path` missing**: stop and ask the user to run `bash setup-vault.sh --update <vault>` from the kit. The slash command can't function without it."

- [ ] **Step 4: Verify**

```bash
test -f commands/update-structure.md
grep -c "structure update" commands/update-structure.md
# Expected: many (>20)
grep -c "\.vault-kit-path" commands/update-structure.md
# Expected: at least 3
grep -ic "CLAUDE_PLUGIN_ROOT" commands/update-structure.md
# Expected: 0 (we're not a plugin anymore)
grep -ic "migrate-vault" commands/update-structure.md
# Expected: 0
```

- [ ] **Step 5: Commit**

```bash
git add commands/update-structure.md
git commit -m "feat: add /update-structure slash-command runner"
```

---

## Stage C — `setup-vault.sh --update` mode (TDD with bats)

This stage uses test-driven development per the existing bats harness in `test/`. Read `test/test_helper.bash` and `test/harness.bats` first to understand the existing fixture style.

### Task C1: Read existing test harness

- [ ] **Step 1: Familiarize with existing tests**

```bash
cat test/test_helper.bash
cat test/harness.bats
ls test/
```

No code changes — pure context-loading.

**Harness conventions every test below uses:**
- `load test_helper` at the top of the bats file makes `$KIT_ROOT` (absolute kit root, exported by helper) and the `setup_test_vault` function (creates `$BATS_TEST_TMPDIR/vault`, exports `$TEST_VAULT`) available.
- Reference the kit's setup script as `"$KIT_ROOT/setup-vault.sh"`, never `$SCRIPT_DIR` — that's an internal variable inside `setup-vault.sh` itself, not in test scope.
- Use `setup_test_vault` to create the per-test vault, then refer to it as `$TEST_VAULT`. Don't re-implement the mkdir.

---

### Task C2: Write failing test — `--update` flag is recognized

**Files:**
- Modify: `~/RS42/projects/vault-setup-kit/test/harness.bats` (or create a new `test/update-mode.bats` if the convention is one bats file per feature — check existing structure)

- [ ] **Step 1: Add failing test**

```bash
@test "setup-vault.sh --update prints update-mode header" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --update "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Update Mode"* ]]
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
bats test/
# Expected: FAIL — current setup-vault.sh has no --update branch, output won't contain "Update Mode"
```

---

### Task C3: Implement `--update` flag parsing in `setup-vault.sh`

**Files:**
- Modify: `~/RS42/projects/vault-setup-kit/setup-vault.sh`

- [ ] **Step 1: Add flag parsing at the top of the script (after `set -euo pipefail`)**

```bash
UPDATE_MODE=0
if [ "${1:-}" = "--update" ]; then
  UPDATE_MODE=1
  shift
fi

VAULT="${1:-$HOME/Claude/ObsidianVault}"
```

- [ ] **Step 2: Add a conditional header echo**

```bash
if [ "$UPDATE_MODE" -eq 1 ]; then
  echo "=== Vault Setup — Update Mode ==="
else
  echo "=== Vault Setup ==="
fi
```

- [ ] **Step 3: Run test to verify it passes**

```bash
bats test/
# Expected: PASS for the new test
```

- [ ] **Step 4: Commit**

```bash
git add setup-vault.sh test/
git commit -m "feat(setup-vault): recognize --update flag"
```

---

### Task C4: Write failing test — `--update` writes `.vault-kit-path`

- [ ] **Step 1: Add failing test**

```bash
@test "setup-vault.sh --update writes .vault-kit-path with absolute kit path" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --update "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [ -f "$TEST_VAULT/.vault-kit-path" ]
  local recorded
  recorded="$(cat "$TEST_VAULT/.vault-kit-path")"
  [ "$recorded" = "$KIT_ROOT" ]
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
bats test/
# Expected: FAIL on the new test — file doesn't exist
```

---

### Task C5: Implement `.vault-kit-path` write

**Files:**
- Modify: `~/RS42/projects/vault-setup-kit/setup-vault.sh`

- [ ] **Step 1: After flag parsing and before folder creation, add**

```bash
if [ "$UPDATE_MODE" -eq 1 ]; then
  echo "[update] Recording kit path to $VAULT/.vault-kit-path"
  echo "$SCRIPT_DIR" > "$VAULT/.vault-kit-path"
fi
```

- [ ] **Step 2: Run test to verify it passes**

```bash
bats test/
# Expected: PASS
```

- [ ] **Step 3: Commit**

```bash
git add setup-vault.sh test/
git commit -m "feat(setup-vault): write .vault-kit-path on --update"
```

---

### Task C6: Write failing test — `--update` installs slash command

- [ ] **Step 1: Add failing test**

```bash
@test "setup-vault.sh --update copies commands/update-structure.md to <vault>/.claude/commands/" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --update "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [ -f "$TEST_VAULT/.claude/commands/update-structure.md" ]
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
bats test/
# Expected: FAIL — slash command not installed yet
```

---

### Task C7: Implement slash-command install

**Files:**
- Modify: `~/RS42/projects/vault-setup-kit/setup-vault.sh`

- [ ] **Step 1: After the .vault-kit-path write, add**

```bash
if [ "$UPDATE_MODE" -eq 1 ]; then
  echo "[update] Installing /update-structure slash command"
  mkdir -p "$VAULT/.claude/commands"
  cp "$SCRIPT_DIR/commands/update-structure.md" "$VAULT/.claude/commands/update-structure.md"
fi
```

(Note: this is an unconditional overwrite — the slash command is kit-shipped and should always reflect the latest version. The user's own vault files in `vault-files/` are still non-clobbered.)

- [ ] **Step 2: Run test to verify it passes**

```bash
bats test/
# Expected: PASS
```

- [ ] **Step 3: Commit**

```bash
git add setup-vault.sh test/
git commit -m "feat(setup-vault): install /update-structure slash command on --update"
```

---

### Task C8: Write failing test — `--update` still copies new canonical files non-clobber

- [ ] **Step 1: Add failing test**

```bash
@test "setup-vault.sh --update copies new canonical files (AGENTS.md) non-clobber" {
  setup_test_vault
  # Pre-existing user file we should NOT clobber
  echo "user-customization" > "$TEST_VAULT/CLAUDE.md"
  run bash "$KIT_ROOT/setup-vault.sh" --update "$TEST_VAULT"
  [ "$status" -eq 0 ]
  # User's CLAUDE.md preserved
  [ "$(cat "$TEST_VAULT/CLAUDE.md")" = "user-customization" ]
  # AGENTS.md added (was new in v0.2)
  [ -f "$TEST_VAULT/AGENTS.md" ]
}
```

- [ ] **Step 2: Run to verify it fails or passes**

Note: this should PASS already if the existing non-clobber copy logic runs in `--update` mode. The test exists to lock the behavior. If it fails, the issue is that the existing copy loop is only running in fresh-install mode.

```bash
bats test/
```

If it passes immediately: skip Task C9 and commit just the test.

If it fails: continue to C9.

---

### Task C9: Ensure non-clobber copy runs in `--update` mode

**Files:**
- Modify: `~/RS42/projects/vault-setup-kit/setup-vault.sh`

- [ ] **Step 1: Verify the existing copy loop runs unconditionally** (it already does per the current script — `--update` mode just adds steps before it; it doesn't gate the copy)

- [ ] **Step 2: Commit the test regardless of whether C8 passed or failed**

```bash
git add test/
git commit -m "test(setup-vault): lock non-clobber behavior under --update"
```

If C8 failed, restructure so the copy loop runs in both modes, then commit the fix as a separate commit (`fix(setup-vault): run non-clobber copy in --update mode`). Keeping the test commit and the fix commit separate makes the failure mode visible in `git log` — useful if we ever bisect a regression.

---

### Task C10: Update final "Next steps" output for `--update` mode

**Files:**
- Modify: `~/RS42/projects/vault-setup-kit/setup-vault.sh`

- [ ] **Step 1: Replace the final `echo "Next steps:"` block with mode-conditional output**

```bash
echo ""
echo "=== Setup Complete ==="
echo ""
if [ "$UPDATE_MODE" -eq 1 ]; then
  echo "Next steps:"
  echo "  1. Open Claude Code in: $VAULT"
  echo "  2. Run: /update-structure"
  echo "     (applies outstanding structure updates interactively)"
else
  echo "Next steps:"
  echo "  1. Open Obsidian and point it at: $VAULT"
  echo "  2. Run setup-plugins.sh to install community plugins"
  echo "  3. Run setup-mcp.sh to register MCP servers with Claude Code"
  echo "  4. Open Personal/Vault-Setup/Vault-Setup.md and start the curriculum"
fi
```

- [ ] **Step 2: Add a test for the update-mode message**

```bash
@test "setup-vault.sh --update next-steps mention /update-structure" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --update "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/update-structure"* ]]
}
```

- [ ] **Step 3: Run tests**

```bash
bats test/
# Expected: all pass
```

- [ ] **Step 4: Commit**

```bash
git add setup-vault.sh test/
git commit -m "feat(setup-vault): update-mode-aware next-steps output"
```

---

### Task C11: Update usage-help text

**Files:**
- Modify: `~/RS42/projects/vault-setup-kit/setup-vault.sh` (header comment block)

- [ ] **Step 1: Replace the existing top-of-file comment block with**

```bash
#!/usr/bin/env bash
# setup-vault.sh — Bootstrap or update an Obsidian vault with hub-and-spoke structure
#
# Usage:
#   bash setup-vault.sh [vault_path]
#     Fresh install: creates folder structure, copies starter content (non-clobber),
#     initializes git.
#
#   bash setup-vault.sh --update [vault_path]
#     Update existing vault: installs /update-structure slash command, records
#     kit path in <vault>/.vault-kit-path, then runs the same non-clobber copy
#     to add any new canonical files (e.g. AGENTS.md in v0.2).
#     User then runs /update-structure in Claude Code to apply outstanding
#     structure updates.
#
#   vault_path defaults to ~/Claude/ObsidianVault
#
# Safe to re-run in either mode — never overwrites user files.
```

- [ ] **Step 2: Commit**

```bash
git add setup-vault.sh
git commit -m "docs(setup-vault): document --update mode in header"
```

---

## Stage D — Smoke tests (human-gated)

These tasks exercise the real flow against synthetic and real vaults. The first run reveals bugs the bats unit tests can't catch — path edge cases, permission issues, real-world filesystem state. **Each task in this stage requires human verification of the output before proceeding.**

**Worktree caveat:** if Stages A–C were executed inside a git worktree (per `superpowers:using-git-worktrees`), `setup-vault.sh` will resolve `SCRIPT_DIR` to the worktree path and write *that* into `.vault-kit-path`. For smoke tests, switch to the canonical kit checkout (`~/RS42/projects/vault-setup-kit/`) before running the script — or accept that the founder's vault will temporarily point at the worktree, which is fine if you're going to merge and clean up immediately after.

### Task D1: Construct synthetic v0.1 test vault

**Files:**
- Create: `/tmp/test-v01-vault/` (test fixture, not committed anywhere)

- [ ] **Step 1: Build a v0.1-shaped vault from kit's pre-v0.2 state**

```bash
rm -rf /tmp/test-v01-vault
mkdir -p /tmp/test-v01-vault
# Use git to fetch the v0.1 vault-files/ snapshot
cd ~/RS42/projects/vault-setup-kit
git show 1293cd5:vault-files/CLAUDE.md > /tmp/test-v01-vault/CLAUDE.md
# Confirm it's the 231-line starter
wc -l /tmp/test-v01-vault/CLAUDE.md
# Expected: ~231 lines
```

- [ ] **Step 2: Initialize as a git repo** (so structure update can use git-based rollback if needed)

```bash
cd /tmp/test-v01-vault
git init -q
git add -A
git -c commit.gpgsign=false commit -q -m "initial v0.1 state"
cd ~/RS42/projects/vault-setup-kit
```

- [ ] **Step 3: Verify state**

```bash
ls -la /tmp/test-v01-vault/
# Expected: CLAUDE.md only (and .git/)
test ! -f /tmp/test-v01-vault/AGENTS.md && echo "AGENTS.md absent — good"
test ! -f /tmp/test-v01-vault/.vault-kit-path && echo "kit-path absent — good"
```

---

### Task D2: Run `setup-vault.sh --update` against synthetic vault

- [ ] **Step 1: Execute**

```bash
cd ~/RS42/projects/vault-setup-kit
bash setup-vault.sh --update /tmp/test-v01-vault
```

- [ ] **Step 2: Manually verify expected outcomes**

```bash
# Slash command installed
test -f /tmp/test-v01-vault/.claude/commands/update-structure.md && echo "✓ slash command installed"
# Kit path recorded
cat /tmp/test-v01-vault/.vault-kit-path
# Expected: /Users/yandifarinango/RS42/projects/vault-setup-kit
# AGENTS.md added (new canonical file from v0.2)
test -f /tmp/test-v01-vault/AGENTS.md && echo "✓ AGENTS.md added"
# CLAUDE.md NOT clobbered (still the 231-line v0.1 starter — the structure update later flips it)
wc -l /tmp/test-v01-vault/CLAUDE.md
# Expected: ~231 lines (NOT 5)
# system-settings/vault-structure.md added
test -f /tmp/test-v01-vault/system-settings/vault-structure.md && echo "✓ vault-structure reference added"
```

- [ ] **Step 3: Report results** to the human running the plan. **HUMAN GATE: verify all four checks passed before continuing.** If any failed, debug before D3.

---

### Task D3: Run `setup-vault.sh --update` against founder's vault

This is the second smoke test — against a vault that's already on the current shape. Expected: kit path written, slash command installed, but no canonical files added (founder already has them all).

- [ ] **Step 1: Snapshot state before** (so we can confirm nothing unexpected changed)

```bash
cd ~/Claude/ObsidianVault
git status > /tmp/founder-vault-pre-update.txt
```

- [ ] **Step 2: Run**

```bash
cd ~/RS42/projects/vault-setup-kit
bash setup-vault.sh --update ~/Claude/ObsidianVault
```

- [ ] **Step 3: Diff post-state**

```bash
cd ~/Claude/ObsidianVault
git status
# Expected new files (untracked):
#   .vault-kit-path
#   .claude/commands/update-structure.md
# NO changes to existing files (CLAUDE.md, AGENTS.md, templates)
```

- [ ] **Step 4: Verify slash command is loadable** (this is a sanity check, doesn't actually invoke it)

```bash
cat ~/Claude/ObsidianVault/.claude/commands/update-structure.md | head -20
# Expected: frontmatter with `description:` and `allowed-tools:`
```

- [ ] **Step 5: HUMAN GATE.** Founder manually invokes `/update-structure --list` in Claude Code inside the vault. Expected output: lists `2026-05-16-agents-md-adoption` as `vacuously applies (AGENTS.md already exists)`. Confirm this behavior with the human before D4.

---

### Task D4: Smoke-test the actual structure update against founder's vault — DRY RUN ONLY

**Goal:** Confirm `/update-structure` (no flags, real run) marks the AGENTS.md update as vacuously-applied and records it in `.vault-structure-updates-applied` without making any file changes to the founder's vault.

- [ ] **Step 1: HUMAN GATE.** Founder runs `/update-structure --dry-run` in Claude Code inside `~/Claude/ObsidianVault`.

Expected output:
```
Reading structure-updates/ from /Users/yandifarinango/RS42/projects/vault-setup-kit
Found 1 candidate: 2026-05-16-agents-md-adoption
Detection: AGENTS.md exists at vault root → does not apply (vacuously applied)
[DRY-RUN] Would record: 2026-05-16-agents-md-adoption  vacuously-applied
```

- [ ] **Step 2: HUMAN GATE.** If dry-run looks correct, founder runs the real `/update-structure`. Expected: same as dry-run, plus `.vault-structure-updates-applied` is created with one line.

```bash
cat ~/Claude/ObsidianVault/.vault-structure-updates-applied
# Expected: "2026-05-16-agents-md-adoption    <timestamp>    vacuously-applied"
```

- [ ] **Step 3: Confirm no file changes**

```bash
cd ~/Claude/ObsidianVault
git status
# Expected new files: .vault-kit-path, .claude/commands/update-structure.md, .vault-structure-updates-applied
# NO modified files
```

---

## Stage E — Cleanup

### Task E1: Delete the personal-os draft files

**Files:**
- Delete: `~/RS42/projects/personal-os/plugins/personal-os/skills/migrate-vault/` (entire directory)

- [ ] **Step 1: Verify nothing else references migrate-vault in personal-os**

```bash
cd ~/RS42/projects/personal-os
grep -rn "migrate-vault" --include="*.md" --include="*.json" --include="*.sh" .
# Expected: matches only inside the directory we're about to delete (or zero matches outside it)
```

- [ ] **Step 2: HUMAN GATE.** Confirm with the user before deleting. Then:

```bash
rm -rf ~/RS42/projects/personal-os/plugins/personal-os/skills/migrate-vault
```

- [ ] **Step 3: Verify deletion**

```bash
test ! -d ~/RS42/projects/personal-os/plugins/personal-os/skills/migrate-vault && echo "✓ deleted"
```

- [ ] **Step 4: If the personal-os repo has uncommitted state from this deletion, commit it**

```bash
cd ~/RS42/projects/personal-os
git status
# If the migrate-vault dir was tracked, git will show the deletion
git add -A
git commit -m "chore: remove migrate-vault draft (moved to vault-setup-kit)"
```

If the migrate-vault directory was untracked (just sitting in working tree), the deletion is a no-op for git.

---

## Stage F — Founder-vault docs

### Task F1: Update `Vault-Setup.md` hub

**Files:**
- Modify: `~/Claude/ObsidianVault/2. Projects/2. RS42/Vault-Setup/Vault-Setup.md` (lines 24–46)

The current "Current Status" section lists a v0.2 punch list focused on *install-time* improvements. We need to:
- Declare v0.2 = structure-update cycle (this work)
- Move the install-improvements punch list to a v0.3 section
- Add a line linking to the spec note and this plan

- [ ] **Step 1: Read current state** to find the exact lines to modify

```bash
grep -n "v0.2 punch list" "$HOME/Claude/ObsidianVault/2. Projects/2. RS42/Vault-Setup/Vault-Setup.md"
```

- [ ] **Step 2: Rewrite the "Current Status" section** to:

```markdown
## Current Status

<!-- Refreshed by /project-sync -->

**v0.1 shipped (2026-05-09)**: Kit pushed to [RS42-AI/vault-setup-kit](https://github.com/RS42-AI/vault-setup-kit) at `1293cd5` (+ `f7c21d0` lint fix). Includes generic CLAUDE.md, area dashboard, 12 templates, and a fully-formed `Personal/Vault-Setup/` starter project (orientation hub + 9-note sanitized curriculum + deep-research resource + 3 onboarding tasks). All four bash scripts (`setup.sh`, `setup-vault.sh`, `setup-plugins.sh`, `setup-mcp.sh`) generalized from the MacBook-Setup precedent. See [[2026-05-09 - Build kit v0.1 with starter content scripts and curriculum]] for the session log.

**First real install (2026-05-09)**: Sister cloned the repo and is running setup. Working so far without a blocker — she got past clone and into the script flow. Don't yet have a full debrief on which steps fully succeeded, the manual handoff points (plugin enable, API key paste), or QMD index build. Need a follow-up session to capture her friction points and feed v0.3.

### v0.2 — structure-update cycle (in flight, 2026-05-18)

Scope: ship the *upgrade path* so v0.1 installs (like sister's) can catch up to current vault shape via `git pull && /update-structure`. New pieces: `structure-updates/` prose docs, `commands/update-structure.md` slash-command runner, `setup-vault.sh --update` mode, `.vault-kit-path` resolution. First structure update is AGENTS.md adoption.

Design: [[Vault-Setup Kit Update Cycle - Prose-Driven Structure Updates for Continuous Vault Shape Evolution]]
Plan: `~/RS42/projects/vault-setup-kit/docs/superpowers/plans/2026-05-18-vault-setup-kit-v0.2.md`

### v0.3 punch list (install-friction, deferred from v0.2)

1. **Post-install debrief with sister** — highest-leverage input; her real friction points should reorder this list
2. **Interactive Claude Code prompt tutorial** — add as the FIRST onboarding task (`Try interactive Claude Code prompts.md`), before "Add my first project". A graded sequence of ~6 prompts that double as an MCP self-test (list vault files, search for "closed-loop", read Vault-Setup.md and summarize, explain closed-loop vs open-loop, create a hello-world note, "Add a project for my apartment search per CLAUDE.md"). Each prompt fails visibly if its capability isn't wired — self-diagnosing install.
3. **API key auto-gen** — `jq -r .apiKey "$VAULT/.obsidian/plugins/obsidian-local-rest-api/data.json"` in `setup-mcp.sh`; removes the manual paste step
4. **Plugin auto-enable** — extend `setup-plugins.sh` to update `community-plugins.json`, not just write `data.json` files; removes the "click Enable in Obsidian for each plugin" step
5. **`setup-prereqs.sh`** — lower priority (sister had her prereqs already), but still useful for fresh-machine cases: brew + node + Claude Code CLI + bun + Obsidian (cask)
6. **End-to-end smoke test** — `bash setup.sh /tmp/test-vault-smoke` on a fresh path, validate every step succeeds before the next user tries it cold
```

- [ ] **Step 3: Verify the hub still parses** (Obsidian Bases blocks intact, etc.)

Open the file in a viewer to confirm the Bases blocks below the Current Status section are untouched. If a section header was used as an Obsidian Bases anchor, check whether anything broke.

```bash
grep -n "^## " "$HOME/Claude/ObsidianVault/2. Projects/2. RS42/Vault-Setup/Vault-Setup.md"
```

- [ ] **Step 4: This change lives in the vault repo (not the kit). Defer the commit to Stage G's vault-side commit.**

---

## Stage G — Release

### Task G1: Verify all bats tests pass

```bash
cd ~/RS42/projects/vault-setup-kit
bats test/
# Expected: all green
```

- [ ] **Step 1: Run**
- [ ] **Step 2: If any fail, fix before tagging**

---

### Task G2: Verify CI passes locally

```bash
cd ~/RS42/projects/vault-setup-kit
# Run any lint/shellcheck the CI runs
bash -n setup-vault.sh
shellcheck setup-vault.sh
```

- [ ] **Step 1: Run lint locally**
- [ ] **Step 2: Fix any new shellcheck warnings introduced by --update mode**

---

### Task G3: Review final commit list

```bash
cd ~/RS42/projects/vault-setup-kit
git log --oneline f7c21d0..HEAD
# Expected commits (rough sequence — exact list will reflect actual work):
#   feat: add canonical AGENTS.md for v0.2 (beginner-templated)
#   refactor: collapse CLAUDE.md to AGENTS.md pointer
#   feat: add load-on-demand vault-structure reference
#   docs: record template-drift audit for v0.2
#   chore: scaffold structure-updates/ and commands/ directories
#   feat: first structure update — AGENTS.md adoption
#   feat: add /update-structure slash-command runner
#   feat(setup-vault): recognize --update flag
#   feat(setup-vault): write .vault-kit-path on --update
#   feat(setup-vault): install /update-structure slash command on --update
#   test(setup-vault): lock non-clobber behavior under --update
#   feat(setup-vault): update-mode-aware next-steps output
#   docs(setup-vault): document --update mode in header
```

- [ ] **Step 1: Confirm history is clean and semantic**

---

### Task G4: Tag v0.2 (HUMAN GATE)

- [ ] **Step 1: HUMAN GATE.** Pause for human approval before tagging or pushing — published artifact.

```bash
cd ~/RS42/projects/vault-setup-kit
git tag -a v0.2 -m "v0.2 — structure-update cycle"
```

- [ ] **Step 2: Confirm tag**

```bash
git tag -l
# Expected: v0.2 in the list
```

---

### Task G5: Push to origin (HUMAN GATE)

- [ ] **Step 1: HUMAN GATE.** Confirm with the user before pushing.

```bash
cd ~/RS42/projects/vault-setup-kit
git push origin main
git push origin v0.2
```

- [ ] **Step 2: Confirm push**

```bash
git ls-remote origin v0.2
# Expected: v0.2 tag visible on remote
```

---

### Task G6: Commit vault-side changes

The vault has uncommitted changes from this work: the spec note (renamed file), and the hub update from Stage F.

- [ ] **Step 1: Stage the vault changes**

```bash
cd ~/Claude/ObsidianVault
git status
# Expected modified/added files:
#   - "2. Projects/2. RS42/Vault-Setup/Notes/Vault-Setup Kit Update Cycle - Prose-Driven Structure Updates for Continuous Vault Shape Evolution.md" (new)
#   - "2. Projects/2. RS42/Vault-Setup/Notes/Vault-Setup Kit Update Cycle - Prose-Driven Migrations for Continuous Vault Shape Evolution.md" (deleted)
#   - "2. Projects/2. RS42/Vault-Setup/Vault-Setup.md" (modified)
#   - .vault-kit-path, .claude/commands/update-structure.md, .vault-structure-updates-applied (untracked — these came from running setup-vault.sh --update against the founder vault)
```

- [ ] **Step 2: Decide what to commit and what to leave for nightly /vault-commit**

Recommended: commit the spec rename + hub update as one logical commit. The untracked runtime files (`.vault-kit-path`, `.vault-structure-updates-applied`, `.claude/commands/update-structure.md`) are machine-specific install artifacts — consider adding them to the vault's `.gitignore` so they don't get committed by accident on any machine:

```
# vault-setup-kit runtime state (machine-local, do not commit)
.vault-kit-path
.vault-structure-updates-applied
.claude/commands/update-structure.md
```

Adding these to `.gitignore` is a separate decision from this commit — defer if the user wants to think about it. For now, leave them untracked; the nightly cleanup will not pick them up if they're in `.gitignore`.

```bash
cd ~/Claude/ObsidianVault
git add "2. Projects/2. RS42/Vault-Setup/Notes/Vault-Setup Kit Update Cycle - Prose-Driven Structure Updates for Continuous Vault Shape Evolution.md"
git add "2. Projects/2. RS42/Vault-Setup/Notes/Vault-Setup Kit Update Cycle - Prose-Driven Migrations for Continuous Vault Shape Evolution.md"  # the deletion
git add "2. Projects/2. RS42/Vault-Setup/Vault-Setup.md"
git commit -m "docs(vault-setup): spec the structure-update cycle and update hub for v0.2"
```

- [ ] **Step 3: HUMAN GATE before pushing the vault repo, if it has a remote at all.**

---

## Post-Plan

After all stages complete:
- Sister-side test: pull v0.2 in her kit clone, run `setup-vault.sh --update`, then `/update-structure`. Real-world verification. Tracked as a follow-up task in `Vault-Setup.md`.
- Open questions from spec ("Version stamping", "Dependencies between structure updates") remain unaddressed in v0.2 — defer until they bite.
- v0.3 (install-friction improvements) becomes the next milestone, driven by sister's debrief.

---

## Execution Notes for the Implementer

- **Stages A and B are mechanical file work.** Suitable for Haiku-tier subagents with controller-curated context. No TDD needed — verify by file-existence + structural greps.
- **Stage C is the only TDD chunk.** Bash code with bats tests. Sonnet-tier subagent; one task per failing-test → implement → green cycle.
- **Stages D, E, G have explicit HUMAN GATES marked.** These are not autonomous-runnable end-to-end:
  - D2, D3, D4 — smoke tests need founder-vault and synthetic-vault eyes-on
  - E1 — file deletion needs confirm
  - G4, G5 — tag + push are published-artifact actions
- **Stage F is a one-shot edit to a vault file** that doesn't get committed in the kit repo. Defer its commit to G6.
- If any task's verification step fails, **stop**. Don't proceed to the next task. Report DONE_WITH_CONCERNS or BLOCKED per the subagent-driven-development conventions.
