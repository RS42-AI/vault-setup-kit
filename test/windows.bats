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

# --- setup-mcp.sh: is_linux_elf rc==2 path (file utility absent) ---

@test "ensure_linux_mcp_binary rc==2 path: bare-Linux + existing file → no-op (Bug 1 regression)" {
  # Only meaningful when the host is Linux; on macOS ensure_linux_mcp_binary returns 0 immediately.
  if [ "$(uname -s)" != "Linux" ]; then skip "host is not Linux; rc==2 no-op only applicable on Linux"; fi
  KIT_SOURCE_ONLY=1 source "$KIT_ROOT/setup-mcp.sh"

  # Stub is_linux_elf to always return 2 (simulates absent `file` utility).
  is_linux_elf() { return 2; }
  # Stub is_wsl to return 1 (bare Linux, not WSL).
  is_wsl() { return 1; }

  local bin="${BATS_TEST_TMPDIR}/bin/mcp-server"
  mkdir -p "$(dirname "$bin")"
  touch "$bin"   # file exists — bare Linux + no `file` → should keep it and return 0

  run ensure_linux_mcp_binary "$bin"
  [ "$status" -eq 0 ]
  [ -f "$bin" ]
  [[ "$output" == *"assuming Linux binary"* ]]
}

# --- setup-mcp.sh: set -e safety of is_linux_elf rc capture (real function, no stub) ---

@test "is_linux_elf on a non-ELF file returns nonzero without aborting under set -e" {
  # Exercises the real is_linux_elf (no stub) on a plain text file.
  # Verifies the set-e-safe capture idiom: even under set -euo pipefail the
  # function's nonzero return must NOT abort the caller — rc is captured, not 0.
  # Runs on macOS too: `file` is present and a text file is definitively non-ELF;
  # if `file` were absent (rc==2), that is still -ne 0, so the assertion holds.
  setup_test_vault
  KIT_SOURCE_ONLY=1 source "$KIT_ROOT/setup-mcp.sh"
  echo "not an elf" > "$TEST_VAULT/fake"
  local rc=0
  is_linux_elf "$TEST_VAULT/fake" || rc=$?
  [ "$rc" -ne 0 ]
}

# --- setup-mcp.sh: get_api_key reads the env var non-interactively ---

@test "get_api_key returns the OBSIDIAN_API_KEY env var when set" {
  KIT_SOURCE_ONLY=1 source "$KIT_ROOT/setup-mcp.sh"
  # With the env var set, get_api_key must NOT prompt (no read → no hang) and
  # must echo the supplied key verbatim. Running this proves the Windows
  # bootstrap can pass the key non-interactively.
  OBSIDIAN_API_KEY=testkey123 run get_api_key
  [ "$status" -eq 0 ]
  [ "$output" = "testkey123" ]
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
