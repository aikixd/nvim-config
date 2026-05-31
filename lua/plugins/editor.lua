local util = require('util')
local config = require('config')

return {
  { "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      debug = {
        enabled = true
      },
      notifier = {
        enabled = true
      },
      picker = {
        enabled = true,
        matcher = {
          history_bonus = true
        },
        win = {
          input = {
            keys = {
              ["u"] = { "preview_scroll_up", mode = {  "n" } },
              ["m"] = { "preview_scroll_down", mode = {  "n" } },
              ["<C-u>"] = { "preview_scroll_up", mode = {  "i", "n" } },
              ["<C-m>"] = { "preview_scroll_down", mode = {  "i", "n" } },
            }
          }
        },
      },
      profiler = {
        enabled = true
      }
    },
    keys = util.map(
      config.mapping.get_filtered('snacks'),
      util.key_canon_to_lazy
    ),
  },
  { 'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys =
      util.map(
        config.mapping.get_filtered('telescope'),
        util.key_canon_to_lazy
      ),
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-b>"] = "preview_scrolling_down",
          },
          n = {
            ["u"] = "preview_scrolling_up",
            ["m"] = "preview_scrolling_down",
            ["q"] = "close",
          }
        }
      },

      pickers = {
        buffers = {
          mappings = {
            n = {
              ["d"] = "delete_buffer"
            }
          }
        }
      }
    }
  },
  { "jmacadie/telescope-hierarchy.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim"
    },
  },
  { 'nvim-mini/mini.nvim',
    version = false,
    event = "VeryLazy",
    config = function(_, _)
      require('mini.indentscope').setup({
        symbol = '│',
        -- draw = { animation = require("mini.indentscope").gen_animation.none() },
        options = {
          n_lines = 70
        }
      })

      require('mini.ai').setup()

      require('mini.comment').setup({})
      require('mini.statusline').setup({
        content = {
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
            local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
            local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
            local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
            local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
            local location      = MiniStatusline.section_location({ trunc_width = 75 })
            local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

            return MiniStatusline.combine_groups({
              { hl = mode_hl,                  strings = { mode } },
              { hl = 'MiniStatuslineDevinfo',  strings = { diff, diagnostics, lsp } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl,                  strings = { search, location } },
            })
          end
        }
      })

      -- vim.keymap.del("n", "b")
      vim.keymap.set("n", "b", "<nop>")


      require('mini.surround').setup({
        mappings = {
          add = 'ba', -- Add surrounding in Normal and Visual modes
          delete = 'bd', -- Delete surrounding
          find = 'bf', -- Find surrounding (to the right)
          find_left = 'bF', -- Find surrounding (to the left)
          highlight = 'bh', -- Highlight surrounding
          replace = 'br', -- Replace surrounding
          update_n_lines = 'bn', -- Update `n_lines`
        },

        custom_surroundings = {
          ['g'] = {
            input = { '%f[%a_:][%w_:]+%b<>', '^.-<().*()>$' },
            output = function()
              local type_name = MiniSurround.user_input("Type name")
              if type_name == nil then return nil end
              return { left = ('%s<'):format(type_name), right = '>' }
            end
          }
        }
      })
    end
  },
  { "OXY2DEV/markview.nvim",
    enabled = false,
    lazy = false,
    priority = 900,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = util.map(
      config.mapping.get_filtered('markview'),
      util.key_canon_to_lazy
    ),
    opts = function()
      local presets = require("markview.presets")

      return {
        markdown = {
          enable = true,
          headings = presets.headings.glow,
          tables = vim.tbl_deep_extend("force", presets.tables.rounded, {
            -- Workaround for border drift when horizontally scrolling wide tables.
            strict = true,
            use_virt_lines = true,
            block_decorator = true,
          }),
        },
        markdown_inline = {
          enable = true,
          checkboxes = {
            enable = true,
          },
        },
        preview = {
          enable = true,
          debounce = 50,
          filetypes = { "markdown" },
          hybrid_modes = { "i" },
          icon_provider = "devicons",
          ignore_buftypes = { "nofile", "prompt", "help", "quickfix" },
          linewise_hybrid_mode = false,
          map_gx = false,
          max_buf_lines = 1000,
          modes = { "n", "no", "c" },
        },
      }
    end
  },
  { "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = util.map(
      config.mapping.get_filtered('render-markdown'),
      util.key_canon_to_lazy
    ),
    opts = {
      file_types = { "markdown" },
      render_modes = { "n", "c", "t" },
      anti_conceal = {
        enabled = false,
      },
      pipe_table = {
        enabled = true,
        cell = "padded",
        border_enabled = true,
        border_virtual = true,
      },
      win_options = {
        wrap = {
          default = true,
          rendered = false,
        },
      },
    },
  },
  { "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
    },
    enabled = false,
  },
  { "j-hui/fidget.nvim",
    opts = {
      progress = {
      }
    },
    config = function (_, opts)
      local fg = require("fidget")
      local fgp = require("fidget.progress")
      local lspu = require("ext.lsp")

      fg.setup(opts)

      vim.api.nvim_create_autocmd("LspRequest", {
        callback = function(args)
          if args.data.request.method == "textDocument/documentHighlight" then return end

          if args.data.request.type == "pending" then
            local handle = 
              fgp.handle.create({
                title = "LSP query",
                message = args.data.request.method,
                lsp_client = { name = args.data.client_id },
              })

            lspu.progress_handle_insert(args.data.request_id, handle)

          elseif args.data.request.type == "error" then
            local prog = lspu.progress_handle_take(args.data.request_id)
            if prog == nil then return end

            local handle = prog.handle
            handle.message = handle.message .. " "
            handle:finish()
          else
            local prog = lspu.progress_handle_take(args.data.request_id)
            if prog == nil then return end

            local handle = prog.handle
            handle.message = handle.message .. " ✔"
            handle:finish()
          end

        end
      })
    end
  },
  { "nvim-neo-tree/neo-tree.nvim",
    -- branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys =
      util.map(
        config.mapping.get_filtered('neo-tree'),
        util.key_canon_to_lazy
      ),
    opts = {
      async_directory_scan = "always",
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
      },
      document_symbols = {
        window = {
          mappings = {
            ["l"] = {
              "toggle_node",
              desc = "Toggle node",
            },
            ["h"] = {
              "close_node",
              desc = "Close node",
            }
          },
        }
      },
      window = {
        mappings = {
          ["<space>"] = {
            "toggle_node",
            nowait = true, -- disable `nowait` if you have existing combos starting with this char that you want to use
          },
          ["<2-LeftMouse>"] = {
            "open",
            desc = "Open"
          },
          ["<cr>"] = {
            "open",
            desc = "Open"

          },
          ["<esc>"] = {
            "cancel",
            desc = "Cancel",
          }, -- close preview or floating neo-tree window
          ["P"] = {
            "toggle_preview",
            config = { use_float = true },
            desc = "Toggle preview"
          },
          ["l"] = {
            "toggle_node",
            desc = "Toggle node",
          },
          -- ["l"] = {
          --   "focus_preview",
          --   desc = "Focus preview"
          -- },
          ["S"] = {
            "open_split",
            desc = "Open in new h-split"
          },
          -- ["S"] = "split_with_window_picker",
          ["s"] = {
            "open_vsplit",
            desc = "Open in new v-split"
          },
          -- ["g"] = {
          --   "open",
          --   nowait = true,
          --   desc = "Open",
          -- },
          -- ["s"] = "vsplit_with_window_picker",
          ["t"] = {
            "open_tabnew",
            desc = "Open in new tab"
          },
          -- ["<cr>"] = "open_drop",
          -- ["t"] = "open_tab_drop",
          ["w"] = {
            "open_with_window_picker",
            desc = "Open in picked window"
          },
          ["C"] = {
            "close_node",
            desc = "Close node"
          },
          ["z"] = {
            "close_all_nodes",
            desc = "Close all nodes"
          },
          --["Z"] = "expand_all_nodes",
          ["R"] = {
            "refresh",
            desc = "Refresh"
          },
          ["a"] = {
            "add",
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = "none", -- "none", "relative", "absolute"
            },
            desc = "Add item"
          },
          ["A"] = {
            "add_directory",
            desc = "Add directory"
          }, -- also accepts the config.show_path and config.insert_as options.
          ["d"] = {
            "delete",
            desc = "Delete"
          },
          ["r"] = {
            "rename",
            desc = "Rename"
          },
          ["y"] = {
            "copy_to_clipboard",
            desc = "Copy to clipboard"
          },
          ["x"] = {
            "cut_to_clipboard",
            desc = "Cut to clipboard"
          },
          ["p"] = {
            "paste_from_clipboard",
            desc = "Pase from clipboard"
          },
          ["c"] = {
            "copy",
            desc = "Copy"
          }, -- takes text input for destination, also accepts the config.show_path and config.insert_as options
          -- ["m"] = {
          --   "move",
          --   desc = "Move"
          -- }, -- takes text input for destination, also accepts the config.show_path and config.insert_as options
          ["e"] = {
            "toggle_auto_expand_width",
            desc = "Toggle auto-expand width"
          },
          ["q"] = {
            "close_window",
            desc = "Close window"
          },
          ["?"] = {
            "show_help",
            desc = "Show help"
          },
          ["<"] = {
            "prev_source",
            desc = "Previous source"
          },
          [">"] = {
            "next_source",
            desc = "Next source"
          },
        }
      },
    },
    config = function(_, opts)
      local defaults = require('neo-tree.defaults')
      if defaults.sources["document_symbols"] == nil then
        defaults.sources[#defaults.sources + 1] = "document_symbols"
        opts.sources = defaults.sources
      else
        vim.notify("Document symbols were added to neotree, remove the addition in config.", vim.log.levels.WARN)
      end

      require('neo-tree').setup(opts)
    end
    --init = function()
    --  if vim.fn.argc() == 1 then
    --    local stat = vim.loop.fs_stat(vim.fn.argv(0))
    --    if stat and stat.type == "directory" then
    --      require("neo-tree")
    --    end
    --  end
    --end,
  },
  { 'lewis6991/gitsigns.nvim',
    enabled = true,
    opts = {
      signs_staged_enable = true,
      current_line_blame_opts = {
        delay = 200,
        virt_text_pos = "right_align"
      },
      attach_to_untracked = true,
    },
    event = "BufAdd",
    keys =
      util.map(
        config.mapping.get_filtered('gitsigns'),
        util.key_canon_to_lazy
      ),
  },
  { "dlyongemallo/diffview.nvim",
    enabled = true,
    opts = {
      view = {
        default = {
          winbar_info = true
        },
        merge_tool = {
          layout = "diff4_mixed"
        }
      },
      keymaps = {
        disable_defaults = false
      }
    },
    keys =
      util.map(
        config.mapping.get_filtered('diffview'),
        util.key_canon_to_lazy
      ),
  },
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
  },
  { 'Bekaboo/dropbar.nvim',
    opts = {
      bar = {
        enable = function (bufnr, winnr, info)
          if vim.bo[bufnr].filetype == 'neo-tree' then
            return false
          end

          if vim.bo[bufnr].buftype ~= 'nofile' then
            return false
          end

          return require('dropbar.configs').opts.bar.enable(bufnr, winnr, info)
        end,
        pick = {
          pivots = 'asdfjkl;ghrtyuvbnm'
        },
        update_debounce = 220,
      },
      menu = {
        -- keymaps = {
        --   ['g'] = function() 
        --     local utils = require('dropbar/utils')
        --     local u = require('util')
        --     local menu = utils.menu.get_current()
        --     local bar = utils.bar.get_current()
        --
        --
        --     vim.print('---')
        --     -- u.print_buf(utils.bar.get({  }))
        --     vim.print(bar)
        --     vim.print('---')
        --     vim.print(menu.prev_buf)
        --     -- vim.print(menu.prev_menu == nil)
        --
        --     vim.print('---')
        --     -- vim.print(menu.prev_menu.symbol_previewed.name)
        --   end
        -- }
      }
    },
    config = function (_, opts)
      local p = require('dropbar')
      local c = require('dropbar.configs')

      local default_enable = c.opts.bar.enable
      local enable = function (bufnr, winnr, info)
          if vim.bo[bufnr].filetype == 'neo-tree' then
            return false
          end

          if vim.bo[bufnr].buftype ~= 'nofile' then
            return false
          end

          return default_enable(bufnr, winnr, info)
        end

      opts.bar.enable = enable

      p.setup(opts)
    end,
    -- optional, but required for fuzzy finder support
    -- dependencies = {
    --   'nvim-telescope/telescope-fzf-native.nvim'
    -- }
    enabled = false,
  },
  { "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys =
      util.map(
        config.mapping.get_filtered('flash'),
        util.key_canon_to_lazy
      ),
  },
  {
    "hasansujon786/super-kanban.nvim",
    dependencies = {
      "folke/snacks.nvim",           -- [required]
      "nvim-orgmode/orgmode",        -- [optional] Org format support
    },
    opts = {}, -- optional: pass your config table here
  },
  {
    dir = "/home/aikixd/Dev/playground/flameline.nvim",
    -- enabled = false,
    name = "flameline",
    config = function()
      require("flameline").setup({
        colors = {
          hot = "#ecc067",
        },
        debug = false,
        heat = {
          edit = 0.3,
          move = 0.3,
          dwell = 0.5,
          spurious_move_factor = 0.1, -- Multiplier for lazy/spurious moves
          propagation_falloff = false, -- If true, heat reduces linearly with distance from center
        },
        models = {
          growth = require('flameline.core').create_logistic_profile(5, 0.5),
          decay = require('flameline.core').create_retention_profile(5, 0.5)
        },
        normalization = {
          enabled = true
        },
        radius = {
          edit = 6,
          move = 3,
          dwell = 6,
        },
      })
    end,
    -- Ensure it loads for relevant files
    event = { "BufReadPost", "BufNewFile" },
  }
}
