# vault-setup-kit

Bootstrap kit that takes a fresh macOS or Windows (via WSL2) device to a working Obsidian + Claude Code and/or Codex AI-assistant operating system in one command.

## What it ships

- A working Obsidian vault with hub-and-spoke folder structure, frontmatter routing, and 14 templates
- An executive Morning Brief plus an optional, neutral Evening Entry—manual by default and safe to invoke from an external scheduler
- A starter `Personal/Vault-Setup/` project with a 9-note curriculum on AI-native architecture, multi-agent systems, and the human-AI collaboration model behind the vault
- A generic `AGENTS.md` operating contract, with `CLAUDE.md` importing it for Claude Code
- Bash scripts to install Obsidian community plugins (Templater, Dataview, Local REST API, MCP Tools, etc.)
- AI-OS Lite installation for Claude Code, Codex, or both
- Bash scripts to register MCP servers (obsidian-mcp-tools, QMD) with Claude Code; Codex MCP wiring is a separate follow-up

## Prerequisites

**macOS**

- macOS
- Obsidian installed ([obsidian.md](https://obsidian.md))
- At least one supported agent:
  - Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
  - [Codex](https://developers.openai.com/codex/)
- (optional, for vault search) `bun`: `brew install oven-sh/bun/bun`

**Windows**

- Windows 10 (build 19041+) or Windows 11
- Obsidian for Windows installed ([obsidian.md](https://obsidian.md)) — the kit does not install it
- Everything else (WSL2, Ubuntu, Node, bun, and the selected agent or agents) is installed automatically by `setup-windows.ps1`

## Usage

### macOS

```bash
git clone https://github.com/RS42-AI/vault-setup-kit.git
cd vault-setup-kit
bash setup.sh
```

Claude Code remains the default for backward compatibility. Choose Codex or install both agents with:

```bash
bash setup.sh --agent=codex
bash setup.sh --agent=both
```

By default, the vault lives at `~/Claude/ObsidianVault`. Pass a different path as an argument:

```bash
bash setup.sh ~/Documents/MyVault
```

The kit runs four stages in order:

1. **setup-vault.sh** — creates the folder structure and copies starter content
2. **setup-plugins.sh** — downloads and configures Obsidian community plugins
3. **setup-mcp.sh** — registers MCP servers when Claude Code is selected
4. **setup-claude-plugins.sh / setup-codex-plugins.sh** — installs the AI-OS Lite daily workflow skills for the selected agent(s)

You can also run any step individually if you only need to refresh part of the setup. All scripts are **idempotent** — re-running won't overwrite existing files.

The daily skills are installed for manual use. Claude Code uses slash commands such as `/start-day`; Codex accepts natural language or explicit skill references such as `Run $start-day for today.` The kit does not install a scheduler.

AI-OS Lite's Codex plugin is installed at the user level, so its skills are available in new Codex tasks across projects. Each person still opens and operates only their own generated vault. This release installs the Codex skills; Codex-specific MCP, CLI permission, and scheduling setup remains an explicit follow-up rather than being silently inferred from the Claude configuration.

### Generalized default

The supported default is the full, generalized system: work and life projects, goals, Morning Briefs, optional Evening Entries, and the starter curriculum. Reflection remains available, but the kit does not prescribe gratitude, journaling, or any personal habit. This is the edition intended for interns and other collaborators.

A legacy `team` edition remains available for compatibility with earlier installs, but it is not the current product direction:

```bash
bash setup.sh --edition=team ~/path/to/work-vault
# or just the vault step:
bash setup-vault.sh --edition=team ~/path/to/work-vault
```

Existing team-edition users can still consult [docs/switching-to-team-edition.md](docs/switching-to-team-edition.md).

### Windows (via WSL2)

1. Clone or download this repo on your Windows machine.
2. Right-click `setup-windows.ps1` and choose **Run as administrator** (or run `.\setup-windows.ps1` from an elevated PowerShell). Claude Code is the default; use `.\setup-windows.ps1 -Agent codex` or `-Agent both` to select Codex.
3. The script installs WSL2 + Ubuntu and then **prompts you to restart your PC**. After restarting, run `setup-windows.ps1` again — it detects WSL is already installed and picks up where it left off.
4. On the second run the script installs Node, bun, and the selected agent(s) inside WSL, then builds the vault and installs the Obsidian plugins (headless). It then **pauses in the PowerShell console** so you can enable the Obsidian plugins. Claude installations also request the Local REST API key before finishing MCP setup.

There is one unavoidable interactive step: opening Obsidian and enabling its plugins. Claude setup also asks for the Local REST API key. Press Enter to skip MCP for now; you can register it later inside WSL with `OBSIDIAN_API_KEY=<your-key> bash ~/vault-setup-kit/setup-mcp.sh`.

**Opening the vault in Obsidian (Windows)**

In Obsidian, choose "Open folder as vault" and navigate to:

```
\\wsl$\Ubuntu\home\<your-username>\Claude\ObsidianVault
```

Replace `<your-username>` with your WSL Ubuntu username (the script prints the exact path when it finishes).

**Running an agent and AI-OS skills**

Claude Code or Codex and the daily AI-OS skills currently run **inside WSL** so the Bash/Python deterministic helpers have a consistent environment. Open Ubuntu—or the WSL terminal profile in Obsidian—to start the selected agent in the vault. Claude uses `/start-day`; in Codex ask `Run $start-day for today.`

## Updating an existing install

If you already installed the kit and want to pick up changes from a newer release:

```bash
cd vault-setup-kit && git pull
bash setup-vault.sh --update ~/Claude/ObsidianVault
```

Then open Claude Code in the vault and run `/update-structure` — it walks you through any pending structural changes interactively. The current structure-update command remains Claude-specific; fresh Codex installs already receive the current structure, and a native Codex updater is follow-up work. See [`docs/architecture/update-channel.md`](docs/architecture/update-channel.md) for the operational mental model.

## After running

1. Open Obsidian, point it at the vault path
2. Open `Personal/Vault-Setup/Vault-Setup.md`
3. Read the curriculum, do the 3 onboarding tasks
4. Customize `AGENTS.md` for your specific areas and projects (`CLAUDE.md` points to it)

## Status

Pilot-ready and under active development. The current public `main` is the supported intern-onboarding path.

## License

Licensed under the [GNU Affero General Public License v3.0](LICENSE) (AGPL-3.0), matching the [AI-OS Lite](https://github.com/RS42-AI/ai-os-lite) plugin it installs.
