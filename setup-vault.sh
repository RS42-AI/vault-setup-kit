#!/usr/bin/env bash
# setup-vault.sh — Bootstrap an Obsidian vault with hub-and-spoke structure
#
# Usage: bash setup-vault.sh [vault_path]
#   vault_path defaults to ~/Claude/ObsidianVault
#
# What it does:
#   1. Creates the hub-and-spoke folder structure
#   2. Copies vault-files/* over the vault (templates, area dashboards,
#      starter Vault-Setup project, CLAUDE.md) — never overwrites
#   3. Initializes git if not already a repo
#
# Safe to re-run — skips existing files (never overwrites).

set -euo pipefail

UPDATE_MODE=0
if [ "${1:-}" = "--update" ]; then
  UPDATE_MODE=1
  shift
fi

VAULT="${1:-$HOME/Claude/ObsidianVault}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/vault-files"

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
  echo "[update] Recording kit path to $VAULT/.vault-kit-path"
  echo "$SCRIPT_DIR" > "$VAULT/.vault-kit-path"
fi

# --- 1. Create folder structure ---
echo "[1/4] Creating folder structure..."

# Top-level folders that always exist (some are populated by vault-files,
# others are intentionally empty to be filled by the user over time).
folders=(
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

for folder in "${folders[@]}"; do
  mkdir -p "$VAULT/$folder"
done
echo "  Ensured ${#folders[@]} folders exist"

# --- 2. Copy vault-files over the vault ---
echo "[2/4] Copying starter content..."

# cp -Rn: recursive, no-clobber. Existing files are preserved.
# We use a tar-pipe to handle the recursive merge cleanly across
# nested directories that may already partially exist in the target.
copied_count=0
while IFS= read -r -d '' src_file; do
  rel="${src_file#"$SRC"/}"
  dest="$VAULT/$rel"
  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"
  if [ -f "$dest" ]; then
    : # skip existing files silently
  else
    cp "$src_file" "$dest"
    copied_count=$((copied_count + 1))
  fi
done < <(find "$SRC" -type f -print0)

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
echo "Next steps:"
echo "  1. Open Obsidian and point it at: $VAULT"
echo "  2. Run setup-plugins.sh to install community plugins"
echo "  3. Run setup-mcp.sh to register MCP servers with Claude Code"
echo "  4. Open Personal/Vault-Setup/Vault-Setup.md and start the curriculum"
