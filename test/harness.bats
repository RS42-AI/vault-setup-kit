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
