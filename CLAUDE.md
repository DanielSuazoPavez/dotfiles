# CLAUDE.md

## Project Overview

Portable dotfiles for setting up a new machine with my preferred development environment. Clone, run install, done.

## Quick Start

```bash
./install.sh              # Symlink configs to home directory
make install              # Alternative
```

## Key Principles

1. **Idempotent**: Running install.sh multiple times is safe
2. **Portable**: Should work on any Linux/WSL machine
3. **Minimal dependencies**: Avoid requiring tools that aren't commonly available
4. **Symlinks over copies**: Changes here reflect immediately

## What's Configured

- Shell (bash, aliases, functions)
- Git (config, ignore, commit template)
- Prompt (Starship)
- Terminal (Ghostty)
- Multiplexer (Zellij)
- Editors (Neovim, VS Code)

## Structure

```
dotfiles/
├── .bashrc, .aliases      # Shell config
├── .config/               # XDG configs (starship, ghostty, zellij, nvim)
├── .vscode/               # VS Code settings
├── scripts/               # Utility scripts
├── install.sh             # Main installer
└── .claude/               # Claude Code config for this repo
```

## When Adding New Configs

1. Add the config file to this repo
2. Update `install.sh` to symlink it
3. Document in README if it's a new tool

## Related Repos

- [claude-toolkit](https://github.com/yourusername/claude-toolkit) - Claude Code skills/agents (sync with `claude-sync`)
- [python-template](https://github.com/yourusername/python-template) - Python project scaffold
