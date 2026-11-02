-- Custom highlight tweaks. Re-applied after every :colorscheme.
local function apply()
  local set = vim.api.nvim_set_hl

  -- Indent guides
  set(0, "IblIndent", { fg = "#30364f" })
  set(0, "IblWhitespace", { fg = "#30364f" })

  -- Diagnostic signs
  set(0, "DiagnosticSignError", { fg = "#f7768e" })
  set(0, "DiagnosticSignWarn", { fg = "#e0af68" })
  set(0, "DiagnosticSignInfo", { fg = "#7aa2f7" })
  set(0, "DiagnosticSignHint", { fg = "#9ece6a" })

  -- Diagnostic text (no underline)
  set(0, "DiagnosticError", { fg = "#f7768e", bold = true })
  set(0, "DiagnosticWarn", { fg = "#e0af68", bold = true })
  set(0, "DiagnosticUnderlineError", { underline = false })
  set(0, "DiagnosticUnderlineWarn", { underline = false })

  -- Statusline counters
  set(0, "StatusLineError", { fg = "#f7768e", bold = false })
  set(0, "StatusLineWarning", { fg = "#e0af68", bold = false })
end

apply()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserColors", { clear = true }),
  callback = apply,
})
