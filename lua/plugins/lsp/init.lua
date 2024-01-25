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
      vim.api.nvim_create_autocmd(
        'LspAttach',
        { 
          callback = function(args)
            local buffer = args.buf
            vim.bo[buffer].omnifunc = 'v:lua.vim.lsp.omnifunc'

            -- Some keybinds require telescope to work, but are not mapped to it
            -- so will fail to execute since telescope may not yet be loaded.
            -- Hense, we're loading it here.
            local lazy_cfg = require("lazy.core.config")
            require("lazy.core.loader").load(
              { lazy_cfg.plugins["telescope.nvim"] },
              { cmd = "LspAttach load" },
              { force = false })

            local config = require('config')

            -- Generic LSP mappings
            for _, k in ipairs(config.mapping.get_filtered('lsp')) do
              k.opts.buffer = buffer
              vim.keymap.set(k.mode, k.lhs, k.rhs, k.opts)
            end

            -- Language specific mappings
            for _, k in ipairs(config.mapping.get_filtered('lsp-' .. vim.bo.filetype)) do
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
    enabled = false,
    event = 'VeryLazy',
    config = function(_, _)
      require('util').debug("setting rust")
      local rt = require('rust-tools')

      local lldb = require('mason-registry').get_package('codelldb')
      local install_path = lldb:get_install_path()
      local codelldb_path = install_path .. '/extension/adapter/codelldb'
      local liblldb_path = install_path .. '/extension/lldb/lib/liblldb.so'

      local adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path)

      rt.setup({
        tools = {
          hover_actions = {
            auto_focus = true
          }
        },
        server = {
          on_attach = function (_, buffer)
            -- TODO: make overrides by lhs
            vim.keymap.set("n", "<leader>ca", rt.code_action_group.code_action_group, { buffer = buffer, desc = "Code action" })
            vim.keymap.set("n", "<leader>cq", rt.hover_actions.hover_actions, { buffer = buffer, desc = "Rust actions" })
          end
        },
        dap = {
          adapter = adapter
        }
      })
    end
  },

  -- Rust again, with different plug. This is a spiritual (and perhaps real) successor of rust-tools.
  {
    'mrcjkb/rustaceanvim',
    version = '^3', -- Recommended
    ft = { 'rust' },
    event = 'VeryLazy',
    dependencies = {
      "nvim-dap"
    },
    config = function () 
      require('util').dbg("setting rustaceanvim")

      local lldb = require('mason-registry').get_package('codelldb')
      local install_path = lldb:get_install_path()
      local codelldb_path = install_path .. '/extension/adapter/codelldb'
      local liblldb_path = install_path .. '/extension/lldb/lib/liblldb.so'
      
      vim.print({ codelldb_path, liblldb_path })

      local adapter = require('rustaceanvim.config').get_codelldb_adapter(codelldb_path, liblldb_path)

      require('util').dbg(adapter)

      vim.g.rustaceanvim = {
        tools = {
          hover_actions = {
            replace_builtin_hover = false,
            auto_focus = true
          },
          float_win_config = {
            auto_focus = true
          }
        },
        dap = {
          adapter = adapter,
          
        }, 
        server = {
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = true,
              check = {
                enable = true,
                -- command = 'clippy',
                features = 'all',
              },
              procMacro = {
                enable = true,
              },
            },
          },
        },
      }
    end
  }
}
