# Dotfiles

Personal development environment configuration for shell, git, editors, and terminal.

## Quick Setup

```bash
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
./install.sh
```

## Prerequisites

> **Fresh machine?** See [docs/BOOTSTRAP.md](docs/BOOTSTRAP.md) for the full
> path from a blank Windows/WSL install to running `install.sh`.

Only `git` and `curl` are required up front — `install.sh` installs the rest.

## What install.sh Installs

Each category prompt means install-if-missing (native package on Tumbleweed,
curl installer/tarball on Ubuntu) plus config symlinks. Already-installed
tools skip straight to linking. Run as your user — the script invokes `sudo`
inline where root is needed.

| Tier | Tools |
|------|-------|
| Core (prompt, default Y) | starship, zellij, neovim, zoxide, ripgrep, broot |
| Core GUI (skipped if headless) | ghostty, Nerd Fonts (JetBrainsMono + FiraCode) |
| Runtimes (prompt, default Y) | uv, node, docker |
| Optional (prompt, default Y) | Claude Code (+ playwright chromium) |
| Doc-only (see [BOOTSTRAP.md](docs/BOOTSTRAP.md)) | rust, go |

## What's Included

- **Shell**: Bash configuration, aliases, functions
- **Git**: Global config, ignore patterns
- **Prompt**: Starship configuration
- **Terminal**: Ghostty settings
- **Multiplexer**: Zellij layouts and config
- **Editor**: Neovim (lazy.nvim, LSP, completion)

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
└── install.sh            # Installation script
```

## Installation

The `install.sh` script installs missing tools and symlinks configuration files to their expected locations. Run it after cloning:

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
