# links.sh — single source of truth for every symlink install.sh creates
# and uninstall.sh removes. Sourced by both; not executable, do not run it.
# To add a config: add one line to LINKS. Nothing else needs editing.

# Resolved from this file's own location so both callers agree no matter
# where the repo is checked out or which cwd they were invoked from.
: "${DOTFILES_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# group:src:dest — src is repo-relative, dest is absolute.
# Groups mirror install.sh's INSTALL_* category flags. The cli-extras/broot
# split is load-bearing: one prompt sets both flags, but install.sh gates the
# two branches separately.
LINKS=(
    "core:.bashrc:$HOME/.bashrc"
    "core:.aliases:$HOME/.aliases"
    "core:.hushlogin:$HOME/.hushlogin"
    "core:.gitconfig:$HOME/.gitconfig"
    "core:.gitignore_global:$HOME/.gitignore_global"
    "starship:.config/starship.toml:$HOME/.config/starship.toml"
    "nvim:.config/nvim:$HOME/.config/nvim"
    "zellij:.config/zellij/config.kdl:$HOME/.config/zellij/config.kdl"
    "zellij:.config/zellij/layouts/project.kdl:$HOME/.config/zellij/layouts/project.kdl"
    "ghostty:.config/ghostty/config:$HOME/.config/ghostty/config"
    "cli-extras:.duckdbrc:$HOME/.duckdbrc"
    "broot:.config/broot/conf.hjson:$HOME/.config/broot/conf.hjson"
    "broot:.config/broot/launcher/bash/br:$HOME/.config/broot/launcher/bash/br"
    "broot:.config/broot/launcher/installed-v4:$HOME/.config/broot/launcher/installed-v4"
)

# links_for_group <group> <out-array-name>
# Populates the caller's array via nameref rather than echoing, so paths
# containing spaces survive.
links_for_group() {
    local group=$1
    local -n out=$2
    out=()
    local entry
    for entry in "${LINKS[@]}"; do
        [[ ${entry%%:*} == "$group" ]] && out+=("$entry")
    done
    return 0
}

# link_src_abs <src> — join a repo-relative src onto DOTFILES_DIR
link_src_abs() {
    echo "$DOTFILES_DIR/$1"
}
