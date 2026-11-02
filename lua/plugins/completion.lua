-- Completion: nvim-cmp (pure Lua, no binaries to download)
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",

  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },

  config = function()
    local cmp = require("cmp")

    cmp.setup({
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },

      completion = {
        completeopt = "menu,menuone,noselect",
        keyword_length = 2,
      },

      performance = {
        debounce = 60,
        throttle = 30,
        max_view_entries = 12,
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),

        -- Enter confirms only a selected item
        ["<CR>"] = cmp.mapping.confirm({ select = false }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = 1 }) then
            vim.snippet.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.snippet.active({ direction = -1 }) then
            vim.snippet.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "path" },
      }, {
        { name = "buffer", keyword_length = 3 },
      }),

      formatting = {
        format = function(entry, item)
          item.menu = ({
            nvim_lsp = "[LSP]",
            buffer = "[Buf]",
            path = "[Path]",
          })[entry.source.name]

          return item
        end,
      },
    })
  end,
}
