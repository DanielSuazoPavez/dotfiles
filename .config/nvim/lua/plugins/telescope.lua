return {
  -- Track master, not a pinned tag: we ride the treesitter `main` branch,
  -- and old telescope tags (0.1.8) call the removed `ft_to_lang` in their
  -- previewer, which errors on current nvim/treesitter.
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })
    telescope.load_extension("ui-select")

    local builtin = require("telescope.builtin")
    -- <leader>ff instead of <C-p>: zellij owns Ctrl-p (pane mode). Pairs with
    -- <leader>fg (live grep) under an 'f' = find group in which-key.
    vim.keymap.set("n", "<leader>ff", function()
      builtin.find_files({ hidden = true, no_ignore = false, file_ignore_patterns = { "^.git/" } })
    end, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", function()
      builtin.live_grep({ additional_args = { "--hidden", "--glob", "!.git" } })
    end, { desc = "Live grep" })

    -- General pickers (all under the <leader>f "find" group).
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume last picker" })
    vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
    vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })

    -- LSP-powered pickers.
    vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
    vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
    vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "LSP references" })
  end,
}
