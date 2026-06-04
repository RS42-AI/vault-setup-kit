#!/usr/bin/env bash
# setup-mcp.sh — Register MCP servers and set Claude Code permissions
#
# Prerequisites:
#   - Claude Code CLI installed (npm install -g @anthropic-ai/claude-code)
#   - Obsidian running with Local REST API plugin enabled
#   - bun (auto-installed: Homebrew on macOS, bun.sh/install on Linux/WSL)
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

# --- R1: WSL2 cross-OS mcp-server binary mismatch ---------------------------
# The "MCP Tools" Obsidian plugin (jacksteamdev/obsidian-mcp-tools) downloads a
# mcp-server binary matching the OS that *Obsidian* runs on (it uses
# os.platform(): win32 -> mcp-server-windows.exe, darwin -> mcp-server-macos-<arch>,
# else -> mcp-server-linux). On a Windows + WSL2 setup, Obsidian is the *Windows*
# app, so it drops a Windows .exe at .obsidian/plugins/mcp-tools/bin/mcp-server —
# but Claude Code runs *inside WSL (Linux)* and needs a *Linux* ELF binary there.
# Registering the .exe via `claude mcp add` would yield an unrunnable server.
#
# Resolution (approach a): the upstream release ships a standalone Linux asset
# `mcp-server-linux` (verified on release 0.2.33; same naming on /latest), so on
# Linux/WSL we (re)download that asset over the plugin path and chmod +x it. This
# is preferred over registering the Windows .exe via WSL interop because it avoids
# coupling to Windows path layout / interop quirks and gives CC a native binary.
# Idempotent: skip when an ELF binary is already in place. NON-FATAL: a failed
# download only WARNs with the manual command, never aborts the setup.
#   Asset:  mcp-server-linux
#   URL:    https://github.com/jacksteamdev/obsidian-mcp-tools/releases/latest/download/mcp-server-linux
# macOS runs are unaffected — this whole path is gated behind Linux/WSL detection.
readonly MCP_LINUX_ASSET_URL="https://github.com/jacksteamdev/obsidian-mcp-tools/releases/latest/download/mcp-server-linux"

is_wsl() {
  # WSL kernels report "microsoft" in /proc/version.
  grep -qi microsoft /proc/version 2>/dev/null
}

is_linux() {
  [ "$(uname -s)" = "Linux" ]
}

# True when the file at $1 is a Linux ELF binary (best-effort: needs `file`).
is_linux_elf() {
  local f="$1"
  [ -f "$f" ] || return 1
  command -v file &>/dev/null || return 2   # can't tell — caller decides
  file -b "$f" 2>/dev/null | grep -qi 'ELF'
}

# On Linux/WSL, ensure $MCP_SERVER_BIN is a runnable Linux binary. If it's missing
# or is the wrong-arch (Windows) binary the plugin dropped, fetch mcp-server-linux.
# NON-FATAL by contract: any failure prints a WARNING + manual command, returns 0.
ensure_linux_mcp_binary() {
  local bin="$1"
  is_linux || return 0          # never touch macOS
  local on_wsl="no"; is_wsl && on_wsl="yes"

  # Decide whether we already have a good Linux binary.
  # Bug 1 fix: set-e-safe rc capture — declare before calling so set -e can't fire
  # between the call and the assignment; || rc=$? means nonzero return is handled
  # by the list operator, not set -e.
  local elf_rc=0
  is_linux_elf "$bin" || elf_rc=$?
  if [ "$elf_rc" -eq 0 ]; then
    echo "  mcp-server is already a Linux ELF binary — leaving it in place."
    return 0
  fi
  if [ "$elf_rc" -eq 2 ]; then
    # `file` unavailable. On WSL the plugin path almost certainly holds a
    # Windows .exe (Obsidian is the Windows app), so re-fetch to be safe.
    # On bare Linux a present binary is likely already correct — keep it.
    if [ -f "$bin" ] && [ "$on_wsl" = "no" ]; then
      echo "  mcp-server present and 'file' unavailable on bare Linux — assuming Linux binary."
      return 0
    fi
    # else: WSL + unverifiable → fall through to (re)download
  fi
  # elf_rc == 1 (exists but not a Linux ELF) or fell through from WSL+unverifiable → (re)download

  echo "  Linux/WSL detected (wsl=$on_wsl) — provisioning Linux mcp-server binary."
  # Bug 2 fix: non-fatal mkdir — warn + print manual command + return 0 on failure.
  if ! mkdir -p "$(dirname "$bin")" 2>/dev/null; then
    echo "  WARNING: cannot create $(dirname "$bin") — skipping Linux mcp-server provisioning."
    echo "  Manual fix: mkdir -p \"$(dirname "$bin")\" && curl -fsSL $MCP_LINUX_ASSET_URL -o \"$bin\" && chmod +x \"$bin\""
    return 0
  fi
  if curl -fsSL "$MCP_LINUX_ASSET_URL" -o "$bin.tmp" 2>/dev/null; then
    local tmp_elf_rc=0
    is_linux_elf "$bin.tmp" || tmp_elf_rc=$?
    if [ "$tmp_elf_rc" -eq 0 ] || [ "$tmp_elf_rc" -eq 2 ]; then
      # rc==2 means `file` is absent — curl -f already rejected HTTP errors,
      # so we trust the download when we can't ELF-validate it.
      if ! mv "$bin.tmp" "$bin" 2>/dev/null; then
        rm -f "$bin.tmp" 2>/dev/null || true
        echo "  WARNING: could not move downloaded binary into place."
        echo "  Manual fix: curl -fsSL $MCP_LINUX_ASSET_URL -o \"$bin\" && chmod +x \"$bin\""
        return 0
      fi
      chmod +x "$bin" 2>/dev/null || true
      echo "  Installed Linux mcp-server: $bin"
      return 0
    fi
    rm -f "$bin.tmp" 2>/dev/null || true
    echo "  WARNING: downloaded asset is not a Linux ELF binary — leaving existing binary untouched."
  else
    rm -f "$bin.tmp" 2>/dev/null || true
    echo "  WARNING: could not download the Linux mcp-server binary."
  fi
  echo "  Resolve manually with:"
  echo "    curl -fsSL $MCP_LINUX_ASSET_URL -o \"$bin\" && chmod +x \"$bin\""
  return 0
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
      local brew_prefix; brew_prefix="$(brew --prefix)"
      export PATH="$brew_prefix/bin:$PATH"
    else
      echo "  WARNING: Homebrew missing; install bun manually"
      return 1
    fi
  else
    curl -fsSL https://bun.sh/install | bash || { echo "  WARNING: bun install failed"; return 1; }
    export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
    export PATH="$BUN_INSTALL/bin:$PATH"
  fi
  # $HOME/.bun/bin/bun is the default install location for the Linux/WSL bun.sh installer
  command -v bun &>/dev/null || [ -x "$HOME/.bun/bin/bun" ]
}

get_api_key() {
  # Prefer a pre-supplied env var (lets the Windows PowerShell bootstrap pass it
  # non-interactively); fall back to an interactive prompt on macOS / direct runs.
  if [ -n "${OBSIDIAN_API_KEY:-}" ]; then
    echo "$OBSIDIAN_API_KEY"
  else
    local k
    read -r -p "  Paste the Local REST API key (or press Enter to skip): " k
    echo "$k"
  fi
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

# R1: under WSL/Linux the plugin may have dropped a Windows .exe here — make sure
# we have a runnable Linux binary before registering it (no-op on macOS).
ensure_linux_mcp_binary "$MCP_SERVER_BIN"

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
  API_KEY="$(get_api_key)"

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
