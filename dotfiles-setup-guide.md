# Dotfiles Setup Guide

A comprehensive guide for setting up and managing a personal dotfiles repository to maintain consistent development environments across machines.

## Platform Support

This guide targets **Linux (Ubuntu/Debian-based distributions)** as the primary platform.

**Windows users**: Use **WSL2** (Windows Subsystem for Linux) and follow the Linux instructions within your WSL environment.

**Not covered**: macOS, native Windows setups.

## What is a Dotfiles Repository?

A dotfiles repository is a personal configuration management system used to:

- **Store configuration files**: Shell configs (`.bashrc`), editor settings, git config, etc.
- **Version control settings**: Track changes to your development environment over time
- **Sync across machines**: Keep consistent setup between different computers
- **Backup configurations**: Prevent loss of carefully crafted settings

## Recommended Configuration Files

### Personal Development Environment Configs
```bash
# Shell & Terminal
~/.bashrc                   # Shell configuration
~/.aliases                  # Shell aliases
~/.hushlogin                # Suppresses login message
~/.config/starship.toml     # Starship prompt config
~/.config/ghostty/config    # Ghostty terminal settings

# Zellij (instead of tmux)
~/.config/zellij/config.kdl # Zellij configuration

# Git
~/.gitconfig                # Global git settings
~/.gitignore_global         # Global gitignore
~/.gitmessage               # Git commit message template

# Development Tools
~/.config/nvim/             # Neovim configuration
~/.config/Code/User/settings.json # VS Code settings (individual files only)
~/.config/Code/User/keybindings.json # VS Code keybindings (individual files only)

```

**Important Notes:**
- Never commit sensitive files like API keys, tokens, passwords, or SSH configurations to your repository.
- SSH setup is out of scope for this guide. Consider setting up SSH keys on each machine independently.
- When symlinking VS Code config files, link individual files (settings.json, keybindings.json) rather than the entire User directory. This prevents VS Code's auto-generated files from cluttering your repository.

## Recommended Dotfiles Repository Structure

A best practice is to make your dotfiles repository mirror the structure of your home directory (`~`). This makes managing symlinks intuitive.

```
dotfiles/
├── .bashrc
├── .aliases
├── .hushlogin
├── .gitconfig
├── .gitignore_global
├── .gitmessage
└── .config/
    ├── starship.toml          # Note: stored directly in .config/
    ├── ghostty/
    │   └── config             # Symlink individual config file
    ├── zellij/
    │   └── config.kdl         # Symlink individual config file
    ├── nvim/
    │   └── ...
    └── Code/
        └── User/
            ├── settings.json  # Symlink individual files
            └── keybindings.json
```

**Note**: Some tools (like Starship) expect their config file directly in `~/.config/`, while others (like Ghostty, Zellij) use subdirectories. When symlinking, link individual configuration files rather than entire directories. This prevents auto-generated cache files or temporary files from cluttering your repository.

## How Symlinks Work

Symlinks (symbolic links) create a reference from one location to another, allowing you to keep your actual config files in your dotfiles repo while making them appear in their expected locations.

### Basic Symlink Commands

```bash
# Create a symlink
ln -s /path/to/actual/file /path/to/symlink

# Example: Link dotfiles repo file to home directory
ln -s ~/dotfiles/.bashrc ~/.bashrc

# Force overwrite existing file with symlink
ln -sf ~/dotfiles/.bashrc ~/.bashrc

# Check if file is a symlink
ls -la ~/.bashrc

# See where symlink points
readlink ~/.bashrc

# Remove symlink (not the target file)
rm ~/.bashrc
```

### Symlink Flags
- `-s`: Create symbolic link
- `-f`: Force overwrite existing files

## Prerequisites

Before setting up your dotfiles, ensure you have these tools installed:

### Required
- **Git**: Version control for your dotfiles
  ```bash
  sudo apt-get update && sudo apt-get install -y git
  ```

- **curl/wget**: For downloading dependencies
  ```bash
  sudo apt-get install -y curl wget unzip
  ```

### Tools These Dotfiles Configure
These should be installed before running the install script:

```bash
# Starship prompt
curl -sS https://starship.rs/install.sh | sh

# Zellij multiplexer
# Check latest release: https://github.com/zellij-org/zellij/releases
cargo install --locked zellij
# OR
wget https://github.com/zellij-org/zellij/releases/download/v0.39.2/zellij-x86_64-unknown-linux-musl.tar.gz
tar -xvf zellij-*.tar.gz
sudo mv zellij /usr/local/bin/

# Ghostty terminal
# Follow instructions at: https://ghostty.org/docs/install/build

# Neovim
sudo apt-get install -y neovim
# OR build from source for latest version
```

### Optional (for enhanced functionality)
- **uv**: Python package manager for pre-commit and Python tools
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

## Setting Up Your Dotfiles Repository

### 1. Create and Initialize Repository

```bash
# Create dotfiles directory
mkdir ~/dotfiles
cd ~/dotfiles

# Initialize git repository
git init

# Create directory structure that mirrors ~/.config
mkdir -p .config/ghostty .config/zellij .config/nvim .config/Code/User
```

### 2. Create .gitignore

Before adding files, create a `.gitignore` to protect against accidentally committing sensitive data:

```bash
cat > .gitignore << 'EOF'
# OS and editor files
.DS_Store
*.swp
*.swo
*~
.vscode-settings-local.json

# Sensitive files (never commit these!)
.ssh/
.aws/
.env
.env.local
*.pem
*.key
.netrc
credentials

# Python
__pycache__/
*.py[cod]
*$py.class
.Python
venv/
.venv/
*.egg-info/

# Pre-commit
.secrets.baseline

# Backup directories created by install script
dotfiles-backup-*/

# Makefile artifacts (if any)
*.o

# VS Code workspace files
*.code-workspace
EOF
```

### 3. Move Existing Configs to Repository

**Important**: Before moving files, ensure your `.bashrc` will source your aliases. If you have an existing `.bashrc`, add this line to the end of it:

```bash
# Source aliases if the file exists
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"
```

Now move or copy your existing configs into the repository:

```bash
# Move existing configs into the new structure (backup first!)
cp ~/.bashrc ~/dotfiles/
cp ~/.aliases ~/dotfiles/
cp ~/.gitconfig ~/dotfiles/
cp ~/.gitmessage ~/dotfiles/
cp -r ~/.config/nvim ~/dotfiles/.config/
cp ~/.config/Code/User/settings.json ~/dotfiles/.config/Code/User/
# ...etc
```

### 4. Create Install Script

Create `~/dotfiles/install.sh`:

```bash
#!/bin/bash
# Dotfiles installation script

set -e # Exit on any error

# Check for required commands
for cmd in git curl; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ Error: $cmd is not installed"
        echo "   Install it with: sudo apt-get install $cmd"
        exit 1
    fi
done

# Variables
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Function to create a symlink with a backup and prompt
link_file() {
    local src=$1
    local dest=$2

    # If the destination exists and is not a symlink, back it up
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Found existing file/dir at $dest."
        read -p "  Backup and replace with symlink? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p "$(dirname "$BACKUP_DIR/$dest")"
            mv "$dest" "$BACKUP_DIR/$dest"
            echo "  Backed up to $BACKUP_DIR/$dest"
        else
            echo "  Skipping $dest..."
            return
        fi
    fi

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Create the symlink
    ln -sf "$src" "$dest"
    echo "  Linked $src -> $dest"
}

echo "🚀 Installing dotfiles..."

# Files and directories in home directory
link_file "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
link_file "$DOTFILES_DIR/.hushlogin" "$HOME/.hushlogin"
link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
link_file "$DOTFILES_DIR/.gitmessage" "$HOME/.gitmessage"

# Config files in ~/.config
link_file "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
link_file "$DOTFILES_DIR/.config/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
link_file "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/.config/Code/User/settings.json" "$HOME/.config/Code/User/settings.json"
link_file "$DOTFILES_DIR/.config/Code/User/keybindings.json" "$HOME/.config/Code/User/keybindings.json"


# Set git to use global settings
if [ -f "$HOME/.gitignore_global" ]; then
    git config --global core.excludesfile ~/.gitignore_global
    echo "  Set git global excludesfile"
fi

if [ -f "$HOME/.gitmessage" ]; then
    git config --global commit.template ~/.gitmessage
    echo "  Set git commit template"
fi

echo "✅ Dotfiles installed successfully!"
echo "🔄 Restart your terminal or run: source ~/.bashrc"
```

### 5. Make Install Script Executable

```bash
chmod +x ~/dotfiles/install.sh
```

### 6. Create README

Create `~/dotfiles/README.md`:

```markdown
# My Dotfiles

Personal development environment configuration files.

## Quick Setup

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## What's Included

- Shell configuration (bash, aliases)
- Git configuration (global ignore, commit template)
- Starship prompt
- Ghostty terminal
- Zellij multiplexer
- Neovim and VS Code settings

```

## Managing Dependencies like Fonts

Tools like Starship, Ghostty, and Zellij require **Nerd Fonts** to display icons correctly. The best practice is to not store these large binary files in your repository. Instead, your installation script can check for and install them if they are missing.

Add this function to your `install.sh`:

```bash
# In install.sh

install_nerd_fonts() {
    local font_dir="$HOME/.local/share/fonts"
    local fonts_to_install=("JetBrainsMono" "FiraCode")

    mkdir -p "$font_dir"

    for font_name in "${fonts_to_install[@]}"; do
        # Check if font is already installed
        if fc-list | grep -qi "$font_name Nerd Font"; then
            echo "✅ $font_name Nerd Font already installed"
            continue
        fi

        echo "📥 Installing $font_name Nerd Font..."
        local version="v3.2.1"  # Check https://github.com/ryanoasis/nerd-fonts/releases
        local zip_file="${font_name}.zip"

        curl -fLo "$zip_file" \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${font_name}.zip"

        unzip -q "$zip_file" -d "$font_dir/${font_name}NerdFont"
        rm "$zip_file"

        echo "✅ $font_name Nerd Font installed"
    done

    # Refresh font cache
    fc-cache -fv
}

# Call the function in the main part of your script
install_nerd_fonts
```

**Then configure your terminal to use the font:**
- **Ghostty**: Set in `~/.config/ghostty/config`:
  ```
  font-family = "JetBrainsMono Nerd Font"
  ```
- **VS Code**: Set in `settings.json`:
  ```json
  "editor.fontFamily": "'JetBrainsMono Nerd Font', monospace"
  ```

## Automating Common Tasks with Makefile

A `Makefile` in your dotfiles repo can streamline common operations. Create `~/dotfiles/Makefile`:

```makefile
.PHONY: help install update check-secrets lint clean test

help:  ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install:  ## Install dotfiles (run install.sh)
	@./install.sh

update:  ## Pull latest changes from git
	@echo "🔄 Updating dotfiles..."
	@git pull origin main
	@echo "✅ Updated! Restart terminal or run: source ~/.bashrc"

check-secrets:  ## Run pre-commit secret detection
	@pre-commit run detect-secrets --all-files

lint:  ## Run all pre-commit hooks
	@pre-commit run --all-files

install-hooks:  ## Install pre-commit hooks
	@pre-commit install
	@echo "✅ Pre-commit hooks installed"

clean:  ## Clean backup directories older than 30 days
	@echo "🧹 Cleaning old backups..."
	@find ~ -maxdepth 1 -name "dotfiles-backup-*" -type d -mtime +30 -exec rm -rf {} \;
	@echo "✅ Cleanup complete"

test:  ## Test install script in dry-run mode
	@echo "🧪 Testing would go here (manual verification recommended)"
	@bash -n install.sh && echo "✅ install.sh syntax OK"

backup:  ## Create manual backup of current configs
	@BACKUP_DIR="$$HOME/dotfiles-manual-backup-$$(date +%Y%m%d-%H%M%S)"; \
	mkdir -p "$$BACKUP_DIR"; \
	cp ~/.bashrc "$$BACKUP_DIR/" 2>/dev/null || true; \
	cp ~/.aliases "$$BACKUP_DIR/" 2>/dev/null || true; \
	echo "✅ Backup created at $$BACKUP_DIR"
```

**Usage:**
```bash
# See all available commands
make help

# Install dotfiles
make install

# Update from git
make update

# Run security checks
make check-secrets

# Install pre-commit hooks
make install-hooks
```

## New Machine Setup Flow

The typical flow for setting up dotfiles on a new machine:

```bash
# 1. Clone your dotfiles repository
git clone https://github.com/DanielSuazoPavez/dotfiles.git ~/dotfiles

# 2. Run the install script
cd ~/dotfiles
./install.sh

# 3. Reload shell (or restart terminal)
source ~/.bashrc

# 4. (Optional) Install pre-commit using uv (if you've set up Python project)
# Only needed if you initialized with `uv init`
uv tool install pre-commit
```

## Updating Dotfiles on Already-Configured Machines

Since your config files are symlinked, updates are automatic when you pull changes:

```bash
cd ~/dotfiles
git pull origin main

# Reload shell to apply changes
source ~/.bashrc
```

**Only re-run the install script if:**
- You've added new config files to the repository
- The directory structure has changed
- Symlinks were accidentally broken

```bash
cd ~/dotfiles
git pull origin main
./install.sh  # Will prompt before overwriting
source ~/.bashrc
```

## Security Checklist

Before pushing your dotfiles repository to a public location, ensure:

1. **Create a `.gitignore` for sensitive files**:
```
# OS and editor files
.DS_Store
*.swp
*.swo
*~
.vscode-settings-local.json

# Sensitive files (never commit these!)
.ssh/
.aws/
.env
.env.local
*.pem
*.key
.netrc
credentials
```

2. **Review your `.bashrc` and `.aliases`** - Ensure they don't contain:
   - API keys or tokens
   - Hardcoded passwords
   - Private URLs or hostnames

3. **Check git config** - Your global `.gitconfig` should not contain sensitive authentication tokens

4. **Make repository private** if you want to store any machine-specific configurations

## Git Configuration for Dotfiles

### Global Git Configuration

```bash
# Set global username and email
git config --global user.name "Your Full Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Set default editor
git config --global core.editor "code --wait"  # for VS Code
```

### Repository-Specific Configuration

For repositories requiring different identity:

```bash
# Inside specific repository
git config user.name "Work Name"
git config user.email "work.email@company.com"
```

## Git Pre-Commit Hooks for Security

**⚠️ Highly Recommended**: Pre-commit hooks prevent accidentally committing secrets to your public repository. While optional, this section is **strongly encouraged** for anyone publishing their dotfiles publicly.

**Time to setup**: ~5 minutes
**Value**: Prevents potentially serious security mistakes

Pre-commit hooks automatically check your changes before committing, preventing accidental commits of sensitive files like API keys, credentials, or private keys.

### Why Pre-Commit Hooks?

- **Prevents secrets from reaching git history** - Once committed, secrets can be hard to fully remove
- **Catches mistakes early** - Warns you before problematic files are staged
- **Automated enforcement** - No manual checks needed
- **Team consistency** - Enforces security standards across machines

### Setting Up Pre-Commit Framework

Install the pre-commit framework using `uv`:

```bash
# Install pre-commit with uv
uv tool install pre-commit

# Verify installation
pre-commit --version
```

Alternatively, use your system package manager:

```bash
# Ubuntu/Debian
sudo apt-get install pre-commit

```

### Create `.pre-commit-config.yaml`

Create this file in your dotfiles repo root:

```yaml
# .pre-commit-config.yaml
repos:
  # Built-in pre-commit hooks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
        name: Trim trailing whitespace
      - id: end-of-file-fixer
        name: Fix end of file
      - id: check-yaml
        name: Check YAML syntax
      - id: check-json
        name: Check JSON syntax
      - id: check-merge-conflict
        name: Check for merge conflicts
      - id: check-added-large-files
        name: Check for large files
        args: ['--maxkb=100']

  # Detect private keys
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        name: Detect secrets
        args: ['--baseline', '.secrets.baseline']

  # Custom regex patterns for additional security
  - repo: local
    hooks:
      - id: check-env-files
        name: Check for .env files
        entry: bash -c 'if git diff --cached --name-only | grep -E "\.env(\.[^/]+)?$"; then echo "ERROR: .env files detected. Use .env.example instead."; exit 1; fi'
        language: system
        stages: [commit]
        exclude: '\.env\.example$'

      - id: check-aws-keys
        name: Check for AWS credentials
        entry: bash -c 'if git diff --cached | grep -E "^\+.*(AKIA[0-9A-Z]{16}|aws_access_key_id[[:space:]]*=[[:space:]]*[A-Z0-9]{20}|aws_secret_access_key[[:space:]]*=[[:space:]]*[A-Za-z0-9/+=]{40})"; then echo "ERROR: AWS credentials detected"; exit 1; fi'
        language: system
        stages: [commit]

      - id: check-api-keys
        name: Check for API keys in code
        entry: bash -c 'if git diff --cached | grep -E "^\+.*(api[_-]?key|apikey|api[_-]?secret|auth[_-]?token)[[:space:]]*[=:][[:space:]]*[\"'\''][a-zA-Z0-9_\-]{20,}[\"'\'']" -i; then echo "ERROR: Potential API key or token detected in assignment"; exit 1; fi'
        language: system
        stages: [commit]
        exclude: '(README|EXAMPLE|SAMPLE|TEST)'
```

### Create `.secrets.baseline`

After creating `.pre-commit-config.yaml`, generate a baseline to ignore existing secrets (if any):

```bash
cd ~/dotfiles
detect-secrets scan --baseline .secrets.baseline
```

This creates a baseline file that `detect-secrets` uses to avoid flagging known exceptions.

### Install Pre-Commit Hooks

```bash
# From inside your dotfiles repo
pre-commit install

# Verify installation
pre-commit run --all-files
```

The `pre-commit install` command sets up the hooks in `.git/hooks/pre-commit`, so they run automatically before each commit.

### Testing the Hooks

Test that your hooks catch secrets:

```bash
# Try to add a fake API key
echo 'API_KEY=sk_test_1234567890' > test-secret.txt
git add test-secret.txt
git commit -m "test"  # This should be blocked by the check-api-keys hook
```

If the hook works, you'll see an error and the commit will be prevented.

### Making Hooks Part of Your Setup

To ensure hooks are installed on all machines, add to your `install.sh`:

```bash
# Check if uv is installed (required for installing pre-commit)
if ! command -v uv &> /dev/null; then
    echo "⚠️  uv is not installed. Please install uv first:"
    echo "    curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "    Then re-run this script."
else
    # Install pre-commit framework using uv
    if command -v pre-commit &> /dev/null; then
        echo "Installing pre-commit hooks..."
        pre-commit install
        echo "✅ Pre-commit hooks installed"
    else
        echo "Installing pre-commit with uv..."
        uv tool install pre-commit
        pre-commit install
        echo "✅ Pre-commit framework and hooks installed"
    fi
fi
```

## Uninstalling Dotfiles

If you need to remove the dotfiles setup and restore your original configs:

### Manual Uninstall

```bash
# 1. Remove symlinks (this won't delete the actual files in ~/dotfiles)
rm ~/.bashrc ~/.aliases ~/.hushlogin ~/.gitconfig ~/.gitignore_global ~/.gitmessage
rm ~/.config/starship.toml
rm ~/.config/ghostty ~/.config/zellij ~/.config/nvim
rm ~/.config/Code/User/settings.json ~/.config/Code/User/keybindings.json

# 2. Restore from backup (if you have one)
# Find your backup directory (format: dotfiles-backup-YYYYMMDD-HHMMSS)
ls -d ~/dotfiles-backup-*
cp -r ~/dotfiles-backup-YYYYMMDD-HHMMSS/.bashrc ~/
# Repeat for other files...

# 3. Remove the dotfiles repository (optional)
rm -rf ~/dotfiles
```

### Automated Uninstall Script

Create `~/dotfiles/uninstall.sh`:

```bash
#!/bin/bash
# Dotfiles uninstall script

set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "🗑️  Uninstalling dotfiles..."
echo "⚠️  This will remove all symlinks created by the install script."
read -p "Continue? (y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Remove symlinks in home directory
for file in .bashrc .aliases .hushlogin .gitconfig .gitignore_global .gitmessage; do
    if [ -L "$HOME/$file" ]; then
        rm "$HOME/$file"
        echo "  Removed symlink: ~/$file"
    fi
done

# Remove symlinks in .config
if [ -L "$HOME/.config/starship.toml" ]; then
    rm "$HOME/.config/starship.toml"
    echo "  Removed symlink: ~/.config/starship.toml"
fi

if [ -L "$HOME/.config/ghostty/config" ]; then
    rm "$HOME/.config/ghostty/config"
    echo "  Removed symlink: ~/.config/ghostty/config"
fi

if [ -L "$HOME/.config/zellij/config.kdl" ]; then
    rm "$HOME/.config/zellij/config.kdl"
    echo "  Removed symlink: ~/.config/zellij/config.kdl"
fi

if [ -L "$HOME/.config/nvim" ]; then
    rm "$HOME/.config/nvim"
    echo "  Removed symlink: ~/.config/nvim"
fi

# Remove VS Code symlinks
if [ -L "$HOME/.config/Code/User/settings.json" ]; then
    rm "$HOME/.config/Code/User/settings.json"
    echo "  Removed symlink: ~/.config/Code/User/settings.json"
fi

if [ -L "$HOME/.config/Code/User/keybindings.json" ]; then
    rm "$HOME/.config/Code/User/keybindings.json"
    echo "  Removed symlink: ~/.config/Code/User/keybindings.json"
fi

echo ""
echo "✅ Dotfiles uninstalled successfully!"
echo ""
echo "Your backup files (if any) are still in ~/dotfiles-backup-* directories."
echo "The dotfiles repository is still in ~/dotfiles (not deleted)."
echo ""
echo "To restore backups, check: ls -d ~/dotfiles-backup-*"
```

Make it executable:

```bash
chmod +x ~/dotfiles/uninstall.sh
```

## Troubleshooting

**Symlink already exists**
```bash
# Check what the symlink points to
readlink ~/.bashrc

# Remove old symlink and re-run install.sh
rm ~/.bashrc
./install.sh
```

**Permission denied when running install.sh**
```bash
chmod +x ~/dotfiles/install.sh
```

**Changes not taking effect**
```bash
# Reload shell configuration
source ~/.bashrc
```

**Existing config conflicts during installation**

The `install.sh` script prompts you to backup existing files before creating symlinks. If you choose not to backup, the script skips that file. You can:
- Re-run `install.sh` for any skipped files and choose to back them up
- Manually merge your existing config with the dotfiles version
- Remove your existing file and re-run `install.sh`

## Benefits

- **Single source of truth**: Edit files in dotfiles repo, changes apply everywhere
- **Version control**: All changes tracked in git
- **Easy sync**: Run install script on new machines
- **Backup and restore**: Never lose your configurations again
- **Consistent environment**: Same setup across all machines
- **Experimentation safety**: Can revert changes easily

## Best Practices

1. **Start small**: Begin with essential configs, add more over time
2. **Test thoroughly**: Always test install script on clean environment
3. **Document everything**: Keep README updated with new additions
4. **Backup before linking**: Always backup existing configurations
5. **Use meaningful directory structure**: Organize configs logically
6. **Keep sensitive data separate**: Never commit passwords or keys
7. **Keep configurations simple**: Focus on essential bash settings

---

## Appendix

### Python Project Initialization (Optional)

If you want to manage Python tools and dependencies in your dotfiles repository, you can initialize a Python project using `uv`:

```bash
# Initialize a Python project
uv init

# Add development tools as dependencies
uv add ruff pytest
```

This creates a `pyproject.toml` file that tracks your Python development tools, making them reproducible across machines.

**When to use this:**
- You want to version control your Python development tools
- You need consistent tool versions across machines
- You're managing a Python-heavy development environment

**Note:** This is optional and only relevant if you're using Python for development. Most users can skip this section.

---

*This guide covers the essential aspects of setting up and maintaining a personal dotfiles repository for consistent development environments.*
