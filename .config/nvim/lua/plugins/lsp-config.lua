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
        ensure_installed = { "lua_ls", "yamlls", "jsonls", "basedpyright", "ruff" }
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

      -- YAML & JSON
      vim.lsp.enable('yamlls')
      vim.lsp.enable('jsonls')

      -- descs are load-bearing: they're what which-key and the <leader>fk
      -- keymaps picker display. An undescribed map is an invisible one.
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover docs" })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set({ 'n' }, '<leader>ca', vim.lsp.buf.code_action, { desc = "Code action" })

      -- Format on save
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*',
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  }
}
