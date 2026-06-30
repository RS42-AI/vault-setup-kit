#!/usr/bin/env bats

load test_helper

@test "team AGENTS.md ships and declares the rs42 area (not personal-only)" {
  run grep -qE '^\| `3\. Areas/RS42/` *\| *`rs42` *\|' "$KIT_ROOT/editions/team/AGENTS.md"
  [ "$status" -eq 0 ]
}

@test "team AGENTS.md does NOT route work items to Personal/Tasks" {
  run grep -q "Personal/Tasks" "$KIT_ROOT/editions/team/AGENTS.md"
  [ "$status" -ne 0 ]
}

@test "team AGENTS.md keeps the search-then-link Note Creation Procedure" {
  run grep -q "## Note Creation Procedure" "$KIT_ROOT/editions/team/AGENTS.md"
  [ "$status" -eq 0 ]
}

@test "team overlay ships an rs42 area dashboard" {
  run grep -q "type: area-dashboard" "$KIT_ROOT/editions/team/3. Areas/RS42/RS42.md"
  [ "$status" -eq 0 ]
  run grep -q "area: rs42" "$KIT_ROOT/editions/team/3. Areas/RS42/RS42.md"
  [ "$status" -eq 0 ]
}

@test "team overlay ships the RS42-Onboarding hub and tasks" {
  [ -f "$KIT_ROOT/editions/team/2. Projects/RS42/RS42-Onboarding/RS42-Onboarding.md" ]
  [ -f "$KIT_ROOT/editions/team/2. Projects/RS42/RS42-Onboarding/Tasks/Log your first work day.md" ]
}

@test "team overlay CLAUDE.md imports AGENTS.md" {
  run grep -q "@AGENTS.md" "$KIT_ROOT/editions/team/CLAUDE.md"
  [ "$status" -eq 0 ]
}

@test "team edition creates the rs42 area, not personal" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --edition=team "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [ -d "$TEST_VAULT/3. Areas/RS42" ]
  [ ! -d "$TEST_VAULT/3. Areas/Personal" ]
  [ ! -d "$TEST_VAULT/Personal" ]
}

@test "team edition omits the personal Journal machinery" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --edition=team "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [ ! -d "$TEST_VAULT/5. Resources/Personal" ]
}

@test "team edition lands the team AGENTS.md (rs42 area row)" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --edition=team "$TEST_VAULT"
  [ "$status" -eq 0 ]
  run grep -qE '`rs42`' "$TEST_VAULT/AGENTS.md"
  [ "$status" -eq 0 ]
  run grep -q "Personal/Tasks" "$TEST_VAULT/AGENTS.md"
  [ "$status" -ne 0 ]
}

@test "team edition ships shared templates and CLAUDE.md" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --edition=team "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [ -f "$TEST_VAULT/CLAUDE.md" ]
  [ -f "$TEST_VAULT/system-settings/Templates/Project Hub Template.md" ]
  [ -d "$TEST_VAULT/2. Projects/RS42/RS42-Onboarding" ]
}

@test "team edition does NOT ship the personal Vault-Setup curriculum" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --edition=team "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [ ! -e "$TEST_VAULT/Personal/Vault-Setup" ]
}

@test "default edition is unchanged — still personal (regression guard)" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" "$TEST_VAULT"
  [ "$status" -eq 0 ]
  [ -d "$TEST_VAULT/Personal" ]
  [ -d "$TEST_VAULT/3. Areas/Personal/Goals" ]
  [ -d "$TEST_VAULT/5. Resources/Personal/Journal" ]
}

@test "unknown edition errors" {
  setup_test_vault
  run bash "$KIT_ROOT/setup-vault.sh" --edition=bogus "$TEST_VAULT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"edition"* ]]
}
