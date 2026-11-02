-- Autocommands: per-language indentation and small quality-of-life helpers.
local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- Indentation helper
local function set_indent(patterns, width, use_tabs)
  autocmd("FileType", {
    group = group,
    pattern = patterns,

    callback = function()
      vim.opt_local.expandtab = not use_tabs
      vim.opt_local.tabstop = width
      vim.opt_local.shiftwidth = width
      vim.opt_local.softtabstop = use_tabs and 0 or width
    end,
  })
end

-- C and C++ follow the Google C++ style (2 spaces).
-- clang-format (see lua/plugins/formatting.lua) enforces the rest.
set_indent({ "c", "cpp" }, 2, false)

autocmd("FileType", {
  group = group,
  pattern = { "c", "cpp" },

  callback = function()
    vim.opt_local.cindent = true
    vim.opt_local.cinoptions = "g1,h1" -- public:/private: indented by 1 space
  end,
})

-- Python
set_indent({ "python" }, 4, false)

-- 2 spaces: web, data, scripting
set_indent({
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "html",
  "css",
  "scss",
  "json",
  "jsonc",
  "yaml",
  "lua",
  "ruby",
  "vue",
  "svelte",
  "xml",
}, 2, false)

-- 4 spaces
set_indent({ "java", "rust", "cs", "kotlin", "php", "swift", "sh", "bash", "zsh" }, 4, false)

-- Real tabs (required by these languages)
set_indent({ "go", "gomod", "gowork" }, 4, true)
set_indent({ "make" }, 8, true)

-- Highlight yanked text
autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Restore the last editing position
autocmd("BufReadPost", {
  group = group,

  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)

    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Remove trailing whitespace on save (not in Markdown: two spaces = line break)
autocmd("BufWritePre", {
  group = group,

  callback = function()
    if not vim.bo.modifiable or vim.bo.filetype == "markdown" then
      return
    end

    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Reload files that changed outside Neovim (git pull, formatters, ...)
autocmd({ "FocusGained", "BufEnter" }, {
  group = group,

  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})
