vim.g.mapleader = " "

-- Tabs/Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Cursor
vim.opt.cursorline = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Scrolling
vim.opt.scrolloff = 8

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Appearance
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- No swap files
vim.opt.swapfile = false

-- Auto-reload files changed on disk (e.g. by Claude Code in the adjacent pane)
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  command = "checktime",
})

-- Yank the current buffer's path (relative to cwd / absolute).
-- clipboard=unnamedplus only redirects implicit yanks, so set + explicitly.
local function yank_path(modifier)
  return function()
    local path = vim.fn.expand(modifier)
    vim.fn.setreg('"', path)
    vim.fn.setreg("+", path)
    vim.notify(path, vim.log.levels.INFO, { title = "Yanked path" })
  end
end

vim.keymap.set("n", "<leader>yp", yank_path("%:."), { desc = "Yank relative path" })
vim.keymap.set("n", "<leader>yP", yank_path("%:p"), { desc = "Yank absolute path" })

-- Split navigation keymaps
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
