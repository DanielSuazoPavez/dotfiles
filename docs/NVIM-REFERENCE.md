# Neovim Reference

A refresher for this dotfiles Neovim setup. `<leader>` = `Space`.
Config lives in `.config/nvim/` (`vim-options.lua` + `lua/plugins/*.lua`),
managed by [lazy.nvim](https://github.com/folke/lazy.nvim).

> Tip: forget a binding? Press `<leader>` (or any prefix like `<leader>f`) and
> **pause** — which-key pops up the full list. Or `<leader>fk` for a searchable
> keymap picker.

## Finding things — Telescope

Fuzzy pickers. Inside any picker: type to filter · `Ctrl-n`/`Ctrl-p` or arrows
to move · `Enter` open · `Ctrl-x` horizontal split · `Ctrl-v` vertical split ·
`Ctrl-t` new tab · `Esc`/`Ctrl-c` close.

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

> Note: `Ctrl-p` is **not** used — zellij owns it (pane mode).

**ui-select**: telescope also hijacks Neovim's generic selection menus, so
prompts like code actions (`<leader>ca`) render as a nice telescope dropdown
instead of the bare numbered list.

## File explorer — Neo-tree

| Key | Action |
|---|---|
| `<leader>e` | Toggle sidebar (reveals current file) |

Sidebar closes itself if it would be the last window (no more full-screen
neo-tree). Hides gitignored files and `.git`; shows other dotfiles.

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
