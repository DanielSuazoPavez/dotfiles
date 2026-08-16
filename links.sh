# links.sh — single source of truth for every symlink install.sh creates
# and uninstall.sh removes. Sourced by both; not executable, do not run it.
# To add a config: add one line to LINKS. A brand-new group also needs one
# GROUP_FLAGS entry below, which declares the gating flag as well as naming it —
# install.sh only adds the prompt that sets it true. Nothing outside this file
# needs editing.
# shellcheck shell=bash  # sourced, so it intentionally has no shebang

# Resolved from this file's own location so both callers agree no matter
# where the repo is checked out or which cwd they were invoked from.
# Assigned unconditionally, never defaulted: uninstall.sh's removal guard
# trusts this value to decide what it may delete, so an inherited environment
# variable must not be able to redirect it. Re-sourcing is harmless — the
# derivation is deterministic.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# group:src:dest — src is repo-relative, dest is absolute.
# No path may contain a ':' — callers split on it with IFS=: and a colon in
# src would silently truncate the path rather than fail.
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

# group -> the INSTALL_* flags that gate it, space-separated.
#   ""            always-on, linked on every run (core)
#   "FLAG"        linked when that flag is true
#   "FLAG FLAG"   OR — linked when ANY listed flag is true. cli-extras and broot
#                 are the load-bearing case: one prompt sets both flags, and the
#                 broot group carries the `br` shell function that .bashrc sources.
# Every group in LINKS must appear here and vice versa; tests/test_links.sh
# asserts both directions, so a new group cannot be added to LINKS alone.
#
# Declaring a flag here is enough: sourcing this file defines every flag named
# below as `false` unless the caller already set it, so install.sh must not
# re-declare them — it only needs the prompt that flips one to `true`.
# uninstall.sh inherits the six `false` values harmlessly: it reads LINKS and
# DOTFILES_DIR only, and never calls group_enabled.
declare -A GROUP_FLAGS=(
    [core]=""
    [starship]="INSTALL_STARSHIP"
    [nvim]="INSTALL_NEOVIM"
    [zellij]="INSTALL_ZELLIJ"
    [ghostty]="INSTALL_GHOSTTY"
    [cli-extras]="INSTALL_RIPGREP INSTALL_BROOT"
    [broot]="INSTALL_BROOT"
)

# Declare every flag GROUP_FLAGS names, defaulting to false. This is the single
# declaration site — no other file initializes a link-gating flag.
#
# Assign-if-unset, never unconditional: `declare -g "$f=false"` would reset a flag
# the caller already set to true, so re-sourcing this file after install.sh's
# prompts would silently disable every group.
#
# `printf -v` rather than `declare` on purpose: this file is sourced at file scope
# today, but `declare` inside a function creates a *local* — if this loop is ever
# moved into one, every group silently stops linking. `printf -v` assigns in the
# current scope with no such trap. core's empty spec contributes nothing.
for _lg_group in "${!GROUP_FLAGS[@]}"; do
    # Unquoted on purpose: an OR-spec is space-separated, same as group_enabled.
    for _lg_flag in ${GROUP_FLAGS[$_lg_group]}; do
        printf -v "$_lg_flag" '%s' "${!_lg_flag:-false}"
    done
done
# Prefixed and unset so sourcing leaks no loop variables into the caller.
unset _lg_group _lg_flag

# links_for_group <group> <out-array-name>
# Populates the caller's array via nameref rather than echoing, so paths
# containing spaces survive. The caller's array must not be named 'out' —
# bash rejects a nameref pointing at its own name.
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

# group_enabled <group> — true if <group> should be linked this run.
# Install-side only: uninstall.sh removes every link regardless of flags.
#
# Safe under `set -u` on two axes, both deliberate:
#   [[ -v GROUP_FLAGS[...] ]]  an unregistered group is a miss, not an abort
#   ${!flag:-}                 an undefined flag reads as empty, not an abort
# The second is what lets a caller with no INSTALL_* in scope (tests/test_links.sh,
# and uninstall.sh should it ever call this) use it without aborting.
#
# Fails closed: an unregistered group is never linked. The test-suite integrity
# assertion is what actually catches a missing entry; failing closed here means a
# typo'd group name is inert rather than linking a config on a machine that
# declined it.
#
# Returns non-zero for "disabled", so call it in a condition context only
# (`if group_enabled x; then`). A bare call under install.sh's `set -e` aborts.
group_enabled() {
    local group=$1 spec flag

    [[ -v GROUP_FLAGS[$group] ]] || return 1
    spec=${GROUP_FLAGS[$group]}

    # Empty spec = always-on.
    [[ -z $spec ]] && return 0

    # OR across the listed flags. $spec is unquoted on purpose: split on spaces.
    for flag in $spec; do
        [[ ${!flag:-} == true ]] && return 0
    done
    return 1
}

# link_src_abs <src> — join a repo-relative src onto DOTFILES_DIR
link_src_abs() {
    echo "$DOTFILES_DIR/$1"
}
