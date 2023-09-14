return {
  {
    "williamboman/mason.nvim",
    opts = { }
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "rust_analyzer" }
    }
  },

  -- LSP
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
        { 
          callback = function(args)
            local buffer = args.buf
            vim.bo[buffer].omnifunc = 'v:lua.vim.lsp.omnifunc'

            for _, k in ipairs(require('config').mapping.get_filtered('lsp')) do
              k.opts.buffer = buffer
              vim.keymap.set(k.mode, k.lhs, k.rhs, k.opts)
            end
          end
        }
      )

      -- Extend client capabilities with cmp-nvim
      local base_capabilities = vim .tbl_deep_extend( "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities())

      -- Lua
      local lua_config = require('plugins/lsp/configs/lua').lspconfig
      lua_config.capabilities = vim .tbl_deep_extend( 'force',
        base_capabilities,
        lua_config.capabilities or {})
      require('lspconfig').lua_ls.setup(lua_config);

      -- Rust is configured via rust-tools
    end
  },

  -- Rust
  -- Techically this is more than an LSP, perhaps a different location may suit better
  {
    'simrat39/rust-tools.nvim',
    dependencies = {
      'mason.nvim'
    },
    event = 'VeryLazy',
    config = function(_, _)
      local rt = require('rust-tools')

      local lldb = require('mason-registry').get_package('codelldb')
      local install_path = lldb:get_install_path()
      local codelldb_path = install_path .. '/extension/adapter/codelldb'
      local liblldb_path = install_path .. '/extension/lldb/lib/liblldb.so'

      rt.setup({
        server = {
          on_attach = function (_, buffer)
            -- TODO: make overrides by lhs
            vim.keymap.set("n", "<leader>ca", rt.code_action_group.code_action_group, { buffer = buffer, desc = "Code action" })
          end
        },
        dap = {
          adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path)
        }
      })
    end
  }
}
