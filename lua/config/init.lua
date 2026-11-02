-- Loads every core module.
-- Order matters: options (leader key) -> plugins -> everything else.
-- Each module is loaded with pcall, so one broken module never takes the
-- whole configuration down.

if vim.fn.has("nvim-0.11") == 0 then
  vim.notify("This configuration needs Neovim 0.11 or newer", vim.log.levels.ERROR)
  return
end

local modules = {
  "config.options",
  "config.lazy",
  "config.colors",
  "config.autocmds",
  "config.keymaps",
  "config.insert_guard",
  "config.diagnostics",
  "config.statusline",
  "config.lsp",
  "config.run",
}

for _, name in ipairs(modules) do
  local ok, err = pcall(require, name)

  if not ok then
    vim.notify(("Failed to load %s:\n%s"):format(name, err), vim.log.levels.ERROR)
  end
end
