return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
          end
          map("]c", gs.next_hunk, "Next hunk")
          map("[c", gs.prev_hunk, "Prev hunk")
          map("<leader>hs", gs.stage_hunk, "Stage hunk")
          map("<leader>hr", gs.reset_hunk, "Reset hunk")
          map("<leader>hp", gs.preview_hunk, "Preview hunk")
          map("<leader>hb", gs.blame_line, "Blame line")
        end,
      })
    end
  }
}
