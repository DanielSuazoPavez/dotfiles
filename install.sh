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

    # Install Cascadia Code (required for Ghostty icon rendering)
    if fc-list | grep -qi "Cascadia Code"; then
        echo "✅ Cascadia Code already installed"
    else
        echo "📥 Installing Cascadia Code..."
        local cascadia_version="v2404.23"
        local cascadia_zip="CascadiaCode.zip"

        curl -fLo "$cascadia_zip" \
            "https://github.com/microsoft/cascadia-code/releases/download/${cascadia_version}/CascadiaCode-${cascadia_version#v}.zip"

        unzip -q "$cascadia_zip" -d /tmp/cascadia
        cp /tmp/cascadia/ttf/CascadiaCode.ttf "$font_dir/"
        cp /tmp/cascadia/ttf/CascadiaCodeNF.ttf "$font_dir/" 2>/dev/null || true
        rm -rf "$cascadia_zip" /tmp/cascadia

        echo "✅ Cascadia Code installed"
    fi

    # Refresh font cache
    fc-cache -fv
}

echo "🚀 Installing dotfiles..."

# Install Nerd fonts
install_nerd_fonts

# Files and directories in home directory
link_file "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
link_file "$DOTFILES_DIR/.hushlogin" "$HOME/.hushlogin"
link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"

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

echo "✅ Dotfiles installed successfully!"
echo "🔄 Restart your terminal or run: source ~/.bashrc"
