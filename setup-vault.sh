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

set -euo pipefail

UPDATE_MODE=0
EDITION="personal"
POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --update) UPDATE_MODE=1; shift ;;
    --edition) EDITION="${2:-}"; shift 2 ;;
    --edition=*) EDITION="${1#*=}"; shift ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
# bash 3.2 (macOS): guard empty-array expansion under `set -u`
if [ ${#POSITIONAL[@]} -gt 0 ]; then set -- "${POSITIONAL[@]}"; else set --; fi

VAULT="${1:-$HOME/Claude/ObsidianVault}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/vault-files"
TEAM_OVERLAY="$SCRIPT_DIR/editions/team"

if [ "$EDITION" != "personal" ] && [ "$EDITION" != "team" ]; then
  echo "ERROR: unknown --edition '$EDITION' (expected: personal | team)"
  exit 1
fi

if [ ! -d "$SRC" ]; then
  echo "ERROR: vault-files/ not found at $SRC"
  echo "Make sure you're running this script from the kit's root directory."
  exit 1
fi

if [ "$UPDATE_MODE" -eq 1 ]; then
  echo "=== Vault Setup — Update Mode ==="
else
  echo "=== Vault Setup ==="
fi
echo "Target vault: $VAULT"
echo ""

if [ "$UPDATE_MODE" -eq 1 ]; then
  if [ ! -d "$VAULT" ]; then
    echo "ERROR: --update requires an existing vault. $VAULT does not exist."
    echo "       For a fresh install, run: bash setup-vault.sh $VAULT"
    exit 1
  fi
  echo "[update] Recording kit path to $VAULT/.vault-kit-path"
  echo "$SCRIPT_DIR" > "$VAULT/.vault-kit-path"
  echo "[update] Installing /update-structure slash command"
  mkdir -p "$VAULT/.claude/commands"
  cp "$SCRIPT_DIR/commands/update-structure.md" "$VAULT/.claude/commands/update-structure.md"
fi

# --- 1. Create folder structure ---
echo "[1/4] Creating folder structure..."

# Top-level folders that always exist (some are populated by content files,
# others are intentionally empty to be filled by the user over time).
# The set is selected by edition: a personal-life vault vs an RS42 work vault.
personal_folders=(
  "1. Daily"
  "2. Projects"
  "3. Areas"
  "3. Areas/Personal"
  "3. Areas/Personal/Goals"
  "4. Contacts"
  "4. Contacts/People"
  "4. Contacts/Meetings"
  "5. Resources"
  "5. Resources/Personal"
  "5. Resources/Personal/Journal"
  "5. Resources/Personal/Journal/Morning Entries"
  "5. Resources/Personal/Journal/Evening Entries"
  "6. Main Notes"
  "Personal"
  "Personal/Tasks"
  "system-settings"
  "system-settings/Templates"
  "system-settings/Pasted Images"
)
team_folders=(
  "1. Daily"
  "2. Projects"
  "2. Projects/RS42"
  "3. Areas"
  "3. Areas/RS42"
  "3. Areas/RS42/Goals"
  "4. Contacts"
  "4. Contacts/People"
  "4. Contacts/Meetings"
  "5. Resources"
  "5. Resources/RS42"
  "6. Main Notes"
  "system-settings"
  "system-settings/Templates"
  "system-settings/Pasted Images"
)
if [ "$EDITION" = "team" ]; then folders=("${team_folders[@]}"); else folders=("${personal_folders[@]}"); fi

for folder in "${folders[@]}"; do
  mkdir -p "$VAULT/$folder"
done
echo "  Ensured ${#folders[@]} folders exist"

# --- 2. Copy starter content over the vault ---
# Personal-only base files that must not ship in a team vault. An overlay can
# override a base file but cannot remove one — removal needs this list.
team_base_excludes=(
  "system-settings/Templates/Journal Entry Template.md"
  "system-settings/Templates/Evening Journal Template.md"
)

# is_excluded REL: true when REL (vault-relative path) is excluded for this edition.
is_excluded() {
  local rel="$1" ex
  [ "$EDITION" = "team" ] || return 1
  for ex in "${team_base_excludes[@]}"; do
    [ "$rel" = "$ex" ] && return 0
  done
  return 1
}

# copy_tree BASE [SUBPATH]: non-clobber copy of files under BASE/[SUBPATH] into
# $VAULT, preserving each file's path relative to BASE. Existing files are kept.
copied_count=0
copy_tree() {
  local base="$1" sub="${2:-}"
  local root="$base"
  [ -n "$sub" ] && root="$base/$sub"
  local src_file rel dest
  while IFS= read -r -d '' src_file; do
    rel="${src_file#"$base"/}"
    if is_excluded "$rel"; then continue; fi
    dest="$VAULT/$rel"
    mkdir -p "$(dirname "$dest")"
    if [ -f "$dest" ]; then
      : # skip existing files silently
    else
      cp "$src_file" "$dest"
      copied_count=$((copied_count + 1))
    fi
  done < <(find "$root" -type f -print0)
}

echo "[2/4] Copying starter content (edition: $EDITION)..."
if [ "$EDITION" = "team" ]; then
  # Overlay FIRST: copy_tree never clobbers, so whatever the overlay ships
  # (its own vault-structure.md, Daily Note Hub template, AGENTS.md, ...)
  # wins over the shared base copied next.
  copy_tree "$TEAM_OVERLAY"
  copy_tree "$SRC" "system-settings"
else
  copy_tree "$SRC"
fi
echo "  Copied $copied_count new files (existing files left alone)"

# --- 3. Place CLAUDE.md ---
# The CLAUDE.md from vault-files/ is already copied above. This step just
# notes it for the user since it's the most important file in the vault.

if [ -f "$VAULT/CLAUDE.md" ]; then
  echo "[3/4] CLAUDE.md present at vault root"
else
  echo "[3/4] WARNING: CLAUDE.md missing. Copy from $SRC/CLAUDE.md manually."
fi

# --- 4. Initialize git ---
echo "[4/4] Checking git..."

if [ -d "$VAULT/.git" ]; then
  echo "  Git already initialized — skipping"
else
  cd "$VAULT"
  git init -q
  cat > .gitignore << 'GITEOF'
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/plugins/*/data.json
.trash/
.DS_Store
GITEOF
  git add -A
  git -c commit.gpgsign=false commit -q -m "feat: initialize vault with hub-and-spoke structure"
  echo "  Git initialized with first commit"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
if [ "$UPDATE_MODE" -eq 1 ]; then
  echo "Next steps:"
  echo "  1. Open Claude Code or Codex in: $VAULT"
  echo "  2. In Claude Code, run: /update-structure"
  echo "     (applies outstanding structure updates interactively)"
else
  echo "Next steps:"
  echo "  1. Open Obsidian and point it at: $VAULT"
  echo "  2. Run setup-plugins.sh to install community plugins"
  echo "  3. Run setup.sh --agent=claude|codex|both for agent integration"
  if [ "$EDITION" = "team" ]; then
    echo "  4. Open '2. Projects/RS42/RS42-Onboarding/RS42-Onboarding.md' and start there"
  else
    echo "  4. Open Personal/Vault-Setup/Vault-Setup.md and start the curriculum"
  fi
fi
