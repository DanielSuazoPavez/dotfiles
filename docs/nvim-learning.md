# Neovim — currently learning

Working doc, not a reference. `docs/NVIM-REFERENCE.md` is the full keymap list;
this is the handful of keys in active rotation plus the things that aren't
keymaps at all (in-picker behavior, motions, grammar).

## The three keys that replace memorizing

| Key | What |
|---|---|
| `<leader>?` | popup of every keymap, grouped by prefix |
| `<leader>fk` | same list, fuzzy-searchable by description |
| `Ctrl-/` *inside a picker* | every key for **that** picker |

`<leader>?` is the browse tool, `<leader>fk` the search tool ("what was the
blame one?" → type `blame`). `Ctrl-/` is why in-picker keys don't need
memorizing.

**Gotcha:** buffer-local keys (LSP, gitsigns) only exist where their plugin has
attached. From the neo-tree sidebar or an empty buffer they're absent, and a
search for them comes up empty. That's context, not breakage.

## Telescope: inside a picker

You land in **insert mode**, so `<leader>` does nothing there — it types a
space. `Esc` first if you want normal-mode keys.

| Key | Effect |
|---|---|
| `Ctrl-j` / `Ctrl-k` | next / previous result |
| `Enter` | open |
| `Ctrl-x` / `Ctrl-v` | open in split / vsplit |
| `Ctrl-y` | open in a new tab |
| `Ctrl-u` / `Ctrl-d` | scroll the **preview** — read without opening |
| `Ctrl-/` | show all keys for this picker |
| `Esc` | normal mode inside the picker (`j`/`k`, `q` quits) |
| `Tab` / `Shift-Tab` | multi-select |
| `Ctrl-a` | send **all** results to quickfix |
| `Alt-a` | send **selected** to quickfix |

> **Zellij owns `Ctrl-n`, `Ctrl-p`, `Ctrl-t` and `Ctrl-q`** (resize, pane and
> tab modes, and Quit) — they never reach nvim, so telescope's defaults for
> those are dead keys here. Navigation uses `Ctrl-j`/`Ctrl-k`; new-tab and
> quickfix are remapped to `Ctrl-y` and `Ctrl-a`. Any telescope documentation
> you read online will list the defaults.

Quickfix follow-up: `:cnext` / `:cprev` walk hits, `:copen` shows the list.

**live_grep is ripgrep, not fuzzy** — it takes regex. Scope it by typing
`pattern -- -g '*.lua'`; everything after ` -- ` goes to rg as flags.

## Motions worth owning

| Key | Effect |
|---|---|
| `w` / `b` | forward / back a word |
| `0` / `^` / `$` | line start / first non-blank / line end |
| `gg` / `G` | top / bottom of file |
| `{` / `}` | previous / next paragraph |
| `%` | matching bracket |
| `f<char>` / `t<char>` | to / just before next char on the line (`;` repeats) |
| `*` | search word under cursor |
| `Ctrl-o` / `Ctrl-i` | back / forward in the jumplist |
| `''` | back to where the last jump started |

## Operators + text objects

Grammar: **operator + text object**. Learn the pieces, the combinations come
free.

Operators: `d` delete · `c` change · `y` yank · `v` select · `>` indent ·
`gu`/`gU` case

Text objects: `iw`/`aw` word · `i"`/`a"` quotes · `ib`/`ab` parens ·
`iB`/`aB` braces · `it`/`at` tag · `ip`/`ap` paragraph

`i` = inner (contents), `a` = around (contents + delimiters). So `ci"` changes
inside quotes, `dap` deletes a paragraph, `yib` yanks inside parens.

## Rotation

Three to five keys a week; ignore the rest. That restraint is the method.

| Week | Focus | Keys |
|---|---|---|
| 1 | Discovery | `<leader>?`, `<leader>fk`, `Ctrl-/` |
| 2 | In-file movement | `f<char>`, `;`, `%`, `*` |
| 3 | Text objects | `ciw`, `ci"`, `cib`, `dap` |
| 4 | Telescope beyond ff/fg | `<leader>fr`, `<leader>fo`, `<leader>fb` |
| 5 | Telescope → quickfix | `Ctrl-a`, `:cnext`, `:cprev`, `:copen` |
| 6 | Jumping | `Ctrl-o`, `Ctrl-i`, `gd`, `gr` |
| 7 | Git in-buffer | `]c`, `[c`, `<leader>hp`, `<leader>hb` |
| 8 | Splits & buffers | `Ctrl-w v`, `Ctrl-w s`, `Tab`, `<leader>bd` |

Rule for the week: catch yourself doing the slow version, undo, redo it the
fast way. Once. Then move on.

## Drills

Against this repo. Each under a minute.

1. **Resume** — `<leader>fg` for `keymap`, open a result, `<leader>fr`. Query
   and position come back; open the next hit.
2. **Quickfix sweep** — `<leader>fg` for `vim.keymap.set`, `Ctrl-a`, then
   `:cnext` through every match.
3. **Preview scroll** — `<leader>ff`, type `telescope`, `Ctrl-u`/`Ctrl-d` to
   read the preview without opening. Decide, then `Enter`.
4. **Split open** — `<leader>ff` → `lsp-config`, press `Ctrl-v` not `Enter`.
   Then `Ctrl-h`/`Ctrl-l` between them.
5. **Text objects** — in `lua/plugins/telescope.lua`, cursor inside a
   `desc = "..."`, press `ci"`, retype, `Esc`, then `u`.
6. **Word grep** — cursor on `builtin`, press `*` for in-file; compare to
   `<leader>fg` for cross-file.

## Reference

- `:Tutor` — built-in interactive tutorial, ~30 min. Worth doing once.
- `:help telescope.builtin` — every picker
- `:help text-objects` — the full object list
- `:checkhealth` — diagnose plugin/LSP problems
