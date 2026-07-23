return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    -- Ensure the parsers we care about are installed.
    require("nvim-treesitter").install({
      "bash",
      "lua",
      "python",
      "markdown",
      "markdown_inline",
    })

    -- The main branch no longer auto-enables highlighting; start treesitter
    -- for any buffer that has a parser available.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(args)
        local ok = pcall(vim.treesitter.start, args.buf)
        if ok then
          -- Use treesitter-based indentation where available.
          vim.bo[args.buf].indentexpr =
            "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
