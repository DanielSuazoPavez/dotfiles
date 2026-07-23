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
    -- Close the current buffer without closing its window. `:bdelete` would
    -- also close the split when it's the buffer's only window, which lets
    -- neo-tree reflow to fill the screen. Switch to another buffer first so
    -- the window survives and the sidebar layout stays intact.
    map("n", "<leader>bd", function()
      local bufs = vim.fn.getbufinfo({ buflisted = 1 })
      local cur = vim.api.nvim_get_current_buf()
      if #bufs > 1 then
        vim.cmd("BufferLineCyclePrev")
      end
      vim.cmd("bdelete " .. cur)
    end, { desc = "Close buffer (keep window)" })
    map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin buffer" })
    -- Jump to buffer by position (Ctrl+1..9)
    for i = 1, 9 do
      map("n", "<C-" .. i .. ">", function()
        require("bufferline").go_to(i, true)
      end, { desc = "Go to buffer " .. i })
    end
  end,
}
