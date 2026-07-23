# Broot Reference

A refresher for this dotfiles broot setup. Config: `.config/broot/conf.hjson`.
The `br` shell function lives at `.config/broot/launcher/bash/br` and is sourced
by `.bashrc` — **use `br`, not `broot`**, so quitting can change your shell's
directory.

> broot is a tree-based file navigator: open one live tree, fuzzy-type to
> filter it, and jump to whatever you want. Its killer feature is `cd`-ing
> your shell into a directory buried deep in the tree.

## Why `br` and not `broot`

A subprocess can't change its parent shell's directory. `br` runs broot,
captures the command it emits on quit (e.g. a `cd`), and `eval`s it in your
shell. Plain `broot` navigates fine but can't move you.

## Core keys

| Key | Action |
|---|---|
| *just type* | Fuzzy-filter the tree |
| `↑` / `↓` | Move selection |
| `Enter` | Dir: go into it · File: open it |
| `Alt Enter` | **cd there and quit** — the main event |
| `Esc` | Clear the search filter |
| `:` | Command mode (type a verb) |
| `?` | Browsable help / full verb + key list |
| `Ctrl →` / `Ctrl ←` | Expand / collapse |
| `Ctrl q` | Quit |

## Command mode (`:`)

Press `:`, type a verb (fuzzy-matched), `Enter` — it acts on the selection.
Typing normally filters; `:verb` *does something*.

| Verb | Action |
|---|---|
| `:cd` | cd to selected dir and quit (= `Alt Enter`) |
| `:rm` `:mv` `:cp` | Delete / move-rename / copy selection |
| `:mkdir name` | Make a directory (verbs can take arguments) |
| `:pt` | Print the tree on quit |
| `:h` | Toggle hidden files |
| `:s` | Toggle sizes column |
| `:toggle_git_ignore` | Respect / ignore `.gitignore` |
| `:sort_by_size` / `:sort_by_date` | Re-sort the tree |
| `:total_search` | Force a full deep search |

## Custom verbs (this config)

Defined in `conf.hjson`, each stays in broot after running:

| Key | Verb | Action |
|---|---|---|
| `Ctrl e` | `:edit` | Open selection in `nvim` |
| `Ctrl g` | `:git` | Open `lazygit` in the selected directory |
| `Ctrl v` | `:view` | Preview selection with `bat` (paging) |

Path placeholders available to verbs: `{file}`, `{directory}`, `{parent}`.

## Useful launch flags

| Command | Does |
|---|---|
| `br` | Normal navigate (git status shown — `default_flags: "g"`) |
| `br -s` | Show sizes, sort by size (find space hogs) |
| `br -h` | Show hidden files |
| `br -w` | Whale-spotting: dedicated disk-usage view |
| `br /` or `br -w /` | Find what's filling the disk |

## Notes / policy

- **`default_flags: "g"`** — git status is shown on every launch. Add `h` to
  that string in `conf.hjson` to show hidden files by default.
- **`respect_git_ignore: true`** — ignored files hidden; toggle with
  `:toggle_git_ignore`.
- The `git`/`view` verbs depend on `lazygit` and `bat`. `bat` is installed by
  the CLI-extras category; `lazygit` is not yet (backlog) — those verbs error
  harmlessly if the tool is missing.
- `installed-v4` marker is committed and symlinked so broot never prompts to
  self-install on a fresh machine.
