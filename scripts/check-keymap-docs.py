#!/usr/bin/env python3
"""Check that docs/*-REFERENCE.md still match the keys the tools actually bind.

This does NOT rewrite the docs. Their descriptions are hand-written and richer
than the config's `desc` strings ("Find files (incl. hidden, excludes .git)"
vs "Find files"), and that prose is worth keeping. What rots is the *set* of
keys: a bind gets added, removed or renamed in the config and the doc silently
stops matching. So the docs stay authored; this reports drift.

Reported per tool:
  MISSING  bound in the config, absent from the doc  -- undocumented key
  STALE    documented, not bound anywhere            -- removed or renamed

Adding a tool means writing one `<tool>_binds()` returning {key: description}
and one `<tool>_documented()` reading its doc, then listing both in TOOLS.
nvim is first; zellij and broot bind in KDL/TOML and need their own parsers.

Exit codes: 0 = in sync, 1 = drift found, 2 = extraction failed.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
NVIM_CONFIG = REPO_ROOT / ".config/nvim/init.lua"
# Only the reference is checked. docs/nvim-learning.md also lists keys, but
# most are nvim built-ins this config never binds (ciw, f<char>, Ctrl-o), so
# every one would report STALE. It documents vim, not this setup.
NVIM_DOC = REPO_ROOT / "docs/NVIM-REFERENCE.md"

# Config files whose keymaps belong in the reference. Anything bound elsewhere
# (nvim built-ins, plugin internals) is out of scope -- the doc describes this
# setup, not all of nvim.
NVIM_OWNED = {
    "telescope.lua",
    "neo-tree.lua",
    "bufferline.lua",
    "gitsigns.lua",
    "lsp-config.lua",
    "vim-options.lua",
    "which-key.lua",
    # undotree declares its key via lazy.nvim's `keys` spec, so lazy's own
    # handler binds it and reports keys.lua as the definition site.
    "keys.lua",
}

# Keys the doc documents but no `vim.keymap.set` call creates. Plugins that
# take their mappings as setup-table config (neo-tree's window.mappings,
# cmp's mapping preset, telescope's defaults.mappings for in-picker keys) are
# invisible to the vim.keymap.set hook, so drift in those is NOT caught -- they
# are listed here only to keep them from being reported stale forever.
NVIM_NON_KEYMAP_SET = {
    "Y", "gy",              # neo-tree window mappings (its setup table)
    "Ctrl-Space", "Enter",  # nvim-cmp mapping preset
}

# Installed before init.lua so it wraps vim.keymap.set ahead of every plugin
# config. Attribution must be by *definition site*: debug.getinfo on the
# callback reports where the handler was written, so `vim.keymap.set("n", "gr",
# telescope_builtin.lsp_references)` would blame telescope's actions.lua rather
# than the config file that bound the key.
NVIM_HOOK_LUA = r"""
_G.__keymap_origin = {}
-- nvim reports <C-h> back as <C-H>, so key the table on a lowercased form.
local function norm(lhs)
  return (lhs:gsub("^ ", "<leader>")):lower()
end
_G.__keymap_norm = norm
local orig_set = vim.keymap.set
vim.keymap.set = function(mode, lhs, rhs, opts)
  local info = debug.getinfo(2, "S")
  local src = (info and info.source or ""):gsub("^@", "")
  local file = vim.fn.fnamemodify(src, ":t")
  local modes = type(mode) == "table" and mode or { mode }
  for _, mo in ipairs(modes) do
    _G.__keymap_origin[mo .. "\0" .. norm(lhs)] = file
  end
  return orig_set(mode, lhs, rhs, opts)
end
"""

# Dumps keymaps as JSON. Two things have to happen before the dump is complete:
#
#   1. A real file is open, so buffer-local maps (LSP, gitsigns) have attached
#      -- they don't exist in a bare instance.
#   2. `User VeryLazy` is fired by hand. lazy.nvim triggers it off UIEnter,
#      which never fires under --headless, so every VeryLazy plugin (which-key
#      and its <leader>?) would otherwise stay unloaded and look unbound.
NVIM_DUMP_LUA = r"""
local out_path = vim.env.KEYMAP_DUMP_OUT
vim.defer_fn(function()
  pcall(vim.cmd, "doautocmd User VeryLazy")
end, 1500)
local origin = _G.__keymap_origin or {}
local norm = _G.__keymap_norm or function(s) return s:lower() end

local function collect()
  local seen, rows = {}, {}
  local function add(m, mode)
    if not m.desc or m.desc == "" then return end
    if m.lhs:match("<Plug>") or m.lhs:match("<SNR>") then return end
    if m.desc:match("%-default$") then return end
    local lhs = m.lhs:gsub("^ ", "<leader>")
    local dedup = mode .. lhs
    if seen[dedup] then return end
    seen[dedup] = true
    rows[#rows + 1] = {
      lhs = lhs,
      desc = m.desc,
      src = origin[mode .. "\0" .. norm(m.lhs)] or "",
    }
  end
  for _, mode in ipairs({ "n", "v", "i" }) do
    for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do add(m, mode) end
    for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do add(m, mode) end
  end
  return rows
end

vim.defer_fn(function()
  local f = assert(io.open(out_path, "w"))
  f:write(vim.json.encode(collect()))
  f:close()
  vim.cmd("qa!")
end, tonumber(vim.env.KEYMAP_DUMP_DELAY) or 6000)
"""


def canon(key: str) -> str:
    """Canonical form for comparing a config lhs against a doc's rendering.

    The docs write `g d` and `] c` with spaces, and `Ctrl-h` where nvim reports
    `<C-H>`; all of those must compare equal to the bound key.
    """
    k = key.strip().strip("`")
    k = re.sub(r"<C-([^>]+)>", r"ctrl-\1", k, flags=re.I)
    k = re.sub(r"<S-([^>]+)>", r"shift-\1", k, flags=re.I)
    k = re.sub(r"<M-([^>]+)>", r"alt-\1", k, flags=re.I)
    k = k.replace("<leader>", "leader-")
    # Bare named keys: the config binds <Tab>/<CR>, the doc writes Tab/Enter.
    k = re.sub(r"<(\w+)>", r"\1", k)
    k = re.sub(r"\s+", "", k)
    return k.lower()


def nvim_binds(sample: Path, delay_ms: int) -> dict[str, str]:
    """Keys bound by this repo's nvim config -> their `desc`."""
    with tempfile.NamedTemporaryFile("r+", suffix=".json") as tmp:
        proc = subprocess.run(
            [
                "nvim", "--headless",
                "--cmd", "lua " + NVIM_HOOK_LUA,
                "-u", str(NVIM_CONFIG),
                str(sample),
                "+lua " + NVIM_DUMP_LUA,
            ],
            env={**os.environ, "KEYMAP_DUMP_OUT": tmp.name,
                 "KEYMAP_DUMP_DELAY": str(delay_ms)},
            capture_output=True, text=True, timeout=delay_ms / 1000 + 30,
        )
        tmp.seek(0)
        raw = tmp.read()
    if not raw.strip():
        sys.stderr.write(
            f"error: nvim produced no keymap dump\n  stderr: {proc.stderr[-400:]}\n"
        )
        raise SystemExit(2)
    return {
        r["lhs"]: r["desc"]
        for r in json.loads(raw)
        if r["src"] in NVIM_OWNED
    }


# A table row: leading `|`, a key cell, an action cell. The key cell holds one
# or more backticked keys -- the docs write alternatives and ranges as
# `Tab` / `Shift-Tab`, `] c` / `[ c`, `Ctrl-1` … `Ctrl-9`.
DOC_ROW = re.compile(r"^\|\s*(?P<keys>(?:[^|`]*`[^`]+`[^|`]*)+)\|\s*(?P<action>.+?)\s*\|\s*$", re.M)
BACKTICKED = re.compile(r"`([^`]+)`")
RANGE_SEP = re.compile(r"…|\.\.\.")


def documented(doc: Path) -> dict[str, str]:
    """Keys appearing in a reference doc's tables -> their description.

    Every backticked token in the key cell counts as documented, so
    `Tab` / `Shift-Tab` registers both. A range (`Ctrl-1` … `Ctrl-9`) is
    expanded over its trailing digit so each key in it counts as covered.
    Command entries (`:Lazy`, `:Mason`) are skipped -- they're ex-commands
    listed for convenience, not keymaps.
    """
    out: dict[str, str] = {}
    for m in DOC_ROW.finditer(doc.read_text()):
        cell, action = m.group("keys"), m.group("action")
        keys = BACKTICKED.findall(cell)
        if RANGE_SEP.search(cell) and len(keys) == 2:
            keys = expand_range(keys[0], keys[1]) or keys
        keys = [k for token in keys for k in expand_alternation(token)]
        for key in keys:
            key = key.strip()
            if key and not key.startswith(":"):
                out[key] = action
    return out


def expand_alternation(token: str) -> list[str]:
    """Expand a slash-joined token: `Ctrl-h/j/k/l` -> four Ctrl- keys.

    Only the suffix after the final `-` varies, so the modifier prefix is
    carried across all alternatives. A token with no slash is returned as-is.
    """
    if "/" not in token:
        return [token]
    head, *rest = token.split("/")
    prefix = head.rsplit("-", 1)[0] + "-" if "-" in head else ""
    return [head] + [alt if "-" in alt else prefix + alt for alt in rest]


def expand_range(lo: str, hi: str) -> list[str]:
    """Expand `Ctrl-1` … `Ctrl-9` into the nine keys it stands for."""
    m_lo, m_hi = re.fullmatch(r"(.*?)(\d)", lo), re.fullmatch(r"(.*?)(\d)", hi)
    if not (m_lo and m_hi and m_lo.group(1) == m_hi.group(1)):
        return []
    prefix = m_lo.group(1)
    return [f"{prefix}{d}" for d in range(int(m_lo.group(2)), int(m_hi.group(2)) + 1)]


def report(tool: str, bound: dict[str, str], docd: dict[str, str],
           exempt: set[str]) -> int:
    bound_canon = {canon(k): k for k in bound}
    doc_canon = {canon(k): k for k in docd}
    exempt_canon = {canon(k) for k in exempt}

    missing = [v for k, v in bound_canon.items() if k not in doc_canon]
    stale = [
        docd_key for k, docd_key in doc_canon.items()
        if k not in bound_canon and k not in exempt_canon
    ]

    if not missing and not stale:
        print(f"{tool}: in sync ({len(bound)} keys)")
        return 0

    print(f"{tool}: DRIFT")
    for key in sorted(missing):
        print(f"  MISSING  `{key}` — bound as {bound[key]!r}, not in the doc")
    for key in sorted(stale):
        print(f"  STALE    `{key}` — documented, not bound")
    return 1


def self_test() -> int:
    """Check the notation handling against the forms the docs actually use.

    These are the fragile part: the docs write a key several ways
    (`Ctrl-h/j/k/l`, `Ctrl-1` … `Ctrl-9`, `] c`, `Tab`) and every one has to
    compare equal to what nvim reports. Runs without nvim.
    """
    cases: list[tuple[object, object, str]] = [
        (expand_alternation("Ctrl-h/j/k/l"),
         ["Ctrl-h", "Ctrl-j", "Ctrl-k", "Ctrl-l"], "slash alternation"),
        (expand_alternation("Tab"), ["Tab"], "plain token"),
        (expand_alternation("] c/[ c"), ["] c", "[ c"], "alternation, no modifier"),
        (expand_range("Ctrl-1", "Ctrl-9"),
         [f"Ctrl-{i}" for i in range(1, 10)], "digit range"),
        (expand_range("Tab", "Enter"), [], "non-range pair"),
        (canon("<Tab>"), canon("Tab"), "angle-bracket named key"),
        (canon("<C-h>"), canon("Ctrl-h"), "ctrl notation"),
        (canon("<S-Tab>"), canon("Shift-Tab"), "shift notation"),
        (canon("] c"), canon("]c"), "spaced key"),
        (canon("<leader>ff"), "leader-ff", "leader expansion"),
    ]
    failed = 0
    for got, want, label in cases:
        if got == want:
            print(f"  + {label}")
        else:
            print(f"  x {label}: {got!r} != {want!r}", file=sys.stderr)
            failed += 1
    print(f"self-test: {len(cases) - failed}/{len(cases)} passed")
    return 1 if failed else 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--self-test", action="store_true",
                    help="check notation handling without launching nvim")
    ap.add_argument("--sample", type=Path,
                    default=REPO_ROOT / "scripts/check-keybind-collisions.py",
                    help="file to open so buffer-local (LSP/gitsigns) maps attach")
    ap.add_argument("--delay", type=int, default=6000,
                    help="ms to wait for LSP/gitsigns attach before dumping")
    args = ap.parse_args()

    if args.self_test:
        return self_test()

    bound = nvim_binds(args.sample, args.delay)
    if not bound:
        sys.stderr.write("error: no keymaps attributed to this config\n")
        return 2
    return report("nvim", bound, documented(NVIM_DOC), NVIM_NON_KEYMAP_SET)


if __name__ == "__main__":
    sys.exit(main())
