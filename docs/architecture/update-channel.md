# How the kit's update channel works

How `setup-vault.sh --update` and `/update-structure` cooperate to keep an installed vault in sync with the kit's canonical shape, without forcing reinstalls or clobbering customizations.

If you want the *design rationale* (why prose-driven migrations rather than mechanical overwrites), the spec lives in the founder's vault at `2. Projects/2. RS42/Vault-Setup/Notes/Vault-Setup Kit Update Cycle - Prose-Driven Structure Updates for Continuous Vault Shape Evolution.md`. This doc covers the *operational mental model* — what files go where, what happens when you run things.

## The two delivery moments

The kit has two distinct moments it interacts with a user's vault:

**Moment 1 — Fresh install.** User runs `bash setup.sh ~/MyVault` (or just `bash setup-vault.sh ~/MyVault`). This creates folder structure, copies starter content, initializes git. The kit's job is done; the vault is theirs to live in.

**Moment 2 — Update channel** (v0.2+). Months later the kit ships improvements — a renamed file, a new template, a structural convention change. The user runs `bash setup-vault.sh --update ~/MyVault`. This is the entry point to the update channel. It does *not* re-run the fresh-install setup — it does three small, additive things and then steps aside.

## What `setup-vault.sh --update` actually does

Three steps, in order, idempotent on every re-run:

1. **Writes `~/MyVault/.vault-kit-path`** — a one-line file containing the absolute path to the kit repo on this machine (e.g. `~/vault-setup-kit`). This is how the slash command finds the kit later.

2. **Copies the slash-command runner** into `~/MyVault/.claude/commands/update-structure.md`. This is an unconditional overwrite — the runner is kit-shipped and should always reflect the latest version. (The runner is agent config, not user content; users do not hand-edit commands files.)

3. **Re-runs the non-clobber copy of `vault-files/*`** — the same loop that ran on fresh install. If the kit ships a new canonical file (like `AGENTS.md` arriving in v0.2), the user receives it. If a file already exists in the user's vault, it is preserved as-is. The user's customizations are never overwritten.

After these three steps the script prints `Next steps:` directing the user to run `/update-structure` in Claude Code.

## What `/update-structure` does at runtime

The user opens Claude Code in their vault and types `/update-structure`. Claude Code finds `<vault>/.claude/commands/update-structure.md`, loads it as instructions, and the body walks Claude through:

1. **Locate vault root** — verify we're in a vault by checking for `CLAUDE.md` or `AGENTS.md`.
2. **Read `.vault-kit-path`** — locate the kit repo on disk. If this file is missing, stop and tell the user to run `setup-vault.sh --update <vault>` first.
3. **Check git state** — warn if uncommitted changes exist; the user can mix kit-added files with pending work, but it should be a conscious choice.
4. **List structure updates** — read `<kit>/structure-updates/*.md`, sort by filename (dated `YYYY-MM-DD-*`), cross-reference against `.vault-structure-updates-applied` to find which are still pending.
5. **For each pending update** — read the prose doc's `## Detection` section, evaluate it against the user's actual vault state.
6. **If detection matches** — walk the user through the `## Changes` section, propose each edit, ask for confirmation before writing. Run the `## Verification` checks. Record outcome.
7. **If detection does not match** — record as `vacuously-applied`. The update is checked off; no files were changed because nothing needed changing.
8. **Append to `.vault-structure-updates-applied`** — one tab-delimited line per update: `<id>    <timestamp>    <status>` where status is `applied` or `vacuously-applied`.

The runner respects flags: `--list` prints the inventory and exits; `--dry-run` walks all steps but skips the write phase and the log append.

## Disk layout (after `setup-vault.sh --update` has run)

```
[Kit repo, edited locally and pulled from GitHub]
~/RS42/projects/vault-setup-kit/
├── structure-updates/
│   └── 2026-05-16-agents-md-adoption.md     (one per shape change; sorted by date)
├── commands/
│   └── update-structure.md                  (the runner; shipped into vaults)
├── setup-vault.sh                           (entry point; --update is the new mode)
└── vault-files/                             (canonical content; copied non-clobber)
    ├── AGENTS.md, CLAUDE.md, ...

[User's vault — receives the bottom three additions]
~/Claude/ObsidianVault/
├── AGENTS.md, CLAUDE.md, ...                (canonical files, non-clobber-copied in)
├── 1. Daily/, 2. Projects/, ...             (user content; never touched by --update)
├── .vault-kit-path                          NEW — points to the kit repo
├── .claude/commands/update-structure.md     NEW — copied from kit/commands/
└── .vault-structure-updates-applied         NEW — appended by /update-structure runs
```

The three "new" files are operational state, not user content. The vault's `.gitignore` can list them so they don't pollute commits.

## Why running it against an already-current vault is safe

The first structure update doc (`2026-05-16-agents-md-adoption.md`) has a Detection rule: `CLAUDE.md > 50 lines AND AGENTS.md missing`. A vault that already has `AGENTS.md` fails the detection — the update is *vacuously applied*: checked off, no edits, no prompts. This is the founder-vault smoke test path.

A vault that *needs* the update (sister's at v0.1 — has the 231-line CLAUDE.md, no AGENTS.md) passes detection. The runner walks her through the change: shows the new `AGENTS.md`, shows the 5-line `CLAUDE.md` pointer that replaces her current one, makes a backup at `CLAUDE.md.pre-agents-md-update`, asks for confirmation before each write, and verifies file shapes after.

In both cases the runner is observable, interruptible, and reversible. The user sees every diff before any write happens.

## The sister-upgrade flow (the canonical user journey)

This is the path the v0.2 release is designed for:

1. Sister is on v0.1. Her kit clone is at, say, `~/code/vault-setup-kit/`. Her vault is at `~/MyVault/`.
2. We tag v0.2 and push it to `RS42-AI/vault-setup-kit`.
3. Sister: `cd ~/code/vault-setup-kit && git pull`. She now has v0.2's `structure-updates/`, `commands/update-structure.md`, and the new `setup-vault.sh --update` flag.
4. Sister: `bash setup-vault.sh --update ~/MyVault`. This writes `.vault-kit-path`, copies the slash command in, and non-clobber-copies in the new `AGENTS.md` and `vault-structure.md`. Her existing `CLAUDE.md` (231 lines, v0.1 style) is preserved.
5. Sister opens Claude Code in `~/MyVault`, types `/update-structure`. The runner finds one pending update, detects "CLAUDE.md > 50 lines AND AGENTS.md exists but is the new 131-line shape, not the v0.1 starter" — actually this triggers detection because AGENTS.md is "missing in v0.1's sense" by being absent before step 4. The runner walks her through swapping CLAUDE.md to the pointer form, with diff confirmation.
6. After completion, `.vault-structure-updates-applied` records the update. Future `/update-structure` runs are no-ops until the kit ships another structure update.

The whole flow assumes the user has the kit repo on disk locally. No GitHub round-trip happens at slash-command time — Claude reads from the local kit repo. Updates to the kit arrive via `git pull` on the kit clone, separately from running the slash command.

## What you don't need to do

- **No re-clone of the kit on update.** `git pull` is enough.
- **No reinstall of the vault.** The update channel is purely additive — non-clobber file copies + a log file.
- **No manual reading of `structure-updates/` prose.** The slash command reads them for you and walks you through changes interactively.
- **No remembering which updates you applied.** `.vault-structure-updates-applied` is the durable record; `/update-structure --list` prints it on demand.

## Where each piece is documented

| Concept | Location |
|---|---|
| Design rationale (why prose-driven) | Founder vault: `Vault-Setup Kit Update Cycle - Prose-Driven Structure Updates for Continuous Vault Shape Evolution.md` |
| Operational mental model (this doc) | `docs/architecture/update-channel.md` |
| v0.2 implementation plan | `docs/superpowers/plans/2026-05-18-vault-setup-kit-v0.2.md` |
| The runner itself | `commands/update-structure.md` |
| The first structure update | `structure-updates/2026-05-16-agents-md-adoption.md` |
| Setup-script behavior | `setup-vault.sh` header comment |
