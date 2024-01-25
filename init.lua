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

-- vim.cmd([[nnoremap <C-i> <C-i> ]])
-- vim.cmd([[inoremap <C-i> <C-i> ]])
--
-- vim.cmd([[nnoremap <Tab> :echo "TAB"<cr>]])
-- vim.cmd([[nnoremap <C-i> :echo "C-I"<cr>]])
local cfg = require("config")
cfg.setup()

local util = require("util")

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
  }
})


cfg.set_keys()
