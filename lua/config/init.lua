local M = {}

M.plugin_priorities = {
  colorscheme = 10000
}

M.mapping = require('config.mapping')


function M.setup(opts)
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  vim.opt.background = "dark"
  vim.opt.cmdheight = 0
  vim.opt.colorcolumn = "100"
  vim.opt.confirm = true
  vim.opt.cursorlineopt = "both"
  vim.opt.cursorline = true
  vim.opt.diffexpr = nil
  vim.opt.diffopt = { 
    "internal",
    "filler",
    "closeoff",
    "context:12",
    "algorithm:histogram",
    "linematch:200",
    "indent-heuristic",
    "iwhite"
  }
  -- vim.opt.fillchars = 'fold'
  vim.opt.foldenable = false
  vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.opt.foldlevel = 20
  -- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldmethod = "expr"
  vim.opt.foldtext = ''
  vim.opt.ignorecase = true
  vim.opt.list = true
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.scrolloff = 7
  vim.opt.signcolumn = "yes:1"
  vim.opt.termguicolors = true
  vim.opt.virtualedit = "block"
  vim.opt.wrap = false

  -- Tabs
  vim.opt.expandtab = true
  vim.opt.tabstop = 2
  vim.opt.softtabstop = 2
  vim.opt.shiftwidth = 2

  -- Debug helper
  _G.dd = function(...)
    Snacks.debug.inspect(...)
  end
  _G.bt = function()
    Snacks.debug.backtrace()
  end
  vim.print = _G.dd

  -- HL yanked text
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function(_)
      vim.hl.on_yank({
        timeout = 350,
        higroup = "@comment.warning"
      })
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    -- pattern = "*",
    callback = function()
      -- Config non modifiable bufs
      if not vim.bo.modifiable then
        vim.wo.colorcolumn = ""
      end
    end,
  })

  vim.keymap.set({"n","v","i","o"}, "<C-i>", "<C-i>")
  -- vim.keymap.set({"n","v","i","o"}, "<Tab>", "<Tab>")
  vim.keymap.set({"n"}, "<Tab>", "<Tab>", { desc = "Fixed tab" })
  require('config.map_fixes').config_netrw_explorer()
  -- require('config.map_fixes').clear_remaps()


  -- Icons
  vim.fn.sign_define("DiagnosticSignError",
    {text = " ", texthl = "DiagnosticSignError"})
  vim.fn.sign_define("DiagnosticSignWarn",
    {text = " ", texthl = "DiagnosticSignWarn"})
  vim.fn.sign_define("DiagnosticSignInfo",
    {text = " ", texthl = "DiagnosticSignInfo"})
  vim.fn.sign_define("DiagnosticSignHint",
    {text = "󰌵", texthl = "DiagnosticSignHint"})

  -- Diagnostics

  vim.diagnostic.config({
    severity_sort = true,
    virtual_text = {
      source = "if_many"
    },
    float = {
      source = true
    }
  })

  vim.notify("Blocking Rust ftplugin.", vim.log.levels.INFO)
  vim.g.loaded_rust          = 1  -- disable $VIMRUNTIME/syntax/rust.vim
  vim.g.loaded_rust_plugin   = 1  -- disable $VIMRUNTIME/plugin/rust.vim
  vim.g.loaded_rust_ftplugin = 1  -- disable $VIMRUNTIME/ftplugin/rust.vim

  vim.cmd("helptags ALL")

  -- Fix for status line disappearing on mode change with cmdheight == 0.
  -- https://www.reddit.com/r/neovim/comments/16hiz32/help_for_disappearing_statusline/
  vim.api.nvim_create_autocmd(
    "ModeChanged",
    {
      callback = function (_)
        vim.schedule(function ()
          vim.cmd('redraw')
        end)
      end
    }
  )

  -- Auto-refresh the status line when diagnostics change.
  -- This should force Feline (or any statusline plugin) to update.
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function()
      -- Force a redraw of the status lines in all windows
      -- Schedule for the next ui cycle to prevent races in treesitter
      vim.schedule(function ()
        vim.cmd("redrawstatus")
      end)
    end,
  })

vim.api.nvim_create_autocmd("User", {
  pattern = "copilot.suggestion",
  callback = function()
    vim.print("Copilot suggestion triggered")
  end,
})

  -- Alias :Q -> :q
  vim.api.nvim_create_user_command("Q", function ()
    vim.cmd("q")
  end, { force = true })

  -- Alias :Vs -> :vs
  vim.api.nvim_create_user_command("Vs", function ()
    vim.cmd("vs")
  end, { force = true })

  vim.api.nvim_create_user_command(
    "CheckMap",
    function (opts)
      local function print_map(maps)
        for _, m in ipairs(maps) do
          if m.lhs == opts.args or m.lhsraw == opts.args then
            print(vim.inspect(m))
          end
        end
      end
      print_map(vim.api.nvim_buf_get_keymap(0, "n"))
      print_map(vim.api.nvim_buf_get_keymap(0, "v"))
      print_map(vim.api.nvim_buf_get_keymap(0, "i"))
      print_map(vim.api.nvim_buf_get_keymap(0, "o"))
      print_map(vim.api.nvim_get_keymap("n"))
      print_map(vim.api.nvim_get_keymap("v"))
      print_map(vim.api.nvim_get_keymap("i"))
      print_map(vim.api.nvim_get_keymap("o"))
    end,
    {
      nargs = 1,
      complete = "function"
    }
  )
end

function M.set_keys()
  for i, v in ipairs(M.mapping.keys.common) do
    -- Only assigne maps with no context
    if v.ctx == nil then
      vim.keymap.set(v.mode, v.lhs, v.rhs, v.opts)
    end
  end
end

return M
