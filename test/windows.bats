#!/usr/bin/env bats

load test_helper

# --- setup-mcp.sh: OS-aware bun install ---

@test "setup-mcp.sh exposes bun_install_cmd that branches on uname" {
  KIT_SOURCE_ONLY=1 source "$KIT_ROOT/setup-mcp.sh"
  run bun_install_cmd "Darwin"
  [ "$status" -eq 0 ]
  [[ "$output" == *"brew install"*"bun"* ]]
  [[ "$output" != *"bun.sh"* ]]
  run bun_install_cmd "Linux"
  [ "$status" -eq 0 ]
  [[ "$output" == *"bun.sh/install"* ]]
}

# --- setup-mcp.sh: R1 Linux mcp-server provisioning is gated off macOS ---

@test "setup-mcp.sh exposes ensure_linux_mcp_binary and Linux/WSL helpers" {
  KIT_SOURCE_ONLY=1 source "$KIT_ROOT/setup-mcp.sh"
  run type -t ensure_linux_mcp_binary
  [ "$output" = "function" ]
  run type -t is_wsl
  [ "$output" = "function" ]
  run type -t is_linux
  [ "$output" = "function" ]
}

@test "ensure_linux_mcp_binary is a no-op on non-Linux (macOS) and returns 0" {
  # Only meaningful when the host is not Linux; on Linux CI this binary path
  # would actually be provisioned, so guard the assertion to non-Linux hosts.
  if [ "$(uname -s)" = "Linux" ]; then skip "host is Linux; gating no-op not applicable"; fi
  KIT_SOURCE_ONLY=1 source "$KIT_ROOT/setup-mcp.sh"
  local bin="${BATS_TEST_TMPDIR}/bin/mcp-server"
  run ensure_linux_mcp_binary "$bin"
  [ "$status" -eq 0 ]
  [ ! -e "$bin" ]
  [ ! -d "${BATS_TEST_TMPDIR}/bin" ]
}

# --- setup-plugins.sh: win32 terminal profile ---

@test "write_terminal_config emits a win32 wsl.exe profile and valid JSON" {
  setup_test_vault
  local dir="$TEST_VAULT/.obsidian/plugins/terminal"
  KIT_SOURCE_ONLY=1 source "$KIT_ROOT/setup-plugins.sh"
  write_terminal_config "$dir"
  [ -f "$dir/data.json" ]
  run grep -q "darwinIntegratedDefault" "$dir/data.json"
  [ "$status" -eq 0 ]
  run grep -q "wsl.exe" "$dir/data.json"
  [ "$status" -eq 0 ]
  run grep -q "win32" "$dir/data.json"
  [ "$status" -eq 0 ]
  run python3 -m json.tool "$dir/data.json"
  [ "$status" -eq 0 ]
}
