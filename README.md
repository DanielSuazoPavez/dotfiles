# My Dotfiles

Personal development environment configuration files for Linux (Ubuntu/Debian-based distributions) and WSL2.

## Prerequisites

Before setting up dotfiles, ensure you have the following installed:

### Required
- **Git**: Version control
  ```bash
  sudo apt-get update && sudo apt-get install -y git
  ```

- **curl/wget**: For downloading dependencies
  ```bash
  sudo apt-get install -y curl wget unzip
  ```

- **uv**: Python package manager (required for `make` commands)
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

### Tools These Dotfiles Configure

Install these before running the install script:

- **Starship prompt**
  ```bash
  curl -sS https://starship.rs/install.sh | sh
  ```

- **Zellij multiplexer**
  ```bash
  # Check latest release: https://github.com/zellij-org/zellij/releases
  cargo install --locked zellij
  # OR
  wget https://github.com/zellij-org/zellij/releases/download/v0.39.2/zellij-x86_64-unknown-linux-musl.tar.gz
  tar -xvf zellij-*.tar.gz
  sudo mv zellij /usr/local/bin/
  ```

- **Ghostty terminal**: Follow [official installation guide](https://ghostty.org/docs/install/build)

- **Neovim**

    Our Neovim configuration is based on `kickstart.nvim` and requires a **recent version of Neovim (v0.9.0 or newer)**.

    The easiest way to install a recent version on Linux is by using the **AppImage**:
    1.  Download the `nvim.appimage` from the [Neovim releases page](https://github.com/neovim/neovim/releases).
    2.  Make it executable: `chmod u+x nvim.appimage`
    3.  Move it to a location in your `PATH`, for example: `sudo mv nvim.appimage /usr/local/bin/nvim`

    Alternatively, you can build from source for the very latest updates. Using your system's package manager (e.g., `sudo apt-get install neovim`) is also an option, but please verify that it provides a recent enough version.

## Quick Setup

```bash
# Clone the repository
git clone https://github.com/DanielSuazoPavez/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install pre-commit hooks (optional but recommended)
make install-hooks

# Install dotfiles
make install

# Reload shell
source ~/.bashrc
```

## What's Included

- Shell configuration (bash, aliases)
- Git configuration (global ignore patterns)
- Starship prompt configuration
- Ghostty terminal settings
- Zellij multiplexer configuration
- Neovim configuration (Kickstart.nvim based)
- VS Code settings and keybindings

## Available Make Commands

After installing `uv`, you can use these commands:

```bash
make help           # Show all available commands
make install        # Install dotfiles (run install.sh)
make update         # Pull latest changes from git
make install-hooks  # Install pre-commit hooks (requires uv)
make lint           # Run all pre-commit hooks
make check-secrets  # Run pre-commit secret detection
make backup         # Create manual backup of current configs
make clean          # Clean backup directories older than 30 days
```

## Updating Dotfiles

Since your config files are symlinked, updates are automatic when you pull changes:

```bash
cd ~/dotfiles
make update
source ~/.bashrc
```

Only re-run `make install` if:
- You've added new config files to the repository
- The directory structure has changed
- Symlinks were accidentally broken

## Uninstalling

To remove dotfiles and restore original configs:

```bash
cd ~/dotfiles
./uninstall.sh
```

This removes all symlinks. Your backups are preserved in `~/dotfiles-backup-*` directories.

## Security

This repository includes pre-commit hooks to prevent accidentally committing secrets:
- Detects API keys, tokens, and credentials
- Checks for AWS credentials
- Validates YAML/JSON syntax
- Prevents committing `.env` files

Run `make install-hooks` to enable these protections.

## License

Personal configuration files - use at your own risk.
