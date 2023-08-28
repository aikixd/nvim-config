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
      vim.print('abc')
      return {
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function (entry, vim_item)
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
              Snippet = "",
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
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
            
            local strings = vim.split(vim_item.kind, "%s", { trimempty = true })
            vim_item.kind = " " .. (strings[1] or "") .. " "

            
            vim_item.menu = " (" .. (strings[2] or "") .. ") " .. sources[entry.source.name] 

            

            --vim_item.menu = ({
            --  buffer = "[󰧮]",
            --  nvim_lsp = "[󰅩]",
            --  luasnip = "[LuaSnip]",
            --  nvim_lua = "[Lua]",
            --  latex_symbols = "[Latex]",
            --})[entry.source.name]
            return vim_item
          end
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),

          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        snippet = {
          expand = function(args)
            
            require('luasnip').lsp_expand(args.body)
          end
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer' },
        }),
        window = {
          completion = {
--            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
            col_offset = -3,

            side_padding = 0,
          },
        },
      }
    end
  }
}
