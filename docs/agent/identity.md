# Identity

## What This Is

A bootstrap kit for a fresh Linux/WSL machine. Clone, run `./install.sh`, and the machine has my working development environment: shell, git, prompt, terminal, multiplexer, editors. Configs are the payload; scripts exist to place them and to install the tools they configure. Anything that doesn't get a new machine closer to "ready to work" doesn't belong here.

## Core Traits

- **Clone-and-run** — a fresh machine reaches working state from one command. Tool installation (starship, zellij, nvim, fonts, …) is part of the job, not a manual prerequisite list.
- **Symlinks, not copies** — configs live here and link out; editing `~/.bashrc` edits the repo. No generated or templated configs.
- **Idempotent by construction** — re-running `install.sh` after a pull is the update mechanism; there is no separate "update" path.
- **Linux/WSL only** — no macOS branches, no Windows-native paths, no OS-detection scaffolding beyond headless/GUI.
- **One tool, one config, one symlink** — adding a tool means: config file in repo, install + symlink lines in `install.sh`, row in README. Nothing more.

## Scope Boundary

**In scope**
- Config files for daily tools (bash, git, starship, ghostty, zellij, nvim, VS Code)
- `install.sh` / `uninstall.sh`, including best-effort tool installation and Nerd Font setup
- README documenting what gets installed and configured
- `docs/agent/identity.md` and repo-serving docs only

**Out of scope**
- Session logs, planning docs, analysis history → delete or move to personal notes (`docs/plans`, `docs/sessions`, `docs/analysis`, stray root `.md` files)
- Project scaffolds/templates → `python-template` (`templates/pre-commit-config-python.yaml`)
- Claude skills/agents/hooks → `claude-toolkit` (`.claude/` stays minimal repo config, toolkit-synced)
- macOS/Windows support

## Decision Filter

Before adding anything, it must pass all three:

1. Does a fresh machine need it to reach working state?
2. Is it a config or the mechanism that installs/places one?
3. Does it work on plain Linux/WSL without OS branching?

## Open Tasks

- **Settle the tool roster** — decide which tools `install.sh` installs (current candidates: starship, zellij, neovim, zoxide, Nerd Fonts; evaluate what else the daily workflow needs) before implementing tool installation.
