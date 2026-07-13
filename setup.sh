#!/usr/bin/env bash
# setup.sh — One-command bootstrap for a fresh Obsidian + Claude Code vault
#
# Runs the setup steps in order:
#   1. setup-vault.sh          — create folder structure and copy starter content
#   2. setup-plugins.sh        — install Obsidian community plugins
#   3. setup-mcp.sh            — register MCP servers with Claude Code
#   4. setup-claude-plugins.sh — install the AI-OS Lite Claude Code plugin
#
# Usage: bash setup.sh [vault_path]
#   vault_path defaults to ~/Claude/ObsidianVault
#   SETUP_YES=1 = non-interactive (skip the "Press Enter" GUI-coordination pauses)

set -euo pipefail

EDITION="personal"
POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --edition) EDITION="${2:-}"; shift 2 ;;
    --edition=*) EDITION="${1#*=}"; shift ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
# bash 3.2 (macOS): guard empty-array expansion under `set -u`
if [ ${#POSITIONAL[@]} -gt 0 ]; then set -- "${POSITIONAL[@]}"; else set --; fi

VAULT="${1:-$HOME/Claude/ObsidianVault}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "============================================================"
echo "  Vault Setup Kit"
echo "  Target: $VAULT"
echo "============================================================"
echo ""

bash "$SCRIPT_DIR/setup-vault.sh" --edition="$EDITION" "$VAULT"
echo ""

echo "------------------------------------------------------------"
echo "  Plugins step requires Obsidian to be CLOSED."
echo "  Press Enter when ready (or Ctrl+C to skip)."
[ -n "${SETUP_YES:-}" ] || read -r
echo "------------------------------------------------------------"
echo ""

bash "$SCRIPT_DIR/setup-plugins.sh" "$VAULT"
echo ""

echo "------------------------------------------------------------"
echo "  Now OPEN Obsidian, point it at $VAULT,"
echo "  and enable: Local REST API, Templater, Dataview, MCP Tools"
echo "  Then come back and press Enter to continue MCP setup."
[ -n "${SETUP_YES:-}" ] || read -r
echo "------------------------------------------------------------"
echo ""

bash "$SCRIPT_DIR/setup-mcp.sh" "$VAULT"
echo ""

echo "------------------------------------------------------------"
echo "  Installing the AI-OS Lite Claude Code plugin"
echo "  (daily commands: /start-day, /process-morning, /vault-commit, ...)"
echo "------------------------------------------------------------"
echo ""

bash "$SCRIPT_DIR/setup-claude-plugins.sh" "$VAULT"

echo ""
echo "============================================================"
if [ "$EDITION" = "team" ]; then
  echo "  All done. Open"
  echo "  $VAULT/2. Projects/RS42/RS42-Onboarding/RS42-Onboarding.md"
  echo "  to start."
else
  echo "  All done. Open $VAULT/Personal/Vault-Setup/Vault-Setup.md"
  echo "  to start the curriculum."
fi
echo "============================================================"
