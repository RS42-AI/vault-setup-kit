#!/usr/bin/env bash
# setup-claude-plugins.sh — install the AI-OS Lite Claude Code plugin
#
# Registers the AI-OS Lite marketplace and installs + enables the plugin, so
# the daily workflow commands are available in Claude Code:
#   /start-day  /process-journal  /prep-evening  /process-evening
#   /vault-commit  /project-sync
#
# The kit ORCHESTRATES the install from the ai-os-lite repo — it does not
# vendor the plugin (the two repos stay decoupled). This requires the repo to
# be published at https://github.com/RS42-AI/ai-os-lite
#
# This step is NON-FATAL: if the CLI is missing or the marketplace can't be
# reached, it warns and the rest of the vault still works. Re-run this script
# alone any time: bash setup-claude-plugins.sh [vault_path]
#
# Usage: bash setup-claude-plugins.sh [vault_path]

set -uo pipefail   # NOTE: no -e — a plugin failure must not abort the install

VAULT="${1:-$HOME/Claude/ObsidianVault}"

MARKETPLACE="RS42-AI/ai-os-lite"
PLUGIN="ai-os-lite@ai-os-lite-marketplace"

echo "=== AI-OS Lite plugin setup ==="
echo ""

# --- 0. Preflight: claude CLI present? ---
if ! command -v claude >/dev/null 2>&1; then
  echo "  SKIP: 'claude' CLI not found on PATH."
  echo "  Install Claude Code, then re-run: bash setup-claude-plugins.sh \"$VAULT\""
  exit 0
fi

# --- 1. Register the marketplace ---
echo "[1/3] Registering AI-OS Lite marketplace ($MARKETPLACE)..."
if ! claude plugin marketplace add "$MARKETPLACE"; then
  echo ""
  echo "  WARNING: could not add the marketplace."
  echo "  Most likely the repo isn't published yet (RS42-AI/ai-os-lite)."
  echo "  Vault setup is otherwise complete — re-run this script once the repo is"
  echo "  public: bash setup-claude-plugins.sh \"$VAULT\""
  exit 0
fi

# --- 2. Install the plugin ---
echo "[2/3] Installing AI-OS Lite plugin..."
if ! claude plugin install "$PLUGIN"; then
  echo "  WARNING: install failed. See the message above. Re-run to retry."
  exit 0
fi

# --- 3. Enable it (install != enable; both are needed for the commands to appear) ---
echo "[3/3] Enabling AI-OS Lite plugin..."
if ! claude plugin enable "$PLUGIN"; then
  echo "  WARNING: enable failed. Try manually: claude plugin enable $PLUGIN"
  exit 0
fi

echo ""
echo "=== AI-OS Lite Installed ==="
echo ""
echo "Verify in Claude Code by running:  /start-day"
echo "Other commands now available: /process-journal /prep-evening"
echo "  /process-evening /vault-commit /project-sync"
