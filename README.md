# vault-setup-kit

Bootstrap kit that takes a fresh macOS or Windows (via WSL2) device to a working Obsidian + Claude Code + AI-assistant operating system in one command.

## What it ships

- A working Obsidian vault with hub-and-spoke folder structure, frontmatter routing, and 14 templates
- An executive Morning Brief plus an optional, neutral Evening Entry—manual by default and safe to invoke from an external scheduler
- A starter `Personal/Vault-Setup/` project with a 9-note curriculum on AI-native architecture, multi-agent systems, and the human-AI collaboration model behind the vault
- A generic `CLAUDE.md` that teaches AI assistants the conventions of this vault
- Bash scripts to install Obsidian community plugins (Templater, Dataview, Local REST API, MCP Tools, etc.)
- Bash scripts to register MCP servers (obsidian-mcp-tools, QMD) with Claude Code

## Prerequisites

**macOS**

- macOS
- Obsidian installed ([obsidian.md](https://obsidian.md))
- Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
- (optional, for vault search) `bun`: `brew install oven-sh/bun/bun`

**Windows**

- Windows 10 (build 19041+) or Windows 11
- Obsidian for Windows installed ([obsidian.md](https://obsidian.md)) — the kit does not install it
- Everything else (WSL2, Ubuntu, Node, Claude Code, bun) is installed automatically by `setup-windows.ps1`

## Usage

### macOS

```bash
git clone git@github.com:RS42-AI/vault-setup-kit.git
cd vault-setup-kit
bash setup.sh
```

By default, the vault lives at `~/Claude/ObsidianVault`. Pass a different path as an argument:

```bash
bash setup.sh ~/Documents/MyVault
```

The kit runs four steps in order:

1. **setup-vault.sh** — creates the folder structure and copies starter content
2. **setup-plugins.sh** — downloads and configures Obsidian community plugins
3. **setup-mcp.sh** — registers MCP servers with Claude Code
4. **setup-claude-plugins.sh** — installs the AI-OS Lite daily workflow skills

You can also run any step individually if you only need to refresh part of the setup. All scripts are **idempotent** — re-running won't overwrite existing files.

The daily skills are installed for manual use. The kit does not install a scheduler; `/start-day` and `/prep-evening` can be wired to one later without changing their behavior.

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
2. Right-click `setup-windows.ps1` and choose **Run as administrator** (or run `.\setup-windows.ps1` from an elevated PowerShell).
3. The script installs WSL2 + Ubuntu and then **prompts you to restart your PC**. After restarting, run `setup-windows.ps1` again — it detects WSL is already installed and picks up where it left off.
4. On the second run the script installs Node, Claude Code, and bun inside WSL, then builds the vault and installs the Obsidian plugins (headless). It then **pauses in the PowerShell console** and asks you to open Obsidian, enable the plugins, and paste the Local REST API key. After you paste the key, it finishes the MCP servers and the AI-OS Lite plugin.

There is one unavoidable interactive step — opening Obsidian and pasting the REST API key — exactly as on macOS. Press Enter at the prompt to skip MCP for now; you can register it later inside WSL with `OBSIDIAN_API_KEY=<your-key> bash ~/vault-setup-kit/setup-mcp.sh`.

**Opening the vault in Obsidian (Windows)**

In Obsidian, choose "Open folder as vault" and navigate to:

```
\\wsl$\Ubuntu\home\<your-username>\Claude\ObsidianVault
```

Replace `<your-username>` with your WSL Ubuntu username (the script prints the exact path when it finishes).

**Running Claude Code and AI-OS commands**

Claude Code and the daily AI-OS commands (`/start-day`, etc.) run **inside WSL** — not in a Windows terminal. Open the Ubuntu app from the Start menu, or use the WSL terminal profile in Obsidian's Terminal plugin, to run them.

## Updating an existing install

If you already installed the kit and want to pick up changes from a newer release:

```bash
cd vault-setup-kit && git pull
bash setup-vault.sh --update ~/Claude/ObsidianVault
```

Then open Claude Code in the vault and run `/update-structure` — it walks you through any pending structural changes interactively. See [`docs/architecture/update-channel.md`](docs/architecture/update-channel.md) for the operational mental model.

## After running

1. Open Obsidian, point it at the vault path
2. Open `Personal/Vault-Setup/Vault-Setup.md`
3. Read the curriculum, do the 3 onboarding tasks
4. Customize `AGENTS.md` for your specific areas and projects (`CLAUDE.md` points to it)

## Status

Pre-v0.1 — under active development.

## License

Licensed under the [GNU Affero General Public License v3.0](LICENSE) (AGPL-3.0), matching the [AI-OS Lite](https://github.com/RS42-AI/ai-os-lite) plugin it installs.
