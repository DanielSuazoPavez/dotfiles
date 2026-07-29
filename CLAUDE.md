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

## Backlog

- Managed via `claude-toolkit backlog` — do not hand-edit the rendered file.
- `BACKLOG.json` is the committed source of truth; `BACKLOG.md` is generated from it.
- Read a single task: `claude-toolkit backlog task <id>` (add `--json` for the raw record).

## Related Repos

- [claude-toolkit](https://github.com/DanielSuazoPavez/claude-toolkit) - Claude Code skills/agents (sync with `claude-sync`)
- [python-template](https://github.com/DanielSuazoPavez/python-template) - Python project scaffold
