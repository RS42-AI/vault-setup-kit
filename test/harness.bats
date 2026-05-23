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

@test "setup-vault.sh --update copies new canonical files (AGENTS.md) non-clobber" {
  setup_test_vault
  echo "user-customization" > "$TEST_VAULT/CLAUDE.md"
  run bash "$KIT_ROOT/setup-vault.sh" --update "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [ "$(cat "$TEST_VAULT/CLAUDE.md")" = "user-customization" ]
  [ -f "$TEST_VAULT/AGENTS.md" ]
}

@test "vault-files/AGENTS.md ships the search-then-link Note Creation Procedure" {
  run grep -q "## Note Creation Procedure" "$KIT_ROOT/vault-files/AGENTS.md"
  [ "$status" -eq 0 ]
  run grep -q "Search the vault first" "$KIT_ROOT/vault-files/AGENTS.md"
  [ "$status" -eq 0 ]
}

@test "setup-vault.sh --update next-steps mention /update-structure" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --update "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/update-structure"* ]]
}

@test "setup-vault.sh --update errors if vault dir does not exist" {
  local missing="$BATS_TEST_TMPDIR/no-such-vault"
  run bash "$KIT_ROOT/setup-vault.sh" --update "$missing"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not exist"* ]]
}
