-- Indent guides (scope highlight is disabled on purpose)
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  lazy = false,

  opts = {
    enabled = true,

    indent = {
      char = "│",
      tab_char = "│",
      highlight = "IblIndent",
    },

    whitespace = {
      highlight = "IblWhitespace",
      remove_blankline_trail = true,
    },

    scope = {
      enabled = false,
      show_start = false,
      show_end = false,
    },

    exclude = {
      filetypes = {
        "help",
        "lazy",
        "mason",
        "neo-tree",
        "NvimTree",
        "TelescopePrompt",
        "TelescopeResults",
        "terminal",
      },
    },
  },
}
