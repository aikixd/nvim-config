local config = require("config")
local util = require('util')

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
      triggers = {
        { "<auto>", mode = "nixsotc" },
        -- { "<C-\\>", mode = { "n", "v" } },
        -- { "a", mode = { "n", "v" } },
      }
    },
    config = function (_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      -- wk.register(config.mapping.groups)
      wk.add(config.mapping.groups)
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
    opts = { disable_legacy_commands = true },
    event = 'VeryLazy',
    keys = util.map(
      config.mapping.get_filtered('icons'),
      util.key_canon_to_lazy
    ),
  }
}
