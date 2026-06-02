# Windows Pilot Checklist — William's Dell (Release Gate)

**Purpose:** William runs this on his Dell before the system goes on Dad's Lenovo.
If any **REQUIRED** step fails, stop. Do not put this on Dad's machine until it is resolved.

Items marked **[REQUIRED]** block the Dad install. Items marked **[NICE-TO-HAVE]** are worth noting but do not block.

---

## 0. Environment (record before starting)

- [ ] Windows version: _____________________________ (Settings → System → About → OS Build)
- [ ] WSL distro installed: _________________________ (may not exist yet — fill in after Phase 2)
- [ ] Obsidian already installed on this machine? Yes / No
- [ ] Obsidian version (if installed): ______________

> These answers close the two open questions from the spec: whether the kit works on Windows 10 vs 11, and which WSL distro `wsl --install` selects by default on this hardware.

---

## Phase 1 — Admin preflight [REQUIRED]

- [ ] Obsidian for Windows is installed. (Download from [obsidian.md](https://obsidian.md) if not.)
- [ ] Clone or download the vault-setup-kit onto the Windows machine.
- [ ] Right-click `setup-windows.ps1` → **Run as administrator** (or open an elevated PowerShell and run `.\setup-windows.ps1`).
- [ ] Script starts without the "Re-run this file as Administrator" error.

---

## Phase 2 — WSL install + reboot [REQUIRED]

- [ ] Script prints "Installing WSL2 + Ubuntu. Your PC will need ONE restart."
- [ ] `wsl --install` runs without fatal error.
- [ ] Script prints the restart prompt and exits cleanly.
- [ ] **Restart the PC.**

---

## Phase 2b — R2 check: resume after reboot (does NOT re-ask for reboot) [REQUIRED]

> R2 risk: `Test-WslReady` reads `wsl --list --quiet` as UTF-16LE; if the re-encoding fails it may re-trigger the install path, asking for a second reboot.

- [ ] Run `setup-windows.ps1` again as Administrator after rebooting.
- [ ] The script detects WSL is already ready and **skips** the `wsl --install` step — it does NOT print "Installing WSL2" again.
- [ ] The script does NOT ask you to restart a second time.

> If it asks to restart again, record the exact output here and stop — this is the UTF-16LE mismatch failure mode. Do not continue until resolved.
>
> Notes: _______________________________________________________

---

## Phase 3 — In-WSL prerequisites [REQUIRED]

- [ ] Script installs `git` and `curl` inside WSL without fatal error.
- [ ] Script installs Node.js (LTS) inside WSL without fatal error.
- [ ] Script installs Claude Code (`claude` command) inside WSL without fatal error.
- [ ] Script installs `bun` inside WSL without fatal error.
- [ ] Phase 3 exits with code 0 (no "WSL prerequisite install failed" message).

---

## Phase 4 — Kit clone + `bash setup.sh` [REQUIRED]

- [ ] Script clones (or locates) the vault-setup-kit inside WSL at `~/vault-setup-kit`.
- [ ] `bash setup.sh` runs to completion — vault folders, plugins, and MCP setup all run.
- [ ] Script prints `=== Done ===` and shows the `\\wsl$\Ubuntu\home\<user>\Claude\ObsidianVault` path.
- [ ] Record the exact WSL path printed: _______________________________________

---

## Phase 5 — Obsidian + vault handshake

### 5a. Open vault from Windows Obsidian [REQUIRED]

- [ ] Open Obsidian (Windows app).
- [ ] Choose "Open folder as vault."
- [ ] Navigate to the `\\wsl$\...` path printed by the script (or type it manually).
- [ ] Vault opens — folders and notes are visible.

### 5b. Community plugins enabled [REQUIRED]

Confirm these four plugins are enabled in Obsidian (Settings → Community plugins):

- [ ] Local REST API
- [ ] MCP Tools
- [ ] Templater
- [ ] Dataview

> `setup-plugins.sh` should have enabled them. If any are listed but not toggled on, enable them manually here.

### 5c. R4 check: API key copy/paste [REQUIRED]

> R4 risk: the Local REST API key is generated in Windows-side Obsidian and must be pasted into the WSL terminal prompt during `setup-mcp.sh`. This is a manual clipboard bridge.

- [ ] In Obsidian: Settings → Community plugins → Local REST API → copy the API Key to clipboard.
- [ ] If `setup-mcp.sh` already ran during Phase 4 and skipped the key (you pressed Enter), re-run it inside WSL: open Ubuntu terminal and run `bash ~/vault-setup-kit/setup-mcp.sh`.
- [ ] When `setup-mcp.sh` prompts "Paste the Local REST API key (or press Enter to skip):", paste the key from clipboard — it appears in the terminal and the script accepts it.
- [ ] Script prints "Registered obsidian-mcp-tools."
- [ ] Manually add the API key env var to `~/.claude.json` (the script prints the exact JSON snippet to add). Confirm the entry is in the file after editing.

---

## Phase 6 — MCP + search proof (R1 + R3) [REQUIRED]

### 6a. R1 check: Linux binary in place

> R1 is the most-likely-to-break risk. Windows-side Obsidian downloads a Windows `.exe` into the plugin bin path. `setup-mcp.sh` must have replaced it with a Linux ELF.

- [ ] Inside WSL, run:
  ```
  file ~/Claude/ObsidianVault/.obsidian/plugins/mcp-tools/bin/mcp-server
  ```
- [ ] Output reports **ELF** (e.g. "ELF 64-bit LSB executable, x86-64"). Not "PE32" or "MS-DOS".

> If the output says PE32 or MS-DOS executable, the R1 provisioning step did not replace the Windows binary. Record the full `file` output and stop — do not proceed to 6b until this is fixed.
>
> Notes: _______________________________________________________

### 6b. MCP servers registered [REQUIRED]

- [ ] Inside WSL, run `claude mcp list`.
- [ ] `obsidian-mcp-tools` appears in the list.
- [ ] `qmd` appears in the list.

### 6c. R3 check + R1 end-to-end: live vault search [REQUIRED]

> This single step proves both R1 (Linux binary runs) and R3 (WSL→Windows localhost forwarding reaches Windows-side Obsidian's Local REST API).

- [ ] Inside WSL, run:
  ```
  claude "search my vault for test"
  ```
- [ ] Claude Code returns actual vault search results (note titles, paths, or content snippets) — not an error, not an empty result.

> If this fails with a connection error, R3 is the likely cause: WSL2→Windows localhost forwarding is not working. Record the error message.
> If this fails with a binary error or permission error, R1 may not be fully resolved.
>
> Notes: _______________________________________________________

---

## Phase 7 — Personal OS command [REQUIRED]

- [ ] Inside WSL, open Claude Code in the vault:
  ```
  cd ~/Claude/ObsidianVault && claude
  ```
- [ ] Run `/start-day` (or another daily Personal OS command) and confirm it executes — it produces output, not an "unknown command" error.

---

## Sign-off

### All REQUIRED checks passed → cleared for Dad's Lenovo

- [ ] Tester name: ___________________________
- [ ] Date tested: ___________________________
- [ ] Windows version confirmed: ___________________________
- [ ] WSL distro confirmed: ___________________________

**Follow-ups discovered during this run** (note anything that needed a workaround, a manual step the script missed, or a step that was confusing for a non-technical user — these feed into what must be hardened before the Dad install):

```
(fill in here)
```

---

*Do not mark this gate as passed unless every REQUIRED checkbox above is ticked. If in doubt, ask before proceeding.*
