#!/usr/bin/env bash
# setup-plugins.sh — Install and configure Obsidian community plugins
#
# What it does:
#   1. Downloads missing essential plugins from GitHub
#   2. Writes plugin configurations (data.json) for each
#   3. Updates community-plugins.json to enable them
#
# Prerequisites:
#   - Obsidian vault exists at the target path
#   - curl available (ships with macOS)
#
# Usage: bash setup-plugins.sh [vault_path]
#   vault_path defaults to ~/Claude/ObsidianVault
#
# IMPORTANT: After running, restart Obsidian for changes to take effect.

set -euo pipefail

VAULT="${1:-$HOME/Claude/ObsidianVault}"
PLUGINS_DIR="$VAULT/.obsidian/plugins"

echo "=== Obsidian Plugin Setup ==="
echo "Vault: $VAULT"
echo ""

mkdir -p "$PLUGINS_DIR"

# --- Helper: download plugin from GitHub ---
download_plugin() {
  local plugin_id="$1"
  local repo="$2"
  local plugin_dir="$PLUGINS_DIR/$plugin_id"

  if [ -f "$plugin_dir/main.js" ]; then
    echo "  SKIP (already installed): $plugin_id"
    return 0
  fi

  echo "  Downloading $plugin_id from $repo..."
  mkdir -p "$plugin_dir"

  local base_url="https://github.com/$repo/releases/latest/download"

  curl -sL "$base_url/main.js" -o "$plugin_dir/main.js"
  curl -sL "$base_url/manifest.json" -o "$plugin_dir/manifest.json"
  curl -sL "$base_url/styles.css" -o "$plugin_dir/styles.css" 2>/dev/null || true

  if [ -s "$plugin_dir/main.js" ]; then
    echo "  INSTALLED: $plugin_id"
  else
    echo "  ERROR: Failed to download $plugin_id — install manually via Obsidian"
    rm -rf "$plugin_dir"
    return 1
  fi
}

# --- 1. Install missing plugins ---
echo "[1/3] Installing plugins..."

# Essential plugins to download if missing (bash 3.2 compatible — no associative arrays)
download_plugin "terminal" "polyipseity/obsidian-terminal" || true
download_plugin "obsidian-linter" "platers/obsidian-linter" || true
download_plugin "templater-obsidian" "SilentVoid13/Templater" || true
download_plugin "dataview" "blacksmithgu/obsidian-dataview" || true
download_plugin "obsidian-git" "Vinzent03/obsidian-git" || true
download_plugin "obsidian-local-rest-api" "coddingtonbear/obsidian-local-rest-api" || true
download_plugin "mcp-tools" "jacksteamdev/obsidian-mcp-tools" || true
download_plugin "editing-toolbar" "PKM-er/obsidian-editing-toolbar" || true
download_plugin "obsidian-excalidraw-plugin" "zsviczian/obsidian-excalidraw-plugin" || true
download_plugin "smart-connections" "brianpetro/obsidian-smart-connections" || true

echo ""

# --- 2. Write plugin configurations ---
echo "[2/3] Writing plugin configurations..."

# --- Terminal ---
echo "  Configuring: Terminal"
cat > "$PLUGINS_DIR/terminal/data.json" << 'EOF'
{
  "addToCommand": true,
  "addToContextMenu": true,
  "createInstanceNearExistingOnes": true,
  "errorNoticeTimeout": 0,
  "exposeInternalModules": true,
  "focusOnNewInstance": true,
  "hideStatusBar": "focused",
  "interceptLogging": true,
  "language": "",
  "macOSOptionKeyPassthrough": true,
  "newInstanceBehavior": "newHorizontalSplit",
  "noticeTimeout": 5,
  "openChangelogOnUpdate": true,
  "pinNewInstance": true,
  "preferredRenderer": "webgl",
  "profiles": {
    "darwinExternalDefault": {
      "args": ["\"$PWD\""],
      "executable": "/System/Applications/Utilities/Terminal.app/Contents/macOS/Terminal",
      "followTheme": true,
      "name": "",
      "platforms": { "darwin": true },
      "restoreHistory": false,
      "rightClickAction": "copyPaste",
      "successExitCodes": ["0", "SIGINT", "SIGTERM"],
      "terminalOptions": { "documentOverride": null },
      "type": "external"
    },
    "darwinIntegratedDefault": {
      "args": ["--login"],
      "executable": "/bin/zsh",
      "followTheme": true,
      "name": "",
      "platforms": { "darwin": true },
      "pythonExecutable": "python3",
      "restoreHistory": false,
      "rightClickAction": "copyPaste",
      "successExitCodes": ["0", "SIGINT", "SIGTERM"],
      "terminalOptions": { "documentOverride": null },
      "type": "integrated",
      "useWin32Conhost": true
    },
    "developerConsole": {
      "followTheme": true,
      "name": "",
      "restoreHistory": false,
      "rightClickAction": "copyPaste",
      "successExitCodes": ["0", "SIGINT", "SIGTERM"],
      "terminalOptions": { "documentOverride": null },
      "type": "developerConsole"
    }
  },
  "defaultProfile": "darwinIntegratedDefault",
  "terminalOptions": { "documentOverride": null }
}
EOF

# --- Linter ---
echo "  Configuring: Linter"
cat > "$PLUGINS_DIR/obsidian-linter/data.json" << 'EOF'
{
  "ruleConfigs": {
    "add-blank-line-after-yaml": { "enabled": true },
    "dedupe-yaml-array-values": {
      "enabled": true,
      "dedupe-alias-key": true,
      "dedupe-tag-key": true,
      "dedupe-array-keys": true,
      "ignore-keys": ""
    },
    "escape-yaml-special-characters": { "enabled": false },
    "force-yaml-escape": { "enabled": false },
    "format-tags-in-yaml": { "enabled": true },
    "format-yaml-array": {
      "enabled": true,
      "alias-key": true,
      "tag-key": true,
      "default-array-style": "multi-line",
      "default-array-keys": true,
      "force-single-line-array-style": "",
      "force-multi-line-array-style": ""
    },
    "insert-yaml-attributes": {
      "enabled": true,
      "text-to-insert": "date: \nstatus: capture\ntype: note\ntags: "
    },
    "move-tags-to-yaml": { "enabled": false },
    "remove-yaml-keys": { "enabled": false },
    "sort-yaml-array-values": {
      "enabled": true,
      "sort-alias-key": true,
      "sort-tag-key": true,
      "sort-array-keys": true,
      "ignore-keys": "",
      "sort-order": "Ascending Alphabetical"
    },
    "yaml-key-sort": {
      "enabled": true,
      "yaml-key-priority-sort-order": "date\ndate created\ndate modified\nstatus\ntype\nproject\nsession_topic\ntags",
      "priority-keys-at-start-of-yaml": true,
      "yaml-sort-order-for-other-keys": "Ascending Alphabetical"
    },
    "yaml-timestamp": {
      "enabled": true,
      "date-created": true,
      "date-created-key": "date created",
      "date-created-source-of-truth": "file system",
      "date-modified": true,
      "date-modified-key": "date modified",
      "date-modified-source-of-truth": "file system",
      "format": "YYYY-MM-DD",
      "convert-to-utc": false,
      "update-on-file-contents-updated": "never"
    },
    "yaml-title": { "enabled": false },
    "yaml-title-alias": { "enabled": false },
    "capitalize-headings": { "enabled": false },
    "file-name-heading": { "enabled": false },
    "header-increment": { "enabled": false },
    "headings-start-line": { "enabled": false },
    "remove-trailing-punctuation-in-heading": { "enabled": false },
    "footnote-after-punctuation": { "enabled": false },
    "move-footnotes-to-the-bottom": { "enabled": false },
    "re-index-footnotes": { "enabled": false },
    "auto-correct-common-misspellings": { "enabled": false },
    "blockquote-style": { "enabled": false },
    "convert-bullet-list-markers": { "enabled": false },
    "default-language-for-code-fences": { "enabled": false },
    "emphasis-style": { "enabled": false },
    "no-bare-urls": { "enabled": false },
    "ordered-list-style": { "enabled": false },
    "proper-ellipsis": { "enabled": false },
    "quote-style": { "enabled": false },
    "remove-consecutive-list-markers": { "enabled": false },
    "remove-empty-list-markers": { "enabled": false },
    "remove-hyphenated-line-breaks": { "enabled": false },
    "remove-multiple-spaces": { "enabled": false },
    "strong-style": { "enabled": false },
    "two-spaces-between-lines-with-content": { "enabled": false },
    "unordered-list-style": { "enabled": false },
    "compact-yaml": { "enabled": false },
    "consecutive-blank-lines": { "enabled": false },
    "convert-spaces-to-tabs": { "enabled": false },
    "empty-line-around-blockquotes": { "enabled": false },
    "empty-line-around-code-fences": { "enabled": false },
    "empty-line-around-horizontal-rules": { "enabled": false },
    "empty-line-around-math-blocks": { "enabled": false },
    "empty-line-around-tables": { "enabled": false },
    "heading-blank-lines": { "enabled": false },
    "line-break-at-document-end": { "enabled": false },
    "move-math-block-indicators-to-their-own-line": { "enabled": false },
    "paragraph-blank-lines": { "enabled": false },
    "remove-empty-lines-between-list-markers-and-checklists": { "enabled": false },
    "remove-link-spacing": { "enabled": false },
    "remove-space-around-characters": { "enabled": false },
    "remove-space-before-or-after-characters": { "enabled": false },
    "space-after-list-markers": { "enabled": false },
    "space-between-chinese-japanese-or-korean-and-english-or-numbers": { "enabled": false },
    "trailing-spaces": { "enabled": false },
    "add-blockquote-indentation-on-paste": { "enabled": false },
    "prevent-double-checklist-indicator-on-paste": { "enabled": false },
    "prevent-double-list-item-indicator-on-paste": { "enabled": false },
    "proper-ellipsis-on-paste": { "enabled": false },
    "remove-hyphens-on-paste": { "enabled": false },
    "remove-leading-or-trailing-whitespace-on-paste": { "enabled": false },
    "remove-leftover-footnotes-from-quote-on-paste": { "enabled": false },
    "remove-multiple-blank-lines-on-paste": { "enabled": false }
  },
  "lintOnSave": true,
  "recordLintOnSaveLogs": false,
  "displayChanged": true,
  "suppressMessageWhenNoChange": false,
  "lintOnFileChange": false,
  "displayLintOnFileChangeNotice": false,
  "settingsConvertedToConfigKeyValues": true,
  "foldersToIgnore": [
    "Excalidraw",
    "system-settings/Pasted Images",
    "system-settings/Templates"
  ],
  "filesToIgnore": [],
  "linterLocale": "system-default",
  "logLevel": "ERROR",
  "lintCommands": [],
  "customRegexes": [],
  "commonStyles": {
    "aliasArrayStyle": "multi-line",
    "tagArrayStyle": "multi-line",
    "minimumNumberOfDollarSignsToBeAMathBlock": 2,
    "escapeCharacter": "\"",
    "removeUnnecessaryEscapeCharsForMultiLineArrays": false
  }
}
EOF

# --- Templater ---
echo "  Configuring: Templater"
cat > "$PLUGINS_DIR/templater-obsidian/data.json" << 'EOF'
{
  "command_timeout": 5,
  "templates_folder": "system-settings/Templates",
  "templates_pairs": [["", ""]],
  "trigger_on_file_creation": true,
  "auto_jump_to_cursor": false,
  "enable_system_commands": false,
  "shell_path": "",
  "user_scripts_folder": "",
  "enable_folder_templates": true,
  "folder_templates": [
    {
      "folder": "system-settings/Templates",
      "template": "system-settings/Templates/Full Note Template.md"
    },
    {
      "folder": "5. Resources/Personal/Journal/Morning Entries",
      "template": "system-settings/Templates/Journal Entry Template.md"
    },
    {
      "folder": "5. Resources/Personal/Journal/Evening Entries",
      "template": "system-settings/Templates/Evening Journal Template.md"
    },
    { "folder": "", "template": "" }
  ],
  "enable_file_templates": false,
  "file_templates": [{ "regex": ".*", "template": "" }],
  "syntax_highlighting": true,
  "syntax_highlighting_mobile": false,
  "enabled_templates_hotkeys": [],
  "startup_templates": [""],
  "intellisense_render": 1
}
EOF

# --- Git ---
echo "  Configuring: Git"
if [ ! -f "$PLUGINS_DIR/obsidian-git/data.json" ]; then
cat > "$PLUGINS_DIR/obsidian-git/data.json" << 'EOF'
{
  "commitMessage": "vault backup: {{date}}",
  "autoCommitMessage": "vault backup: {{date}}",
  "commitDateFormat": "YYYY-MM-DD HH:mm:ss",
  "autoSaveInterval": 0,
  "autoPushInterval": 0,
  "autoPullInterval": 0,
  "autoPullOnBoot": false,
  "disablePush": false,
  "pullBeforePush": true,
  "disablePopups": false,
  "showErrorNotices": true,
  "showStatusBar": true,
  "syncMethod": "merge",
  "refreshSourceControl": true,
  "showBranchStatusBar": true,
  "showFileMenu": true,
  "diffStyle": "split"
}
EOF
else
  echo "    SKIP (config exists): obsidian-git"
fi

echo ""

# --- 3. Update community-plugins.json ---
echo "[3/4] Updating community-plugins.json..."

cat > "$VAULT/.obsidian/community-plugins.json" << 'EOF'
[
  "dataview",
  "templater-obsidian",
  "obsidian-git",
  "obsidian-local-rest-api",
  "obsidian-excalidraw-plugin",
  "editing-toolbar",
  "mcp-tools",
  "smart-connections",
  "obsidian-linter",
  "terminal"
]
EOF

echo "  Enabled 10 plugins in community-plugins.json"

echo ""

# --- 4. Set default attachment folder ---
# Without this, Obsidian's default sends pasted images/screenshots to the vault
# root. Point them at system-settings/Pasted Images to match the canonical vault.
echo "[4/4] Setting attachment folder location..."

APP_JSON="$VAULT/.obsidian/app.json"
if [ ! -f "$APP_JSON" ]; then
  cat > "$APP_JSON" << 'EOF'
{
  "attachmentFolderPath": "system-settings/Pasted Images"
}
EOF
  echo "  Set attachments -> system-settings/Pasted Images"
else
  echo "  SKIP (app.json exists): not overwriting existing Obsidian settings."
  echo "  If pasted images land in the vault root, set Settings -> Files & Links"
  echo "  -> 'Default location for new attachments' to system-settings/Pasted Images."
fi

echo ""
echo "=== Plugin Setup Complete ==="
echo ""
echo "IMPORTANT: Restart Obsidian for changes to take effect."
echo ""
echo "After restart, verify:"
echo "  1. Settings → Community Plugins → all 10 plugins listed and enabled"
echo "  2. Open a terminal: Cmd+P → 'Terminal: Open terminal'"
echo "  3. Create a new note → Linter auto-inserts frontmatter on save (Cmd+S)"
echo "  4. Settings → Local REST API → copy the API Key (needed for MCP setup)"
echo ""
echo "Plugin list:"
echo "  - Terminal         → integrated terminal for Claude Code"
echo "  - Linter           → auto-inserts frontmatter, sorts YAML on save"
echo "  - Templater        → folder templates for journals, daily hubs"
echo "  - Dataview         → advanced queries"
echo "  - Git              → version control from Obsidian"
echo "  - Local REST API   → MCP bridge (obsidian-mcp-tools depends on this)"
echo "  - MCP Tools        → Claude Code ↔ Obsidian connection"
echo "  - Editing Toolbar  → formatting toolbar"
echo "  - Excalidraw       → visual diagrams"
echo "  - Smart Connections → AI-powered note linking"
