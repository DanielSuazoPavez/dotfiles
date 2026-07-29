#!/bin/bash
# Dev tooling for working on this repo (NOT machine bootstrap).
#
# install.sh provisions a machine. This script installs what this repo's own
# lint and commit hooks need. The two are deliberately separate entrypoints
# and share no code — see "Bootstrap vs Dev Tooling" in CLAUDE.md.
#
# Installs: shellcheck (pre-commit's local hook), pre-commit (make lint).
# Idempotent: re-running when both are present is a no-op.

set -euo pipefail

# curl installers and `uv tool install` drop shims in ~/.local/bin, which may
# not be on this script's PATH yet. Prepend before any command -v check.
PATH="$HOME/.local/bin:$PATH"

FAILED=()

# Package manager detection (Tumbleweed vs Ubuntu/Debian).
PKG=""
if command -v zypper &> /dev/null; then
    PKG="zypper"
elif command -v apt-get &> /dev/null; then
    PKG="apt"
fi

# ============================================================================
# Helpers
#
# Deliberately duplicated from install.sh rather than sourced. dev-setup and
# install.sh are separate use cases; neither should break when the other
# changes. Keep the duplication small enough that this stays true.
# ============================================================================

# Yes/no prompt, default yes. Non-interactive (no TTY) assumes the default
# instead of blocking on read.
prompt_yn() {
    local msg=$1
    if [ ! -t 0 ]; then
        echo "$msg [Y/n] y  (non-interactive, assuming yes)"
        return 0
    fi
    read -p "$msg [Y/n] " -n 1 -r
    echo
    [[ -z $REPLY || $REPLY =~ ^[Yy]$ ]]
}

# Run a command with sudo; on failure print it for manual execution and
# return 1 so the caller can record a failure and continue.
try_sudo() {
    if sudo "$@"; then
        return 0
    else
        echo "  ! sudo failed. Run manually: sudo $*"
        return 1
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

# ============================================================================
# Installers
# ============================================================================

# uv is a hard dependency: it is this repo's only sanctioned Python tool path
# (no system Python), so pre-commit cannot be installed without it.
ensure_uv() {
    command -v uv &> /dev/null && return 0
    echo "  uv is required to install pre-commit (this repo uses no system Python)."
    if prompt_yn "  Install uv now?"; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        PATH="$HOME/.local/bin:$PATH"
        command -v uv &> /dev/null
    else
        echo "  ! skipped. Install it yourself, then re-run:"
        echo "      curl -LsSf https://astral.sh/uv/install.sh | sh"
        return 1
    fi
}

# The shellcheck binary must come from the system because the pre-commit hook is
# `language: system` — see the comment in .pre-commit-config.yaml.
# (Comment worded to avoid a leading "# shellcheck", which parses as a directive.)
install_shellcheck() {
    command -v shellcheck &> /dev/null && { echo "  + shellcheck (already installed)"; return 0; }
    echo "  Installing shellcheck..."
    # Package name differs: ShellCheck on zypper, shellcheck on apt.
    pkg_install ShellCheck shellcheck
}

install_pre_commit() {
    command -v pre-commit &> /dev/null && { echo "  + pre-commit (already installed)"; return 0; }
    if ! ensure_uv; then
        echo "  ! cannot install pre-commit without uv"
        return 1
    fi
    echo "  Installing pre-commit..."
    uv tool install pre-commit
    PATH="$HOME/.local/bin:$PATH"
}

# ============================================================================
# Main
# ============================================================================

echo "Setting up dev tooling for this repo..."
echo

if ! install_shellcheck; then
    FAILED+=("shellcheck")
fi

if ! install_pre_commit; then
    FAILED+=("pre-commit")
fi

echo
echo "Verifying tools..."
for tool in shellcheck pre-commit; do
    if command -v "$tool" &> /dev/null; then
        echo "  + $tool"
    else
        echo "  x $tool (not on PATH — re-run or install manually)"
    fi
done

echo
if [ ${#FAILED[@]} -eq 0 ]; then
    echo "Dev tooling ready. Next: make install-hooks"
else
    echo "Dev setup completed with errors:"
    for tool in "${FAILED[@]}"; do
        echo "  - install failed: $tool"
    done
    echo "Fix the above, then re-run: make dev-setup"
    exit 1
fi
