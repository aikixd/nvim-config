local util = require('util')
local config = require('config')

return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = util.map(
      config.mapping.get_filtered('trouble'),
      util.key_canon_to_lazy
    ),
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  }
}
