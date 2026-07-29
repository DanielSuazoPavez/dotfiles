# CLAUDE.md

## Project Overview

Portable dotfiles for setting up a new machine with my preferred development environment. Clone, run install, done. Character and boundaries: `docs/agent/identity.md`.

## Quick Start

```bash
./install.sh              # Symlink configs to home directory
make install              # Alternative
```

## Key Principles

1. **Idempotent**: Running install.sh multiple times is safe
2. **Portable**: Should work on any Linux/WSL machine
3. **Minimal dependencies**: Avoid requiring tools that aren't commonly available
   (applies to `install.sh`; repo tooling is separate — see Bootstrap vs Dev Tooling)
4. **Symlinks over copies**: Changes here reflect immediately

## What's Configured

- Shell (bash, aliases, functions)
- Git (config, ignore, commit template)
- Prompt (Starship)
- Terminal (Ghostty)
- Multiplexer (Zellij)
- Editor (Neovim)

## Structure

```
dotfiles/
├── .bashrc, .aliases      # Shell config
├── .config/               # XDG configs (starship, ghostty, zellij, nvim)
├── scripts/               # Utility scripts
├── install.sh             # Main installer
└── .claude/               # Claude Code config for this repo
```

## When Adding New Configs

1. Add the config file to this repo
2. Add one `group:src:dest` line to `LINKS` in `links.sh` — that single line covers linking, verification, and uninstall. Do not add `link_file` calls to `install.sh`.
3. Document in README if it's a new tool

## Tool Versions

**Track latest by default.** New tools fetch whatever upstream ships now — unpinned
installer, `releases/latest/download/...`, or the distro package.

Pin only when one of these holds, and record it inline as `# pinned: <reason>`:

1. The artifact is content the configs reference by version (glyph codepoints, schemas, themes) — not a program that updates itself
2. An upstream release broke a real install here (date the comment, say what broke)
3. No self-update path *and* a known-bad release is in circulation

A version with no reason is not a pin. Where upstream offers no `latest` URL the version
is *forced*, not a policy pin — say so in the comment (see nvm in `install.sh`).

## Bootstrap vs Dev Tooling

`install.sh` provisions a **machine**. `scripts/dev-setup.sh` (`make dev-setup`)
installs what working on **this repo** needs. Separate entrypoints, no shared code.

```bash
make dev-setup   # shellcheck, pre-commit, git hooks
```

`shellcheck` is required by the `language: system` hook in
`.pre-commit-config.yaml`; `pre-commit` backs `make lint` and `make check-secrets`.
`pre-commit` installs via `uv tool install` (no system Python), so `uv` is a hard
dependency — `dev-setup` prompts to install it if missing. The script is idempotent;
re-running on a set-up machine is a no-op.

Consequences, in order of how often they bite:

1. **Do not add repo tooling to `install.sh`.** `shellcheck` and `pre-commit`
   belong in `dev-setup.sh`. Same for any future linter, formatter, or test runner.
2. **Dev-time dependencies are acceptable.** Lint and tests run on an
   already-provisioned machine. "This repo bootstraps a bare machine, so its
   tooling must run on a bare one" is not a valid argument against a tool — it
   constrains `install.sh` only.
3. **The two scripts duplicate helpers on purpose** (`try_sudo`, `pkg_install`,
   the prompt). Do not factor them into a shared file; the independence is the
   point.

Note `make test` does not run shellcheck — lint is a commit-time gate, not a
test-time one.

## Backlog

- Managed via `claude-toolkit backlog` — do not hand-edit the rendered file.
- `BACKLOG.json` is the committed source of truth; `BACKLOG.md` is generated from it.
- Read a single task: `claude-toolkit backlog task <id>` (add `--json` for the raw record).

## Related Repos

- [claude-toolkit](https://github.com/DanielSuazoPavez/claude-toolkit) - Claude Code skills/agents (sync with `claude-sync`)
- [python-template](https://github.com/DanielSuazoPavez/python-template) - Python project scaffold
