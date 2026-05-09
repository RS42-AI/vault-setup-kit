#!/usr/bin/env bash

# Project root used by all tests
KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export KIT_ROOT

# Throwaway test vault — recreated per test
setup_test_vault() {
  export TEST_VAULT="${BATS_TEST_TMPDIR}/vault"
  mkdir -p "$TEST_VAULT"
}

# Throwaway test workspace
setup_test_workspace() {
  export TEST_WORKSPACE="${BATS_TEST_TMPDIR}/workspace"
  mkdir -p "$TEST_WORKSPACE"
}
