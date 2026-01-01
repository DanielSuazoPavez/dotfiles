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

-- Split navigation keymaps
vim.keymap.set("n", "<C-h>", "<C-w>h", {})
vim.keymap.set("n", "<C-j>", "<C-w>j", {})
vim.keymap.set("n", "<C-k>", "<C-w>k", {})
vim.keymap.set("n", "<C-l>", "<C-w>l", {})
