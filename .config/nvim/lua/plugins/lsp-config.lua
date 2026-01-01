return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "yamlls", "jsonls" }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Enable inlay hints globally
      vim.lsp.inlay_hint.enable(true)

      -- Show diagnostics as virtual text at end of line
      vim.diagnostic.config({
        virtual_text = true,
      })

      -- Lua LSP
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            hint = {
              enable = true,
            },
          },
        },
      })
      vim.lsp.enable('lua_ls')

      -- Python LSP (basedpyright)
      vim.lsp.config('basedpyright', {
        settings = {
          basedpyright = {
            analysis = {
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "basic",
              useLibraryCodeForTypes = true
            },
          },
        },
      })
      vim.lsp.enable('basedpyright')

      -- Ruff (Python linter/formatter)
      vim.lsp.enable('ruff')

      -- SQL
      vim.lsp.enable('sqls')

      -- YAML & JSON
      vim.lsp.enable('yamlls')
      vim.lsp.enable('jsonls')

      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set({ 'n' }, '<leader>ca', vim.lsp.buf.code_action, {})
    end
  }
}
