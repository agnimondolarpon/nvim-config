-- Language servers for every supported language.
-- A server is enabled only when its program is installed, so a missing
-- server never produces an error. Run :LspServers to see the status.
local map = vim.keymap.set

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Completion capabilities from nvim-cmp (if available)
local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

if cmp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities()
end

-- server name (nvim-lspconfig) = program that must exist
local servers = {
  clangd = "clangd",
  pyright = "pyright-langserver",
  ts_ls = "typescript-language-server",
  html = "vscode-html-language-server",
  cssls = "vscode-css-language-server",
  jsonls = "vscode-json-language-server",
  lua_ls = "lua-language-server",
  bashls = "bash-language-server",
  yamlls = "yaml-language-server",
  gopls = "gopls",
  rust_analyzer = "rust-analyzer",
}

local active = {}
local missing = {}

for name, program in pairs(servers) do
  if vim.fn.executable(program) == 1 then
    table.insert(active, name)
  else
    table.insert(missing, name .. " (" .. program .. ")")
  end
end

table.sort(active)
table.sort(missing)

vim.lsp.config("*", { capabilities = capabilities })

-- clangd: Google style when the project has no .clang-format
vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--fallback-style=Google" },
  capabilities = capabilities,
})

vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  capabilities = capabilities,
})

-- Lua: do not warn about the global "vim"
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

if #active > 0 then
  vim.lsp.enable(active)
end

vim.api.nvim_create_user_command("LspServers", function()
  vim.notify(
    "Enabled: "
      .. table.concat(active, ", ")
      .. "\nNot installed: "
      .. table.concat(missing, ", ")
  )
end, { desc = "Show available language servers" })

-- Shortcuts
map("n", "K", vim.lsp.buf.hover, { desc = "Show documentation" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
map("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })

map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
