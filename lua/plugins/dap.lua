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
    },
    config = function ()
      util.dbg("setting dap")
      local dap = require('dap')

      -- This is used by simrat plugin
      dap.defaults.rt_lldb.exception_breakpoints = {'rust_panic'}
      -- This is used by mrcjkb plugin
      dap.defaults.lldb.exception_breakpoints = {'rust_panic'}
      dap.repl.commands.help = { '.help', '.h' }

      -- dap.set_exception_breakpoints({'rust_panic'})
    end
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
