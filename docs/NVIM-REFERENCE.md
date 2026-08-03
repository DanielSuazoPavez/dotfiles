# Neovim Reference

A refresher for this dotfiles Neovim setup. `<leader>` = `Space`.
Config lives in `.config/nvim/` (`vim-options.lua` + `lua/plugins/*.lua`),
managed by [lazy.nvim](https://github.com/folke/lazy.nvim).

> Tip: forget a binding? Press `<leader>` (or any prefix like `<leader>f`) and
> **pause** — which-key pops up the full list. `<leader>?` shows every keymap,
> `<leader>fk` searches them by description.

Still learning the setup? `docs/nvim-learning.md` has the active rotation,
in-picker keys, and drills. `scripts/check-keymap-docs.py` verifies this file
still matches what the config binds.

## Discovery — which-key

Press a prefix and pause; which-key lists what can follow it. Group labels are
set for `<leader>f` (find), `h` (git hunk), `b` (buffer), `y` (yank path) and
`c` (code). Built-in presets are on too, so `g`, `z`, `"` and `'` list their
options — that covers vim itself, not just this config.

| Key | Action |
|---|---|
| `<leader>?` | Popup of every keymap, grouped |

Buffer-local keys (LSP, gitsigns) only appear where their plugin has attached —
from the neo-tree sidebar or an empty buffer they're genuinely absent.

## Finding things — Telescope

Fuzzy pickers. Inside any picker: type to filter · `Ctrl-j`/`Ctrl-k` or arrows
to move · `Enter` open · `Ctrl-x` horizontal split · `Ctrl-v` vertical split ·
`Ctrl-y` new tab · `Ctrl-a` send all results to quickfix · `Esc`/`Ctrl-c` close.
`Ctrl-/` lists every key for the current picker.

| Key | Action |
|---|---|
| `<leader>ff` | Find files (incl. hidden, excludes `.git`) |
| `<leader>fg` | Live grep — search file *contents* |
| `<leader>fb` | Open buffers |
| `<leader>fo` | Recent files (across sessions) |
| `<leader>fr` | Resume last picker (keeps your query) |
| `<leader>fh` | Help tags — search `:help` |
| `<leader>fk` | Keymaps — searchable list of every bind |
| `<leader>fs` | Document symbols (needs LSP) |
| `<leader>fd` | Diagnostics — all errors/warnings (needs LSP) |

> Note: zellij owns `Ctrl-n`, `Ctrl-p`, `Ctrl-t` and `Ctrl-q` (resize, pane and
> tab modes, and Quit) — they never reach nvim. Telescope's defaults for those
> are remapped: navigation is `Ctrl-j`/`Ctrl-k`, new-tab is `Ctrl-y`, and
> send-to-quickfix is `Ctrl-a` (`Alt-a` for selected only). Upstream telescope
> docs will show the originals.

**ui-select**: telescope also hijacks Neovim's generic selection menus, so
prompts like code actions (`<leader>ca`) render as a nice telescope dropdown
instead of the bare numbered list.

## File explorer — Neo-tree

| Key | Action |
|---|---|
| `<leader>e` | Toggle sidebar (reveals current file) |
| `Y` | Yank path of node under cursor, relative to cwd |
| `gy` | Yank absolute path of node under cursor |

Sidebar closes itself if it would be the last window (no more full-screen
neo-tree). Hides gitignored files and `.git`; shows other dotfiles.

`Y`/`gy` are buffer-local to the tree — `Y` is still yank-line everywhere else.
Neo-tree's own `y` is unrelated: it stages a node for `p` (a file copy), not a
path yank. On the root row `Y` gives an absolute path, since cwd can't be made
relative to itself.

## Paths — current buffer

| Key | Action |
|---|---|
| `<leader>yp` | Yank buffer's path, relative to cwd |
| `<leader>yP` | Yank buffer's absolute path |

All four path yanks write the system clipboard (`+`) as well as `"`, and echo
what they copied. Built-in alternatives: `Ctrl-g` shows the relative path,
`1 Ctrl-g` the absolute one.

## Buffers — Bufferline (VS Code-style tabs)

| Key | Action |
|---|---|
| `Tab` / `Shift-Tab` | Next / previous buffer |
| `Ctrl-1` … `Ctrl-9` | Jump to buffer by position |
| `<leader>bd` | Close buffer (keeps the window/split intact) |
| `<leader>bp` | Pin buffer |

## LSP — code intelligence

Servers auto-install via mason: `lua_ls`, `basedpyright` + `ruff` (Python),
`yamlls`, `jsonls`. Inlay hints on; diagnostics shown as virtual text.
**Format-on-save is enabled for all buffers.**

| Key | Action |
|---|---|
| `K` | Hover docs |
| `g d` | Go to definition |
| `g r` | Find references (telescope) |
| `<leader>ca` | Code action |
| `<leader>fs` | Document symbols |
| `<leader>fd` | Project diagnostics |

## Git — Gitsigns

Gutter signs for added/changed/removed lines.

| Key | Action |
|---|---|
| `] c` / `[ c` | Next / previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |

## Completion & snippets — nvim-cmp + LuaSnip

Popup appears as you type in insert mode. Sources: LSP, snippets, path, buffer.
Snippet library: friendly-snippets (loads per-filetype automatically).

| Key | Action |
|---|---|
| `Ctrl-Space` | Trigger completion |
| `Enter` | Confirm selection |
| `Tab` | Next item / expand-or-jump to next snippet field |
| `Shift-Tab` | Previous item / jump to previous snippet field |

Snippets show up in the popup marked as such. Confirm one, then `Tab` through
its placeholder fields.

## Windows & undo

| Key | Action |
|---|---|
| `Ctrl-h/j/k/l` | Move between splits |
| `<leader>u` | Toggle undotree |

## Editor defaults worth knowing

- 2-space indentation, relative + absolute line numbers, cursorline.
- System clipboard (`unnamedplus`) — yank/paste shares the OS clipboard.
- No swapfiles. Splits open right/below.
- **autoread**: files edited by Claude Code in the adjacent zellij pane reload
  automatically on focus/buffer-enter.

## Plugin management — lazy.nvim

| Command | Action |
|---|---|
| `:Lazy` | Open the plugin UI |
| `:Lazy sync` | Install / update / clean |
| `:Lazy update <plugin>` | Update one plugin |
| `:Mason` | Manage LSP servers |

## Gotchas

- **Treesitter is on the `main` branch** (newer breaking API). Parsers install
  via an explicit `install()` call; highlighting starts from a `FileType`
  autocmd. Don't expect the old `ensure_installed`/`highlight.enable` config.
- **Telescope tracks `master`**, not a pinned tag — old tags call the removed
  `ft_to_lang` and crash the previewer on current nvim/treesitter.
- `after/ftplugin/lua.lua` is intentionally empty to override Neovim's built-in
  lua ftplugin.
