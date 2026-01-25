# Dotfiles

Personal development environment configuration for shell, git, editors, and terminal.

## Quick Setup

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## What's Included

- **Shell**: Bash configuration, aliases, functions
- **Git**: Global config, commit template, ignore patterns
- **Prompt**: Starship configuration
- **Terminal**: Ghostty settings
- **Multiplexer**: Zellij layouts and config
- **Editors**: Neovim and VS Code settings

## Related Projects

| Project | Description |
|---------|-------------|
| [claude-toolkit](https://github.com/yourusername/claude-toolkit) | Claude Code skills, agents, hooks, and memory templates |
| [python-template](https://github.com/yourusername/python-template) | Python/data engineering project scaffold |

## Structure

```
dotfiles/
├── bash/           # Shell configuration
├── git/            # Git config and templates
├── starship/       # Prompt configuration
├── ghostty/        # Terminal settings
├── zellij/         # Multiplexer config
├── nvim/           # Neovim configuration
├── vscode/         # VS Code settings
├── .claude/        # Claude Code config for this repo
└── install.sh      # Installation script
```

## Installation

The `install.sh` script symlinks configuration files to their expected locations. Run it after cloning:

```bash
./install.sh
```

To update after pulling changes:

```bash
./install.sh
```

## License

MIT
