# Identity

## What This Is

A bootstrap kit for a fresh Linux/WSL machine. Clone, run `./install.sh`, and the machine has my working development environment: shell, git, prompt, terminal, multiplexer, editors. Configs are the payload; scripts exist to place them and to install the tools they configure. Anything that doesn't get a new machine closer to "ready to work" doesn't belong here.

## Core Traits

- **Clone-and-run** — a fresh machine reaches working state from one command. `install.sh` installs the roster: core CLI (starship, zellij, neovim, zoxide, ripgrep, broot), GUI (ghostty, Nerd Fonts), runtimes (uv, node, docker), and optionally Claude Code. rust/go stay doc-only.
- **Symlinks, not copies** — configs live here and link out; editing `~/.bashrc` edits the repo. No generated or templated configs.
- **Idempotent by construction** — re-running `install.sh` after a pull is the update mechanism; there is no separate "update" path.
- **Linux/WSL only** — no macOS branches, no Windows-native paths. Supported package managers: zypper (Tumbleweed) and apt (Ubuntu/WSL); no other OS-detection scaffolding beyond headless/GUI.
- **One tool, one config, one symlink** — adding a tool means: config file in repo, install + symlink lines in `install.sh`, row in README. Nothing more.

## Scope Boundary

**In scope**
- Config files for daily tools (bash, git, starship, ghostty, zellij, nvim, VS Code)
- `install.sh` / `uninstall.sh`, including best-effort tool installation and Nerd Font setup
- README documenting what gets installed and configured
- `docs/agent/identity.md` and repo-serving docs only

**Out of scope**
- Session logs, planning docs, analysis history → delete or move to personal notes (no `docs/plans`, `docs/sessions`, `docs/analysis`, or stray root `.md` files)
- Project scaffolds/templates → `python-template` (no `templates/` dir here)
- Claude skills/agents/hooks → `claude-toolkit` (`.claude/` stays minimal repo config, toolkit-synced)
- macOS/Windows support

## Decision Filter

Before adding anything, it must pass all three:

1. Does a fresh machine need it to reach working state?
2. Is it a config or the mechanism that installs/places one?
3. Does it work on plain Linux/WSL without OS branching?
