# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.19] - 2026-07-29

### Changed
- `.bashrc`: the file-level `# shellcheck disable=SC1090,SC1091` from v0.1.18 is replaced by per-line `# shellcheck source=/dev/null` on the five optional tool init files (aliases, cargo, nvm ×2, `.local/bin/env`) plus broot. The git-completions source (`/usr/share/bash-completion/completions/git`) is a constant, package-owned path and is now left checked, so a path that moves upstream gets reported instead of silently waived. Closes the follow-up left open in v0.1.18's Notes.
- `.pre-commit-config.yaml`: corrected the shellcheck hook's comment. It attributed SC1090/SC1091 suppression to `# shellcheck shell=bash`, which only settles SC2148 — the source notices came from the file-level `disable` this release removes. It also implied `.aliases` needed the same handling; `.aliases` has no `source` statements, so those notices never arise there.

### Fixed
- `.bashrc`: the `.local/bin/env` line tested `"$HOME/.local/bin/env"` but sourced `"$HOME/.local/share/../bin/env"`. Both resolve to the same file, so this is not a behavior change — the guard was never checking a different path than it sourced — but the mismatch read as a typo.

### Notes
- Coverage was verified rather than assumed: pointing the git-completions source at a nonexistent path makes SC1091 fire, confirming the line is genuinely checked and not passing by accident. The pre-commit hook runs `shellcheck -x`, matching how the check was verified.
- Broot's launcher was the one source v0.1.18's Notes did not enumerate (it listed four optional sources; there are five, plus `~/.aliases`). It resolves from `$HOME` like the rest and gets the same per-line directive.
- The two nvm lines still use upstream's `&& \.` pattern verbatim, unchanged for the reason given in v0.1.18: editing them means diverging from what nvm re-appends on reinstall.

## [0.1.18] - 2026-07-29

### Changed
- `.pre-commit-config.yaml`: the shellcheck hook now covers `.bashrc` and `.aliases`. Its `files:` regex had excluded shell *config* since v0.1.15 on the grounds that SC2148 (no shebang) and SC1090 (non-constant source) are inherent to a sourced file. That reasoning was sound but rested on unverified evidence — see Notes. Both files are now clean under the same hook that gates the scripts.
- `.bashrc`, `.aliases`: carry `# shellcheck shell=bash`, matching how `links.sh` and `tests/helpers.sh` already declare themselves as sourced-not-executed.

### Fixed
- `.aliases`: the dircolors line used `test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"`, which is not if-then-else — the fallback `eval` also runs when the first one fails, not only when the file is unreadable. Rewritten as `if/then/else`. Benign in practice (falling back to default colors is the sane outcome either way), but it was a real finding that the hook exclusion had been hiding.

### Notes
- The exclusion's premise was correct; its evidence was not. When it was written, `.bashrc` could not be read in-session — a secrets guard blocks reading shell init files — so only 2 of its 6 findings were ever classified. The other 4 were assumed benign. Linting a file is not reading it, which is what made this resolvable: `shellcheck` produced a verdict on `.bashrc` without its contents entering the session. All 4 turned out to be SC1091 "not following" on optional tool init files (cargo, nvm ×2, `.local/bin/env`), each already guarded by a `-f`/`-s` test and absent by design on a machine without that tool.
- `-S warning` was the tempting cheap fix and does not work: SC2148 is severity *error*, so it survives the filter and `.bashrc` still fails. It would also have dropped info-level checks on `install.sh` and `tests/`, trading existing coverage for new. Two comment lines were the smaller change.
- `disable=SC1091` is file-level on `.bashrc`, which is blunter than ideal — the git-completions source (`/usr/share/bash-completion/completions/git`) is a constant, resolvable path, so a genuine breakage there now goes unreported. Accepted for now; the tighter alternative is per-line `# shellcheck source=/dev/null` on the four optional sources, left for if that path ever changes.
- The two nvm lines use the same `&& \.` pattern rewritten in `.aliases`, and were left alone: they are upstream's installer output verbatim, and editing them means diverging from what nvm re-appends on reinstall.

## [0.1.17] - 2026-07-29

### Added
- `scripts/dev-setup.sh` and `make dev-setup`: installs what working on this repo requires — `shellcheck` (the `language: system` pre-commit hook) and `pre-commit` (`make lint`, `make check-secrets`) — then chains into `make install-hooks`. Closes the gap noted in v0.1.15: a fresh clone hit `Executable shellcheck not found` on its first commit, because `install.sh` installs neither tool and no doc mentioned either. Idempotent; a run on a set-up machine is a no-op.

### Changed
- `CLAUDE.md`: added a **Bootstrap vs Dev Tooling** section. `install.sh` provisions a *machine*; `dev-setup.sh` provisions *this repo's tooling*. Key Principle 3 ("minimal dependencies") is now scoped to `install.sh`, since as written it was the exact sentence that would veto a dev-time dependency.
- `.claude-toolkit-ignore`: un-ignores `.claude/rules/workflow/backlog.md` so `claude-sync` pulls it. Its absence was the whole of the `backlog-notes-rule-missing` task, now removed from the backlog.

### Notes
- The boundary is the point; `dev-setup.sh` is just the thing that makes it concrete. The missing distinction had already produced one bad argument: bats-core was rejected for the test harness because "this repo bootstraps a bare machine, so its tests must run on a bare one" — wrong, since tests run on an already-provisioned dev machine. That constraint binds `install.sh` alone. This release does not exercise the freedom it restores: the plain-bash harness stays.
- The two scripts duplicate `try_sudo`, `pkg_install`, and their prompt rather than sharing a `lib/`. Deliberate — they are separate use cases and neither should break when the other changes, at a cost of ~25 duplicated lines. `install.sh` is untouched by this release, which is the test that the boundary holds.
- `pre-commit` installs via `uv tool install`, keeping the repo's no-system-Python stance, so `uv` is a hard dependency and `dev-setup` prompts for it when missing. `prompt_yn` assumes the default when stdin is not a TTY, so the script cannot hang unattended.
- `README.md` deliberately says nothing about any of this — it stays a machine-setup doc, and its "only `git` and `curl` up front" line remains correct for that audience. No `CONTRIBUTING.md`: one person works on this repo, so the principle lives in `CLAUDE.md` where future decisions actually read it.
- The apt path (`shellcheck` lowercase, vs `ShellCheck` on zypper) is unverified — no Ubuntu machine here. First Ubuntu run is the real test.

## [0.1.16] - 2026-07-29

### Changed
- `install.sh`: Nerd Fonts now fetches `releases/latest/download/` rather than the pinned `v3.2.1`, dropping the hand-maintained "check releases" comment that was the pin's only upkeep mechanism. The fonts are gated on an `fc-list` check, so machines with 3.2.1 already installed do not re-fetch — this affects fresh installs only.
- `CLAUDE.md`: added a **Tool Versions** section stating the default (track latest) and the three criteria that justify an exception, so each newly added tool no longer re-opens the question ad hoc.

### Notes
- Policy is *track latest; pin only for a stated reason, recorded inline as `# pinned: <reason>`*. The criteria: the artifact is content the configs reference by version (glyph codepoints, schemas, themes) rather than a self-updating program; an upstream release broke a real install here; or there is no self-update path and a known-bad release is in circulation. A version with no reason is not a pin.
- The distinction that made the policy tractable is *forced* versus *policy* pin. `curl | sh` installers cannot be pinned without vendoring the script, and `releases/latest/download/...` is fully under our control — so the question "pin or track" only genuinely applies to the fetches we own. nvm sits in a third category: its installer is tag-only upstream with no `latest` URL, so `v0.40.1` is forced rather than chosen, and now says so inline to survive the next version audit.
- Both pre-existing pins failed all three criteria on inspection. Nerd Fonts was simply the version current when fonts were added; nvm's was copied from upstream's README snippet, and is the weaker pin regardless since node itself installs via `nvm install --lts`. Net result is zero policy pins in the tree, which is why no `TOOL_VERSIONS` registry was introduced — a single forced version does not need one.

## [0.1.15] - 2026-07-28

### Added
- `tests/`: a runnable harness for the scripts that provision `$HOME`. 28 assertions across three suites, run by `make test`. Previously the target printed "Testing would go here (manual verification recommended)" and syntax-checked `install.sh` only — the v0.1.14 symlink refactor was verified by scratch-`HOME` scripts that were written ad hoc and thrown away.
  - `tests/test_links.sh` enforces what `links.sh` had only documented: no stray colon in any path (the `IFS=:` split truncates silently), every `src` exists, no duplicate `dest`, every `dest` under `$HOME`, and the nameref contract of `links_for_group`.
  - `tests/test_install.sh` asserts the produced link set equals `LINKS` exactly in both directions, every link resolves into the repo, and the repo's tracked `.gitconfig` is untouched by a run.
  - `tests/test_uninstall.sh` covers the four behaviors v0.1.14 introduced: total removal, a foreign link at a managed path skipped rather than deleted, a **dangling** link into the repo removed, and idempotence.
- `.pre-commit-config.yaml`: a shellcheck hook. It uses the system binary via `repo: local` rather than `koalaman/shellcheck-precommit`, which ships only a `docker_image` hook that cannot read the working tree under rootless Docker. Scoped to the executable scripts — shell *config* (`.bashrc`, `.aliases`) is sourced into an interactive shell rather than run, so SC2148 and SC1090 describe what those files are, not defects.

### Fixed
- `scripts/extract-claude-configs.sh`: `${file#$src_dir/}` left `$src_dir` unquoted inside the expansion, so it was treated as a glob pattern — a path containing `[`, `*`, or `?` would strip the wrong prefix. Surfaced by the new shellcheck hook (SC2295).

### Changed
- `Makefile`: `test` now syntax-checks all three scripts and runs every `tests/test_*.sh`, propagating a failing suite instead of swallowing it.
- `Makefile`, `uninstall.sh`: emoji removed from status output, matching `install.sh`, which never used any.

### Notes
- Test isolation rests on three mechanisms, each load-bearing. PATH stubs make the 15 `install_*` functions early-return on their `command -v` guard, so a run touches neither the network nor `sudo`. `GIT_CONFIG_GLOBAL` is required because `install.sh` runs `git config --global` and the real `~/.gitconfig` is a symlink into this repo — redirecting `HOME` alone is not enough, git follows the symlink and writes *through* it into the tracked file. Clearing `DISPLAY`/`WAYLAND_DISPLAY` forces headless, fixing the prompt count at 7 so the same input means the same thing on a GUI box and a headless one.
- The harness answers `install.sh`'s prompts positionally, and that stream cannot self-detect a mismatch: on EOF `read` returns non-zero but leaves `REPLY` empty, and `prompt_category` treats empty as *yes*. A prompt added to `install.sh` would have been answered yes silently while the suite still passed. `test_install.sh` now pins the accepted categories so that fails loudly instead.
- Backlog: added `dev-tooling-vs-bootstrap` (P3). `make lint` now hard-requires shellcheck, which `install.sh` does not install, so a fresh contributor hits "Executable shellcheck not found" on their first commit. Provisioning a new machine and developing this repo are different requirements and should be separated.

## [0.1.14] - 2026-07-28

### Fixed
- `uninstall.sh`: removed only 9 of the 13 symlinks `install.sh` created, leaving `~/.config/zellij/layouts/project.kdl`, `~/.config/broot/conf.hjson`, `~/.config/broot/launcher/bash/br`, and `~/.config/broot/launcher/installed-v4` dangling into a repo the user may then delete. `br` is sourced by `.bashrc`, so that one kept a removed tool wired into the shell rather than sitting inert. All 14 managed links are now removable.
- `uninstall.sh`: `DOTFILES_DIR` was hardcoded to `$HOME/dotfiles` — wrong for any checkout elsewhere. It was dead code before, but the new removal guard depends on it, so it now comes from `links.sh`. The closing message carried the same wrong path and now reports the real one.
- `install.sh`: `.duckdbrc` was verified under `INSTALL_RIPGREP` alone while being linked under `INSTALL_RIPGREP || INSTALL_BROOT`, so declining ripgrep but accepting broot linked the file and then reported it missing. Both now use the same condition.
- `install.sh`: `~/.config/broot/launcher/installed-v4` was linked but never verified — it had reached neither the verify list nor the uninstall list.

### Changed
- `links.sh` (new) is the single source of truth for every symlink. `install.sh` and `uninstall.sh` both source it and loop over `LINKS`; the three hand-maintained lists (link call-sites, verify call-sites, removal blocks) are gone. Adding a config to an existing group is now one line in one file. The three-list structure is what produced the gaps above — `installed-v4` had slipped out of two of them.
- `uninstall.sh`: removal is target-checked. A symlink at a managed path pointing outside the repo is the user's own, so it is skipped and reported rather than deleted. The guard tests the raw `readlink` target, not a resolved one, so a link dangling into a deleted repo is still cleaned up — that being the case this fix exists for. `rm` is never `-r`/`-f`: `~/.config/nvim` is a symlink to a directory.
- `uninstall.sh`: refuses to run as root, mirroring `install.sh`. Under `sudo`, `$HOME` is `/root`, every managed path misses, and the script would report success having removed nothing.

### Notes
- `links.sh` derives `DOTFILES_DIR` unconditionally rather than defaulting it, because that value decides what `uninstall.sh` may delete — an inherited environment variable must not be able to redirect it.
- Two constraints now documented in `links.sh`: no path may contain a `:` (callers split on it), and a caller's array must not be named `out` (bash rejects a self-referencing nameref). Neither is reachable today.
- Backlog: added `links-new-category-flow` (P3) and `install-script-testing` (P2), both split out of this work.

## [0.1.13] - 2026-07-28

### Added
- `install.sh`: `install_duckdb` joins the CLI extras group (prompt now reads "ripgrep, broot, bat, trash-cli, duckdb"). duckdb isn't packaged on zypper or apt, so the official installer is used unconditionally. It only symlinks into `~/.local/bin` when that directory already exists, so the function creates it first — without that, a fresh machine installs duckdb but never puts it on `PATH`.
- `.duckdbrc`, symlinked to `~/.duckdbrc`, applying to `duckdb -c` as well as the REPL: `.startup_text none` (no banner), `.maxrows 20`, `.thousand_sep ,`, `.nullvalue NULL` so a real NULL is distinguishable from an empty string, and `.timer on`. `.startup_text none` must be the literal first line — anything before it, comments included, triggers a "should be on top" warning on every run. Dot-commands take the rest of the line as their argument, so comments sit on their own lines rather than trailing.
- `docs/DUCKDB-REFERENCE.md`: `SUMMARIZE` as the opening move on an unfamiliar file, bare-path reads and globs for csv/tsv/ndjson/parquet, the `read_xlsx()` `header=false` default that yields columns named `A1`/`B1`, the Excel write path, and the `-no-init` escape hatch (there is no `-norc`).
- `uninstall.sh`: removes the `~/.duckdbrc` symlink.

### Fixed
- `Makefile`: `check-secrets` ran `pre-commit run detect-secrets`, but no such hook is configured — the target failed with "No hook with id 'detect-secrets'". It now runs `gitleaks`, which is what `.pre-commit-config.yaml` actually declares. `.PHONY` also gained the missing `install-hooks` and `backup` targets.

### Notes
- Excel writes need the `excel` extension, but `.duckdbrc` ships the `INSTALL excel; LOAD excel;` pair **commented out** — writing xlsx isn't a primary use, and loading it on every invocation isn't worth the cost. Both lines are needed if enabled: `autoinstall_known_extensions` fires on *autoload*, not on an explicit `LOAD`, so a bare `LOAD excel;` exits 1 on a machine that hasn't cached the extension — and a failed init line aborts the whole file, which would break every duckdb invocation rather than just the Excel ones.
- Backlog: added `uninstall-symlink-gaps` (P2) and `tool-version-pinning-policy` (P2), both surfaced by duckdb-setup research and deliberately kept out of its scope.

## [0.1.12] - 2026-07-28

### Added
- `.bashrc`: `AWS_VAULT_BACKEND=file`, so `aws-vault` stores credentials in its own encrypted file (`~/.awsvault/keys/`) instead of the KWallet-backed Secret Service default. KWallet's provider is global — pointing it at a project-specific wallet would make that wallet the catch-all for every app on the system, so the file backend is what actually gives per-use isolation. Without the export set, `aws-vault` silently falls back to KWallet and reports stored credentials as missing.

### Changed
- Backlog: `s3drive-eval` removed — S3Drive was evaluated and rejected (multi-file download is paywalled, and it wanted long-lived AWS credentials in a freemium client). The "S3/cloud storage GUI" slot it was filling resolved to "no GUI needed": `rclone mount --vfs-cache-mode full` exposes the bucket as a directory and `duckdb` reads parquet straight off it.
- Backlog: `new-machine-tools` widened from GUI/desktop tools to cover CLI tools as well, with the S3 outcome and install gotchas recorded (`aws-vault` isn't packaged for openSUSE; `rclone` remotes want `env_auth = true` so they read from `aws-vault` rather than storing their own copy).
- Backlog: added `duckdb-setup` (P1), `bitwarden-cli-setup` (P1), and `bitwarden-programmatic` (P2).

## [0.1.11] - 2026-07-28

### Added
- `.gitconfig`: multi-account routing by directory tree. `includeIf` stanzas point `~/projects/work/raiz/` and `~/projects/work/blumar/` at untracked identity files (`~/.gitconfig-raiz`, `~/.gitconfig-blumar`) carrying the per-account name, email, and `useConfigOnly = true`; each rewrites remotes to its own SSH host alias so the right key pushes. Personal repos rewrite `git@github.com:` to `git@github-hata:`. Auth and authorship are pinned separately because they fail independently.
- `docs/gitconfig-conditional-includes.md` rewritten from a generic `includeIf` note into the actual three-account setup: key generation and upload, the `~/.ssh/config` host aliases (`IdentitiesOnly yes` is load-bearing), identity files, per-account verification, and the gotchas — `includeIf` can't apply during `clone`, and repos outside the mapped trees fall back to the personal identity silently.

### Changed
- `.gitconfig`: credential helpers call `gh` from `PATH` instead of a hardcoded `/usr/bin/gh`, which broke on machines where gh installs elsewhere (homebrew, nix).

## [0.1.10] - 2026-07-28

### Added
- Neovim: treesitter-based folding for JSON and markdown. `zc`/`zo`/`za` collapse a JSON object/array from its key line or a markdown section from its heading (nested headings fold with it); clicking the `+`/`-` in the fold column toggles the same folds. Folds start open (`foldlevel=99`) and the `json` parser joins the ensure-installed list.

### Changed
- Neo-tree sidebar narrowed from 35 to 30 columns.

## [0.1.9] - 2026-07-27

### Fixed
- `.gitconfig`: `core.excludesfile` used a hardcoded `/home/hata/...` path, breaking on machines with a different username. Now `~/.gitignore_global`.

### Security
- `.gitconfig`: dropped `credential.helper = store`, which persists credentials in plaintext to `~/.git-credentials` and took precedence over `cache` for any host without a more specific block. GitHub and gist were already delegating to `gh auth git-credential` and were unaffected; other hosts (GitLab, self-hosted) now fall through to `cache` only.

## [0.1.8] - 2026-07-27

### Added
- Neovim: `nvim-treesitter-context` pins the current section heading (or code scope) at the top of the window while scrolling — up to 3 nested levels.
- Neovim: markdown-local `]]` / `[[` keymaps jump between ATX headings and anchor the heading to the true top line of the view, bypassing `scrolloff`.

## [0.1.7] - 2026-07-23

### Added
- `trash-cli` added to the CLI-extras install category. Packaged under the same name on both openSUSE and Debian/Ubuntu; provides the `trash` command and is included in the install verify loop.

## [0.1.6] - 2026-07-23

### Added
- broot file navigator wired in: the `br` shell function (sourced by `.bashrc`) so quitting can `cd` your shell, a committed `conf.hjson` with custom verbs (`Ctrl-e` edit in nvim, `Ctrl-g` lazygit, `Ctrl-v` bat preview) and git-status-by-default, and an `installed-v4` marker so broot never prompts to self-install. All symlinked by `install.sh`. See `docs/BROOT-REFERENCE.md`.
- `bat` added to the CLI-extras install category (with a `batcat`→`bat` shim for Debian/Ubuntu, where the package ships under the other name).
- Neovim telescope pickers beyond find-files/live-grep: buffers, help tags, resume, recent files, keymaps, document symbols, diagnostics, and LSP references (`gr`). All grouped under the `<leader>f` "find" prefix.
- `docs/NVIM-REFERENCE.md` and `docs/ZELLIJ-REFERENCE.md` — keybind/usage refreshers, linked from the README's Editor and Multiplexer entries.

### Fixed
- Neo-tree no longer fills the screen when the last buffer closes (`close_if_last_window`), and `<leader>bd` now deletes the buffer without closing its window/split — the sidebar layout stays intact.
- Telescope now tracks `master` instead of the pinned `0.1.8` tag, which called the removed `ft_to_lang` and crashed the previewer on the current nvim/treesitter `main` branch.

### Changed
- Telescope find-files rebound from `Ctrl-p` to `<leader>ff` (zellij owns `Ctrl-p` for pane mode).

### Notes
- Backlog: renamed `nvim-lazygit` → "Install lazygit + wire into nvim and broot" (P2). broot's `Ctrl-g` verb already calls lazygit; the task now covers the shared `install_lazygit` prereq for both consumers.
- Backlog: added `telescope-fzf-native` (P3) — consider the C-compiled sorter for faster fuzzy filtering.
- Scope cleanup per `docs/agent/identity.md`: removed out-of-scope files that don't help a fresh machine reach working state — `dotfiles-setup-guide.md` (stray root doc), `docs/analysis`/`docs/plans`/`docs/sessions` (session and planning history), and `templates/pre-commit-config-python.yaml` (belongs in `python-template`). Fixed the dangling `dotfiles-setup-guide.md` link in `docs/BOOTSTRAP.md`, dropped the now-moot `.gitignore` entries, and refreshed the out-of-scope examples in `identity.md`.

## [0.1.5] - 2026-07-23

### Added
- `install.sh` now installs the tool roster, not just symlinks configs. Distro detection (zypper on Tumbleweed, apt on Ubuntu/WSL) drives install-if-missing per category: core CLI (starship, zellij, neovim, zoxide, ripgrep, broot), GUI (ghostty, Nerd Fonts), runtimes (uv, node, docker), and optionally Claude Code (+ playwright chromium). Already-installed tools skip straight to linking (idempotent). A root-guard refuses `sudo ./install.sh` so user-space installs land in `$HOME`; `sudo` is invoked inline only where root is needed, and a failure is recorded and reported rather than aborting the run. rust/go stay doc-only.

### Fixed
- `alias cd='z'` is now guarded behind `command -v zoxide` — without zoxide installed, `cd` no longer breaks on a fresh machine.
- Go env in `.bashrc` (`GOROOT`/`GOPATH`/PATH) guarded behind `/usr/local/go` existence.

### Changed
- Docs realigned with the installed roster: identity's clone-and-run trait names the tiers and the settled roster (stale "Open Tasks" removed); `docs/BOOTSTRAP.md` retitled as Ubuntu/WSL pre-steps and no longer claims install.sh "only symlinks configs"; `docs/DUAL-BOOT-TUMBLEWEED.md` Phase 4 trimmed to prerequisites + `./install.sh`; README documents the roster tiers and install-if-missing behavior.

### Notes
- Bootstrap docs now install `ripgrep`: added to the `apt` base-packages line in `docs/BOOTSTRAP.md` (WSL/Ubuntu) and the `zypper in` dev-tools line in `docs/DUAL-BOOT-TUMBLEWEED.md` (openSUSE, plus `ripgrep-bash-completion`). It was an undocumented dependency — the repo's bash guard enforces `rg` over `grep -r` and nvim's telescope live-grep needs it.

## [0.1.4] - 2026-07-23

### Added
- Buffer tabs in nvim (VS Code style) via `bufferline.nvim` with catppuccin/Monokai highlights: `Tab`/`Shift+Tab` cycle buffers, `Ctrl+1`..`Ctrl+9` jump by position, `<leader>bd` closes and `<leader>bp` pins. The catppuccin highlight lookup is guarded with `pcall` so config survives load-order shifts, and neo-tree gets an offset so tabs don't overlap the sidebar.

### Changed
- neo-tree sidebar toggle moved from `Ctrl+e`/`Ctrl+n` to `<leader>e`, freeing `Ctrl+e` (zellij move) and `Ctrl+n` (zellij resize) from collision. `Alt+e` was considered but rejected — Alt-as-modifier is unreliable across terminals.

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
