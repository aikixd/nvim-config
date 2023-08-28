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
    lazy = false,
    priority = config.plugin_priorities.legendary,
    config = function ()
      vim.cmd('colorscheme catppuccin-macchiato')
    end
  }
}
