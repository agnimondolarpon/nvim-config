-- Statusline with live error / warning counters.

-- Global on purpose: the statusline expression calls it through v:lua.
_G.diagnostic_status = function()
  local errors = 0
  local warnings = 0

  for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      errors = errors + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      warnings = warnings + 1
    end
  end

  local result = {}

  if errors > 0 then
    table.insert(result, "%#StatusLineError#E: " .. errors .. "%*")
  else
    table.insert(result, "E: 0")
  end

  if warnings > 0 then
    table.insert(result, "%#StatusLineWarning#W: " .. warnings .. "%*")
  else
    table.insert(result, "W: 0")
  end

  return table.concat(result, "  ")
end

vim.opt.statusline = " %f %h%m%r %= " .. "%{%v:lua.diagnostic_status()%} " .. "%l:%c %p%% "

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufEnter", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("UserStatusline", { clear = true }),
  callback = function()
    vim.cmd("redrawstatus")
  end,
})
