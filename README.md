# vault-setup-kit

Bootstrap kit that takes a fresh macOS device to a working Obsidian + Claude Code + AI-assistant operating system in one command.

## What it ships

- A working Obsidian vault with hub-and-spoke folder structure, frontmatter routing, and 12 templates
- A starter `Personal/Vault-Setup/` project with a 9-note curriculum on AI-native architecture, multi-agent systems, and the human-AI collaboration model behind the vault
- A generic `CLAUDE.md` that teaches AI assistants the conventions of this vault
- Bash scripts to install Obsidian community plugins (Templater, Dataview, Local REST API, MCP Tools, etc.)
- Bash scripts to register MCP servers (obsidian-mcp-tools, QMD) with Claude Code

## Prerequisites

- macOS
- Obsidian installed ([obsidian.md](https://obsidian.md))
- Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
- (optional, for vault search) `bun`: `brew install oven-sh/bun/bun`

## Usage

```bash
git clone git@github.com:RS42-AI/vault-setup-kit.git
cd vault-setup-kit
bash setup.sh
```

By default, the vault lives at `~/Claude/ObsidianVault`. Pass a different path as an argument:

```bash
bash setup.sh ~/Documents/MyVault
```

The kit runs three steps in order:

1. **setup-vault.sh** — creates the folder structure and copies starter content
2. **setup-plugins.sh** — downloads and configures Obsidian community plugins
3. **setup-mcp.sh** — registers MCP servers with Claude Code

You can also run any step individually if you only need to refresh part of the setup. All scripts are **idempotent** — re-running won't overwrite existing files.

## After running

1. Open Obsidian, point it at the vault path
2. Open `Personal/Vault-Setup/Vault-Setup.md`
3. Read the curriculum, do the 3 onboarding tasks
4. Customize `CLAUDE.md` for your specific areas and projects

## Status

Pre-v0.1 — under active development.
