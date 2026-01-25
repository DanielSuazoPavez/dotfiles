# Dotfiles

Personal development environment configuration for shell, git, editors, and terminal.

## Quick Setup

```bash
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
./install.sh
```

## Prerequisites

Install these tools before running `install.sh`:

| Tool | Install | Required for |
|------|---------|--------------|
| git | `sudo apt install git` | Always |
| curl | `sudo apt install curl` | Font downloads |
| starship | [starship.rs](https://starship.rs) | Prompt |
| zellij | [zellij.dev](https://zellij.dev) | Multiplexer |
| neovim | `sudo apt install neovim` (or [neovim.io](https://neovim.io)) | Editor |
| zoxide | `cargo install zoxide` | Smarter cd |

GUI tools (optional, skipped on headless):
- ghostty
- VS Code

## What's Included

- **Shell**: Bash configuration, aliases, functions
- **Git**: Global config, ignore patterns
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

## Troubleshooting

**Fonts not rendering correctly**
- Ensure Nerd Fonts installed: `fc-list | grep -i nerd`
- Configure your terminal to use "JetBrainsMono Nerd Font"

**Starship prompt not showing**
- Check if installed: `starship --version`
- Verify .bashrc sources correctly: `source ~/.bashrc`

**Zellij keybinds not working**
- Check config loaded: `zellij options`
- Config path: `~/.config/zellij/config.kdl`

## License

MIT
