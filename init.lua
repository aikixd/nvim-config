local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local cfg = require("config")
local util = require("util")

cfg.setup()

if util.debugging then

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('Debug-ColorScheme', {}),
    callback = function () print "ColorScheme called" end,
  })

  vim.api.nvim_create_autocmd('CursorMoved', {
    group = vim.api.nvim_create_augroup('Debug-CursorMoved', {}),
    callback = function () print "CursorMoved called" end,
  })


  vim.api.nvim_create_autocmd('BufHidden', {
    group = vim.api.nvim_create_augroup('Debug-BufHidden', {}),
    callback = function () print "BufHidden called" end,
  })


  vim.api.nvim_create_autocmd('InsertCharPre', {
    group = vim.api.nvim_create_augroup('Debug-InsertCharPre', {}),
    callback = function () print "InsertCharPre called" end,
  })
end


require("lazy").setup({
  spec = {
    { import = "plugins" },
    -- { import = "plugins/editor" },
    { import = "plugins/lsp" },
    -- { import = "plugins/code" }
  },
  checker = {
    check_pinned = true
  }
})

require('config.lsp').setup({})

cfg.set_keys()
