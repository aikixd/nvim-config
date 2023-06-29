local M = {}

M.plugin_priorities = {
  legendary = 10000
}

local function mk_map(mode, lhs, rhs, opts)
  if type(opts) == "string" then opts = { desc = opts } end

  return {
    mode = mode,
    lhs = lhs,
    rhs = rhs,
    opts = opts
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
    mk_map({ "n" }, "<C-l>", "<C-w><C-l>", "To right window"),
    mk_map({ "n" }, "<C-h>", "<C-w><C-h>", "To left window"),
    mk_map({ "n" }, "<C-j>", "<C-w><C-j>", "To lower window"),
    mk_map({ "n" }, "<C-k>", "<C-w><C-k>", "To upper window"),
    mk_map({ "n", "v" }, "<leader>mk", ":Legendary<cr>", "Key map"),
    mk_map({ "n", "v" }, "<leader>fq", ":Explore<cr>", "Explorer (built-in)"),
  }
}


local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts)
end

function M.setup(opts) 
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  vim.opt.number = true
  vim.opt.scrolloff = 4
  vim.opt.virtualedit = "block"

end

function M.set_keys()
  for i, v in ipairs(M.keymap.common) do
    map(v.mode, v.lhs, v.rhs, v.opts)
  end
end

return M
