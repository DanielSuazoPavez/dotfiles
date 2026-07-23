# Zellij Reference

A refresher for this dotfiles Zellij setup. Config: `.config/zellij/config.kdl`
(custom keybinds, defaults cleared) + `.config/zellij/layouts/project.kdl`.
Shell helpers live in `.aliases`.

> Zellij is **modal** (like vim). You start in `normal` mode and press a
> `Ctrl` key to enter a mode, then single keys act within it. `Esc` or `Enter`
> returns to normal. The status bar at the bottom shows the current mode and
> its keys.

## Modes — how to enter them

| Key | Mode | For |
|---|---|---|
| `Ctrl p` | **pane** | Splitting, focusing, closing panes |
| `Ctrl t` | **tab** | Creating / moving between tabs |
| `Ctrl n` | **resize** | Resizing the focused pane |
| `Ctrl e` | **move** | Relocating panes |
| `Ctrl s` | **scroll** | Scrolling / searching the scrollback |
| `Ctrl o` | **session** | Session manager, config, plugins, detach |
| `Ctrl b` | **tmux** | tmux-style compatibility binds |
| `Ctrl g` | **locked** | Lock zellij so keys pass through to the app |

`Ctrl g` again unlocks. `Ctrl q` quits the whole session.

## Quick actions — no mode needed (`Alt` from anywhere)

These work directly from normal mode (and most others), so you skip the
mode dance for the common stuff:

| Key | Action |
|---|---|
| `Alt n` | New pane |
| `Alt h/j/k/l` or arrows | Move focus (wraps to adjacent tab left/right) |
| `Alt =` / `Alt +` | Increase pane size |
| `Alt -` | Decrease pane size |
| `Alt [` / `Alt ]` | Previous / next layout |
| `Alt f` | Toggle floating panes |
| `Alt 1`…`Alt 9` | Go to tab by number |
| `Alt i` / `Alt o` | Move current tab left / right |

## Pane mode (`Ctrl p`, then…)

| Key | Action |
|---|---|
| `n` | New pane |
| `d` | Split **down** |
| `r` | Split **right** |
| `s` | New **stacked** pane |
| `h/j/k/l` or arrows | Move focus |
| `x` | Close focused pane |
| `f` | Toggle fullscreen for focused pane |
| `z` | Toggle pane frames |
| `w` | Toggle floating panes |
| `e` | Toggle embed / float for focused pane |
| `c` | Rename pane |
| `p` | Cycle focus |

## Tab mode (`Ctrl t`, then…)

| Key | Action |
|---|---|
| `n` | New tab |
| `x` | Close tab |
| `r` | Rename tab |
| `1`…`9` | Go to tab N |
| `h/l` or arrows | Previous / next tab |
| `Tab` | Toggle to last-used tab |
| `b` | Break pane into its own tab |
| `[` / `]` | Break pane to left / right tab |
| `s` | Toggle sync (type into all panes at once) |

## Resize mode (`Ctrl n`, then…)

| Key | Action |
|---|---|
| `h/j/k/l` or arrows | Increase toward that edge |
| `H/J/K/L` | Decrease from that edge |
| `+` / `=` | Increase |
| `-` | Decrease |

## Move mode (`Ctrl e`, then…)

| Key | Action |
|---|---|
| `h/j/k/l` or arrows | Move pane in that direction |
| `n` / `Tab` | Move pane to next position |
| `p` | Move pane backwards |

## Scroll & search (`Ctrl s`, then…)

| Key | Action |
|---|---|
| `j/k` or arrows | Line down / up |
| `Ctrl f` / `Ctrl b` | Page down / up |
| `d` / `u` | Half-page down / up |
| `s` | Enter search (type, `Enter` to confirm) |
| `e` | Edit scrollback in `$EDITOR` |
| `Ctrl c` | Jump to bottom + exit |

In search: `n`/`p` next/previous match, `c` toggle case, `w` toggle wrap,
`o` toggle whole-word.

## Session mode (`Ctrl o`, then…)

| Key | Action |
|---|---|
| `w` | Session manager (switch/create sessions) |
| `d` | Detach from session |
| `c` | Configuration UI |
| `p` | Plugin manager |
| `a` | About |

## Copy / paste

`copy_on_select` is on — **selecting text with the mouse copies it**
automatically to the system clipboard. No keybind needed.

## Shell helpers (from `.aliases`)

| Command | Action |
|---|---|
| `zj` | `zellij` |
| `zja` | Attach to a session |
| `zjl` | List sessions |
| `zjk` | Kill a session |
| `zjka` | Kill all sessions |
| `proj` | Open **current dir** as a project **session** (nvim + Claude Code + scratch), named after the dir. Create-or-attach. |
| `projtab` | Same project layout as a **tab** in the current session (or defers to `proj` if outside zellij). |

## The `project` layout

Used by `proj` / `projtab`. Opens a tab with:

- **nvim** (67%, left) — opens `BACKLOG.md` with the neo-tree sidebar if the
  repo has one, else opens the directory.
- **Claude Code** (33%, right).
- A hidden **floating "scratch" shell** — toggle with `Alt f` for quick
  commands over the top.

Every tab keeps its top tab-bar and bottom status-bar (set via
`default_tab_template` in the layout).

## Notes / policy

- **Keybinds are cleared to defaults-off** (`clear-defaults=true`) and fully
  redefined — this is the authoritative set, not stock zellij.
- **Zellij owns terminal keybinds.** Ghostty deliberately avoids binds that
  would collide; see `scripts/check-keybind-collisions.py`.
- Startup tips are off; pane frames on; default mode `normal`; default layout
  `default`.
