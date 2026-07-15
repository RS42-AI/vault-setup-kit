#!/usr/bin/env bash
# setup.sh — One-command bootstrap for a fresh Obsidian + AI-agent vault
#
# Runs the setup steps in order:
#   1. setup-vault.sh          — create folder structure and copy starter content
#   2. setup-plugins.sh        — install Obsidian community plugins
#   3. setup-mcp.sh            — register MCP servers when Claude is selected
#   4. setup-*-plugins.sh      — install AI-OS Lite for Claude, Codex, or both
#
# Usage: bash setup.sh [--agent=claude|codex|both] [vault_path]
#   vault_path defaults to ~/Claude/ObsidianVault
#   --agent defaults to claude for backward compatibility
#   SETUP_YES=1 = non-interactive (skip the "Press Enter" GUI-coordination pauses)

set -euo pipefail

EDITION="personal"
AGENT="claude"
POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --edition) EDITION="${2:-}"; shift 2 ;;
    --edition=*) EDITION="${1#*=}"; shift ;;
    --agent) AGENT="${2:-}"; shift 2 ;;
    --agent=*) AGENT="${1#*=}"; shift ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
# bash 3.2 (macOS): guard empty-array expansion under `set -u`
if [ ${#POSITIONAL[@]} -gt 0 ]; then set -- "${POSITIONAL[@]}"; else set --; fi

VAULT="${1:-$HOME/Claude/ObsidianVault}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$AGENT" in
  claude|codex|both) ;;
  *)
    echo "ERROR: unknown --agent '$AGENT' (expected: claude | codex | both)"
    exit 1
    ;;
esac

echo ""
echo "============================================================"
echo "  Vault Setup Kit"
echo "  Target: $VAULT"
echo "  Agent:  $AGENT"
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
if [ "$AGENT" = "claude" ] || [ "$AGENT" = "both" ]; then
  echo "  and enable: Local REST API, Templater, Dataview, MCP Tools"
  echo "  Then come back and press Enter to continue MCP setup."
else
  echo "  and enable: Templater and Dataview. Local REST API and MCP"
  echo "  Tools are optional until Codex integration setup is added."
  echo "  Then come back and press Enter to continue."
fi
[ -n "${SETUP_YES:-}" ] || read -r
echo "------------------------------------------------------------"
echo ""

if [ "$AGENT" = "claude" ] || [ "$AGENT" = "both" ]; then
  bash "$SCRIPT_DIR/setup-mcp.sh" "$VAULT"
  echo ""
else
  echo "Skipping Claude-specific MCP registration for --agent=codex."
  echo "Codex MCP/CLI integration setup is a separate optional step."
  echo ""
fi

echo "------------------------------------------------------------"
echo "  Installing the AI-OS Lite agent plugin(s): $AGENT"
echo "  (start-day, process-morning, vault-commit, and related skills)"
echo "------------------------------------------------------------"
echo ""

if [ "$AGENT" = "claude" ] || [ "$AGENT" = "both" ]; then
  bash "$SCRIPT_DIR/setup-claude-plugins.sh" "$VAULT"
fi
if [ "$AGENT" = "codex" ] || [ "$AGENT" = "both" ]; then
  bash "$SCRIPT_DIR/setup-codex-plugins.sh" "$VAULT"
fi

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
