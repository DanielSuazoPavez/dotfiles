"""Shared nvim chord extraction for check-keymap-docs.py and
check-keybind-collisions.py.

Both scripts need "what chord does nvim believe it owns" -- one to check doc
drift, the other to check zellij collisions -- via two different sources:

  keymap_set   Chords bound through `vim.keymap.set` (built-ins, LSP, plugin
               config files). Extracted via a headless-nvim hook that wraps
               `vim.keymap.set` before init.lua loads, then dumps
               nvim_buf_get_keymap/nvim_get_keymap after firing `User
               VeryLazy` by hand (never fires under --headless).

  setup_table  Chords passed as data into a plugin's own `setup({...})` table
               (telescope's `defaults.mappings`, neo-tree's
               `window.mappings`, cmp's `mapping` preset) -- invisible to the
               vim.keymap.set hook since the plugin, not nvim, binds them
               internally. Extracted by patching `require` itself (not the
               plugin module directly -- lazy.nvim, which makes these plugins
               requirable at all, is itself require()'d from init.lua, so
               nothing is requirable yet at the point this hook installs) to
               wrap each target's `setup` the moment it first becomes
               requirable, capturing its `opts` table before delegating.

Neither extraction filters by source file -- callers apply their own
filtering (e.g. check-keymap-docs.py's NVIM_OWNED) after the fact.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
NVIM_CONFIG = REPO_ROOT / ".config/nvim/init.lua"

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
  -- Basenames collide across runtimes: nvim's own runtime/ftplugin/markdown.lua
  -- binds gO and ]]/[[, and this repo's after/ftplugin/markdown.lua rebinds the
  -- latter two (ours load second and win). Only the `after/` copy is ours.
  -- Match on the path segment, not stdpath("config") -- the config dir is a
  -- symlink into the dotfiles repo, so sources resolve to the repo path.
  if src:find("/ftplugin/", 1, true) then
    file = (src:find("/after/ftplugin/", 1, true) and "after/" or "runtime/") .. file
  end
  local modes = type(mode) == "table" and mode or { mode }
  for _, mo in ipairs(modes) do
    _G.__keymap_origin[mo .. "\0" .. norm(lhs)] = file
  end
  return orig_set(mode, lhs, rhs, opts)
end
"""

# Patches telescope/neo-tree/cmp's `setup` so the opts table each plugin was
# actually configured with is captured verbatim -- not a static/optimistic
# parse of the .lua files, which could miss conditionally-constructed
# mappings. Installed via the same `--cmd "lua ..."` mechanism as
# NVIM_HOOK_LUA, so it runs before init.lua sources anything.
#
# `pcall(require, modname)` at --cmd time always fails: lazy.nvim -- which
# adds each plugin's directory to the runtimepath -- is itself require()'d
# from inside init.lua (line 15), so no plugin is requirable yet when a
# --cmd hook runs. Patching `require` itself instead of the module sidesteps
# load order entirely: whenever *anything* (lazy.nvim included) first
# requires one of these three modules, this wrapper patches its `.setup`
# before handing the module back, so the patch is in place before that
# plugin's own config() function gets a chance to call setup().
NVIM_SETUP_TABLE_HOOK_LUA = r"""
_G.__setup_table_chords = {}
local TARGETS = {
  telescope = {
    path = "telescope.lua",
    extract = function(o)
      local m = (o.defaults or {}).mappings or {}
      return { i = vim.tbl_keys(m.i or {}), n = vim.tbl_keys(m.n or {}) }
    end,
  },
  ["neo-tree"] = {
    path = "neo-tree.lua",
    extract = function(o)
      return { n = vim.tbl_keys(((o.window or {}).mappings) or {}) }
    end,
  },
  cmp = {
    path = "cmp.lua",
    extract = function(o)
      return { i = vim.tbl_keys(o.mapping or {}) }
    end,
  },
}
-- Two calling conventions show up across these plugins: telescope/neo-tree
-- expose `setup` as a plain function, but nvim-cmp exposes it as a table
-- with a `__call` metamethod (`cmp.setup(opts)` really invokes
-- `getmetatable(cmp.setup).__call`). Wrap whichever one is actually callable.
local function wrap_setup(target, orig_setup)
  return function(opts)
    _G.__setup_table_chords[target.path] = target.extract(opts or {})
    return orig_setup(opts)
  end
end

local orig_require = require
_G.require = function(modname)
  local mod = orig_require(modname)
  local target = TARGETS[modname]
  if not (target and type(mod) == "table" and not target.patched) then
    return mod
  end
  if type(mod.setup) == "function" then
    target.patched = true
    local orig_setup = mod.setup
    mod.setup = wrap_setup(target, orig_setup)
  else
    local mt = getmetatable(mod.setup)
    if mt and type(mt.__call) == "function" then
      target.patched = true
      local orig_call = mt.__call
      mt.__call = function(self, opts, ...)
        _G.__setup_table_chords[target.path] = target.extract(opts or {})
        return orig_call(self, opts, ...)
      end
    end
  end
  return mod
end
"""

# Dumps keymaps + setup-table chords as JSON. Two things have to happen
# before the dump is complete:
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
      mode = mode,
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
  f:write(vim.json.encode({
    keymap_set = collect(),
    setup_table = _G.__setup_table_chords or {},
  }))
  f:close()
  vim.cmd("qa!")
end, tonumber(vim.env.KEYMAP_DUMP_DELAY) or 6000)
"""


def _nvim_chords_one(sample: Path, delay_ms: int) -> dict:
    """Raw keymap_set rows + setup_table chords from a single nvim run on `sample`."""
    with tempfile.NamedTemporaryFile("r+", suffix=".json") as tmp:
        proc = subprocess.run(
            [
                "nvim", "--headless",
                "--cmd", "lua " + NVIM_HOOK_LUA + NVIM_SETUP_TABLE_HOOK_LUA,
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
    return json.loads(raw)


def all_nvim_chords(samples: list[Path], delay_ms: int) -> dict:
    """Merge keymap_set + setup_table chords across all `samples`.

    Buffer-local maps only attach in a buffer of the right filetype, and no
    one buffer attaches them all: the LSP keys need a Python file, the
    markdown ftplugin keys need a `.md`. Each sample is dumped in its own
    nvim run and the results merged.

    Returns:
      {
        "keymap_set": {mode: {lhs: {"desc": str, "src": str}}},
        "setup_table": {mode: {lhs: str}},  # lhs -> source file label
      }
    """
    keymap_set: dict[str, dict[str, dict]] = {}
    setup_table: dict[str, dict[str, str]] = {}

    for sample in samples:
        dump = _nvim_chords_one(sample, delay_ms)

        for row in dump.get("keymap_set", []):
            mode_map = keymap_set.setdefault(row["mode"], {})
            # First sample to report a (mode, lhs) wins. Different samples
            # attach different buffer-local maps (LSP needs a .py, ftplugin
            # needs a .md), but a given (mode, lhs) should mean the same bind
            # everywhere -- so a later sample must not silently overwrite an
            # earlier one's src attribution for the same key.
            mode_map.setdefault(row["lhs"], {"desc": row["desc"], "src": row["src"]})

        st = dump.get("setup_table") or {}
        for src_path, by_mode in (st.items() if isinstance(st, dict) else []):
            mode_items = by_mode.items() if isinstance(by_mode, dict) else []
            for mode, lhs_list in mode_items:
                mode_map = setup_table.setdefault(mode, {})
                for lhs in (lhs_list or []):
                    mode_map.setdefault(lhs, src_path)

    return {"keymap_set": keymap_set, "setup_table": setup_table}
