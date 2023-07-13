local M = {}

M.plugin_priorities = {
  legendary = 10000
}

local function mk_map(mode, lhs, rhs, opts, ctx)
  if type(opts) == "string" then opts = { desc = opts } end

  return {
    mode = mode,
    lhs = lhs,
    rhs = rhs,
    opts = opts,
    ctx = ctx
  }
end

M.key_groups = { 
  mode = { "n", "v" },
  ["g"] = { name = "+goto", mode = { "n", "v", "o" } },
  ["<leader>"] = { name = "select" },
  ["<leader>f"] = { name = "+find/fs" },
  ["<leader>m"] = { name = "+meta" },
}

M.keymap = {
  common = {
    mk_map({ "n", "v" }, "<esc>", ":noh<cr><esc>", "Escape and clear hlsearch"),
    
    -- Section: hjkl
    mk_map({ "n" }, "<C-l>", "<C-w><C-l>", "To right window"),
    mk_map({ "n" }, "<C-h>", "<C-w><C-h>", "To left window"),
    mk_map({ "n" }, "<C-j>", "<C-w><C-j>", "To lower window"),
    mk_map({ "n" }, "<C-k>", "<C-w><C-k>", "To upper window"),


    mk_map({ "n", "v" }, "0", "col('.') == 1 ? '^' : '0'", { desc = "Home", expr = true }),
    mk_map({ "n", "v", "o" }, "u", "<C-u>", "Scroll up"),
    mk_map({ "n", "v", "o" }, "m", "<C-d>", "Scroll down"),
    mk_map({ "n" }, "<C-z>", "u", "Undo"),
    mk_map({ "n", "v", "o"}, "w", "b", "Previous word"),
    mk_map({ "n", "v", "o"}, "W", "B", "Previous WORD"),
    mk_map({ "n"}, "<S-z>", "<C-r>", "Redo"),

    -- Move Lines
    mk_map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" }),
    mk_map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" }),
    mk_map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" }),
    mk_map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" }),
    mk_map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" }),
    mk_map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" }),

    -- Section: <leader>f
    mk_map({ "n", "v" }, "<leader>fb", ":Telescope buffers<cr>", "Find buffer", "telescope"),
    mk_map({ "n", "v" }, "<leader>ff", ":Telescope find_files<cr>", "Find file", "telescope"),
    mk_map({ "n", "v" }, "<leader>fF", ":Telescope oldfiles<cr>", "Previous files", "telescope"),
    mk_map({ "n", "v" }, "<leader>fq", ":Explore<cr>", "Explorer (built-in)"),

    -- Section: <leader>s
    mk_map({ "n", "v" }, "<leader>sf", ":Telescope current_buffer_fuzzy_find<cr>", "Search here", "telescope"),
    mk_map({ "n", "v" }, "<leader>ss", ":Telescope live_grep<cr>", "Search in files", "telescope"),

    -- Resize window 
    mk_map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" }),
    mk_map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" }),
    mk_map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" }),
    mk_map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" }),

  },
}


local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts)
end


local function config_netrw_explorer()
  vim.api.nvim_create_autocmd({"FileType"}, {
    pattern = {"netrw"},
    callback = function() 
      if vim.b.netrw_fixed then return end
      vim.b.netrw_fixed = true

      local map = vim.api.nvim_buf_get_keymap(0, "n")
      local maps = {}
      local descs = {
        ["<F1>"] = "Open help",
        ["<Del>"] = "Delete",
        ["%"] = "New file",
        ["-"] = "Dir up",
        ["a"] = "Cycle display modes",
        ["C"] = "Set editing window",
        ["D"] = "Delete",
        ["i"] = "List view",
        ["I"] = "Banner visibilit",
        ["o"] = "Browse (New window)",
        ["O"] = "Obtain a file",
        ["p"] = "Preview file",
        ["P"] = "Browse (Prev window)",
        ["r"] = "Reverse sorting order",
        ["R"] = "Rename",
        ["s"] = "Sort by",
        ["S"] = "Suffix priority in sorting",
        ["t"] = "Open (New tab)",
        ["u"] = "Back",
        ["U"] = "Forward",
        ["x"] = "Open with",
        ["X"] = "Exec with system()",
      }
      local hide = { 
        "<LeftMouse>",
	"<2-LeftMouse>",
	"<C-LeftMouse>",
	"<S-LeftMouse>",
	"<S-LeftDrag>",
	"<MiddleMouse>",
	"<RightMouse>",
	"<CR>",
	"<S-CR>",
      }

      for _, m in ipairs(map) do
        if descs[m.lhs] then
	  maps[m.lhs] = { 
            m.rhs, 
            descs[m.lhs], 
            buffer = 0,
            expr = m.expr,
            noremap = m.noremap,
            silent = m.silent }
        end
      end

      for _, m in ipairs(hide) do
        maps[m] = { "which_key_ignore", buffer = 0 }
      end

      local wk = require("which-key")
      wk.register(maps)
      wk.register({ ["c"] = { name = "dir", buffer = 0 } })
      
      vim.keymap.del("n", "<C-l>", { buffer = 0 })
      vim.keymap.del("n", "<C-r>", { buffer = 0 })
    end
  })
end

function M.setup(opts) 
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  vim.opt.number = true
  vim.opt.scrolloff = 4
  vim.opt.virtualedit = "block"
  vim.opt.wrap = false

  config_netrw_explorer()

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
      print_map(vim.api.nvim_get_keymap("n"))
      print_map(vim.api.nvim_get_keymap("v"))
    end,
    { 
      nargs = 1,
      complete = "function"
    }
  )
end

function M.get_keys_filtered(ctx)
  local r = {}

  for _, m in ipairs(M.keymap.common) do
    if m.ctx == ctx then table.insert(r, m) end
  end

  return r
end

function M.set_keys()
  for i, v in ipairs(M.keymap.common) do
    -- Only assigne maps with no context
    if v.ctx == nil then
      map(v.mode, v.lhs, v.rhs, v.opts)
    end
  end
end

return M
