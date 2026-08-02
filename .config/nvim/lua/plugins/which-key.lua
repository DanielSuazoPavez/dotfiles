return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        -- Pop the menu fast. The default 1000ms is long enough that you give up
        -- and guess instead of waiting, which defeats the point of the plugin.
        delay = 300,
        -- Show built-in motions/text-objects/registers/marks too, not just our
        -- leader maps. This is where nvim-in-general discovery comes from:
        -- pressing `g`, `z`, `"` or `'` lists what's actually available.
        plugins = {
          marks = true,
          registers = true,
          presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
          },
        },
      })

      -- Group labels. Without these, pressing <leader> shows bare letters; with
      -- them it reads as a menu. Keep in sync with the keymaps defined in the
      -- plugin files named in each comment.
      wk.add({
        { "<leader>f", group = "find (telescope)" }, -- plugins/telescope.lua
        { "<leader>h", group = "git hunk" },         -- plugins/gitsigns.lua
        { "<leader>b", group = "buffer" },           -- plugins/bufferline.lua
        { "<leader>y", group = "yank path" },        -- vim-options.lua
        { "<leader>c", group = "code" },             -- plugins/lsp-config.lua
      })

      -- Cheatsheet-in-a-pane: a searchable popup of every active keymap.
      -- <leader>? is which-key's own view (grouped, respects context);
      -- <leader>fk (telescope keymaps) is the fuzzy-searchable one.
      vim.keymap.set("n", "<leader>?", function()
        wk.show({ global = true })
      end, { desc = "All keymaps (which-key)" })
    end,
  },
}
