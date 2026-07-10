#!/usr/bin/env bats

load test_helper

REQUIRED_HEADINGS=("## Context" "## Detection" "## Changes" "## Verification" "## Rollback")

@test "every structure-updates/*.md has id/date/description frontmatter and the five required section headings" {
  local failures=""
  local f base frontmatter id_line id_value date_line desc_line heading

  for f in "$KIT_ROOT"/structure-updates/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f" .md)"
    frontmatter="$(sed -n '2,/^---$/p' "$f")"

    id_line="$(echo "$frontmatter" | grep -m1 '^id:' || true)"
    if [ -z "$id_line" ]; then
      failures="${failures}
${base}: missing 'id:' in frontmatter"
    else
      id_value="$(echo "$id_line" | sed -E 's/^id:[[:space:]]*//')"
      if [ "$id_value" != "$base" ]; then
        failures="${failures}
${base}: id '${id_value}' does not match filename"
      fi
    fi

    date_line="$(echo "$frontmatter" | grep -m1 '^date:' || true)"
    [ -z "$date_line" ] && failures="${failures}
${base}: missing 'date:' in frontmatter"

    desc_line="$(echo "$frontmatter" | grep -m1 '^description:' || true)"
    [ -z "$desc_line" ] && failures="${failures}
${base}: missing 'description:' in frontmatter"

    for heading in "${REQUIRED_HEADINGS[@]}"; do
      grep -qF "$heading" "$f" || failures="${failures}
${base}: missing '${heading}' section heading"
    done
  done

  if [ -n "$failures" ]; then
    echo "$failures"
    return 1
  fi
}
