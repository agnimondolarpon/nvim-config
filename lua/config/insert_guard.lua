-- Insert mode only with "i".
-- Every other key that starts insert, replace or select mode is disabled,
-- so accidental multi-key presses on a touch keyboard cannot start typing.
-- Toggle with :InsertGuard.
local map = vim.keymap.set

local insert_keys = {
  n = {
    "a", "A", "I", "o", "O",
    "s", "S", "c", "C", "R",
    "gi", "gI", "gR",
    "gh", "gH",
    "<Insert>",
  },

  x = {
    "c", "s", "C", "S", "R",
    "I", "A",
    "<C-g>",
  },
}

local enabled = false

local function set_guard(on)
  for mode, keys in pairs(insert_keys) do
    for _, key in ipairs(keys) do
      if on then
        map(mode, key, "<Nop>", { desc = "Disabled (use i)" })
      else
        pcall(vim.keymap.del, mode, key)
      end
    end
  end

  enabled = on
end

set_guard(true)

vim.api.nvim_create_user_command("InsertGuard", function()
  set_guard(not enabled)
  vim.notify("InsertGuard: " .. (enabled and "ON" or "OFF"))
end, { desc = "Toggle insert-only-with-i protection" })
