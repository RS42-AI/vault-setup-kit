#!/usr/bin/env bats

load test_helper

@test "test harness loads" {
  [ -n "$KIT_ROOT" ]
  [ -d "$KIT_ROOT" ]
}

@test "setup_test_vault creates clean dir" {
  setup_test_vault
  [ -d "$TEST_VAULT" ]
}

@test "setup-vault.sh --update prints update-mode header" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --update "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Update Mode"* ]]
}

@test "setup-vault.sh --update writes .vault-kit-path with absolute kit path" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --update "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [ -f "$TEST_VAULT/.vault-kit-path" ]
  local recorded
  recorded="$(cat "$TEST_VAULT/.vault-kit-path")"
  [ "$recorded" = "$KIT_ROOT" ]
}

@test "setup-vault.sh --update copies commands/update-structure.md to <vault>/.claude/commands/" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --update "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [ -f "$TEST_VAULT/.claude/commands/update-structure.md" ]
}
