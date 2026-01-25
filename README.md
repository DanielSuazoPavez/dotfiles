# Dotfiles

Personal development environment configuration for shell, git, editors, and terminal.

## Quick Setup

```bash
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
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
├── .bashrc, .aliases     # Shell config
├── .gitconfig, etc.      # Git config
├── .config/
│   ├── starship.toml     # Prompt
│   ├── ghostty/          # Terminal
│   ├── zellij/           # Multiplexer
│   └── nvim/             # Editor
├── .vscode/              # VS Code settings
└── install.sh            # Installation script
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
