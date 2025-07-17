local config = require("config")
local util = require('util')

return {
  -- Handle vim.ui.select and vim.ui.input
  { 'stevearc/dressing.nvim',
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
  { "folke/which-key.nvim",
    -- enabled = false,
    event = "VeryLazy",
    init = function()
      -- vim.o.timeout = true
      -- vim.o.timeoutlen = 300
    end,
    opts = {
      triggers = {
        -- { "<auto>", mode = "nixsotc" },
        { "<leader>", mode = { "n", "v" } }
      },
    },
    config = function (_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add(config.mapping.groups)
    end
  },
  -- An icon picker
  { "ziontee113/icon-picker.nvim",
    opts = { disable_legacy_commands = true },
    event = 'VeryLazy',
    keys = util.map(
      config.mapping.get_filtered('icons'),
      util.key_canon_to_lazy
    ),
  },
  -- A theme
  { "catppuccin/nvim",
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
  -- A theme
  { "webhooked/kanso.nvim",
    lazy = false,
    priority = 10000,
    -- config = function (_, opts)
    --   require('kanso').setup(opts)
    --   vim.cmd([[colorscheme kanso]])
    -- end
  }
}
