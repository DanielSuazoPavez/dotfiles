return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin" },
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        separator_style = "thin",
        show_buffer_close_icons = true,
        show_close_icon = false,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },
      highlights = (function()
        local ok, cat = pcall(require, "catppuccin.groups.integrations.bufferline")
        return ok and cat.get() or {}
      end)(),
    })

    -- VS Code-style tab navigation
    local map = vim.keymap.set
    map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
    map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
    map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
    map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin buffer" })
    -- Jump to buffer by position (Ctrl+1..9)
    for i = 1, 9 do
      map("n", "<C-" .. i .. ">", function()
        require("bufferline").go_to(i, true)
      end, { desc = "Go to buffer " .. i })
    end
  end,
}
