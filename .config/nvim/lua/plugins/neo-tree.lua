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

    require("neo-tree").setup({})
    vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal toggle left<CR>", {})
  end,
}
