local util = require('util')
local config = require('config')

return {
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    keys = util.map(
      config.mapping.get_filtered('dap'),
      util.key_canon_to_lazy
    ),
    dependencies = {
      'nvim-dap-ui'
    }
  },
  {
    'rcarriga/nvim-dap-ui',
    keys = util.map(
      config.mapping.get_filtered('dap-ui'),
      util.key_canon_to_lazy
    ),
    opts = {
      layouts = {
        {
          -- You can change the order of elements in the sidebar
          elements = {
            -- For some reason the elements are ordered reversed.
            { id = "breakpoints", size = 0.25 },
            { id = "watches", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "scopes", size = 0.25 },
          },
          size = 40,
          position = "left", -- Can be "left" or "right"
        },
        {
          elements = {
            "console",
            "repl",
          },
          size = 10,
          position = "bottom", -- Can be "bottom" or "top"
        },
      },
    },
    config = function(_, opts)
      local dap = require('dap')
      local dapui = require('dapui')
      dapui.setup(opts)

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  }
}
