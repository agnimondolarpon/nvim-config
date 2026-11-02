-- Treesitter (main branch).
-- Parsers are installed manually with :TSInstallMine.
-- Needs: tree-sitter CLI >= 0.26.1, a C compiler, curl, tar.
-- If those are missing Neovim keeps working with regex highlighting.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,

  config = function()
    local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

    -- Start highlighting only when a parser exists
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    vim.api.nvim_create_user_command("TSInstallMine", function()
      if vim.fn.executable("tree-sitter") == 0 then
        vim.notify("tree-sitter CLI not found", vim.log.levels.WARN)
        return
      end

      local out = vim.fn.system({ "tree-sitter", "--version" })
      local major, minor, patch = out:match("(%d+)%.(%d+)%.(%d+)")

      major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)

      local version_ok = major ~= nil
        and (major > 0 or minor > 26 or (minor == 26 and patch >= 1))

      if not version_ok then
        vim.notify(
          "tree-sitter CLI must be >= 0.26.1 (found: " .. vim.trim(out) .. ")",
          vim.log.levels.WARN
        )
        return
      end

      require("nvim-treesitter").install({
        "c",
        "cpp",
        "python",
        "bash",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "json",
        "yaml",
        "toml",
        "java",
        "go",
        "rust",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "regex",
        "diff",
        "markdown",
        "markdown_inline",
      })
    end, { desc = "Install my treesitter parsers" })
  end,
}
