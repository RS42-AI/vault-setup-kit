#!/usr/bin/env bats

load test_helper

make_codex_stub() {
  local bin_dir="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$bin_dir"
  cat > "$bin_dir/codex" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$CODEX_LOG"
if [ "${CODEX_FAIL_ON:-}" = "marketplace" ] && [[ "$*" == "plugin marketplace add "* ]]; then
  exit 1
fi
if [ "${CODEX_FAIL_ON:-}" = "plugin" ] && [[ "$*" == "plugin add "* ]]; then
  exit 1
fi
STUB
  chmod +x "$bin_dir/codex"
  export CODEX_TEST_PATH="$bin_dir:/usr/bin:/bin"
}

make_setup_fixture() {
  export SETUP_FIXTURE="$BATS_TEST_TMPDIR/kit"
  mkdir -p "$SETUP_FIXTURE"
  cp "$KIT_ROOT/setup.sh" "$SETUP_FIXTURE/setup.sh"

  local script
  for script in setup-vault setup-plugins setup-mcp setup-claude-plugins setup-codex-plugins; do
    {
      echo '#!/usr/bin/env bash'
      echo "printf '%s\\n' '$script' >> \"\$SETUP_LOG\""
    } > "$SETUP_FIXTURE/$script.sh"
    chmod +x "$SETUP_FIXTURE/$script.sh"
  done
}

@test "setup-codex-plugins is non-fatal when Codex is unavailable" {
  setup_test_vault
  mkdir -p "$BATS_TEST_TMPDIR/empty-path"
  run env PATH="$BATS_TEST_TMPDIR/empty-path" /bin/bash "$KIT_ROOT/setup-codex-plugins.sh" "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"SKIP: 'codex' CLI not found"* ]]
}

@test "setup-codex-plugins registers the public marketplace and installs AI-OS Lite" {
  setup_test_vault
  make_codex_stub
  export CODEX_LOG="$BATS_TEST_TMPDIR/codex.log"

  run env PATH="$CODEX_TEST_PATH" CODEX_LOG="$CODEX_LOG" /bin/bash "$KIT_ROOT/setup-codex-plugins.sh" "$TEST_VAULT"
  [ "$status" -eq 0 ]
  grep -Fxq "plugin marketplace add RS42-AI/ai-os-lite" "$CODEX_LOG"
  grep -Fxq "plugin add ai-os-lite@ai-os-lite-marketplace" "$CODEX_LOG"
  [[ "$output" == *"AI-OS Lite Installed for Codex"* ]]
  [[ "$output" == *"$TEST_VAULT"* ]]
}

@test "setup-codex-plugins keeps marketplace failures non-fatal" {
  setup_test_vault
  make_codex_stub
  export CODEX_LOG="$BATS_TEST_TMPDIR/codex.log"

  run env PATH="$CODEX_TEST_PATH" CODEX_LOG="$CODEX_LOG" CODEX_FAIL_ON=marketplace /bin/bash "$KIT_ROOT/setup-codex-plugins.sh" "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"WARNING: could not add"* ]]
  ! grep -Fq "plugin add ai-os-lite@ai-os-lite-marketplace" "$CODEX_LOG"
}

@test "setup-codex-plugins accepts a marketplace override for isolated release tests" {
  setup_test_vault
  make_codex_stub
  export CODEX_LOG="$BATS_TEST_TMPDIR/codex.log"

  run env PATH="$CODEX_TEST_PATH" CODEX_LOG="$CODEX_LOG" AI_OS_LITE_MARKETPLACE=/tmp/ai-os-lite /bin/bash "$KIT_ROOT/setup-codex-plugins.sh" "$TEST_VAULT"
  [ "$status" -eq 0 ]
  grep -Fxq "plugin marketplace add /tmp/ai-os-lite" "$CODEX_LOG"
}

@test "setup.sh defaults to the existing Claude path" {
  setup_test_vault
  make_setup_fixture
  local log="$BATS_TEST_TMPDIR/setup.log"

  run env SETUP_YES=1 SETUP_LOG="$log" bash "$SETUP_FIXTURE/setup.sh" "$TEST_VAULT"
  [ "$status" -eq 0 ]
  grep -Fxq "setup-mcp" "$log"
  grep -Fxq "setup-claude-plugins" "$log"
  ! grep -Fxq "setup-codex-plugins" "$log"
}

@test "setup.sh --agent=codex selects only the Codex agent integration" {
  setup_test_vault
  make_setup_fixture
  local log="$BATS_TEST_TMPDIR/setup.log"

  run env SETUP_YES=1 SETUP_LOG="$log" bash "$SETUP_FIXTURE/setup.sh" --agent=codex "$TEST_VAULT"
  [ "$status" -eq 0 ]
  grep -Fxq "setup-codex-plugins" "$log"
  ! grep -Fxq "setup-mcp" "$log"
  ! grep -Fxq "setup-claude-plugins" "$log"
}

@test "setup.sh --agent=both installs both agent integrations" {
  setup_test_vault
  make_setup_fixture
  local log="$BATS_TEST_TMPDIR/setup.log"

  run env SETUP_YES=1 SETUP_LOG="$log" bash "$SETUP_FIXTURE/setup.sh" --agent both "$TEST_VAULT"
  [ "$status" -eq 0 ]
  grep -Fxq "setup-mcp" "$log"
  grep -Fxq "setup-claude-plugins" "$log"
  grep -Fxq "setup-codex-plugins" "$log"
}

@test "setup.sh rejects an unknown agent" {
  setup_test_vault
  make_setup_fixture

  run env SETUP_YES=1 SETUP_LOG="$BATS_TEST_TMPDIR/setup.log" bash "$SETUP_FIXTURE/setup.sh" --agent=other "$TEST_VAULT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"expected: claude | codex | both"* ]]
}
