return {
  {
    "williamboman/mason.nvim",
    opts = { }
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls" }
    }
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp"
    },
    config = function (lspc, _)
      -- require("mason").setup()
      -- require("mason-lspconfig").setup()

      vim.api.nvim_create_autocmd(
        'LspAttach',
        { callback = function(args)
            local buffer = args.buf
            vim.bo[buffer].omnifunc = 'v:lua.vim.lsp.omnifunc'

            for _, k in ipairs(require('config').mapping.get_filtered('lsp')) do
              k.opts.buffer = buffer
              vim.keymap.set(k.mode, k.lhs, k.rhs, k.opts)
            end
          end
        }
      )

      local capabilities =
        vim
        .tbl_deep_extend(
          "force",
          {},
          vim.lsp.protocol.make_client_capabilities(),
          require("cmp_nvim_lsp").default_capabilities())

      -- Lua
      require('lspconfig').lua_ls.setup({
        capabilities = capabilities,
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
      });
    end
  }
}
