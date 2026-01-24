return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      color_overrides = {
        mocha = {
          base = "#272822", -- Monokai background
          mantle = "#1e1f1c", -- Monokai sidebar/explorer background
        },
      },
    })
    vim.cmd.colorscheme("catppuccin-mocha")
  end,
}
