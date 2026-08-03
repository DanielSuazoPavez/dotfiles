return {
  -- Track master, not a pinned tag: we ride the treesitter `main` branch,
  -- and old telescope tags (0.1.8) call the removed `ft_to_lang` in their
  -- previewer, which errors on current nvim/treesitter.
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        -- Pickers are floating windows sized off `vim.o.columns` -- the whole
        -- nvim instance, i.e. the zellij pane. They overlay neo-tree rather
        -- than sharing width with it, so the sidebar doesn't factor in.
        -- A quarter-width pane on a wide monitor lands around 95 columns,
        -- under telescope's default preview_cutoff=120, so the stock
        -- horizontal layout crushes or drops the preview. `flex` flips to
        -- vertical (preview stacked on top, full width) below flip_columns,
        -- which stays readable where a side-by-side sliver would not.
        layout_strategy = "flex",
        layout_config = {
          flex = { flip_columns = 130 },
          horizontal = {
            preview_width = 0.55,
            preview_cutoff = 100,
          },
          vertical = {
            -- Preview on top, results below: reads like a file, not a column.
            mirror = true,
            preview_height = 0.5,
            preview_cutoff = 10,
          },
          -- Near-full pane: at a quarter-width pane on a wide monitor (~95
          -- columns) every column counts, and the float overlays neo-tree
          -- rather than sharing width with it, so there's nothing to leave
          -- room for.
          width = 0.98,
          height = 0.95,
        },
        -- Wrap long lines in the preview rather than truncating them off the
        -- right edge -- the main readability win at narrow widths.
        preview = {
          filetype_hook = function(_, bufnr, opts)
            vim.wo[opts.winid].wrap = true
            return true
          end,
        },
        -- Zellij intercepts Ctrl-n/p/t/q before nvim ever sees them (resize,
        -- pane and tab modes, and Quit), so telescope's defaults for those are
        -- dead keys in this setup. Zellij owns the bind; telescope moves.
        -- Ctrl-n/Ctrl-p need no replacement: Ctrl-j/Ctrl-k already navigate.
        mappings = {
          i = {
            ["<C-y>"] = "select_tab",              -- was <C-t>
            ["<C-a>"] = "send_to_qflist",          -- was <C-q>: open the full
            ["<M-a>"] = "send_selected_to_qflist", -- list, then :cnext
          },
          n = {
            ["<C-y>"] = "select_tab",
            ["<C-a>"] = "send_to_qflist",
            ["<M-a>"] = "send_selected_to_qflist",
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })
    telescope.load_extension("ui-select")

    local builtin = require("telescope.builtin")
    -- <leader>ff instead of <C-p>: zellij owns Ctrl-p (pane mode). Pairs with
    -- <leader>fg (live grep) under an 'f' = find group in which-key.
    vim.keymap.set("n", "<leader>ff", function()
      builtin.find_files({ hidden = true, no_ignore = false, file_ignore_patterns = { "^.git/" } })
    end, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", function()
      builtin.live_grep({ additional_args = { "--hidden", "--glob", "!.git" } })
    end, { desc = "Live grep" })

    -- General pickers (all under the <leader>f "find" group).
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume last picker" })
    vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
    -- Search keymaps *by description* -- the one thing <leader>? can't do
    -- ("what was the blame one?" -> type "blame"). Default builtin.keymaps
    -- lists every mode plus plugin-internal maps, which buries the ~30 you
    -- actually type, so restrict to normal mode and drop undescribed entries.
    vim.keymap.set("n", "<leader>fk", function()
      builtin.keymaps({
        modes = { "n" },
        show_plug = false,
        only_buf = false,
      })
    end, { desc = "Search keymaps by description" })

    -- LSP-powered pickers.
    vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
    vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
    vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "LSP references" })
  end,
}
