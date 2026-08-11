#!/usr/bin/env python3
"""Check for keybinding collisions between ghostty, zellij, and nvim.

Policy (see CLAUDE.md / zellij setup): zellij and whatever runs inside it own
keybinds; ghostty stays out of the way. This script surfaces chords bound in
BOTH so that, on friction, the ghostty binding can be removed.

It also cross-references zellij's global binds against nvim's normal- and
insert-mode chords (via `scripts/_nvim_chords.py`): zellij's `shared_except`/
`shared_among`/`normal` sections intercept a chord before nvim, running as a
zellij pane, ever sees it, regardless of nvim's own mode -- so a nvim bind
reusing one of those chords is a dead key, the same class of problem as a
ghostty collision.

Ghostty binds are read from `ghostty +list-keybinds` (effective: defaults +
user config). Zellij binds are parsed from its config.kdl. Chords are
normalized to a canonical form (sorted modifiers + lowercased key) so that
`ctrl+shift+j` and `Ctrl Shift j` compare equal.

Zellij binds reachable only inside a mode (pane/tab/resize/...) can only
collide while in that mode; binds reachable from normal mode ("global") are
the ones that actually shadow ghostty or nvim. Both are reported, global
first.

Exit code: 1 if any GLOBAL collision is found (ghostty or nvim), else 0
(mode-local collisions are informational and do not fail the check).
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

from _nvim_chords import all_nvim_chords

ZELLIJ_CONFIG = Path.home() / ".config/zellij/config.kdl"
REPO_ROOT = Path(__file__).resolve().parent.parent

# Modifier spellings -> canonical token.
MOD_ALIASES = {
    "ctrl": "ctrl", "control": "ctrl",
    "alt": "alt", "opt": "alt", "option": "alt",
    "shift": "shift",
    "super": "super", "cmd": "super", "command": "super", "meta": "super",
}
MOD_ORDER = {"ctrl": 0, "alt": 1, "shift": 2, "super": 3}


def canon(chord: str) -> str:
    """Normalize a chord to 'mod+mod+key' with sorted mods and lowercased key."""
    parts = re.split(r"[+ ]+", chord.strip())
    mods, keys = [], []
    for p in parts:
        if not p:
            continue
        low = p.lower()
        if low in MOD_ALIASES:
            mods.append(MOD_ALIASES[low])
        else:
            keys.append(low)
    mods = sorted(set(mods), key=lambda m: MOD_ORDER[m])
    return "+".join(mods + keys)


def ghostty_binds() -> dict[str, str]:
    """Return {canonical_chord: action} from `ghostty +list-keybinds`."""
    out = subprocess.run(
        ["ghostty", "+list-keybinds"],
        capture_output=True, text=True, check=True,
    ).stdout
    binds: dict[str, str] = {}
    for line in out.splitlines():
        m = re.match(r"\s*keybind\s*=\s*(.+?)=(.+)$", line)
        if not m:
            continue
        chord, action = m.group(1), m.group(2)
        # Skip pure-text binds like shift+enter=text:... — those are
        # intentional passthroughs, not interceptions to worry about.
        if action.startswith("text:"):
            continue
        binds[canon(chord)] = action.strip()
    return binds


# Zellij "sections" that are reachable from normal mode without first entering
# another mode. A bind inside `pane {}` only fires while in pane mode, so it
# can't shadow ghostty globally.
GLOBAL_SECTIONS = {"shared_except", "shared_among", "normal"}


def zellij_binds(config: Path) -> list[tuple[str, str, bool]]:
    """Return [(canonical_chord, raw_chord, is_global)] from config.kdl."""
    text = config.read_text()
    results: list[tuple[str, str, bool]] = []
    section_stack: list[str] = []
    for line in text.splitlines():
        stripped = line.strip()
        # Track section headers like `pane {` or `shared_except "locked" {`.
        sec = re.match(r"(\w+)(?:\s+\"[^\"]*\")*\s*\{", stripped)
        if sec:
            section_stack.append(sec.group(1))
            continue
        if stripped == "}":
            if section_stack:
                section_stack.pop()
            continue
        b = re.match(r'bind\s+"([^"]+)"', stripped)
        if b:
            raw = b.group(1)
            is_global = any(s in GLOBAL_SECTIONS for s in section_stack)
            results.append((canon(raw), raw, is_global))
    return results


# nvim's <...> notation for the modifiers canon() already understands.
# <C-j> -> "Ctrl j", <M-a> -> "Alt a", <S-Tab> -> "Shift Tab". A bare named
# key (<Tab>, <CR>) or a plain letter carries no modifier and canon() passes
# it through unchanged.
NVIM_MOD_TAG = re.compile(r"<([CMS])-([^>]+)>", re.I)
NVIM_MOD_NAME = {"c": "Ctrl", "m": "Alt", "s": "Shift"}


def _nvim_lhs_to_chord(lhs: str) -> str:
    """Adapt an nvim lhs (<C-j>, <M-a>) into canon()'s 'Ctrl j' style input."""
    m = NVIM_MOD_TAG.fullmatch(lhs)
    if not m:
        return lhs
    return f"{NVIM_MOD_NAME[m.group(1).lower()]} {m.group(2)}"


def nvim_binds(delay_ms: int = 6000) -> dict[str, str]:
    """Return {canonical_chord: raw_lhs} for every chord nvim binds in normal
    or insert mode, from both `vim.keymap.set` and plugin setup tables
    (telescope, neo-tree, cmp). Insert mode matters as much as normal here:
    zellij intercepts a chord before nvim sees it regardless of nvim's own
    mode, since nvim is just a pane -- and cmp's whole completion mapping
    preset, plus telescope's in-picker keys, are insert-mode-only. Unlike
    check-keymap-docs.py's nvim_binds(), this is not filtered to this repo's
    own config files -- built-ins, LSP defaults, and third-party plugin
    defaults can all be shadowed by zellij too.
    """
    samples = [
        REPO_ROOT / "scripts/check-keybind-collisions.py",
        REPO_ROOT / "docs/NVIM-REFERENCE.md",
    ]
    chords = all_nvim_chords(samples, delay_ms)

    binds: dict[str, str] = {}
    for source in (chords["keymap_set"], chords["setup_table"]):
        for mode in ("n", "i"):
            for lhs in source.get(mode, {}):
                binds[canon(_nvim_lhs_to_chord(lhs))] = lhs
    return binds


def main() -> int:
    if not ZELLIJ_CONFIG.exists():
        print(f"zellij config not found: {ZELLIJ_CONFIG}", file=sys.stderr)
        return 2

    gh = ghostty_binds()
    zj = zellij_binds(ZELLIJ_CONFIG)
    nv = nvim_binds()

    global_hits, mode_hits, nvim_hits = [], [], []
    for cchord, raw, is_global in zj:
        if cchord in gh:
            row = (cchord, raw, gh[cchord])
            (global_hits if is_global else mode_hits).append(row)
        if is_global and cchord in nv:
            nvim_hits.append((cchord, raw, nv[cchord]))

    def show(title: str, rows: list[tuple[str, str, str]], other_label: str) -> None:
        print(f"\n{title} ({len(rows)}):")
        if not rows:
            print("  none")
            return
        for cchord, raw, other in sorted(set(rows)):
            print(f"  {cchord:20}  zellij: {raw:14}  {other_label}: {other}")

    show("GLOBAL collisions (ghostty shadows a normal-mode zellij bind)",
         global_hits, "ghostty")
    show("Mode-local collisions (only while in that zellij mode)",
         mode_hits, "ghostty")
    show("GLOBAL collisions (zellij shadows an nvim normal- or insert-mode bind)",
         nvim_hits, "nvim")

    print()
    if global_hits or nvim_hits:
        print("-> Per policy, remove the ghostty/nvim binding for each GLOBAL collision.")
        return 1
    print("-> No global collisions.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
