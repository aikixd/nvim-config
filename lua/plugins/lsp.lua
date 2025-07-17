local util = require('util')
local config = require('config')

return {
  { "williamboman/mason.nvim",
    opts = { }
  },
  { "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "rust_analyzer" },
      automatic_enable = {
        exclude = {
          "rust_analyzer",
        }
      }
    }
  },
  { "neovim/nvim-lspconfig",
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp"
    },
  },
  { "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = util.map(
      config.mapping.get_filtered('trouble'),
      util.key_canon_to_lazy
    ),
    opts = { },
  },
  -- Rust
  { 'mrcjkb/rustaceanvim',
    ft = { 'rust' },
    enabled = true,
    lazy = false,
    dependencies = {
      "nvim-dap"
    },
    config = function () 
      require('util').dbg("setting rustaceanvim")

      -- Init debug adapter
      local install_path = vim.fn.expand("$MASON/packages/codelldb")
      local codelldb_path = install_path .. '/extension/adapter/codelldb'
      local liblldb_path = install_path .. '/extension/lldb/lib/liblldb.so'

      vim.notify(
        "Rust lldb paths:\n"
        .."  codelldb: "..codelldb_path.."\n"
        .."  liblldb: "..liblldb_path.."\n",
        vim.log.levels.INFO
      )

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
          },
        },
        dap = { adapter = adapter, },

        -- https://rust-analyzer.github.io/manual.html#configuration
        server = {
          -- https://rust-analyzer.github.io/manual.html#troubleshooting
          -- Env for RA server
          extraEnv = {
          --   RA_LOG = "lsp_server=debug"
          },

          root_dir = function (filename, default)
            local r = default(filename)
            vim.notify("Attached to WS dir: "..r, vim.log.levels.INFO)
            return r
          end,

          default_settings = {
            ['rust-analyzer'] = require("config.lsp.configs.rust").server_settings,
          },
        },
      }
    end
  },
  -- Haskell
  { 'mrcjkb/haskell-tools.nvim',
    version = '^4', -- Recommended
    lazy = false, -- This plugin is already lazy
  }
}
