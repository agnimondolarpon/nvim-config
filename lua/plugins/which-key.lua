-- Shows available keys after pressing <leader> (or any prefix) and waiting
return {
  "folke/which-key.nvim",
  event = "VeryLazy",

  opts = {
    preset = "classic",
    delay = 300,
    icons = { mappings = false },

    spec = {
      { "<leader>f", group = "find" },
      { "<leader>h", group = "git hunks" },
      { "<leader>s", group = "session" },
    },
  },
}
