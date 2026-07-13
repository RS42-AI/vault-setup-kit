#!/usr/bin/env bats

load test_helper

MORNING_TEMPLATE="vault-files/system-settings/Templates/Journal Entry Template.md"
EVENING_TEMPLATE="vault-files/system-settings/Templates/Evening Journal Template.md"
DAILY_TEMPLATE="vault-files/system-settings/Templates/Daily Note Hub Template.md"

@test "Morning Brief template uses the new command and system completion field" {
  run grep -qF "habit_morning_brief: false" "$KIT_ROOT/$MORNING_TEMPLATE"
  [ "$status" -eq 0 ]
  run grep -qF "/process-morning" "$KIT_ROOT/$MORNING_TEMPLATE"
  [ "$status" -eq 0 ]
  run grep -qF "/process-journal" "$KIT_ROOT/$MORNING_TEMPLATE"
  [ "$status" -ne 0 ]
}

@test "Evening Entry is optional, free-form, and frontmatter tracked" {
  local file="$KIT_ROOT/$EVENING_TEMPLATE"
  run grep -qF "habit_evening_reflection: false" "$file"
  [ "$status" -eq 0 ]
  run grep -qF "## Evening" "$file"
  [ "$status" -eq 0 ]
  run grep -qF "### AI Summary" "$file"
  [ "$status" -eq 0 ]

  local forbidden
  for forbidden in "## Evening Habits" "## Context" "## Reflection" "What went well today" "What could I improve" "Grateful for:"; do
    run grep -qF "$forbidden" "$file"
    [ "$status" -ne 0 ]
  done
}

@test "Daily hub presents Morning Brief and neutral Evening labels" {
  local file="$KIT_ROOT/$DAILY_TEMPLATE"
  run grep -qF "## Morning Brief" "$file"
  [ "$status" -eq 0 ]
  run grep -qF "Open Morning Brief" "$file"
  [ "$status" -eq 0 ]
  run grep -qF "## Evening Reflection" "$file"
  [ "$status" -ne 0 ]
}

@test "a fresh generalized vault ships the revised templates" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" "$TEST_VAULT"
  [ "$status" -eq 0 ]
  run grep -qF "## Morning Brief" "$TEST_VAULT/system-settings/Templates/Daily Note Hub Template.md"
  [ "$status" -eq 0 ]
  run grep -qF "habit_evening_reflection: false" "$TEST_VAULT/system-settings/Templates/Evening Journal Template.md"
  [ "$status" -eq 0 ]
}
