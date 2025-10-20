#!/bin/bash
# Optional tools installation script

set -e # Exit on any error

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

check_dependencies() {
    echo "🔎 Checking for essential dependencies..."
    local missing_count=0
    local dependencies=("git" "curl" "cargo" "make")

    for dep in "${dependencies[@]}"; do
        if ! command_exists "$dep"; then
            echo "❌ Error: Required command '$dep' is not found."
            ((missing_count++))
        fi
    done

    if [ "$missing_count" -gt 0 ]; then
        echo "🔥 Please install the missing dependencies and run the script again."
        exit 1
    else
        echo "✅ All essential dependencies are installed."
    fi
    echo "" # for spacing
}

install_zoxide() {
    if command_exists zoxide; then
        echo "✅ zoxide is already installed."
        return
    fi
    echo "📥 Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    echo "✅ zoxide installed."
}

install_broot() {
    if command_exists broot; then
        echo "✅ broot is already installed."
        return
    fi
    if ! command_exists cargo; then
        echo "⚠️ Warning: cargo is not installed. Cannot install broot."
        echo "   Please install Rust and cargo: https://www.rust-lang.org/tools/install"
        return
    fi
    echo "📥 Installing broot..."
    cargo install broot
    # broot --install # This requires user interaction, skipping for now.
    echo "✅ broot installed. Run 'broot --install' to complete setup."
}

install_starship() {
    if command_exists starship; then
        echo "✅ starship is already installed."
        return
    fi
    echo "📥 Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo "✅ starship installed."
}

install_zellij() {
    if command_exists zellij; then
        echo "✅ zellij is already installed."
        return
    fi
    if ! command_exists cargo; then
        echo "⚠️ Warning: cargo is not installed. Cannot install zellij."
        echo "   Please install Rust and cargo: https://www.rust-lang.org/tools/install"
        return
    fi
    echo "📥 Installing zellij..."
    cargo install --locked zellij
    echo "✅ zellij installed."
}

install_nushell() {
    if command_exists nu; then
        echo "✅ nushell is already installed."
        return
    fi
    if ! command_exists cargo; then
        echo "⚠️ Warning: cargo is not installed. Cannot install nushell."
        echo "   Please install Rust and cargo: https://www.rust-lang.org/tools/install"
        return
    fi
    echo "📥 Installing nushell..."
    cargo install nu
    echo "✅ nushell installed."
}

install_neovim() {
    if command_exists nvim; then
        echo "✅ neovim is already installed."
        return
    fi
    echo "📥 Installing neovim (AppImage)..."
    curl -fLo nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    if [ -d "$HOME/.local/bin" ]; then
        mv nvim.appimage "$HOME/.local/bin/nvim"
        echo "✅ neovim installed to ~/.local/bin/nvim"
    else
        mkdir -p "$HOME/.local/bin"
        mv nvim.appimage "$HOME/.local/bin/nvim"
        echo "✅ neovim installed to ~/.local/bin/nvim"
        echo "ℹ️ Added ~/.local/bin to your PATH for this session. Please add it to your .bashrc or .zshrc file."
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

install_nvm() {
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        echo "✅ nvm is already installed."
        return
    fi
    echo "📥 Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    echo "✅ nvm installed. Please restart your shell."
}

# Main script execution
check_dependencies

echo "🚀 This script will help you install the recommended tools for this dotfiles setup."

read -p "  Install zoxide? (y/n) " -n 1 -r && echo
if [[ $REPLY =~ ^[Yy]$ ]]; then install_zoxide; fi

read -p "  Install broot? (y/n) " -n 1 -r && echo
if [[ $REPLY =~ ^[Yy]$ ]]; then install_broot; fi

read -p "  Install starship? (y/n) " -n 1 -r && echo
if [[ $REPLY =~ ^[Yy]$ ]]; then install_starship; fi

read -p "  Install zellij? (y/n) " -n 1 -r && echo
if [[ $REPLY =~ ^[Yy]$ ]]; then install_zellij; fi

read -p "  Install nushell? (y/n) " -n 1 -r && echo
if [[ $REPLY =~ ^[Yy]$ ]]; then install_nushell; fi

read -p "  Install neovim? (y/n) " -n 1 -r && echo
if [[ $REPLY =~ ^[Yy]$ ]]; then install_neovim; fi

read -p "  Install nvm? (y/n) " -n 1 -r && echo
if [[ $REPLY =~ ^[Yy]$ ]]; then install_nvm; fi

echo ""
echo "ℹ️ For the following tools, manual installation is recommended:"
echo "  - Ghostty: https://ghostty.org/docs/install"
echo "  - Visual Studio Code: https://code.visualstudio.com/docs/setup/linux"

echo "✅ Optional tools installation finished."
