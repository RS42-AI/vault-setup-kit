#Requires -Version 5.1
<#
  setup-windows.ps1 — One-file Windows entry point for the vault-setup-kit.
  Enables WSL2 + Ubuntu, installs prerequisites inside WSL, then runs the
  EXISTING bash setup.sh unchanged. The user never types a Linux command.

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

# Phase 4 — clone/locate the kit inside WSL and run the EXISTING setup.sh
# Double-quoted here-string: $KitRepo expands (PowerShell var); `$HOME and `$KIT
# are backtick-escaped so they reach bash as literal $HOME and $KIT.
$run = @"
set -euo pipefail
KIT="`$HOME/vault-setup-kit"
[ -d "`$KIT/.git" ] || git clone $KitRepo "`$KIT"
cd "`$KIT" && (git pull --ff-only 2>&1 || echo "  WARNING: git pull skipped (offline or diverged HEAD); running existing local version")
bash setup.sh
"@
$run | wsl.exe -d $Distro -- bash -s
if ($LASTEXITCODE -ne 0) { throw "WSL setup.sh failed (exit $LASTEXITCODE). See errors above." }

# Phase 5 — tell the user how to open the vault from Windows Obsidian
# wsl`$ — backtick-escaped so the literal share name "wsl$" is written, not a variable.
# $Distro and $wslUser — no escape, these ARE PowerShell variables that should expand.
$wslUser = (wsl.exe -d $Distro -- bash -lc 'echo $USER').Trim()
if (-not $wslUser) { $wslUser = "<your-username>" }
Write-Host "`n=== Done ===" -ForegroundColor Green
Write-Host "Open Obsidian (Windows) and 'Open folder as vault' at:"
Write-Host "  \\wsl`$\$Distro\home\$wslUser\Claude\ObsidianVault" -ForegroundColor Cyan
