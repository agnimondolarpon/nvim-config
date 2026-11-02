-- <F5>: run the current file in a terminal split.
-- bin  = program that must exist
-- hint = how to install it
-- cmd  = builds the shell command (f = escaped file, o = escaped path without extension)
local runners = {
  c = {
    bin = "clang",
    hint = "pkg install clang",
    cmd = function(f, o)
      return "clang -Wall -Wextra -std=c17 " .. f .. " -o " .. o .. " && " .. o
    end,
  },

  cpp = {
    bin = "clang++",
    hint = "pkg install clang",
    cmd = function(f, o)
      return "clang++ -Wall -Wextra -std=c++17 " .. f .. " -o " .. o .. " && " .. o
    end,
  },

  python = {
    bin = "python",
    hint = "pkg install python",
    cmd = function(f)
      return "python " .. f
    end,
  },

  javascript = {
    bin = "node",
    hint = "pkg install nodejs",
    cmd = function(f)
      return "node " .. f
    end,
  },

  typescript = {
    bin = "node",
    hint = "pkg install nodejs (recent version)",
    cmd = function(f)
      return "node " .. f
    end,
  },

  lua = {
    bin = "nvim",
    hint = "pkg install neovim",
    cmd = function(f)
      return "nvim -l " .. f
    end,
  },

  sh = {
    bin = "bash",
    hint = "pkg install bash",
    cmd = function(f)
      return "bash " .. f
    end,
  },

  go = {
    bin = "go",
    hint = "pkg install golang",
    cmd = function(f)
      return "go run " .. f
    end,
  },

  rust = {
    bin = "rustc",
    hint = "pkg install rust",
    cmd = function(f, o)
      return "rustc " .. f .. " -o " .. o .. " && " .. o
    end,
  },

  java = {
    bin = "java",
    hint = "pkg install openjdk-17",
    cmd = function(f)
      return "java " .. f
    end,
  },

  ruby = {
    bin = "ruby",
    hint = "pkg install ruby",
    cmd = function(f)
      return "ruby " .. f
    end,
  },

  php = {
    bin = "php",
    hint = "pkg install php",
    cmd = function(f)
      return "php " .. f
    end,
  },

  perl = {
    bin = "perl",
    hint = "pkg install perl",
    cmd = function(f)
      return "perl " .. f
    end,
  },
}

runners.bash = runners.sh
runners.zsh = runners.sh

local function run_file()
  local file = vim.fn.expand("%:p")
  local output = vim.fn.expand("%:p:r")
  local ft = vim.bo.filetype

  if file == "" then
    vim.notify("Save the file first", vim.log.levels.WARN)
    return
  end

  local runner = runners[ft]

  if not runner then
    vim.notify("Unsupported filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  if vim.fn.executable(runner.bin) == 0 then
    vim.notify(runner.bin .. " not found. Try: " .. runner.hint, vim.log.levels.WARN)
    return
  end

  if vim.bo.modified then
    vim.cmd("write")
  end

  local cmd = runner.cmd(vim.fn.shellescape(file), vim.fn.shellescape(output))

  vim.cmd("botright 12split")
  vim.cmd("terminal " .. cmd)
end

vim.keymap.set("n", "<F5>", run_file, { desc = "Run current file" })
