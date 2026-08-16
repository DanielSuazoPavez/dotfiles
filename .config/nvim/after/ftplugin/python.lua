-- Treesitter folding: collapse function and class bodies, and the blocks
-- nested inside them, with zc/zo/za or by clicking the +/- markers in the
-- fold column.
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Open everything by default; folding is opt-in per fold, not a collapsed
-- wall of text on open.
vim.opt_local.foldlevel = 99
vim.opt_local.foldcolumn = "1"
