local util = require('util')
local config = require('config')

return {
  { "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp"
  },
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = {
        preset = 'super-tab',
        -- cmdline = {
        --   ['<Space>'] = { 'hide', 'fallback' },
        -- },

        --   ['<C-e>'] = cmp.mapping.abort(),
        --   ['<CR>'] = cmp.mapping.confirm({ select = false, }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        --   ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        --   -- ['.'] = cmp.mapping.confirm({ select = false }),
        --   -- ['('] = cmp.mapping.confirm({ select = false }),
        --   ['<M-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        --   ['<M-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        --   ['<M-u>'] = cmp.mapping.scroll_docs(-4),
        --   ['<M-m>'] = cmp.mapping.scroll_docs(4),

        ['<Tab>'] = false, -- { 'accept', 'fallback' },
        ['<M-k>'] = { 'select_prev', 'fallback' },
        ['<M-j>'] = { 'select_next', 'fallback' },
        ['<M-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<M-m>'] = { 'scroll_documentation_down', 'fallback' },

      -- disable a keymap from the preset
      -- ['<C-e>'] = false, -- or {}

      -- show with a list of providers
      -- ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },

      -- control whether the next command will be run when using a function
      -- ['<C-n>'] = {
      --   function(cmp)
      --     if some_condition then return end -- runs the next command
      --     return true -- doesn't run the next command
      --   end,
      --   'select_next'
      -- },
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = {
        documentation = { auto_show = true },
        accept = {
          auto_brackets = { enabled = true },
        },
        list = {
          selection = {
            auto_insert = false
          }
        },
        ghost_text = {
          enabled = true,
        }
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" },
    config = function (_, opts)
      require("blink-cmp").setup(opts)
    end
  },
  { 'hrsh7th/nvim-cmp',
    enabled = false,
    version = false,
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    opts = function ()
      require("util").dbg("setting cmp")

      local cmp = require('cmp')
      local compare = require('cmp.config.compare')
      local types = require('cmp.types')

      -- An attempt to change the order of the items in the list.
      local compare_kind = function (left, right)
        local kind1 = left:get_kind()  --- @type lsp.CompletionItemKind | number
        local kind2 = right:get_kind() --- @type lsp.CompletionItemKind | number

        -- if kind1 == types.lsp.CompletionItemKind.Field then return true end
        -- if kind2 == types.lsp.CompletionItemKind.Field then return false end
        --
        -- if kind1 == types.lsp.CompletionItemKind.Snippet then return false end
        -- if kind2 == types.lsp.CompletionItemKind.Snippet then return true end
        -- Fallback to default
        return compare.kind(left, right)
      end

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

            -- For some reason snippets are duplicated
            if kind_name == "Snippet" then vim_item.dup = 0 end

            return vim_item
          end
        },
        -- mapping = cmp.mapping.preset.insert({
        --   ['<C-Space>'] = cmp.mapping.complete(),
        --   ['<C-e>'] = cmp.mapping.abort(),
        --   ['<CR>'] = cmp.mapping.confirm({ select = false, }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        --   ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        --   -- ['.'] = cmp.mapping.confirm({ select = false }),
        --   -- ['('] = cmp.mapping.confirm({ select = false }),
        --   ['<M-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        --   ['<M-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        --   ['<M-u>'] = cmp.mapping.scroll_docs(-4),
        --   ['<M-m>'] = cmp.mapping.scroll_docs(4),
        -- }),
        snippet = {
          expand = function(args)

            require('luasnip').lsp_expand(args.body)
          end
        },
        sorting = {
          comparators = {
            compare.offset,
            compare.exact,
            -- compare.scopes,
            compare.score,
            compare.recently_used,
            compare.locality,
            compare_kind, -- Wraps compare.kind
            compare.sort_text,
            -- compare.length,
            compare.order,
          },
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
            autocomplete = false,
            -- border = 'rounded',
          },
        },
        performance = {
          max_view_entries = 100,
          debounce = 160,
          throttle = 80,
          filtering_context_budget = 30,
        }
      }
    end,
    config = function (_, opts)
      local cmp = require('cmp')

      cmp.setup(opts)

      cmp.event:on("menu_opened", function()
        vim.b.copilot_suggestion_hidden = true
      end)

      cmp.event:on("menu_closed", function()
        vim.b.copilot_suggestion_hidden = false
      end)
    end
  },
  { 'saghen/blink.pairs',
    dependencies = 'saghen/blink.lib',

    version = '*',
    -- download prebuilt binaries from github releases, must be on a versioned release
    build = function() require('blink.pairs').download():pwait(60000) end,

    --- @module 'blink.pairs'
    --- @type blink.pairs.Config
    opts = {
      mappings = {
        -- you can call require("blink.pairs.mappings").enable()
        -- and require("blink.pairs.mappings").disable()
        -- to enable/disable mappings at runtime
        enabled = true,
        -- cmdline = true,
        -- or disable with `vim.g.pairs = false` (global) and `vim.b.pairs = false` (per-buffer)
        -- and/or with `vim.g.blink_pairs = false` and `vim.b.blink_pairs = false`
        disabled_filetypes = {},
        -- see the defaults:
        -- https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L14
        pairs = {},
      },
      highlights = {
        enabled = true,
        -- requires require('vim._extui').enable({}), otherwise has no effect
        -- cmdline = true,
        groups = {
          -- 'BlinkPairsOrange',
          -- 'BlinkPairsPurple',
          -- 'BlinkPairsBlue',
          'RainbowDelimiterBlue',
          'RainbowDelimiterCyan',
          'RainbowDelimiterGreen',
          'RainbowDelimiterOrange',
          'RainbowDelimiterRed',
          'RainbowDelimiterViolet',
          'RainbowDelimiterYellow',
        },
        -- unmatched_group = 'BlinkPairsUnmatched',

        -- highlights matching pairs under the cursor
        matchparen = {
          enabled = true,
          -- known issue where typing won't update matchparen highlight, disabled by default
          -- cmdline = false,
          group = 'BlinkPairsMatchParen',
        },
      },
      debug = false,
    }
  },
  -- Highlights
  { "RRethy/vim-illuminate",
    opts = {
      providers = {
        'lsp',
        'treesitter',
        'regex',
      },
      delay = 180,
      large_file_cutoff = 2500,
      large_file_overrides = { 'lsp' },
    },
    config = function (_, opts)

      
      local plugin = require('illuminate')
      plugin.configure(opts)

      local key_tmpl = config.mapping.get_filtered('illuminate')

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          if vim.bo.filetype == "codecompanion" then
            return
          end

          local buffer = vim.api.nvim_get_current_buf()

          local dir_map = {
            ["[["] = plugin.goto_prev_reference,
            ["]]"] = plugin.goto_next_reference,
          }

          for _, k in ipairs(key_tmpl) do
            local fn = dir_map[k.lhs]
            if fn then
              vim.keymap.set("n", k.lhs, function() fn(false) end, { buffer = buffer, desc = k.desc })
            else
              vim.notify(
                ("illuminate: unexpected lhs '%s' for desc '%s'")
                  :format(tostring(k.lhs), tostring(k.desc)),
                vim.log.levels.WARN)
            end
          end

        end,
      })
    end,
  },
  { "nvim-treesitter/nvim-treesitter",
    -- enabled = false,
    build = ":TSUpdate",
    branch = "main",
    dependencies = {
      -- This is deprecated. Leaving here lest I forget to find a replacement.
      -- 'nvim-treesitter/nvim-treesitter-refactor'
    },
    event = { "BufReadPost", "BufNewFile" },
    config = function ()
      local ts = require("nvim-treesitter")

      -- ts.setup()

      ts.install({
        "html",
        "lua",
        "markdown",
        "markdown_inline",
        "rust",
        "vim",
        "vimdoc",
        "yaml",
    })
    end
  }
}
