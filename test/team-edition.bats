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
