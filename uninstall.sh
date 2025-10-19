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
for file in .bashrc .aliases .hushlogin .gitconfig .gitignore_global; do
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
