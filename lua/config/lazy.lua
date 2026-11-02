-- Bootstraps lazy.nvim and loads every spec in lua/plugins/.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.notify("lazy.nvim installation failed:\n" .. out, vim.log.levels.ERROR)
    return
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "plugins" } }, {
  -- Stable on Termux: no luarocks, no background update checks
  rocks = { enabled = false },
  checker = { enabled = false },
  change_detection = { notify = false },
  install = { colorscheme = { "tokyonight-night" } },

  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
