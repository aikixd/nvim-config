local config = require("config")

return { 
  -- Handle vim.ui.select and vim.ui.input
  {
    'stevearc/dressing.nvim',
    opts = {
      select = {
        builtin = {
          win_options = {
            winblend = 0;
          }
        }
      }
    },
  },
  -- Key helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      hidden = {},
    },
    config = function (_, otps)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(config.mapping.groups)
    end
  },

  {
    'freddiehaddad/feline.nvim',
    dependencies = {
      'catppuccin'
    },
    config = function (_, _)
      -- Adapted from catppuccin feline integration
      local C = require("catppuccin.palettes").get_palette("macchiato")
      local assets = {
        left_separator = "",
        right_separator = "",
        mode_icon = "",
        dir = "󰉖",
        file = "󰈙",
        lsp = {
          server = "󰅡",
          error = "",
          warning = "",
          info = "",
          hint = "",
        },
        git = {
          branch = "",
          added = "",
          changed = "",
          removed = "",
        },
      }
      local sett = {
        text = C.mantle,
        bkg = C.mantle,
        diffs = C.mauve,
        extras = C.overlay1,
        curr_file = C.maroon,
        curr_dir = C.flamingo,
        show_modified = false,
      }
      local mode_colors = {
        ["n"] = { "NORMAL", C.lavender },
        ["no"] = { "N-PENDING", C.lavender },
        ["i"] = { "INSERT", C.green },
        ["ic"] = { "INSERT", C.green },
        ["t"] = { "TERMINAL", C.green },
        ["v"] = { "VISUAL", C.flamingo },
        ["V"] = { "V-LINE", C.flamingo },
        ["␖"] = { "V-BLOCK", C.flamingo },
        ["R"] = { "REPLACE", C.maroon },
        ["Rv"] = { "V-REPLACE", C.maroon },
        ["s"] = { "SELECT", C.maroon },
        ["S"] = { "S-LINE", C.maroon },
        ["␓"] = { "S-BLOCK", C.maroon },
        ["c"] = { "COMMAND", C.peach },
        ["cv"] = { "COMMAND", C.peach },
        ["ce"] = { "COMMAND", C.peach },
        ["r"] = { "PROMPT", C.teal },
        ["rm"] = { "MORE", C.teal },
        ["r?"] = { "CONFIRM", C.mauve },
        ["!"] = { "SHELL", C.green },
      }
      local one_monokai = {
        fg = "#abb2bf",
        bg = "#1e2024",
        green = "#98c379",
        yellow = "#e5c07b",
        purple = "#c678dd",
        orange = "#d19a66",
        peanut = "#f6d5a4",
        red = "#e06c75",
        aqua = "#61afef",
        darkblue = "#282c34",
        dark_red = "#f75f5f",
      }

      local vi_mode_colors = {
        NORMAL = "green",
        OP = "green",
        INSERT = "yellow",
        VISUAL = "purple",
        LINES = "orange",
        BLOCK = "dark_red",
        REPLACE = "red",
        COMMAND = "aqua",
      }

      local c = {
        vim_mode = {
          provider = {
            name = "vi_mode",
            opts = {
              show_mode_name = true,
              -- padding = "center", -- Uncomment for extra padding.
            },
          },
          hl = function()
            return {
              fg = sett.text,
              bg = mode_colors[vim.api.nvim_get_mode().mode][2],
              style = "bold",
              --name = "NeovimModeHLColor",
            }
          end,
          left_sep = "block",
          right_sep = "block",
        },
        gitBranch = {
          provider = "git_branch",
          hl = {
            fg = C.text,
            bg = "darkblue",
            style = "bold",
          },
          left_sep = "block",
          right_sep = "block",
        },
        gitDiffAdded = {
          provider = "git_diff_added",
          hl = {
            fg = "green",
            bg = "darkblue",
          },
          left_sep = "block",
          right_sep = "block",
        },
        gitDiffRemoved = {
          provider = "git_diff_removed",
          hl = {
            fg = "red",
            bg = "darkblue",
          },
          left_sep = "block",
          right_sep = "block",
        },
        gitDiffChanged = {
          provider = "git_diff_changed",
          hl = {
            fg = "fg",
            bg = "darkblue",
          },
          left_sep = "block",
          right_sep = "right_filled",
        },
        separator = {
          provider = "",
        },
        fileinfo = {
          provider = {
            name = "file_info",
            opts = {
              type = "relative-short",
            },
          },
          hl = {
            style = "bold",
          },
          left_sep = " ",
          right_sep = " ",
        },
        diagnostic_errors = {
          provider = "diagnostic_errors",
          hl = {
            fg = "red",
          },
        },
        diagnostic_warnings = {
          provider = "diagnostic_warnings",
          hl = {
            fg = "yellow",
          },
        },
        diagnostic_hints = {
          provider = "diagnostic_hints",
          hl = {
            fg = "aqua",
          },
        },
        diagnostic_info = {
          provider = "diagnostic_info",
        },
        lsp_client_names = {
          provider = "lsp_client_names",
          hl = {
            fg = "purple",
            bg = "darkblue",
            style = "bold",
          },
          left_sep = "left_filled",
          right_sep = "block",
        },
        file_type = {
          provider = {
            name = "file_type",
            opts = {
              filetype_icon = true,
              case = "titlecase",
            },
          },
          hl = {
            fg = "red",
            bg = "darkblue",
            style = "bold",
          },
          left_sep = "block",
          right_sep = "block",
        },
        file_encoding = {
          provider = "file_encoding",
          hl = {
            fg = "orange",
            bg = "darkblue",
            style = "italic",
          },
          left_sep = "block",
          right_sep = "block",
        },
        position = {
          provider = "position",
          hl = {
            fg = "green",
            bg = "darkblue",
            style = "bold",
          },
          left_sep = "block",
          right_sep = "block",
        },
        line_percentage = {
          provider = "line_percentage",
          hl = {
            fg = "aqua",
            bg = "darkblue",
            style = "bold",
          },
          left_sep = "block",
          right_sep = "block",
        },
        scroll_bar = {
          provider = {
            name = "scroll_bar",
            opts = {
              reverse = true
            }
          },
          hl = {
            fg = "yellow",
            style = "bold",
          },
        },
      }

      local left = {
        c.vim_mode,
        c.gitBranch,
        c.gitDiffAdded,
        c.gitDiffRemoved,
        c.gitDiffChanged,
        c.separator,
        c.fileinfo,
        c.diagnostic_errors,
        c.diagnostic_warnings,
        c.diagnostic_info,
        c.diagnostic_hints,
      }

      local middle = {
      }

      local right = {
        c.lsp_client_names,
        c.file_type,
        c.file_encoding,
        c.position,
        c.line_percentage,
        c.scroll_bar,
      }

      local components = {
        active = {
          left,
          middle,
          right,
        },
        inactive = {
          left,
          middle,
          right,
        },
      }

      require('feline').setup({
        components = components,
        theme = one_monokai,
        vi_mode_colors = vi_mode_colors,
      })
    end
  },

-- Disabled till I will want to figure out how to make it work with ehich-key, if ever.
--
--  {
--     'mrjones2014/legendary.nvim',
--     -- sqlite is only needed if you want to use frecency sorting
--     -- dependencies = { 'kkharji/sqlite.lua' }
--     priority = config.plugin_priorities.legendary,
--     lazy = false,
--     opts = { 
--       lazy_nvim = { auto_register = true },
--       which_key = { auto_register = true },
--     },
--     config = function (_, opts)
--       require('legendary').setup(opts)
--       
--     end
--  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 10000,
    opts = {
      flavour = "macchiato",
      term_colors = true,
      integrations = {
        neotree = true
      }
    },
    config = function (_, opts)
      require('catppuccin').setup(opts)
      vim.cmd([[colorscheme catppuccin]])
    end
  },
  {
    "ziontee113/icon-picker.nvim",
    opts = { disable_legacy_commands = true }
  }
}
