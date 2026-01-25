# ~/.bashrc: executed by bash(1) for non-login shells.

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
    . ~/.aliases
fi

# Zellij
alias zj='zellij'
alias zja='zellij attach --create main'
alias zjl='zellij list-sessions'
alias zj-bmsop='zellij attach --create bmsop -- --layout bmsop'

# Claude toolkit
alias claude-sync="$HOME/projects/personal/claude-toolkit/bin/claude-sync"

# ============================================================================
# Programming Languages & Tools
# ============================================================================

# Rust (cargo)
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# Go
export GOROOT=/usr/local/go
export GOPATH=$HOME/go

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Update PATH
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH

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
    source "$HOME/.config/broot/launcher/bash/br"
fi

# git autocompletion
source /usr/share/bash-completion/completions/git

source ~/.nvm/nvm.sh
nvm use node --silent

# Playwright browser path for MCP server
export PLAYWRIGHT_BROWSER_PATH=/home/hata/.cache/ms-playwright/chromium-1205/chrome-linux64/chrome
