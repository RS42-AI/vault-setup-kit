#!/usr/bin/env bats

load test_helper

@test "starter vault follows the current taxonomy and canonical hub contracts" {
  run grep -R -n "^status: develop$" "$KIT_ROOT/vault-files"
  [ "$status" -ne 0 ]

  local area="$KIT_ROOT/vault-files/3. Areas/Personal/Personal.md"
  local project="$KIT_ROOT/vault-files/Personal/Vault-Setup/Vault-Setup.md"
  local heading current previous

  previous=0
  for heading in "## Ideas" "## Goals" "## Projects" "## Active Tasks" "## Notes" "## Resources" "## Dev Logs" "## Reflections" "## Related Areas"; do
    current="$(grep -nF "$heading" "$area" | head -n 1 | cut -d: -f1)"
    [ -n "$current" ]
    [ "$current" -gt "$previous" ]
    previous="$current"
  done

  previous=0
  for heading in "## Overview" "## Current Status" "## Active Tasks" "## On Hold" "## Completed Tasks" "## Resources" "## Knowledge Notes" "## Dev Log" "## Meetings" "## Related Projects"; do
    current="$(grep -nF "$heading" "$project" | head -n 1 | cut -d: -f1)"
    [ -n "$current" ]
    [ "$current" -gt "$previous" ]
    previous="$current"
  done

  [ -f "$KIT_ROOT/vault-files/Personal/Vault-Setup/Tasks/Set up my AGENTS.md" ]
  [ ! -e "$KIT_ROOT/vault-files/Personal/Vault-Setup/Tasks/Set up my AGENTS.md.md" ]

  run grep -R -nF "[[Agentic Department Architecture Patterns]]" "$KIT_ROOT/vault-files"
  [ "$status" -ne 0 ]
}
