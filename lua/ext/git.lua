local gitsigns = require('gitsigns')

local M = {}

function M.toggle_extended_info()
  gitsigns.toggle_linehl()
  gitsigns.toggle_numhl()
  gitsigns.toggle_deleted()
end

function M.gitsigns_actions()
  local actions = gitsigns.get_actions()

  local opts = {};

  for k, v in pairs(actions) do
    table.insert(opts, k)
  end

  vim.ui.select(opts, {
    prompt = 'Select an action'
  }, function(e, i) 
      vim.print(e .. i)
      actions[e]()
    end
  )
end

return M
