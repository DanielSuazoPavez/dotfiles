return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    -- Neo-tree colors
    vim.cmd([[
      highlight NeoTreeDirectoryName guifg=#E6DB74
      highlight NeoTreeDirectoryIcon guifg=#E6DB74
      highlight NeoTreeFileName guifg=#F8F8F2
      highlight NeoTreeGitUntracked guifg=#A6E22E
      highlight NeoTreeGitModified guifg=#FD971F
      highlight NeoTreeGitConflict guifg=#F92672
    ]])

    require("neo-tree").setup({
      -- If neo-tree would be the last window open (e.g. after closing the
      -- final buffer), close it instead of letting it fill the screen.
      close_if_last_window = true,
      window = {
        width = 35,
      },
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          never_show = { ".git" },
        },
        use_libuv_file_watcher = true,
      },
    })
    vim.keymap.set("n", "<leader>e", ":Neotree filesystem reveal toggle left<CR>", { desc = "Toggle file explorer" })
  end,
}
