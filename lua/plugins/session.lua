-- Sessions: get your open files back after Android kills Termux.
-- Sessions are saved automatically; restoring is manual (nothing opens by surprise).
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},

  keys = {
    {
      "<leader>ss",
      function()
        require("persistence").load()
      end,
      desc = "Restore session (this folder)",
    },
    {
      "<leader>sl",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Restore last session",
    },
    {
      "<leader>sd",
      function()
        require("persistence").stop()
      end,
      desc = "Do not save this session",
    },
  },
}
