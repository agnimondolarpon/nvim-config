-- File explorer. Icons need a Nerd Font in the terminal.
return {
  "nvim-tree/nvim-tree.lua",

  dependencies = {
    { "nvim-tree/nvim-web-devicons", opts = { default = true } },
  },

  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },

  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "File explorer" },
    { "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal current file" },
  },

  opts = {
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")

      api.config.mappings.default_on_attach(bufnr)

      -- Keep Ctrl+k for window navigation
      pcall(vim.keymap.del, "n", "<C-k>", { buffer = bufnr })
    end,

    view = { width = 28, side = "left" },

    renderer = {
      icons = {
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = false,
          modified = false,
          diagnostics = false,
          bookmarks = false,
        },

        web_devicons = {
          file = { enable = true, color = true },
          folder = { enable = false, color = true },
        },

        glyphs = {
          folder = { arrow_closed = "▸", arrow_open = "▾" },
        },
      },
    },

    git = { enable = false },

    -- Close the tree after opening a file (small screen)
    actions = {
      open_file = { quit_on_open = true },
    },
  },
}
