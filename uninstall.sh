#!/bin/bash
# Dotfiles uninstall script

set -e

# Refuse to run as root: under sudo, $HOME resolves to /root, every managed
# path misses, and the script would report success having removed nothing.
if [ "$EUID" -eq 0 ]; then
    echo "Error: do not run as root (no 'sudo ./uninstall.sh')."
    echo "Run as your user; the symlinks live in your \$HOME."
    exit 1
fi

# The symlink list lives in links.sh, which also derives DOTFILES_DIR.
# Sourced by script path so ./uninstall.sh works from any cwd.
# shellcheck source=links.sh
source "$(cd "$(dirname "$0")" && pwd)/links.sh"

SKIPPED=()

echo "Uninstalling dotfiles..."
echo "This will remove all symlinks created by the install script."
read -p "Continue? (y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Remove a managed symlink, but only if it points into this repo — a link at a
# managed path aimed elsewhere belongs to the user, not to us. Checks the raw
# target, not the resolved one: a dangling link into a deleted repo is exactly
# what we are here to clean up.
unlink_dest() {
    local dest=$1
    [ -L "$dest" ] || return 0

    local target
    target=$(readlink "$dest")
    case "$target" in
        "$DOTFILES_DIR"/*) ;;
        *) echo "  ? $dest -> $target (not ours, skipped)"
           SKIPPED+=("$dest")
           return 0 ;;
    esac

    # Plain rm, never -r: ~/.config/nvim is a symlink to a directory, and the
    # -L guard above is what makes removal safe.
    rm "$dest"
    echo "  Removed symlink: $dest"
}

# Unconditional: uninstall cannot know which categories were installed, and
# removing an absent link is already a no-op.
for entry in "${LINKS[@]}"; do
    IFS=: read -r _ _ dest <<< "$entry"
    unlink_dest "$dest"
done

if [ ${#SKIPPED[@]} -gt 0 ]; then
    echo
    echo "Left in place (not created by these dotfiles):"
    for dest in "${SKIPPED[@]}"; do
        echo "  - $dest"
    done
fi

echo ""
echo "Dotfiles uninstalled successfully!"
echo ""
echo "Your backup files (if any) are still in ~/dotfiles-backup-* directories."
echo "The dotfiles repository is still in $DOTFILES_DIR (not deleted)."
echo ""
echo "To restore backups, check: ls -d ~/dotfiles-backup-*"
