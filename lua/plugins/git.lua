-- Git: change signs, hunk actions and blame (gitsigns.nvim)
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },

  opts = {
    signs = {
      add = { text = "┃" },
      change = { text = "┃" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },

    current_line_blame = false,

    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next hunk")

      map("[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Previous hunk")

      map("<leader>hp", gs.preview_hunk, "Preview hunk")
      map("<leader>hs", gs.stage_hunk, "Stage hunk")
      map("<leader>hr", gs.reset_hunk, "Reset hunk")
      map("<leader>hd", gs.diffthis, "Diff this file")

      map("<leader>hb", function()
        gs.blame_line({ full = true })
      end, "Blame line")

      map("<leader>hB", gs.toggle_current_line_blame, "Toggle inline blame")
    end,
  },
}
