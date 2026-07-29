#!/bin/bash
# Dotfiles installation script

set -e # Exit on any error

# Refuse to run as root: user-space installs (fonts, starship, uv, nvm,
# claude) must land in the invoking user's $HOME, not /root.
# The script calls sudo itself where root is required.
if [ "$EUID" -eq 0 ]; then
    echo "Error: do not run as root (no 'sudo ./install.sh')."
    echo "Run as your user; sudo is invoked where needed."
    exit 1
fi

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

# The symlink list lives in links.sh, which also derives DOTFILES_DIR.
# Sourced by script path so ./install.sh works from any cwd.
# shellcheck source=links.sh
source "$(cd "$(dirname "$0")" && pwd)/links.sh"

BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
FAILED_LINKS=()
FAILED_INSTALLS=()

# Package manager detection (Tumbleweed vs Ubuntu/Debian)
PKG=""
if command -v zypper &> /dev/null; then
    PKG="zypper"
elif command -v apt-get &> /dev/null; then
    PKG="apt"
fi

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

# Link every entry in a group. Resolves src against DOTFILES_DIR so links.sh
# can stay repo-relative.
link_group() {
    local group=$1
    local entries=() entry src dest
    links_for_group "$group" entries
    for entry in "${entries[@]}"; do
        IFS=: read -r _ src dest <<< "$entry"
        link_file "$DOTFILES_DIR/$src" "$dest"
    done
}

# Verify every entry in a group
verify_group() {
    local group=$1
    local entries=() entry dest
    links_for_group "$group" entries
    for entry in "${entries[@]}"; do
        IFS=: read -r _ _ dest <<< "$entry"
        verify_symlink "$dest"
    done
}

# Groups in LINKS order — not GROUP_FLAGS key order (an associative array
# iterates in hash order, which puts broot before core and reshuffles on any key
# insertion) and not sorted. LINKS order reproduces exactly the sequence the
# hand-written link_group calls ran in, which makes this refactor a provable
# no-op on link sequencing rather than an argument that order shouldn't matter.
groups_in_links_order() {
    local -n _out=$1
    _out=()
    local entry group seen=" "
    for entry in "${LINKS[@]}"; do
        group=${entry%%:*}
        [[ $seen == *" $group "* ]] && continue
        seen="$seen$group "
        _out+=("$group")
    done
}

# Link every enabled group. Best-effort like run_install: a disabled group is
# skipped silently, and the explicit `return 0` keeps a trailing disabled group
# from tripping `set -e`.
link_groups() {
    local groups=() group
    groups_in_links_order groups
    for group in "${groups[@]}"; do
        if group_enabled "$group"; then
            link_group "$group"
        fi
    done
    return 0
}

# Verify every enabled group — the same predicate that linked them, so the link
# and verify phases cannot drift apart. That drift is the bug this refactor exists
# to make impossible.
verify_groups() {
    local groups=() group
    groups_in_links_order groups
    for group in "${groups[@]}"; do
        if group_enabled "$group"; then
            verify_group "$group"
        fi
    done
    return 0
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

# Run a command with sudo; on failure print it for manual execution and
# return 1 (callers run via run_install, which records the failure and
# continues — best-effort: user-space tools still install without root).
try_sudo() {
    if sudo "$@"; then
        return 0
    else
        echo "  ! sudo failed. Run manually: sudo $*"
        return 1
    fi
}

# Run an installer function best-effort: a failure is recorded and reported
# in the summary instead of aborting the whole run under set -e.
run_install() {
    local fn=$1
    if "$fn"; then
        return 0
    else
        FAILED_INSTALLS+=("${fn#install_}")
        return 0
    fi
}

# Install a native package (name may differ per distro).
# Usage: pkg_install <zypper-name> [<apt-name>]  (apt-name defaults to zypper-name)
pkg_install() {
    local zname=$1
    local aname=${2:-$1}
    case "$PKG" in
        zypper) try_sudo zypper install -y "$zname" ;;
        apt)    try_sudo apt-get install -y "$aname" ;;
        *)      echo "  ! no supported package manager; install $zname manually"; return 1 ;;
    esac
}

# --- Core tools -------------------------------------------------------------

install_starship() {
    command -v starship &> /dev/null && return 0
    echo "  Installing starship..."
    if [ "$PKG" = "zypper" ]; then
        pkg_install starship
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
}

install_zellij() {
    command -v zellij &> /dev/null && return 0
    echo "  Installing zellij..."
    if [ "$PKG" = "zypper" ]; then
        pkg_install zellij
    else
        curl -sL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz \
            | tar -xz -C /tmp && try_sudo mv /tmp/zellij /usr/local/bin/
    fi
}

install_neovim() {
    command -v nvim &> /dev/null && return 0
    echo "  Installing neovim..."
    if [ "$PKG" = "zypper" ]; then
        pkg_install neovim
    else
        # apt neovim is stale; official tarball to /opt
        local ok=0
        curl -fsLo /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
            && try_sudo tar -C /opt -xzf /tmp/nvim.tar.gz \
            && try_sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
            || ok=1
        rm -f /tmp/nvim.tar.gz
        return "$ok"
    fi
}

install_zoxide() {
    command -v zoxide &> /dev/null && return 0
    echo "  Installing zoxide..."
    if [ "$PKG" = "zypper" ]; then
        pkg_install zoxide
    else
        curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi
}

install_ripgrep() {
    command -v rg &> /dev/null && return 0
    echo "  Installing ripgrep..."
    pkg_install ripgrep   # packaged on both distros
}

install_bat() {
    command -v bat &> /dev/null && return 0
    echo "  Installing bat..."
    pkg_install bat   # packaged on both distros
    # Debian/Ubuntu ship the binary as `batcat`; expose it as `bat`
    if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    fi
}

install_trash_cli() {
    command -v trash &> /dev/null && return 0
    echo "  Installing trash-cli..."
    pkg_install trash-cli   # packaged on both distros
}

install_broot() {
    command -v broot &> /dev/null && return 0
    echo "  Installing broot..."
    if [ "$PKG" = "zypper" ]; then
        pkg_install broot
    else
        # not in Ubuntu repos; prebuilt binary from dystroy.org
        curl -fsLo /tmp/broot https://dystroy.org/broot/download/x86_64-linux/broot
        chmod +x /tmp/broot && try_sudo mv /tmp/broot /usr/local/bin/broot
    fi
}

install_duckdb() {
    command -v duckdb &> /dev/null && return 0
    echo "  Installing duckdb..."
    # not packaged on zypper or apt; official installer puts the binary in
    # ~/.duckdb/cli/<ver> and symlinks it into ~/.local/bin — but only if that
    # dir already exists, so create it first.
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://install.duckdb.org | sh
}

install_ghostty() {
    command -v ghostty &> /dev/null && return 0
    echo "  Installing ghostty..."
    if [ "$PKG" = "zypper" ]; then
        pkg_install ghostty
    else
        echo "  ! ghostty has no official Ubuntu package; see https://ghostty.org/download"
        return 1
    fi
}

# --- Runtimes ---------------------------------------------------------------

install_uv() {
    command -v uv &> /dev/null && return 0
    echo "  Installing uv (Python per-project; no system Python)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_node() {
    command -v node &> /dev/null && return 0
    echo "  Installing node..."
    if [ "$PKG" = "zypper" ]; then
        pkg_install nodejs24
    else
        # apt node is stale; use nvm
        # nvm's installer is tag-only upstream (no 'latest' URL), so this version
        # is forced rather than a policy pin -- bump opportunistically.
        curl -fso- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        # shellcheck source=/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        if command -v nvm &> /dev/null; then
            nvm install --lts
        else
            echo "  ! nvm install failed; install node manually: https://github.com/nvm-sh/nvm"
            return 1
        fi
    fi
}

install_docker() {
    command -v docker &> /dev/null && return 0
    echo "  Installing docker..."
    if [ "$PKG" = "zypper" ]; then
        pkg_install docker && try_sudo zypper install -y docker-compose
        try_sudo systemctl enable --now docker
    else
        curl -fsSL https://get.docker.com | sh
    fi
    try_sudo usermod -aG docker "$USER"
    echo "  ! log out/in (or 'wsl --shutdown') for the docker group to apply"
}

# --- Claude Code (optional, default yes) ------------------------------------

install_claude() {
    command -v claude &> /dev/null && return 0
    echo "  Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    # Playwright chromium for the Playwright MCP server (needs node)
    if command -v npx &> /dev/null; then
        npx playwright install chromium --with-deps || \
            echo "  ! playwright chromium install failed; rerun: npx playwright install chromium --with-deps"
    else
        echo "  ! node/npx not found; after installing node run: npx playwright install chromium --with-deps"
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
        local zip_file="${font_name}.zip"

        curl -fLo "$zip_file" \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"

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
INSTALL_FONTS=false
INSTALL_ZOXIDE=false
INSTALL_RIPGREP=false
INSTALL_BROOT=false
INSTALL_RUNTIMES=false
INSTALL_CLAUDE=false

if prompt_category "Starship prompt" "y"; then
    INSTALL_STARSHIP=true
fi

if prompt_category "Neovim" "y"; then
    INSTALL_NEOVIM=true
fi

if prompt_category "Zellij" "y"; then
    INSTALL_ZELLIJ=true
fi

if prompt_category "zoxide (smarter cd)" "y"; then
    INSTALL_ZOXIDE=true
fi

if prompt_category "CLI extras (ripgrep, broot, bat, trash-cli, duckdb)" "y"; then
    INSTALL_RIPGREP=true
    INSTALL_BROOT=true
fi

if prompt_category "Runtimes (uv, node, docker)" "y"; then
    INSTALL_RUNTIMES=true
fi

if prompt_category "Claude Code (+ playwright)" "y"; then
    INSTALL_CLAUDE=true
fi

if [ "$HEADLESS" = false ]; then
    if prompt_category "Ghostty" "y"; then
        INSTALL_GHOSTTY=true
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
link_group core

# Set git global excludesfile
if [ -f "$HOME/.gitignore_global" ]; then
    git config --global core.excludesfile ~/.gitignore_global
fi

# Starship
if [ "$INSTALL_STARSHIP" = true ]; then
    echo "Installing Starship..."
    run_install install_starship
    link_group starship
fi

# Neovim
if [ "$INSTALL_NEOVIM" = true ]; then
    echo "Installing Neovim..."
    run_install install_neovim
    link_group nvim
fi

# Zellij
if [ "$INSTALL_ZELLIJ" = true ]; then
    echo "Installing Zellij..."
    run_install install_zellij
    link_group zellij
fi

# Ghostty (GUI only)
if [ "$INSTALL_GHOSTTY" = true ]; then
    echo "Installing Ghostty..."
    run_install install_ghostty
    link_group ghostty
fi

# zoxide
if [ "$INSTALL_ZOXIDE" = true ]; then
    echo "Installing zoxide..."
    run_install install_zoxide
fi

# CLI extras
if [ "$INSTALL_RIPGREP" = true ] || [ "$INSTALL_BROOT" = true ]; then
    echo "Installing CLI extras..."
    run_install install_ripgrep
    run_install install_broot
    run_install install_bat
    run_install install_trash_cli
    run_install install_duckdb
    link_group cli-extras
fi

# broot config + br shell function (sourced by .bashrc)
if [ "$INSTALL_BROOT" = true ]; then
    link_group broot
fi

# Runtimes
if [ "$INSTALL_RUNTIMES" = true ]; then
    echo "Installing runtimes..."
    run_install install_uv
    run_install install_node
    run_install install_docker
fi

# Claude Code
if [ "$INSTALL_CLAUDE" = true ]; then
    echo "Installing Claude Code..."
    run_install install_claude
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

verify_groups

echo
echo "Verifying tools..."
# curl installers drop binaries in ~/.local/bin, which may not be on the
# script's PATH yet on a fresh machine
PATH="$HOME/.local/bin:$PATH"
for tool in starship zellij nvim zoxide rg broot bat trash duckdb; do
    if command -v "$tool" &> /dev/null; then
        echo "  + $tool"
    else
        echo "  x $tool (not on PATH — re-run or install manually)"
    fi
done

echo

# ============================================================================
# Summary
# ============================================================================

if [ ${#FAILED_LINKS[@]} -eq 0 ] && [ ${#FAILED_INSTALLS[@]} -eq 0 ]; then
    echo "Dotfiles installed successfully!"
else
    echo "Installation completed with errors:"
    for link in "${FAILED_LINKS[@]}"; do
        echo "  - broken symlink: $link"
    done
    for tool in "${FAILED_INSTALLS[@]}"; do
        echo "  - install failed: $tool"
    done
fi

echo "Restart your terminal or run: source ~/.bashrc"
