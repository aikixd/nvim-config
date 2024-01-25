local util = require('util')
local config = require('config')

return {
  {
    'nvim-telescope/telescope.nvim',
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
  {
    'echasnovski/mini.nvim',
    version = false,
    event = "VeryLazy",
    config = function(_, _)
      require('mini.indentscope').setup({
        symbol = '│'
      })

      require('mini.comment').setup({
      })
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = { }
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
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
            nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
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
            desc = "Open"
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
          ["m"] = {
            "move",
            desc = "Move"
          }, -- takes text input for destination, also accepts the config.show_path and config.insert_as options
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
  {
    'lewis6991/gitsigns.nvim',
    opts = {}
  },
  {
    "sindrets/diffview.nvim",
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
        disable_defaults = true
      }
    },
    keys =
      util.map(
        config.mapping.get_filtered('diffview'),
        util.key_canon_to_lazy
      ),
  },
  {
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    -- dependencies = {
    --   'nvim-telescope/telescope-fzf-native.nvim'
    -- }
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys =
      util.map(
        config.mapping.get_filtered('flash'),
        util.key_canon_to_lazy
      ),
  }
}
