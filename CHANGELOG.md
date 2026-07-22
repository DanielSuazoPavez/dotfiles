# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Notes
- Added project identity doc (`docs/agent/identity.md`): bootstrap kit for fresh Linux/WSL machines — clone-and-run, symlinks, idempotent; scope boundaries and decision filter
- Migrated backlog to `BACKLOG.json` (claude-toolkit managed); `BACKLOG.md` is now auto-rendered and gitignored
- Backlog seeded with identity-driven tasks: settle tool roster, implement tool installation in `install.sh`, cut out-of-scope files

## [0.1.0] - 2026-07-22

Initial versioned release. Capabilities to date:

### Added
- `install.sh` interactive installer with headless detection, category prompts (Starship, Neovim, Zellij, Ghostty, VS Code, Fonts), and symlink verification
- Shell config (bash, aliases, functions), git config, Starship prompt, Ghostty, Zellij, Neovim, VS Code settings
- `.claude-toolkit-ignore` declaring toolkit-synced rules not applicable to this repo

### Changed
- `.claude/` is now managed by claude-toolkit sync; repo tracks only `settings.json` and `mcp.json` (removed locally-maintained hooks/skills superseded by the toolkit)
- Removed non-applicable synced rules (python-conventions, backlog, lessons-policy, env-vars, permissions-config, settings-reload, execution, claude-md-standard, artifacts-gitignored)
- Zellij config overhaul; simplified `zja` alias; dropped `claude-sync` alias
- Restructured `BACKLOG.md` to priority-based format
