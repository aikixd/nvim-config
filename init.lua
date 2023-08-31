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
cfg.setup()


require("lazy").setup({
  spec = {
    { import = "plugins" },
    -- { import = "plugins/editor" },
    { import = "plugins/lsp" },
    -- { import = "plugins/code" }
  }
})


cfg.set_keys()
