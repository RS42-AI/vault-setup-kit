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
