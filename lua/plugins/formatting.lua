-- Formatting: conform.nvim
--   * format on save (toggle with :FormatToggle)
--   * <leader>= formats the buffer or the visual selection
-- A formatter whose program is not installed is skipped silently on save.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },

  keys = {
    {
      "<leader>=",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "x" },
      desc = "Format",
    },
  },

  init = function()
    vim.api.nvim_create_user_command("FormatToggle", function()
      vim.g.disable_autoformat = not vim.g.disable_autoformat
      vim.notify("Format on save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
    end, { desc = "Toggle format on save" })
  end,

  opts = {
    formatters_by_ft = {
      -- C is formatted like C++ (same Google style)
      c = { "clang_format" },
      cpp = { "clang_format" },

      python = { "ruff_format", "black", stop_after_first = true },

      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },

      lua = { "stylua" },
      sh = { "shfmt" },
      go = { "gofmt" },
      rust = { "rustfmt" },
    },

    formatters = {
      -- Uses the project's .clang-format when it exists, Google style otherwise.
      -- Pin Google style in a project with:
      --   clang-format --style=Google -dump-config > .clang-format
      clang_format = {
        prepend_args = { "--fallback-style=Google" },
      },
    },

    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      return { timeout_ms = 1500, lsp_format = "never", quiet = true }
    end,
  },
}
