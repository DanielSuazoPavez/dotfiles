# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Notes
- Added `docs/BOOTSTRAP.md` §6 keyboard-layout guidance: use `us(altgr-intl)` on native desktops so `'`/`"` type instantly (no dead keys) while Spanish accents stay on AltGr; `setxkbmap` test + `localectl` persist commands

## [0.1.1] - 2026-07-22

### Added
- Neovim buildout: nvim-cmp + LuaSnip completion, gitsigns, nvim-autopairs, which-key, undotree, LSP format-on-save, and `autoread` + `checktime` so Claude Code's edits in the adjacent pane reload live
- Per-project workflow: `.config/zellij/layouts/project.kdl` (nvim 2/3, Claude Code 1/3) and a `proj` shell function that creates or attaches a zellij session named after the current directory
- `EDITOR`/`VISUAL=nvim` and a guarded uv env source in `.bashrc`; uv added to the README tool table

### Changed
- Ghostty `window-theme=ghostty` so window chrome follows the dark terminal background
- `mason-lspconfig` `ensure_installed` now matches the enabled LSPs (added basedpyright, ruff, sqls)

### Removed
- VS Code entirely: install/uninstall prompts, symlink logic, and `.config/Code/` — Neovim is now the sole editor
- Stale root doc `20260107_neovim_status.md` (its recommendations are now implemented)

### Notes
- Added `docs/BOOTSTRAP.md`: fresh-machine pre-steps (WSL setup, base packages, GitHub auth, tool installs incl. Docker+Compose, Claude Code, Playwright chromium, WSL font caveat); linked from README prerequisites
- Added `docs/DUAL-BOOT-TUMBLEWEED.md`: dual-boot guide for this PC (disk facts, cleanup phase, install walkthrough, NVIDIA/MOK, snapper escape hatches, Fedora fallback); shrink moved to installer-side after Disk Management hit NTFS-metadata cap
- Backlog: distro decision recorded (Tumbleweed first, Fedora fallback; Debian testing / Arch ruled out); disk-cleanup task completed and removed (C: 15→127 GB free via docker prune + vhdx compaction + fstrim)
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
