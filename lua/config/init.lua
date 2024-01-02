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
  vim.opt.foldenable = false
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldmethod = "expr"
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

  vim.keymap.set({"n","v","i","o"}, "<C-i>", "<C-i>")
  -- vim.keymap.set({"n","v","i","o"}, "<Tab>", "<Tab>")
  vim.keymap.set({"n"}, "<Tab>", "<Tab>")

  require('config.map_fixes').config_netrw_explorer()

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
      print_map(vim.api.nvim_get_keymap("n"))
      print_map(vim.api.nvim_get_keymap("v"))
      print_map(vim.api.nvim_get_keymap("i"))
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
