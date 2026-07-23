#!/usr/bin/env python3
"""Check for keybinding collisions between ghostty and zellij.

Policy (see CLAUDE.md / zellij setup): zellij and whatever runs inside it own
keybinds; ghostty stays out of the way. This script surfaces chords bound in
BOTH so that, on friction, the ghostty binding can be removed.

Ghostty binds are read from `ghostty +list-keybinds` (effective: defaults +
user config). Zellij binds are parsed from its config.kdl. Chords are
normalized to a canonical form (sorted modifiers + lowercased key) so that
`ctrl+shift+j` and `Ctrl Shift j` compare equal.

Zellij binds reachable only inside a mode (pane/tab/resize/...) can only
collide while in that mode; binds reachable from normal mode ("global") are
the ones that actually shadow ghostty. Both are reported, global first.

Exit code: 1 if any GLOBAL collision is found, else 0 (mode-local collisions
are informational and do not fail the check).
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ZELLIJ_CONFIG = Path.home() / ".config/zellij/config.kdl"

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


def main() -> int:
    if not ZELLIJ_CONFIG.exists():
        print(f"zellij config not found: {ZELLIJ_CONFIG}", file=sys.stderr)
        return 2

    gh = ghostty_binds()
    zj = zellij_binds(ZELLIJ_CONFIG)

    global_hits, mode_hits = [], []
    for cchord, raw, is_global in zj:
        if cchord in gh:
            row = (cchord, raw, gh[cchord])
            (global_hits if is_global else mode_hits).append(row)

    def show(title: str, rows: list[tuple[str, str, str]]) -> None:
        print(f"\n{title} ({len(rows)}):")
        if not rows:
            print("  none")
            return
        for cchord, raw, action in sorted(set(rows)):
            print(f"  {cchord:20}  zellij: {raw:14}  ghostty: {action}")

    show("GLOBAL collisions (ghostty shadows a normal-mode zellij bind)", global_hits)
    show("Mode-local collisions (only while in that zellij mode)", mode_hits)

    print()
    if global_hits:
        print("-> Per policy, remove the ghostty binding for each GLOBAL collision.")
        return 1
    print("-> No global collisions.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
