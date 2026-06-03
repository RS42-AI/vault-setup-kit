#Requires -Version 5.1
<#
  setup-windows.ps1 — One-file Windows entry point for the vault-setup-kit.
  Enables WSL2 + Ubuntu, installs prerequisites inside WSL, then drives the kit's
  sub-scripts directly: vault + plugins run headless, then PowerShell pauses (real
  console TTY) to collect the Local REST API key and finishes MCP + Personal OS.
  The user never types a Linux command.

  Usage (from an elevated PowerShell):  .\setup-windows.ps1
#>
param(
  [string]$Distro = "Ubuntu",
  [string]$KitRepo = "https://github.com/RS42-AI/vault-setup-kit.git"
)
$ErrorActionPreference = "Stop"

function Test-Admin { ([Security.Principal.WindowsPrincipal] `
  [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
  [Security.Principal.WindowsBuiltinRole]::Administrator) }

function Test-WslReady {
  if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) { return $false }
  # wsl --list --quiet emits UTF-16LE on some Windows builds; re-encode to UTF-8 before matching.
  $raw = [byte[]](wsl.exe --list --quiet)
  $list = [System.Text.Encoding]::Unicode.GetString($raw) -replace '\x00', ''
  return ($LASTEXITCODE -eq 0 -and $list -match [regex]::Escape($Distro))
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
# Single-quoted here-string: PowerShell expands nothing — all $ reach bash literally.
$bootstrap = @'
set -euo pipefail
sudo apt-get update -y && sudo apt-get install -y git curl
command -v node >/dev/null || { curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs; }
command -v claude >/dev/null || sudo npm install -g @anthropic-ai/claude-code
command -v bun >/dev/null || { curl -fsSL https://bun.sh/install | bash; }
'@
$bootstrap | wsl.exe -d $Distro -- bash -s
if ($LASTEXITCODE -ne 0) { throw "WSL prerequisite install failed (exit $LASTEXITCODE). See errors above." }

# Phase 4 — drive the sub-scripts directly, with the human-coordination pauses
# happening here in the PowerShell console (a real TTY) instead of piping the
# interactive setup.sh into a TTY-less bash -s (which aborts at its read pauses).

# 4.1 — clone/locate the kit inside WSL.
# Double-quoted here-string: $KitRepo expands (PowerShell var); `$HOME and `$KIT
# are backtick-escaped so they reach bash as literal $HOME and $KIT.
$clone = @"
set -euo pipefail
KIT="`$HOME/vault-setup-kit"
[ -d "`$KIT/.git" ] || git clone $KitRepo "`$KIT"
cd "`$KIT" && (git pull --ff-only 2>&1 || echo "  WARNING: git pull skipped (offline or diverged HEAD); running existing local version")
"@
$clone | wsl.exe -d $Distro -- bash -s
if ($LASTEXITCODE -ne 0) { throw "WSL kit clone/pull failed (exit $LASTEXITCODE). See errors above." }

# 4.2 — run vault + plugins HEADLESS (neither pauses; SETUP_YES=1 belt-and-suspenders).
# `$HOME backtick-escaped so it reaches bash literally; SETUP_YES is a bash assignment.
$headless = @"
set -euo pipefail
cd "`$HOME/vault-setup-kit"
SETUP_YES=1 bash setup-vault.sh
SETUP_YES=1 bash setup-plugins.sh
"@
$headless | wsl.exe -d $Distro -- bash -s
if ($LASTEXITCODE -ne 0) { throw "WSL vault/plugins setup failed (exit $LASTEXITCODE). See errors above." }

# 4.3 — compute the WSL username NOW so we can show the real \\wsl$ path in the prompt.
# wsl`$ — backtick-escaped so the literal share name "wsl$" is written, not a variable.
$wslUser = (wsl.exe -d $Distro -- bash -lc 'echo $USER').Trim()
if (-not $wslUser) { $wslUser = "<your-username>" }
$vaultPath = "\\wsl`$\$Distro\home\$wslUser\Claude\ObsidianVault"

# 4.4 — PowerShell pause (real console): open Obsidian, enable plugins, grab the key.
Write-Host "`n------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Obsidian handshake needed before MCP can register:" -ForegroundColor Cyan
Write-Host "  1. Open Obsidian (Windows) -> 'Open folder as vault' at:"
Write-Host "       $vaultPath" -ForegroundColor Yellow
Write-Host "  2. Enable these community plugins: Local REST API, MCP Tools, Templater, Dataview."
Write-Host "  3. Copy the key from Settings -> Local REST API -> API Key."
Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
$apiKey = Read-Host "Paste the Local REST API key (or press Enter to skip MCP for now)"

# 4.5 — run MCP + Personal OS plugin in WSL, passing the key via env.
# Escape single quotes for the single-quoted bash string ('->'\'') so an unexpected
# character in the key can't break or inject into the command. $apiKey/$Distro are
# PowerShell vars and expand here.
$apiKeyEsc = $apiKey.Replace("'", "'\''")
wsl.exe -d $Distro -- bash -lc "cd ~/vault-setup-kit && OBSIDIAN_API_KEY='$apiKeyEsc' bash setup-mcp.sh && bash setup-claude-plugins.sh"
if ($LASTEXITCODE -ne 0) { throw "WSL MCP/plugin setup failed (exit $LASTEXITCODE). See errors above." }

# Phase 5 — done; remind the user how to open the vault and run the daily commands.
Write-Host "`n=== Done ===" -ForegroundColor Green
Write-Host "Open Obsidian (Windows) and 'Open folder as vault' at:"
Write-Host "  $vaultPath" -ForegroundColor Cyan
Write-Host "Claude Code + Personal OS commands run inside WSL: open the Ubuntu app and run /start-day." -ForegroundColor Cyan
