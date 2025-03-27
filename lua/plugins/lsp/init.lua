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
      local lua_config = require('plugins/lsp/configs/lua').lspconfig
      lua_config.capabilities = vim.tbl_deep_extend('force',
        base_capabilities,
        lua_config.capabilities or {})
      require('lspconfig').lua_ls.setup(lua_config);

      -- Solidity
      local solidity_config = require('plugins/lsp/configs/solidity').lspconfig
      solidity_config.capabilities = vim.tbl_deep_extend('force',
        base_capabilities,
        solidity_config.capabilities or {})
      require('lspconfig').solidity.setup(solidity_config);

      -- Rust is configured via rust-tools
    end
  },

  -- Rust
  {
    'mrcjkb/rustaceanvim',
    -- version = '^3', -- Recommended
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

      local server_settings = {
        -- Env for cargo
        extraEnv = { },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        cargo = {
          -- allTargets = true, -- default
          -- features = "all"
        },
        cfg = {
          setTest = true
        },
        checkOnSave = true,
        check = {
          -- allTargets = false,
          enable = true,
          -- command = 'clippy',
          -- features = "all",
        },
        completion = {
          privateEditable = {
            enable = true
          }
        },
        procMacro = {
          enable = true,
        },
        trace = {
          -- server = "verbose"
        },
        inlayHints = { -- Placed to make toggling easier
          bindingModeHints = {
            enable = false
          },
          closureCaptureHints = {
            enable = false
          },
          discriminantHints = {
            enable = false
          },
          expressionAdjustmentHints = {
            enable = false
          },
          implicitDrops = {
            enable = false
          },
          lifetimeElisionHints = {
            enable = "never",
            useParameterNames = true
          },
        }
      }

      server_settings = vim.tbl_deep_extend(
        "force",
        server_settings,
        require('ext/lang').rust.config_override)

      vim.g.rustaceanvim = {
        tools = {
          hover_actions = {
            replace_builtin_hover = false,
            auto_focus = true
          },
          float_win_config = {
            auto_focus = true
          },
          -- on_initialized = function (health)
          --   vim.print(health)
          -- end
        },
        dap = {
          adapter = adapter,
        },
        -- https://rust-analyzer.github.io/manual.html#configuration
        server = {
          -- https://rust-analyzer.github.io/manual.html#troubleshooting
          -- Env for RA server
          extraEnv = {
          --   RA_LOG = "lsp_server=debug"
          },
          settings = {
            ['rust-analyzer'] = server_settings,
          },
        },
      }
    end
  },

  -- Haskell
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^4', -- Recommended
    lazy = false, -- This plugin is already lazy
  }
}
