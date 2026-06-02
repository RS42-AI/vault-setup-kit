#!/usr/bin/env bash
# setup-mcp.sh — Register MCP servers and set Claude Code permissions
#
# Prerequisites:
#   - Claude Code CLI installed (npm install -g @anthropic-ai/claude-code)
#   - Obsidian running with Local REST API plugin enabled
#   - bun installed (for QMD)
#
# Usage: bash setup-mcp.sh [vault_path]
#   vault_path defaults to ~/Claude/ObsidianVault

set -euo pipefail

VAULT="${1:-$HOME/Claude/ObsidianVault}"

bun_install_cmd() {
  # Echo the correct bun install command for the given `uname -s` value.
  case "$1" in
    Darwin) echo "brew install oven-sh/bun/bun" ;;
    *)      echo "curl -fsSL https://bun.sh/install | bash" ;;  # Linux/WSL
  esac
}

ensure_bun() {
  if command -v bun &>/dev/null; then
    echo "  bun: $(bun --version)"
    return 0
  fi
  local os; os="$(uname -s)"
  local cmd; cmd="$(bun_install_cmd "$os")"
  echo "  bun not found — installing via: $cmd"
  if [ "$os" = "Darwin" ]; then
    if command -v brew &>/dev/null; then
      brew install oven-sh/bun/bun
    else
      echo "  WARNING: Homebrew missing; install bun manually"
      return 1
    fi
  else
    curl -fsSL https://bun.sh/install | bash || { echo "  WARNING: bun install failed"; return 1; }
    export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
    export PATH="$BUN_INSTALL/bin:$PATH"
  fi
  command -v bun &>/dev/null || [ -x "$HOME/.bun/bin/bun" ]
}

# Allow tests to source just the function definitions (skip the procedural body).
[ "${KIT_SOURCE_ONLY:-0}" = "1" ] && return 0 2>/dev/null || true

echo "=== Claude Code MCP Setup ==="
echo "Vault: $VAULT"
echo ""

# --- 1. Check prerequisites ---
echo "[1/4] Checking prerequisites..."

if ! command -v claude &>/dev/null; then
  echo "  ERROR: Claude Code CLI not found. Install with:"
  echo "    npm install -g @anthropic-ai/claude-code"
  exit 1
fi
echo "  Claude Code: $(claude --version 2>/dev/null || echo 'installed')"

if ensure_bun; then
  SKIP_QMD=false
else
  echo "  WARNING: bun unavailable — QMD installation will be skipped"
  SKIP_QMD=true
fi

# --- 2. Register obsidian-mcp-tools ---
echo ""
echo "[2/4] Registering obsidian-mcp-tools..."

MCP_SERVER_BIN="$VAULT/.obsidian/plugins/mcp-tools/bin/mcp-server"

if [ ! -f "$MCP_SERVER_BIN" ]; then
  echo "  WARNING: MCP Tools plugin not found at expected path."
  echo "  Make sure the 'MCP Tools' community plugin is installed in Obsidian."
  echo "  Expected: $MCP_SERVER_BIN"
  echo ""
  echo "  After installing in Obsidian, get the API key from:"
  echo "    Settings → Community Plugins → Local REST API → API Key"
  echo ""
  echo "  Then run manually:"
  echo "    claude mcp add obsidian-mcp-tools --scope user -- $MCP_SERVER_BIN"
  echo "    # Add OBSIDIAN_API_KEY to the env in ~/.claude.json"
else
  echo "  Found MCP Tools binary."
  echo ""
  echo "  IMPORTANT: You need the API key from Obsidian."
  echo "  Settings → Community Plugins → Local REST API → copy the API Key"
  echo ""
  # TODO (v2): auto-fetch the API key by reading
  # $VAULT/.obsidian/plugins/obsidian-local-rest-api/data.json (the
  # plugin stores its generated key there). For now, paste manually.
  read -r -p "  Paste the Local REST API key (or press Enter to skip): " API_KEY

  if [ -n "$API_KEY" ]; then
    claude mcp add obsidian-mcp-tools \
      --scope user \
      --transport stdio \
      -- "$MCP_SERVER_BIN"

    echo ""
    echo "  Registered obsidian-mcp-tools."
    echo "  NOTE: You must manually add the OBSIDIAN_API_KEY env var to ~/.claude.json:"
    echo "    \"env\": { \"OBSIDIAN_API_KEY\": \"$API_KEY\" }"
  else
    echo "  Skipped — run this script again when you have the key."
  fi
fi

# --- 3. Install and register QMD ---
echo ""
echo "[3/4] Setting up QMD..."

if [ "$SKIP_QMD" = true ]; then
  echo "  Skipped (bun not installed)"
else
  if ! command -v qmd &>/dev/null && [ ! -f "$HOME/.bun/bin/qmd" ]; then
    echo "  Installing QMD..."
    bun install -g github:tobi/qmd
  else
    echo "  QMD already installed"
  fi

  QMD_BIN="${HOME}/.bun/bin/qmd"
  if [ ! -f "$QMD_BIN" ]; then
    QMD_BIN="$(command -v qmd 2>/dev/null || true)"
  fi

  if [ -n "$QMD_BIN" ]; then
    claude mcp add qmd \
      --scope user \
      --transport stdio \
      -- "$QMD_BIN" mcp

    echo "  Registered QMD MCP server."

    echo "  Adding vault collection..."
    "$QMD_BIN" collection add "$VAULT" --name vault 2>/dev/null || echo "  Collection 'vault' may already exist"

    echo ""
    echo "  To build the search index (downloads ~2.2GB models on first run):"
    echo "    $QMD_BIN embed"
    echo ""
    echo "  To add a context description:"
    echo "    $QMD_BIN context add qmd://vault \"Personal notes and project documentation\""
  fi
fi

# --- 4. Set permissions ---
echo ""
echo "[4/4] Permissions..."

cat << 'PERMS'

  Add these to the "allow" array in ~/.claude/settings.json:

  "allow": [
    "mcp__obsidian-mcp-tools__search_vault_smart",
    "mcp__obsidian-mcp-tools__search_vault_simple",
    "mcp__obsidian-mcp-tools__get_vault_file",
    "mcp__obsidian-mcp-tools__list_vault_files",
    "mcp__obsidian-mcp-tools__get_active_file",
    "mcp__obsidian-mcp-tools__create_vault_file",
    "mcp__obsidian-mcp-tools__append_to_vault_file",
    "mcp__obsidian-mcp-tools__patch_vault_file",
    "mcp__obsidian-mcp-tools__search_vault",
    "mcp__qmd__search",
    "mcp__qmd__vector_search",
    "mcp__qmd__deep_search",
    "mcp__qmd__get",
    "mcp__qmd__multi_get",
    "mcp__qmd__status"
  ]

PERMS

echo ""
echo "=== MCP Setup Complete ==="
echo ""
echo "Test with: claude 'search my vault for test'"
