#!/usr/bin/env bash
# setup-codex-plugins.sh — install the AI-OS Lite Codex plugin
#
# Registers the public AI-OS Lite marketplace and installs the plugin for the
# current Codex user. The plugin is user-level, while the vault remains an
# independent per-user instance.
#
# This step is NON-FATAL: if Codex is missing or the marketplace cannot be
# reached, the vault setup remains usable and this script can be re-run later.
#
# Usage: bash setup-codex-plugins.sh [vault_path]

set -uo pipefail

VAULT="${1:-$HOME/Claude/ObsidianVault}"
MARKETPLACE="${AI_OS_LITE_MARKETPLACE:-RS42-AI/ai-os-lite}"
PLUGIN="ai-os-lite@ai-os-lite-marketplace"

echo "=== AI-OS Lite Codex plugin setup ==="
echo "Vault: $VAULT"
echo ""

if ! command -v codex >/dev/null 2>&1; then
  echo "  SKIP: 'codex' CLI not found on PATH."
  echo "  Install Codex, then re-run: bash setup-codex-plugins.sh \"$VAULT\""
  exit 0
fi

echo "[1/2] Registering AI-OS Lite marketplace ($MARKETPLACE)..."
if ! codex plugin marketplace add "$MARKETPLACE"; then
  echo ""
  echo "  WARNING: could not add the AI-OS Lite marketplace."
  echo "  Vault setup is otherwise complete. Re-run this script to retry."
  exit 0
fi

echo "[2/2] Installing AI-OS Lite for Codex..."
if ! codex plugin add "$PLUGIN"; then
  echo "  WARNING: plugin installation failed. Re-run this script to retry."
  exit 0
fi

echo ""
echo "=== AI-OS Lite Installed for Codex ==="
echo ""
echo "Start a new Codex task with this vault as the workspace:"
echo "  $VAULT"
echo "Then try: Run \$start-day for today."
