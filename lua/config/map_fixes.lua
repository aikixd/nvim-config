local util = require('util')

local function buffer_fix_maps(descs, hide)
  local map = vim.api.nvim_buf_get_keymap(0, "n")
  
  local maps = {}


  print(vim.bo.filetype)

  vim.defer_fn(function () print(vim.inspect(vim.api.nvim_buf_get_keymap(0, "n"))) end, 1500)

  for _, m in ipairs(map) do
    if descs[m.lhs] then
      maps[m.lhs] = { 
      m.rhs, 
      descs[m.lhs], 
      buffer = 0,
      expr = m.expr,
      noremap = m.noremap,
      silent = m.silent }
    end
  end

  for _, m in ipairs(hide) do
    maps[m] = { "which_key_ignore", buffer = 0 }
  end

  local wk = require("which-key")
  wk.register(maps)
end

local M = { }

function M.neo_tree()
  if vim.b.neo_tree_fixed then return end

  vim.b.neo_tree_fixed = true

  local descs = {
    ["a"] = "Create item"
  }

  local hide = {
  }

  buffer_fix_maps(descs, hide)
end

return M
