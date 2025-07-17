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
        enabled = true
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
  { 'echasnovski/mini.nvim',
    version = false,
    event = "VeryLazy",
    config = function(_, _)
      require('mini.indentscope').setup({
        symbol = '│'
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
            local handle = lspu.progress_handle_take(args.data.request_id)
            if handle == nil then return end
            handle.message = handle.message .. " "
            handle:finish()
          else
            local handle = lspu.progress_handle_take(args.data.request_id)
            if handle == nil then return end
            handle.message = handle.message .. " "
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
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
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
            "focus_preview",
            desc = "Focus preview"
          },
          ["S"] = {
            "open_split",
            desc = "Open in new h-split"
          },
          -- ["S"] = "split_with_window_picker",
          ["s"] = {
            "open_vsplit",
            desc = "Open in new v-split"
          },
          ["g"] = {
            "open",
            nowait = true,
            desc = "Open",
          },
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
  { "sindrets/diffview.nvim",
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
  { 'Bekaboo/dropbar.nvim',
    opts = {
      bar = {
        pick = {
          pivots = 'asdfjkl;ghrtyuvbnm'
        }
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
    }
    -- optional, but required for fuzzy finder support
    -- dependencies = {
    --   'nvim-telescope/telescope-fzf-native.nvim'
    -- }
  },
  { "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys =
      util.map(
        config.mapping.get_filtered('flash'),
        util.key_canon_to_lazy
      ),
  }
}
