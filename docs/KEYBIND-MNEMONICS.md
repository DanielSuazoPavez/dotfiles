# Keybind Mnemonics

What a letter is *supposed* to mean, across zellij, neovim and broot. Nothing
recorded this before, so the same letter drifted to different verbs in different
modes — `s` still means *stacked* / *sync* / *scroll* / *search* / *share*
depending on where you are. This document fixes the intended meaning of each
letter so a new bind is decidable (consult the table instead of guessing), and
lists every current binding that contradicts it.

A small **core set** — `h j k l`, `r`, `n`, `x` — is enforced in the config;
everything else is recorded, not policed. See `## Notes / policy` for what that
distinction obliges.

## Scope and tiers

Two different questions get confused here. *Can* two tools bind the same key
(overlap) is `scripts/check-keybind-collisions.py`'s job. *Should* a letter mean
the same verb everywhere (meaning) is this document's.

Zellij intercepts a key before any inner tool sees it, but only for the sections
it treats as global. There are two tiers:

| Tier | What it covers | Reserved against nvim/broot? |
|---|---|---|
| **Global chords** | `Alt f/h/i/j/k/l/n/o/p`, `Alt` digits/arrows/brackets, `Ctrl e/g/n/o/p/q/s/t` — the `shared_except` sections (`config.kdl:148-197`) | **Yes.** Hard reservation; nvim never receives them. |
| **Mode-local letters** | Every bare letter in `pane`, `tab`, `resize`, `move`, `scroll`, `search`, `session` | **No.** They only fire after you enter that mode. |

**From normal mode, zellij reserves no bare letter.** Every global reservation is
`Alt`- or `Ctrl`-chorded. The bare letters `d h j k l u` in
`shared_among "scroll" "search"` (`config.kdl:204-221`) are the only bare letters
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

Axis = the family of verbs the letter belongs to. Status **core** means the
letter is governed: it has one verb, deviations get fixed rather than recorded,
and a new bind may not claim it for anything else. **held** means it already
means one thing everywhere it appears but is not load-bearing enough to govern.
**contested** means more than one verb claims it and no meaning is being
invented to break the tie.

The core set is deliberately small — `h` `j` `k` `l` `r` `n` `x`. Everything
else is documentation, not policy.

**Scoped exceptions.** Two bindings contradict a core letter and are kept
anyway, because they inherit a stronger convention from another tool:

| Binding | Why it stands |
|---|---|
| search mode `n` / `p` = next / previous match | vim's search bindings; "new" is meaningless inside a search |
| session mode `d` = detach | `d` = *down* is a motion-axis claim; session mode is a deliberate, rarely-entered namespace |

An exception is a decision, not a deviation — it is listed here rather than in
`## Known deviations` so the deviation table stays a work-list.

| Letter | Verb | Axis | Status |
|---|---|---|---|
| `h` | left / previous | motion | **core** — pane, tab, resize, move, scroll, `Alt` |
| `j` | down / next | motion | **core** — same six surfaces |
| `k` | up / previous | motion | **core** — same six surfaces |
| `l` | right / next | motion | **core** — same six surfaces |
| `r` | rename | edit | **core** — pane and tab agree |
| `x` | close | destroy | **core** — `CloseFocus` (pane) and `CloseTab` (tab) agree |
| `b` | break out | structure | **held** — `BreakPane` in tab mode; `<leader>b` = buffer in nvim is a different namespace |
| `f` | find | search | **held in nvim** (`<leader>f` subtree is all pickers) — **contested** in zellij: *fullscreen* (pane) and *floating* (`Alt f`) |
| `n` | new | create | **core** — `NewPane`, `NewTab`, `Alt n`. Search-mode *next* is a scoped exception; `Ctrl n` = resize remains a deviation |
| `s` | — | — | **contested**: *stacked* (pane), *sync* (tab), *scroll* (`Ctrl s`), *search* (scroll mode), *share* (session) |
| `p` | — | — | **contested**: *pane* (`Ctrl p`), *previous* (`Search "up"` — scoped exception), *pin* (`Alt p`, `<leader>bp`), *plugin manager* (session), *preview* (`<leader>hp`) |
| `e` | — | — | **contested**: *embed* (pane), *move* mode (`Ctrl e`), *edit* (scroll, broot) vs *explorer* (`<leader>e` in nvim) |
| `c` | — | — | **contested**: *case sensitivity* (search), *configuration* (session), *code* (`<leader>c` in nvim). Freed in pane mode when `r` took rename — left unbound rather than reassigned |
| `d` | down | motion | **held** — `HalfPageScrollDown`; session *detach* is a scoped exception, `<leader>fd` is a different namespace |
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

Every current binding that contradicts a **core** or **held** row above. Rows
are keyed on the bind text — line numbers drift, the bind is the identity.
Scoped exceptions (see `## The charter`) are decisions and are not listed here.

| Binding | Location | Does today | Charter says |
|---|---|---|---|
| `bind "s" { NewPane "stacked"; ... }` | `.config/zellij/config.kdl:33` (pane) | New stacked pane | `n` is *new*; `s` also means sync/scroll/search/share elsewhere |
| `bind "s" { ToggleActiveSyncTab; ... }` | `.config/zellij/config.kdl:60` (tab) | Toggle tab sync | Disagrees with pane-mode `s` = *stacked* |
| `bind "s" { SwitchToMode "entersearch"; ... }` | `.config/zellij/config.kdl:100` (scroll) | Enter search | Third verb on `s` — and it is reached via `Ctrl s` = *scroll* |
| `bind "Ctrl n" { SwitchToMode "resize"; }` | `.config/zellij/config.kdl:196` | Enter resize mode | `n` = *new*; positional inheritance from stock zellij, not mnemonic |
| `bind "e" { TogglePaneEmbedOrFloating; ... }` | `.config/zellij/config.kdl:14` (pane) | Embed / float the pane | `e` is contested; nvim's `<leader>e` = *explorer* and broot's `ctrl-e` = *edit* |
| `bind "Ctrl e" { SwitchToMode "move"; }` | `.config/zellij/config.kdl:181` | Enter move mode | Mode-entry chords are otherwise first-letter-of-noun — but `Ctrl m` is reserved (= `Enter`, see notes), so this one has no clean fix |
| `bind "Ctrl o" { SwitchToMode "session"; }` | `.config/zellij/config.kdl:184` | Enter session mode | *session* should be `s`, but `Ctrl s` is *scroll*; positional inheritance |
| `bind "p" { SwitchFocus; }` | `.config/zellij/config.kdl:29` (pane) | Cycle pane focus | `p` = *pane* as a mode-entry noun (`Ctrl p`); here it is a verb |
| `bind "f" { ToggleFocusFullscreen; ... }` | `.config/zellij/config.kdl:15` (pane) | Toggle fullscreen | `f` = *find* is held across nvim's entire `<leader>f` subtree |
| `bind "Alt f" { ToggleFloatingPanes; }` | `.config/zellij/config.kdl:167` | Toggle floating panes | Third verb on `f`, and a *global* reservation — this one nvim genuinely cannot reuse |
| `bind "Alt i" { MoveTab "left"; }` | `.config/zellij/config.kdl:169` | Move tab left | *left* is `h`; `i` means *pin* in pane mode |

## Notes / policy

- **Core letters are enforced; everything else is recorded.** A bind that
  contradicts a **core** letter gets fixed. A bind that contradicts a **held**
  or **contested** letter gets a row in `## Known deviations` and is left alone.
  That asymmetry is the whole policy — a core set small enough to actually hold
  beats a comprehensive one nobody follows.
- **Adding a key?** Find the letter above. **core** → use it for that verb or
  pick another letter. **held** → prefer that verb. **contested** → you are
  free, but add your choice to the contested list.
- **The remaining deviations are deliberately unchanged.** Every row in that
  table is a documented fact, not an oversight. It is the work-list if the core
  set is ever widened.
- **Scoped exceptions are decisions, not debt.** search `n`/`p` and session `d`
  contradict a core letter and stay. Do not "fix" them.
- **`Ctrl m`, `Ctrl i` and `Ctrl [` are reserved — never bind them.** At the
  ASCII layer they *are* `Enter` (0x0D), `Tab` (0x09) and `Esc` (0x1B). Only the
  Kitty keyboard protocol tells them apart, so a bind works in Ghostty and
  silently becomes the wrong action over SSH, in tmux, or in any terminal
  without it. This config binds all three aliases in overlapping mode-space
  (`enter` at `config.kdl:199`, `tab` at `:95`, `esc` at `:202`), so the clash is
  live, not hypothetical. `Ctrl m` for *move* mode is the tempting one — it is
  the right mnemonic and still not worth it.
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
