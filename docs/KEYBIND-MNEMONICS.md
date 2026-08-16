# Keybind Mnemonics

What a letter is *supposed* to mean, across zellij, neovim and broot. Nothing
recorded this before, so the same letter drifted to different verbs in different
modes — `r` is *rename* in zellij's tab mode but *new pane right* in pane mode,
`s` is *stacked* / *sync* / *scroll* / *search* depending on where you are. This
document fixes the intended meaning of each letter so a new bind is decidable
(consult the table instead of guessing), and lists every current binding that
contradicts it. **It changes no keybindings** — see `## Notes / policy`.

## Scope and tiers

Two different questions get confused here. *Can* two tools bind the same key
(overlap) is `scripts/check-keybind-collisions.py`'s job. *Should* a letter mean
the same verb everywhere (meaning) is this document's.

Zellij intercepts a key before any inner tool sees it, but only for the sections
it treats as global. There are two tiers:

| Tier | What it covers | Reserved against nvim/broot? |
|---|---|---|
| **Global chords** | `Alt f/h/i/j/k/l/n/o/p`, `Alt` digits/arrows/brackets, `Ctrl e/g/n/o/p/q/s/t` — the `shared_except` sections (`config.kdl:142-191`) | **Yes.** Hard reservation; nvim never receives them. |
| **Mode-local letters** | Every bare letter in `pane`, `tab`, `resize`, `move`, `scroll`, `search`, `session` | **No.** They only fire after you enter that mode. |

**From normal mode, zellij reserves no bare letter.** Every global reservation is
`Alt`- or `Ctrl`-chorded. The bare letters `d h j k l u` in
`shared_among "scroll" "search"` (`config.kdl:198-215`) are the only bare letters
in a section the collision checker calls global — and that section is itself
mode-scoped, so they fire only once you are already scrolling or searching.

`scripts/check-keybind-collisions.py:90` classifies those `shared_among` letters
as global via `GLOBAL_SECTIONS = {"shared_except", "shared_among", "normal"}`.
That is the conservative and correct answer to *its* question (can zellij shadow
nvim?). It is not a claim that nvim may not use the letter. Concretely: nvim's
`<leader>h` = *git hunk* is **not** shadowed by zellij's `h` = *left*. The whole
`<leader>` namespace is unconstrained by zellij, and this charter governs it for
consistency of meaning only.

Broot binds three chorded verbs (`ctrl-e` edit, `ctrl-g` git, `ctrl-v` view) and
no bare letters, so it contributes almost nothing to govern — but note `ctrl-e`
and `ctrl-g` are zellij globals, so broot only sees them outside zellij.

## The charter

Axis = the family of verbs the letter belongs to. Status **held** means the
letter already means one thing everywhere it appears; **contested** means more
than one verb claims it and no meaning is being invented to break the tie.

| Letter | Verb | Axis | Status |
|---|---|---|---|
| `h` | left / previous | motion | **held** — pane, tab, resize, move, scroll, `Alt` |
| `j` | down / next | motion | **held** — same six surfaces |
| `k` | up / previous | motion | **held** — same six surfaces |
| `l` | right / next | motion | **held** — same six surfaces |
| `x` | close | destroy | **held** — `CloseFocus` (pane) and `CloseTab` (tab) agree |
| `b` | break out | structure | **held** — `BreakPane` in tab mode; `<leader>b` = buffer in nvim is a different namespace |
| `f` | find | search | **held in nvim** (`<leader>f` subtree is all pickers) — **contested** in zellij: *fullscreen* (pane) and *floating* (`Alt f`) |
| `n` | new | create | **held in pane/tab** (`NewPane`, `NewTab`, `Alt n`) — **contested**: also *next* (`Search "down"`) and *move* (`MovePane`, move mode) |
| `s` | — | — | **contested**: *stacked* (pane), *sync* (tab), *scroll* (`Ctrl s`), *search* (scroll mode), *share* (session) |
| `r` | — | — | **contested**: *right* (pane, `NewPane "right"`) vs *rename* (tab) |
| `p` | — | — | **contested**: *pane* (`Ctrl p`), *previous* (`Search "up"`, `MovePaneBackwards`), *pin* (`Alt p`, `<leader>bp`), *plugin manager* (session), *preview* (`<leader>hp`) |
| `e` | — | — | **contested**: *embed* (pane), *move* mode (`Ctrl e`), *edit* (scroll, broot) vs *explorer* (`<leader>e` in nvim) |
| `c` | — | — | **contested**: *change name* (pane rename), *case sensitivity* (search), *configuration* (session), *code* (`<leader>c` in nvim) |
| `d` | down | motion | **held in zellij motion contexts** (`NewPane "down"`, `HalfPageScrollDown`) — **contested** by *detach* (session) and *diagnostics* (`<leader>fd`) |
| `w` | — | — | **contested**: *floating window* (pane), *wrap* (search), *session manager* (session) |
| `z` | frames / fold | display | **held** — `TogglePaneFrames` in zellij; vim's own `z` prefix is folds, a different tool's namespace |
| `i` | pin / insert-left | structure | **contested**: `TogglePanePinned` (pane) vs `MoveTab "left"` (`Alt i`) |
| `o` | — | — | **contested**: *session* mode (`Ctrl o`), *whole word* (search), *move tab right* (`Alt o`), *oldfiles* (`<leader>fo`) |
| `u` | up (half page) | motion | **held** — only one use, `HalfPageScrollUp` |
| `q` | quit | destroy | **held** — `Ctrl q` |
| `g` | git / lock | — | **contested**: *locked mode* (`Ctrl g` in zellij) vs *git* (`ctrl-g` in broot, `<leader>hs`-family in nvim) |
| `y` | yank | copy | **held** — `<leader>y` in nvim; unused by zellij |
| `t` | tab | noun | **held** — `Ctrl t` enters tab mode |
| `a` | about / action | — | **contested**: *about* (session) vs *action* (`<leader>ca`) |

Rows with no verb are contested by design: there are more verbs in play (*new*,
*next*, *close*, *change*, *sync*, *scroll*, *search*, *stacked*, *session*) than
letters to hold them. Marking a letter contested is the honest outcome; inventing
a meaning nothing currently uses would make the table lie.

## Known deviations

Every current binding that contradicts a **held** row above. Rows are keyed on
the bind text — line numbers drift, the bind is the identity.

| Binding | Location | Does today | Charter says |
|---|---|---|---|
| `bind "r" { NewPane "right"; ... }` | `.config/zellij/config.kdl:26` (pane) | New pane to the right | `r` is contested; *right* belongs to `l` on the motion axis, and `r` = *rename* in tab mode |
| `bind "r" { SwitchToMode "renametab"; ... }` | `.config/zellij/config.kdl:54` (tab) | Rename the tab | Same letter as pane-mode *right* — the sharpest contradiction in the config |
| `bind "c" { SwitchToMode "renamepane"; ... }` | `.config/zellij/config.kdl:14` (pane) | Rename the pane | Rename is `r` in tab mode; `c` for the same verb in pane mode splits it |
| `bind "s" { NewPane "stacked"; ... }` | `.config/zellij/config.kdl:28` (pane) | New stacked pane | `n` is *new*; `s` also means sync/scroll/search/share elsewhere |
| `bind "s" { ToggleActiveSyncTab; ... }` | `.config/zellij/config.kdl:55` (tab) | Toggle tab sync | Disagrees with pane-mode `s` = *stacked* |
| `bind "s" { SwitchToMode "entersearch"; ... }` | `.config/zellij/config.kdl:94` (scroll) | Enter search | Third verb on `s` — and it is reached via `Ctrl s` = *scroll* |
| `bind "n" { MovePane; }` | `.config/zellij/config.kdl:88` (move) | Move pane forward | `n` = *new* (held in pane/tab); this is *next* |
| `bind "n" { Search "down"; }` | `.config/zellij/config.kdl:98` (search) | Next match | `n` = *new*; vim-inherited *next* — kept deliberately, but it is a deviation |
| `bind "Ctrl n" { SwitchToMode "resize"; }` | `.config/zellij/config.kdl:190` | Enter resize mode | `n` = *new*; positional inheritance from stock zellij, not mnemonic |
| `bind "e" { TogglePaneEmbedOrFloating; ... }` | `.config/zellij/config.kdl:16` (pane) | Embed / float the pane | `e` is contested; nvim's `<leader>e` = *explorer* and broot's `ctrl-e` = *edit* |
| `bind "Ctrl e" { SwitchToMode "move"; }` | `.config/zellij/config.kdl:175` | Enter move mode | Mode-entry chords are otherwise first-letter-of-noun; *move* should be `m` |
| `bind "Ctrl o" { SwitchToMode "session"; }` | `.config/zellij/config.kdl:178` | Enter session mode | *session* should be `s`, but `Ctrl s` is *scroll*; positional inheritance |
| `bind "p" { SwitchFocus; }` | `.config/zellij/config.kdl:24` (pane) | Cycle pane focus | `p` = *pane* as a mode-entry noun (`Ctrl p`); here it is a verb |
| `bind "p" { MovePaneBackwards; }` | `.config/zellij/config.kdl:89` (move) | Move pane backward | *previous*, not *pane* |
| `bind "p" { Search "up"; }` | `.config/zellij/config.kdl:100` (search) | Previous match | *previous*, not *pane* |
| `bind "d" { NewPane "down"; ... }` | `.config/zellij/config.kdl:15` (pane) | New pane below | *down* is `j` on the motion axis; `d` is also *detach* in session mode |
| `bind "d" { Detach; }` | `.config/zellij/config.kdl:119` (session) | Detach the session | Conflicts with `d` = *down* used in pane and scroll modes |
| `bind "f" { ToggleFocusFullscreen; ... }` | `.config/zellij/config.kdl:17` (pane) | Toggle fullscreen | `f` = *find* is held across nvim's entire `<leader>f` subtree |
| `bind "Alt f" { ToggleFloatingPanes; }` | `.config/zellij/config.kdl:161` | Toggle floating panes | Third verb on `f`, and a *global* reservation — this one nvim genuinely cannot reuse |
| `bind "c" { SearchToggleOption "CaseSensitivity"; }` | `.config/zellij/config.kdl:97` (search) | Toggle case sensitivity | Disagrees with pane-mode `c` = *change name* |
| `bind "Alt i" { MoveTab "left"; }` | `.config/zellij/config.kdl:163` | Move tab left | *left* is `h`; `i` means *pin* in pane mode |

## Notes / policy

- **The charter governs *new* binds.** Adding a key? Find the letter above. If
  it is **held**, use it for that verb or pick another letter. If it is
  **contested**, you are free — but add your choice to the contested list.
- **The deviations are deliberately unchanged.** Every row in that table is a
  documented fact, not a bug and not an oversight — rebinding was explicitly
  deferred. The table is the work-list if normalization is ever approved.
- **This document is *meaning*; `scripts/check-keybind-collisions.py` is
  *overlap*.** A binding can be collision-free and still mnemonically wrong, and
  the checker will never say so.
- **Nothing enforces this automatically.** `scripts/check-keymap-docs.py` checks
  doc/config key-*set* drift for the tools in its `TOOLS` list; the charter has
  no `desc` counterpart and is deliberately not in it. A semantic checker is a
  deferred follow-up.
- **`h/j/k/l` is untouchable.** Six zellij modes agree on it and nvim inherits it
  from vim. No letter gets a verb that would break the motion axis.
- **Cross-tool clashes are meaning-only, not shadowing.** `h` = *git hunk* in
  nvim coexists fine with `h` = *left* in zellij, because zellij's `h` is
  mode-local. See `## Scope and tiers`.
