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
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    opts = function ()
      require("util").dbg("setting cmp")

      local cmp = require('cmp')

      -- Create new hl groups with fg and bg swapped. Used for `kind` display.
      local default = vim.api.nvim_get_hl(0, { name = 'Normal' })
      local pref = 'CmpItemKind'
      for k, v in pairs(vim.api.nvim_get_hl(0, {})) do
        if string.sub(k, 0, string.len(pref)) == pref
           and v["link"] == nil -- CmpItemKind* all link to CmpItemKind
          then
          vim.api.nvim_set_hl(0, k.."Inv", { fg = default.bg, bg = v.fg })
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

            local kind_name = vim_item.kind
            vim_item.kind = " " .. (kind_icons[kind_name] or "?") .. " "
            vim_item.kind_hl_group = "CmpItemKind" .. kind_name .. "Inv"
            vim_item.menu = sources[entry.source.name]

            return vim_item
          end
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = false, }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
          ['.'] = cmp.mapping.confirm({ select = false }),
          ['('] = cmp.mapping.confirm({ select = false }),
          ['<M-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ['<M-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ['<M-u>'] = cmp.mapping.scroll_docs(-4),
          ['<M-m>'] = cmp.mapping.scroll_docs(4),
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

  -- Highlights
  {
    "RRethy/vim-illuminate",
    opts = {
      providers = {
        'lsp',
        'treesitter',
        'regex',
      },
      large_file_cutoff = 2500,
      large_file_overrides = { 'lsp' },
    },
    config = function (_, opts)
      local plugin = require('illuminate')
      plugin.configure(opts)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          vim.keymap.set("n", "]]", function() plugin.goto_next_reference(false) end, { buffer = buffer, desc = "Next occurence" })
          vim.keymap.set("n", "[[", function() plugin.goto_prev_reference(false) end, { buffer = buffer, desc = "Prev occurence" })
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    -- enabled = false,
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
