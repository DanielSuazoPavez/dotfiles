# ~/.bashrc: executed by bash(1) for non-login shells.
# shellcheck shell=bash  # sourced by interactive shells, no shebang by design
#
# Optional tool init files are marked per-line with 'source=/dev/null': each is
# guarded by a -f/-s test and absent by design on a machine without that tool.
# Sources at constant, package-owned paths are deliberately left checked, so a
# path that moves upstream gets reported instead of silently waived.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ============================================================================
# Shell Options and History
# ============================================================================

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# History length settings
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ============================================================================
# Aliases
# ============================================================================

# Source aliases
if [ -f ~/.aliases ]; then
    # shellcheck source=/dev/null
    . ~/.aliases
fi

# ============================================================================
# Programming Languages & Tools
# ============================================================================

# Rust (cargo)
if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
fi

# Go

if [ -d /usr/local/go ]; then
    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
fi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Update PATH
export PATH=$HOME/.local/bin:$PATH

# ============================================================================
# Shell Enhancements
# ============================================================================

# Starship prompt
if command -v starship &> /dev/null; then
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
    eval "$(starship init bash)"
fi

# zoxide (smarter cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# broot (better tree)
if [ -f "$HOME/.config/broot/launcher/bash/br" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.config/broot/launcher/bash/br"
fi

# git autocompletion
if [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
fi

# Playwright browser path for MCP server
export PLAYWRIGHT_BROWSER_PATH="$HOME/.cache/ms-playwright/chromium-1205/chrome-linux64/chrome"

# shellcheck source=/dev/null
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

export EDITOR=nvim
export VISUAL=nvim

# AWS Vault - use encrypted file backend instead of KWallet
export AWS_VAULT_BACKEND=file
