-- Global keymaps. Plugin keymaps live next to their plugin spec.
local map = vim.keymap.set

-- Save
map("n", "<C-s>", "<cmd>write<CR>", { desc = "Save file" })
map("i", "<C-s>", "<Esc><cmd>write<CR>", { desc = "Save file" })
map("v", "<C-s>", "<Esc><cmd>write<CR>", { desc = "Save file" })

-- Quit
map("n", "<C-q>", "<cmd>quit<CR>", { desc = "Quit Neovim" })
map("n", "<C-x>", "<cmd>x<CR>", { desc = "Save and quit" })
map("n", "<C-n>", "<cmd>quit!<CR>", { desc = "Quit without saving" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<leader>wq", "<cmd>wq<CR>", { desc = "Save and quit" })

-- Whole-file helpers
map("n", "<C-d>", "ggdG", { desc = "Delete all text" })
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Move selected lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the cursor centered
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
map("n", "n", "nzzzv", { desc = "Next match" })
map("n", "N", "Nzzzv", { desc = "Previous match" })

-- Terminal
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
