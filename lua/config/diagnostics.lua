-- Diagnostic display: signs only, no inline text, no underline.
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
  underline = false,

  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "●",
      [vim.diagnostic.severity.WARN] = "●",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },

  severity_sort = true,
  update_in_insert = true,

  float = {
    border = "rounded",
    source = true,
  },
})
