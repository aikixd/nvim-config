local M = {}

function M.setup(opts)

  vim.api.nvim_create_autocmd(
    'LspAttach',
    { 
      callback = function(args)
        local buffer = args.buf
        vim.bo[buffer].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Some keybinds require telescope to work, but are not mapped to it
        -- so will fail to execute since telescope may not yet be loaded.
        -- Hense, we're loading it here.
        -- local lazy_cfg = require("lazy.core.config")
        -- require("lazy.core.loader").load(
        --   { lazy_cfg.plugins["telescope.nvim"] },
        --   { cmd = "LspAttach load" },
        --   { force = false })

        local config = require('config')

        -- Mappings --
        -- Generic LSP mappings
        for _, k in ipairs(config.mapping.get_filtered('lsp')) do
          k.opts.buffer = buffer
          vim.keymap.set(k.mode, k.lhs, k.rhs, k.opts)
        end

        -- Language specific mappings, overrides generic on collision
        for _, k in ipairs(config.mapping.get_filtered('lsp-' .. vim.bo.filetype)) do
          k.opts.buffer = buffer
          vim.keymap.set(k.mode, k.lhs, k.rhs, k.opts)
        end

      end
    }
  )


  -- Extend client capabilities with cmp-nvim
  local base_capabilities = vim.tbl_deep_extend( "force",
    vim.lsp.protocol.make_client_capabilities(),
    require("cmp_nvim_lsp").default_capabilities())

  -- Lua
  local lua_config = require('config/lsp/configs/lua').lspconfig
  lua_config.capabilities = vim.tbl_deep_extend('force',
    base_capabilities,
    lua_config.capabilities or {})
  vim.lsp.config['lua_ls'] = lua_config
  vim.lsp.enable('lua_ls')

  -- Solidity
  local solidity_config = require('config/lsp/configs/solidity').lspconfig
  solidity_config.capabilities = vim.tbl_deep_extend('force',
    base_capabilities,
    solidity_config.capabilities or {})
  vim.lsp.config['solidity'] = solidity_config
  vim.lsp.enable('solidity')

end

return M
