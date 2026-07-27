return {
  "nvim-treesitter/nvim-treesitter-context",
  config = function()
    require("treesitter-context").setup({
      max_lines = 3,
      multiline_threshold = 1,
    })
  end,
}
