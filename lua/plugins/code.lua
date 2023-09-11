return {
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp"
  },
  {
    'hrsh7th/nvim-cmp',
    version = false,
    event = 'InsertEnter',

    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    opts = function ()
      local cmp = require('cmp')

      -- Swap fg and bg in the item kind groups to color icons in the cmp menu
      local default = vim.api.nvim_get_hl(0, { name = 'Normal' })
      local pref = 'CmpItemKind'
      for k, v in pairs(vim.api.nvim_get_hl(0, {})) do
        if string.sub(k, 0, string.len(pref)) == pref
           and v["link"] == nil -- CmpItemKind* all link to CmpItemKind
          then
          vim.api.nvim_set_hl(0, k, { fg = default.bg, bg = v.fg })
        end
      end

      return {
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function (entry, vim_item)
            -- TODO: extract the lists
            local kind_icons = {
              Text = "",
              Method = "󰆧",
              Function = "󰊕",
              Constructor = "",
              Field = "󰇽",
              Variable = "󰂡",
              Class = "󰠱",
              Interface = "",
              Module = "",
              Property = "󰜢",
              Unit = "",
              Value = "󰎠",
              Enum = "",
              Keyword = "󰌋",
              Snippet = "…",
              Color = "󰏘",
              File = "󰈙",
              Reference = "",
              Folder = "󰉋",
              EnumMember = "",
              Constant = "󰏿",
              Struct = "",
              Event = "",
              Operator = "󰆕",
              TypeParameter = "󰅲",
            }

            local sources = {
              buffer = "[󰧮]",
              nvim_lsp = "[󰅩]",
              luasnip = "[LuaSnip]",
              nvim_lua = "[Lua]",
              latex_symbols = "[Latex]",
            }

            vim_item.kind = " " .. (kind_icons[vim_item.kind] or "?") .. " "
            vim_item.menu = sources[entry.source.name]

            return vim_item
          end
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = false, }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        snippet = {
          expand = function(args)

            require('luasnip').lsp_expand(args.body)
          end
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'nvim_lua' },
          { name = 'path' },
          { name = 'buffer' },
        }),
        window = {
          completion = {
--            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
            col_offset = -3,

            side_padding = 0,
            -- border = 'rounded',
          },
        },
      }
    end
  },

  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    dependencies = {
      'nvim-treesitter/nvim-treesitter-refactor'
    },
    event = { "BufReadPost", "BufNewFile" },
    config = function ()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
          ensure_installed = { "lua", "vim", "vimdoc", "rust" },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },
          refactor = {
            highlight_definitions = {
              enable = false,
              clear_on_cursor_move = false,
            }
          }
        })
    end
  }
}
