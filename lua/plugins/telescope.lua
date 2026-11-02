-- Fuzzy finder. Needs: ripgrep, fd (optional)
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },

  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Search text" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Open buffers" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help" },
  },

  opts = {
    defaults = {
      -- Regex preview is lighter and more stable than treesitter preview
      preview = { treesitter = false },

      layout_strategy = "vertical",
      sorting_strategy = "ascending",

      layout_config = {
        prompt_position = "top",
        width = 0.98,
        height = 0.95,
      },

      file_ignore_patterns = { "^%.git/", "node_modules/" },
    },

    pickers = {
      find_files = { hidden = true },
    },
  },
}
