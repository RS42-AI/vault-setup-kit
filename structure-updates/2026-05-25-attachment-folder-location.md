---
id: 2026-05-25-attachment-folder-location
date: 2026-05-25
description: Set Obsidian's default attachment folder to system-settings/Pasted Images so pasted images and screenshots stop landing in the vault root.
related_note: "[[2026-05-22-day-one-usable-onboarding-design]]"
also_see: "[[Vault-Setup Kit Update Cycle - Prose-Driven Structure Updates for Continuous Vault Shape Evolution]]"
---

## Context

The kit never shipped an `.obsidian/app.json`, so a freshly-installed vault inherited Obsidian's **default** attachment location — the vault root. Pasted images and screenshots dumped into the top level and had to be moved by hand. The canonical vault sets `attachmentFolderPath` to `system-settings/Pasted Images`; this update restores that setting on already-installed vaults. Fresh installs now get it directly from `setup-plugins.sh`.

`app.json` is a single JSON object holding many unrelated Obsidian preferences, so this update **merges one key** — it must not overwrite the whole file.

## Detection

This structure update **applies** if:

1. The vault has an `.obsidian/` folder (it's a real Obsidian vault), AND
2. `.obsidian/app.json` is missing, OR exists but its `attachmentFolderPath` is absent / not equal to `system-settings/Pasted Images`.

Check with: `python3 -c "import json,sys; d=json.load(open('.obsidian/app.json')); print(d.get('attachmentFolderPath'))"` (or `jq -r '.attachmentFolderPath' .obsidian/app.json`).

- If `.obsidian/app.json` already has `"attachmentFolderPath": "system-settings/Pasted Images"` → record as **vacuously applied** and skip.
- If the user has *deliberately* set a different attachment folder (a non-default value that isn't the vault root), show them the intended value and **ask before changing** — don't clobber an intentional choice.

## Changes

### File: `.obsidian/app.json` (merge one key, preserve everything else)

Set `attachmentFolderPath` to `system-settings/Pasted Images`, leaving all other keys untouched.

- **If the file does not exist**, create it with:

  ```json
  {
    "attachmentFolderPath": "system-settings/Pasted Images"
  }
  ```

- **If the file exists**, merge the single key without disturbing other settings. Prefer a JSON-aware merge:

  ```
  jq '.attachmentFolderPath = "system-settings/Pasted Images"' .obsidian/app.json > .obsidian/app.json.tmp \
    && mv .obsidian/app.json.tmp .obsidian/app.json
  ```

  or, if `jq` is unavailable:

  ```
  python3 - <<'PY'
  import json
  p = ".obsidian/app.json"
  d = json.load(open(p))
  d["attachmentFolderPath"] = "system-settings/Pasted Images"
  json.dump(d, open(p, "w"), indent=2)
  PY
  ```

**Do not hand-edit the raw JSON with a text replace** unless both tools are unavailable — a malformed `app.json` makes Obsidian silently reset preferences.

After the setting is in place, the `system-settings/Pasted Images/` folder is created by Obsidian on the next paste; you don't need to create it manually.

## Verification

After applying, all must be true:

- `.obsidian/app.json` is valid JSON (parses without error).
- Its `attachmentFolderPath` equals `system-settings/Pasted Images`.
- No other keys in `app.json` were removed or changed (`git diff .obsidian/app.json` shows only the one key added/changed, if the vault is a git repo).

If any check fails, do NOT record the update as applied. Report which check failed and stop.

## Rollback

```
git checkout .obsidian/app.json
```

If the vault is not a git repo, remove the `attachmentFolderPath` key from `.obsidian/app.json` (or restore it to its prior value), keeping the rest of the file intact.
