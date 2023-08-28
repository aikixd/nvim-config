local util = require('util')

local M = {}

function M.config_netrw_explorer()
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
return M
