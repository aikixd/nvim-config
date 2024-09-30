return {
  {
    'freddiehaddad/feline.nvim',
    enabled = true,
    dependencies = {
      'catppuccin'
    },
    config = function (_, _)
      -- Adapted from catppuccin feline integration
      local clr = require("catppuccin.palettes").get_palette("macchiato") or {}
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
        text = clr.mantle,
        bkg = clr.mantle,
        diffs = clr.mauve,
        extras = clr.overlay1,
        curr_file = clr.maroon,
        curr_dir = clr.flamingo,
        show_modified = false,
      }
      local mode_colors = {
        ["n"] = { "NORMAL", clr.lavender },
        ["no"] = { "N-PENDING", clr.lavender },
        ["i"] = { "INSERT", clr.green },
        ["ic"] = { "INSERT", clr.green },
        ["t"] = { "TERMINAL", clr.green },
        ["v"] = { "VISUAL", clr.flamingo },
        ["V"] = { "V-LINE", clr.flamingo },
        ["␖"] = { "V-BLOCK", clr.flamingo },
        ["R"] = { "REPLACE", clr.maroon },
        ["Rv"] = { "V-REPLACE", clr.maroon },
        ["s"] = { "SELECT", clr.maroon },
        ["S"] = { "S-LINE", clr.maroon },
        ["␓"] = { "S-BLOCK", clr.maroon },
        ["c"] = { "COMMAND", clr.peach },
        ["cv"] = { "COMMAND", clr.peach },
        ["ce"] = { "COMMAND", clr.peach },
        ["r"] = { "PROMPT", clr.teal },
        ["rm"] = { "MORE", clr.teal },
        ["r?"] = { "CONFIRM", clr.mauve },
        ["!"] = { "SHELL", clr.green },
      }
      local theme = {
        fg = clr.text,
        bg = clr.mantle,
        green = clr.green,
        yellow = clr.yellow,
        purple = clr.mauve,
        orange = clr.peach,
        peanut = "#f6d5a4",
        red = clr.red,
        aqua = clr.sapphire,
        darkblue = clr.crust,
        dark_red = clr.flamingo,
      }

      local c = {
        vim_mode = {
          provider = {
            name = "vi_mode",
            opts = {
              show_mode_name = true,
            },
          },
          hl = function()
            local mode_color = mode_colors[vim.api.nvim_get_mode().mode]

            if mode_color == nil
            then
              vim.api.nvim_notify(
                "No color found for mode '" .. vim.api.nvim_get_mode().mode .. "'",
                vim.log.levels.WARN,
                {})
              mode_color = mode_colors['n']
            end

            return {
              fg = sett.text,
              bg = mode_color[2],
              style = "bold",
            }
          end,
          left_sep = "block",
          right_sep = "block",
        },
        gitIcon = { 
          provider = "  ", 
          hl = {
            fg = clr.overlay1,
            bg = clr.surface0
          },
        },
        gitIconSep = {
          provider = "",
          hl = { fg = clr.surface0 }
        },
        gitBranch = {
          provider = "git_branch",
          hl = {
            fg = clr.text,
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
              type = "relative",
            },
          },
          short_provider = {
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
            fg = "bg",
            bg = "yellow",
            style = "bold",
          },
        },
      }

      local left = {
        c.vim_mode,
        c.gitIcon,
        c.gitIconSep,
        -- c.gitBranch,
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


      local left_x = {
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
          left_x,
          middle,
          right,
        },
      }

      local c_components = {
        {
          condition = function ()
            return vim.api.nvim_buf_get_option(0, 'filetype') == 'neo-tree'
          end,
          active = {
            { },
            { c.file_type },
          },
          inactive = {
            { },
            { c.file_type }
          }
        },
        {
          condition = function ()
            return vim.api.nvim_buf_get_option(0, 'filetype') == 'qf'
          end,
          active = {
            { 
              { provider = function() return "> " .. vim.api.nvim_win_get_var(0, "quickfix_title") end } 
            },
            { c.file_type,
              c.line_percentage, 
              c.scroll_bar },
          },
          inactive = {
            { 
              { provider = function() return "> " .. vim.api.nvim_win_get_var(0, "quickfix_title") end } 
            },
            { c.file_type,
              c.line_percentage, 
              c.scroll_bar },
          }
        }
      }

      require('feline').setup({
        components = components,
        conditional_components = c_components,
        theme = theme,
      })
    end
  }}
