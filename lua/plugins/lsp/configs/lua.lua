local M = {}

M.lspconfig = {
  on_init = function(client)
    local path = client.workspace_folders[1].name

    if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          -- library = { vim.env.VIMRUNTIME }
          -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
          library = vim.api.nvim_get_runtime_file("", true),

          -- Disables question caused by environment emulation
          -- https://github.com/LuaLS/lua-language-server/discussions/1688
          -- https://github.com/neovim/nvim-lspconfig/issues/1700
          checkThirdParty = false
        },
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

return M
