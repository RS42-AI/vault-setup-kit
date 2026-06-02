#!/usr/bin/env bash
# setup.sh — One-command bootstrap for a fresh Obsidian + Claude Code vault
#
# Runs the setup steps in order:
#   1. setup-vault.sh          — create folder structure and copy starter content
#   2. setup-plugins.sh        — install Obsidian community plugins
#   3. setup-mcp.sh            — register MCP servers with Claude Code
#   4. setup-claude-plugins.sh — install the Personal OS Claude Code plugin
#
# Usage: bash setup.sh [vault_path]
#   vault_path defaults to ~/Claude/ObsidianVault

set -euo pipefail

VAULT="${1:-$HOME/Claude/ObsidianVault}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "============================================================"
echo "  Vault Setup Kit"
echo "  Target: $VAULT"
echo "============================================================"
echo ""

bash "$SCRIPT_DIR/setup-vault.sh" "$VAULT"
echo ""

echo "------------------------------------------------------------"
echo "  Plugins step requires Obsidian to be CLOSED."
echo "  Press Enter when ready (or Ctrl+C to skip)."
read -r
echo "------------------------------------------------------------"
echo ""

bash "$SCRIPT_DIR/setup-plugins.sh" "$VAULT"
echo ""

echo "------------------------------------------------------------"
echo "  Now OPEN Obsidian, point it at $VAULT,"
echo "  and enable: Local REST API, Templater, Dataview, MCP Tools"
echo "  Then come back and press Enter to continue MCP setup."
read -r
echo "------------------------------------------------------------"
echo ""

bash "$SCRIPT_DIR/setup-mcp.sh" "$VAULT"
echo ""

echo "------------------------------------------------------------"
echo "  Installing the Personal OS Claude Code plugin"
echo "  (daily commands: /start-day, /process-journal, /vault-commit, ...)"
echo "------------------------------------------------------------"
echo ""

bash "$SCRIPT_DIR/setup-claude-plugins.sh" "$VAULT"

echo ""
echo "============================================================"
echo "  All done. Open $VAULT/Personal/Vault-Setup/Vault-Setup.md"
echo "  to start the curriculum."
echo "============================================================"
