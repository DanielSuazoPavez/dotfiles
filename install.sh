#!/bin/bash
# Dotfiles installation script

set -e # Exit on any error

# ============================================================================
# Dependency Check
# ============================================================================

for cmd in git curl; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed"
        echo "   Install it with: sudo apt-get install $cmd"
        exit 1
    fi
done

# ============================================================================
# Variables
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
FAILED_LINKS=()

# ============================================================================
# Headless Detection
# ============================================================================

HEADLESS=false
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    HEADLESS=true
fi

# ============================================================================
# Helper Functions
# ============================================================================

# Create a symlink with backup and prompt
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
}

# Verify a symlink is valid
verify_symlink() {
    local dest=$1
    if [ -L "$dest" ] && [ -e "$dest" ]; then
        echo "  + $dest"
    else
        echo "  x $dest (broken)"
        FAILED_LINKS+=("$dest")
    fi
}

# Prompt for category installation
prompt_category() {
    local name=$1
    local default=$2
    if [ "$default" = "y" ]; then
        read -p "Install $name? [Y/n] " -n 1 -r
        echo
        [[ -z $REPLY || $REPLY =~ ^[Yy]$ ]]
    else
        read -p "Install $name? [y/N] " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Install Nerd Fonts
install_nerd_fonts() {
    local font_dir="$HOME/.local/share/fonts"
    local fonts_to_install=("JetBrainsMono" "FiraCode")

    mkdir -p "$font_dir"

    for font_name in "${fonts_to_install[@]}"; do
        # Check if font is already installed
        if fc-list | grep -qi "$font_name Nerd Font"; then
            echo "  $font_name Nerd Font already installed"
            continue
        fi

        echo "  Installing $font_name Nerd Font..."
        local version="v3.2.1"  # Check https://github.com/ryanoasis/nerd-fonts/releases
        local zip_file="${font_name}.zip"

        curl -fLo "$zip_file" \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${font_name}.zip"

        unzip -q "$zip_file" -d "$font_dir/${font_name}NerdFont"
        rm "$zip_file"

        echo "  $font_name Nerd Font installed"
    done

    # Refresh font cache
    fc-cache -fv > /dev/null 2>&1
}

# ============================================================================
# Main
# ============================================================================

echo "Installing dotfiles from $DOTFILES_DIR"
echo

# Headless notification
if [ "$HEADLESS" = true ]; then
    echo "Headless environment detected - GUI tools will be skipped"
    echo
fi

# ============================================================================
# Category Prompts
# ============================================================================

# Shell basics are always installed (no prompt)
INSTALL_STARSHIP=false
INSTALL_NEOVIM=false
INSTALL_ZELLIJ=false
INSTALL_GHOSTTY=false
INSTALL_VSCODE=false
INSTALL_FONTS=false

if prompt_category "Starship prompt" "y"; then
    INSTALL_STARSHIP=true
fi

if prompt_category "Neovim" "y"; then
    INSTALL_NEOVIM=true
fi

if prompt_category "Zellij" "y"; then
    INSTALL_ZELLIJ=true
fi

if [ "$HEADLESS" = false ]; then
    if prompt_category "Ghostty" "y"; then
        INSTALL_GHOSTTY=true
    fi

    if prompt_category "VS Code" "y"; then
        INSTALL_VSCODE=true
    fi

    if prompt_category "Nerd Fonts" "y"; then
        INSTALL_FONTS=true
    fi
fi

echo

# ============================================================================
# Installation
# ============================================================================

# Shell basics (always installed)
echo "Installing shell basics..."
link_file "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
link_file "$DOTFILES_DIR/.hushlogin" "$HOME/.hushlogin"
link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"

# Set git global excludesfile
if [ -f "$HOME/.gitignore_global" ]; then
    git config --global core.excludesfile ~/.gitignore_global
fi

# Starship
if [ "$INSTALL_STARSHIP" = true ]; then
    echo "Installing Starship config..."
    link_file "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
fi

# Neovim
if [ "$INSTALL_NEOVIM" = true ]; then
    echo "Installing Neovim config..."
    link_file "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
fi

# Zellij
if [ "$INSTALL_ZELLIJ" = true ]; then
    echo "Installing Zellij config..."
    link_file "$DOTFILES_DIR/.config/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
fi

# Ghostty (GUI only)
if [ "$INSTALL_GHOSTTY" = true ]; then
    echo "Installing Ghostty config..."
    link_file "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
fi

# VS Code (GUI only)
if [ "$INSTALL_VSCODE" = true ]; then
    echo "Installing VS Code config..."
    link_file "$DOTFILES_DIR/.config/Code/User/settings.json" "$HOME/.config/Code/User/settings.json"
    link_file "$DOTFILES_DIR/.config/Code/User/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
fi

# Nerd Fonts (GUI only)
if [ "$INSTALL_FONTS" = true ]; then
    echo "Installing Nerd Fonts..."
    install_nerd_fonts
fi

echo

# ============================================================================
# Verification
# ============================================================================

echo "Verifying symlinks..."

# Shell basics
verify_symlink "$HOME/.bashrc"
verify_symlink "$HOME/.aliases"
verify_symlink "$HOME/.hushlogin"
verify_symlink "$HOME/.gitconfig"
verify_symlink "$HOME/.gitignore_global"

# Optional configs
[ "$INSTALL_STARSHIP" = true ] && verify_symlink "$HOME/.config/starship.toml"
[ "$INSTALL_NEOVIM" = true ] && verify_symlink "$HOME/.config/nvim"
[ "$INSTALL_ZELLIJ" = true ] && verify_symlink "$HOME/.config/zellij/config.kdl"
[ "$INSTALL_GHOSTTY" = true ] && verify_symlink "$HOME/.config/ghostty/config"
if [ "$INSTALL_VSCODE" = true ]; then
    verify_symlink "$HOME/.config/Code/User/settings.json"
    verify_symlink "$HOME/.config/Code/User/keybindings.json"
fi

echo

# ============================================================================
# Summary
# ============================================================================

if [ ${#FAILED_LINKS[@]} -eq 0 ]; then
    echo "Dotfiles installed successfully!"
else
    echo "Installation completed with errors:"
    for link in "${FAILED_LINKS[@]}"; do
        echo "  - $link"
    done
fi

echo "Restart your terminal or run: source ~/.bashrc"
