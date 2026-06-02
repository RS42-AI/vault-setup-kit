#!/usr/bin/env bats

load test_helper

# --- setup-mcp.sh: OS-aware bun install ---

@test "setup-mcp.sh exposes bun_install_cmd that branches on uname" {
  KIT_SOURCE_ONLY=1 source "$KIT_ROOT/setup-mcp.sh"
  run bun_install_cmd "Darwin"
  [ "$status" -eq 0 ]
  [[ "$output" == *"brew install"*"bun"* ]]
  run bun_install_cmd "Linux"
  [ "$status" -eq 0 ]
  [[ "$output" == *"bun.sh/install"* ]]
}

# --- setup-plugins.sh: win32 terminal profile ---

@test "write_terminal_config emits a win32 wsl.exe profile and valid JSON" {
  setup_test_vault
  local dir="$TEST_VAULT/.obsidian/plugins/terminal"
  mkdir -p "$dir"
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
