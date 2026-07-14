#Requires -Version 5.1
<#
  setup-windows.ps1 — One-file Windows entry point for the vault-setup-kit.
  Enables WSL2 + Ubuntu, installs prerequisites inside WSL, then drives the kit's
  sub-scripts directly: vault + plugins run headless, then PowerShell pauses (real
  console TTY) to collect any required Local REST API key and finishes the
  selected Claude/Codex AI-OS Lite setup.
  The user never types a Linux command.

  Usage (from an elevated PowerShell):
    .\setup-windows.ps1
    .\setup-windows.ps1 -Agent codex
    .\setup-windows.ps1 -Agent both
#>
param(
  [string]$Distro = "Ubuntu",
  [string]$KitRepo = "https://github.com/RS42-AI/vault-setup-kit.git",
  [ValidateSet("claude", "codex", "both")]
  [string]$Agent = "claude"
)
$ErrorActionPreference = "Stop"

function Test-Admin { ([Security.Principal.WindowsPrincipal] `
  [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
  [Security.Principal.WindowsBuiltinRole]::Administrator) }

function Test-WslReady {
  if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) { return $false }
  # Directly probe the distro rather than parsing wsl --list output (UTF-16LE decoding
  # is unreliable across PS 5.1 console code pages). If the distro is installed and
  # functional, `wsl -d <Distro> -- true` exits 0.
  try {
    wsl.exe -d $Distro -- true 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
  } catch {
    return $false
  }
}

# Phase 1 — preflight
if (-not (Test-Admin)) { throw "Re-run this file as Administrator (right-click -> Run as administrator)." }

# Phase 2 — WSL install (reboot-and-resume)
if (-not (Test-WslReady)) {
  Write-Host "Installing WSL2 + $Distro. Your PC will need ONE restart." -ForegroundColor Cyan
  wsl.exe --install -d $Distro
  Write-Host "`nRESTART your PC, then double-click this file again to finish." -ForegroundColor Yellow
  exit 0   # resume on re-run after reboot
}

# Phase 3 — in-WSL prerequisites (idempotent)
# Run each command as a separate wsl.exe call with bash -lc to avoid CRLF issues:
# PS 5.1 re-encodes CRLF when piping multi-line strings to native processes even after
# an in-memory -replace, so piped here-strings reliably break bash brace-groups.
# Grant passwordless sudo first using root (-u root needs no password) so apt-get
# doesn't prompt when called from a non-TTY context.
$wslUser = (wsl.exe -d $Distro -- bash -lc 'echo $USER').Trim()
if ($wslUser) {
  wsl.exe -d $Distro -u root -- bash -c "echo '$wslUser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$wslUser-nopasswd && chmod 440 /etc/sudoers.d/$wslUser-nopasswd"
  Write-Host "Configured passwordless sudo for $wslUser inside WSL." -ForegroundColor Cyan
}

Write-Host "Phase 3: Installing prerequisites in WSL..." -ForegroundColor Cyan
wsl.exe -d $Distro -- bash -lc 'sudo apt-get update -y && sudo apt-get install -y git curl unzip'
if ($LASTEXITCODE -ne 0) { throw "WSL apt-get failed (exit $LASTEXITCODE). See errors above." }

wsl.exe -d $Distro -- bash -lc 'command -v node >/dev/null 2>&1 || { curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs; }'
if ($LASTEXITCODE -ne 0) { throw "WSL Node.js install failed (exit $LASTEXITCODE). See errors above." }

if ($Agent -in @("claude", "both")) {
  wsl.exe -d $Distro -- bash -lc 'command -v claude >/dev/null 2>&1 || sudo npm install -g @anthropic-ai/claude-code'
  if ($LASTEXITCODE -ne 0) { throw "WSL Claude Code install failed (exit $LASTEXITCODE). See errors above." }
}

if ($Agent -in @("codex", "both")) {
  wsl.exe -d $Distro -- bash -lc 'command -v codex >/dev/null 2>&1 || sudo npm install -g @openai/codex'
  if ($LASTEXITCODE -ne 0) { throw "WSL Codex install failed (exit $LASTEXITCODE). See errors above." }
}

wsl.exe -d $Distro -- bash -lc 'command -v bun >/dev/null 2>&1 || { curl -fsSL https://bun.sh/install | bash; }'
if ($LASTEXITCODE -ne 0) { throw "WSL bun install failed (exit $LASTEXITCODE). See errors above." }

# Phase 4 — drive the sub-scripts directly, with the human-coordination pauses
# happening here in the PowerShell console (a real TTY) instead of piping the
# interactive setup.sh into a TTY-less bash -s (which aborts at its read pauses).

# 4.1 — clone/locate the kit inside WSL.
wsl.exe -d $Distro -- bash -lc "[ -d ~/vault-setup-kit/.git ] || git clone $KitRepo ~/vault-setup-kit"
if ($LASTEXITCODE -ne 0) { throw "WSL kit clone failed (exit $LASTEXITCODE). See errors above." }
wsl.exe -d $Distro -- bash -lc 'cd ~/vault-setup-kit && git pull --ff-only || true'
if ($LASTEXITCODE -ne 0) { throw "WSL kit pull failed (exit $LASTEXITCODE). See errors above." }

# 4.2 — run vault + plugins HEADLESS (neither pauses; SETUP_YES=1 belt-and-suspenders).
# Ensure git has a user identity so setup-vault.sh can make the initial commit.
wsl.exe -d $Distro -- bash -lc 'git config --global user.email 2>/dev/null | grep -q . || git config --global user.email "vault@local"'
wsl.exe -d $Distro -- bash -lc 'git config --global user.name 2>/dev/null | grep -q . || git config --global user.name "Vault"'
# Vault goes on the Windows filesystem so Obsidian can watch files normally.
# \\wsl$\ paths cause EISDIR errors because Obsidian's file watcher doesn't work
# on WSL's network-share filesystem. From WSL, C:\ is /mnt/c/.
$winVaultPath = "C:\Users\$env:USERNAME\Claude\ObsidianVault"
$wslVaultPath = "/mnt/c/Users/$env:USERNAME/Claude/ObsidianVault"

wsl.exe -d $Distro -- bash -lc "cd ~/vault-setup-kit && SETUP_YES=1 bash setup-vault.sh '$wslVaultPath'"
if ($LASTEXITCODE -ne 0) { throw "WSL vault setup failed (exit $LASTEXITCODE). See errors above." }
wsl.exe -d $Distro -- bash -lc "cd ~/vault-setup-kit && SETUP_YES=1 bash setup-plugins.sh '$wslVaultPath'"
if ($LASTEXITCODE -ne 0) { throw "WSL plugins setup failed (exit $LASTEXITCODE). See errors above." }

# 4.4 — PowerShell pause (real console): open Obsidian and enable plugins.
Write-Host "`n------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Obsidian setup:" -ForegroundColor Cyan
Write-Host "  1. Open Obsidian (Windows) -> 'Open folder as vault' at:"
Write-Host "       $winVaultPath" -ForegroundColor Yellow
Write-Host "  2. Enable these community plugins: Local REST API, MCP Tools, Templater, Dataview."
if ($Agent -in @("claude", "both")) {
  Write-Host "  3. Copy the key from Settings -> Local REST API -> API Key."
} else {
  Write-Host "  3. Return here after the plugins are enabled."
}
Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
if ($Agent -in @("claude", "both")) {
  $apiKey = Read-Host "Paste the Local REST API key (or press Enter to skip MCP for now)"
} else {
  Read-Host "Press Enter to continue with Codex plugin setup" | Out-Null
  $apiKey = ""
}

# 4.5 — run the selected MCP/plugin setup in WSL, passing the key via env.
# Escape single quotes for the single-quoted bash string ('->'\'') so an unexpected
# character in the key can't break or inject into the command. $apiKey/$Distro are
# PowerShell vars and expand here.
$apiKeyEsc = $apiKey.Replace("'", "'\''")
switch ($Agent) {
  "claude" {
    $agentSetup = "OBSIDIAN_API_KEY='$apiKeyEsc' bash setup-mcp.sh '$wslVaultPath' && bash setup-claude-plugins.sh '$wslVaultPath'"
  }
  "codex" {
    $agentSetup = "bash setup-codex-plugins.sh '$wslVaultPath'"
  }
  "both" {
    $agentSetup = "OBSIDIAN_API_KEY='$apiKeyEsc' bash setup-mcp.sh '$wslVaultPath' && bash setup-claude-plugins.sh '$wslVaultPath' && bash setup-codex-plugins.sh '$wslVaultPath'"
  }
}
wsl.exe -d $Distro -- bash -lc "cd ~/vault-setup-kit && $agentSetup"
if ($LASTEXITCODE -ne 0) { throw "WSL $Agent plugin setup failed (exit $LASTEXITCODE). See errors above." }

# Phase 5 — done; remind the user how to open the vault and run the daily commands.
Write-Host "`n=== Done ===" -ForegroundColor Green
Write-Host "Open Obsidian (Windows) and 'Open folder as vault' at:"
Write-Host "  $winVaultPath" -ForegroundColor Cyan
if ($Agent -eq "claude") {
  Write-Host "Claude Code + AI-OS Lite run inside WSL: open Ubuntu and run /start-day." -ForegroundColor Cyan
} elseif ($Agent -eq "codex") {
  Write-Host "Codex + AI-OS Lite run inside WSL: open Ubuntu, start Codex in the vault, and ask it to run `$start-day." -ForegroundColor Cyan
} else {
  Write-Host "Claude Code and Codex + AI-OS Lite run inside WSL. Start either agent in the vault." -ForegroundColor Cyan
}
