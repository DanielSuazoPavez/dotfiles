-- Section navigation: jump between ATX headings and anchor them to the
-- top of the view (bypassing scrolloff so the heading sits on line 1).
local function goto_heading(backward)
  local flags = backward and "bW" or "W"
  if vim.fn.search([[^#\+\s]], flags) ~= 0 then
    local scrolloff = vim.o.scrolloff
    vim.o.scrolloff = 0
    vim.cmd("normal! zt")
    vim.o.scrolloff = scrolloff
  end
end

vim.keymap.set("n", "]]", function()
  goto_heading(false)
end, { buffer = true, desc = "Next heading (anchored to top)" })

vim.keymap.set("n", "[[", function()
  goto_heading(true)
end, { buffer = true, desc = "Previous heading (anchored to top)" })
