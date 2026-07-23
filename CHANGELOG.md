# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.3] - 2026-07-23

### Fixed
- `proj` never created a new session — `zellij --layout X --session NAME` errors "session not found" when NAME doesn't exist instead of creating it. Now uses `zellij --layout project attach "$name" -c` (create-or-attach). Pre-existing bug from 0.1.1, exposed while testing the create path.

### Added
- Floating "scratch" terminal in the project layout — a quick shell toggled with `Alt+f` over the nvim+Claude panes, persists across toggles
- `projtab` shell function: opens the current repo as a project *tab* in the running zellij session (focus-if-exists), and defers to `proj` when outside zellij — giving a two-scope model (`proj` = session per project, `projtab` = tab in the current session)
- Project launch opens `BACKLOG.md` with the neo-tree sidebar when the repo has one, else opens the directory (shared by `proj` and `projtab`)
- `Alt+1`..`Alt+9` jump directly to tabs without entering tab mode
- `scripts/check-keybind-collisions.py`: reports chords bound in both ghostty and zellij (normalizes modifier spelling), separating global from mode-local collisions

### Changed
- zellij mode entry aligned to the `Ctrl+*` convention: lock on `Ctrl+g` (symmetric with the `Ctrl+g` that exits lock), move on `Ctrl+e` — reverses the `Alt+m` move binding from 0.1.2
- Project layout panes named (`nvim`, `claude-code`, `scratch`) and `pane_frames` re-enabled so the focused pane and names are visible — reverses the `pane_frames` disable from 0.1.2
- Project layout restructured with a `default_tab_template` so tabs created via `new-tab` keep their tab-bar/status-bar (without it, `projtab` tabs rendered bare)

### Notes
- Keybind policy recorded: zellij (and what runs inside it) owns keybinds; ghostty stays out of the way, and on friction the ghostty binding is removed (`shift+enter` kept). Backlog `keybind-mnemonics` (P2) added to later normalize the *meaning* of mnemonic letters across tools
- Known: `projtab` has occasionally duplicated a tab instead of focusing the existing one; cause not pinned down, left as-is (a stray tab is cheap to close)

## [0.1.2] - 2026-07-23

### Fixed
- lualine theme set to `catppuccin-mocha` (the bare `catppuccin` theme does not exist, only flavor-specific ones) and declares catppuccin as a dependency so load order is correct
- treesitter migrated to the `main` branch for Neovim 0.12 compatibility — the pinned `v0.9.2` tag threw `attempt to call method 'range'` on 0.12; highlight/indent now enabled via a `FileType` autocmd

### Changed
- Dropped the `sqls` SQL LSP from `mason-lspconfig` and lsp-config (it requires a Go toolchain, which isn't installed, so Mason failed to build it)
- treesitter manages `bash` in addition to `lua`/`python`/`markdown`; removed the orphan `diff` parser that broke `:TSUpdate`
- neo-tree sidebar toggle bound to `Ctrl+e` with width 35
- zellij move-mode moved off `Ctrl+h` to `Alt+m` so `Ctrl+h/j/k/l` reach Neovim splits; `pane_frames` disabled

### Removed
- Stale `.claude-sync-ignore` (referenced a non-existent `skills/wrap-up/` path)

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
