-- Core editor options (no plugins required).
local opt = vim.opt

-- Leader keys (must be set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- netrw is replaced by nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.number = true
opt.relativenumber = false
opt.numberwidth = 4
opt.signcolumn = "yes:2" -- room for diagnostics and git signs together
opt.cursorline = true
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

-- Text display
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.showbreak = "↳ "
opt.scrolloff = 5
opt.sidescrolloff = 5
opt.colorcolumn = "80"

-- Indentation (per-language rules live in config/autocmds.lua)
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.autoindent = true
opt.smartindent = true
opt.shiftround = true

-- Windows and statusline
opt.laststatus = 2
opt.showmode = false
opt.showcmd = true
opt.ruler = true
opt.splitright = true
opt.splitbelow = true
opt.equalalways = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.wildmenu = true
opt.wildmode = "longest:full,full"

-- Files
-- Swap file + write backup stay ON: Android can kill Termux at any time,
-- and the swap file lets Neovim recover unsaved work.
opt.undofile = true
opt.swapfile = true
opt.backup = false
opt.writebackup = true
opt.autoread = true
opt.confirm = true

-- Sessions (used by persistence.nvim)
opt.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds"

-- Performance
opt.updatetime = 250
opt.timeoutlen = 400

-- Clipboard (only when a provider exists, otherwise Neovim warns on every yank)
if vim.fn.has("clipboard") == 1 then
  opt.clipboard = "unnamedplus"
end

-- Mouse
opt.mouse = "a"
