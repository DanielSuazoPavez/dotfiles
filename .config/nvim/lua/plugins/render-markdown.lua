return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = { "markdown" },
  config = function()
    require("render-markdown").setup({
      -- Headings span only their own text, not the full window width.
      heading = { width = "block" },
      -- Rendering drops on the cursor line in insert mode, so editing
      -- always shows raw markdown.
      render_modes = { "n", "c" },
    })
  end,
}
