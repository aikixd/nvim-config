local M = {}

local function mk_map(mode, lhs, rhs, opts, ctx)
  if type(opts) == "string" then opts = { desc = opts, noremap = true } end

  if type(mode) == "table" then
    mode = table.concat(mode)
  end

  local chars = {}
  for i = 1, #mode do
    table.insert(chars, mode:sub(i, i))
  end

  return {
    mode = chars,
    lhs = lhs,
    rhs = rhs,
    opts = opts,
    ctx = ctx
  }
end

M.groups = {
  mode = { "n", "v" },
  ["g"] = { name = "+goto", mode = { "n", "v", "o" } },
  ["<leader>"] = { name = "select" },
  ["<leader>c"] = { name = "+code" },
  ["<leader>f"] = { name = "+find/fs" },
  ["<leader>m"] = { name = "+meta" },
  ["<leader>s"] = { name = "+search" },
  ["z"] = { name = "+generic" },
}

local run_lua_from_visual = function ()
  -- Exit the visual mode to update the markers
  vim.api.nvim_feedkeys('\027', 'xt', false)
  local _, ls, cs = unpack(vim.fn.getpos('\'<'))
  local _, le, ce = unpack(vim.fn.getpos('\'>'))

  -- If line mode selection is used, the column of the last line
  -- will be the max col value possible. We're trimming that here.
  local le_len = #vim.fn.getline(le)
  if ce > le_len then ce = le_len end

  local text =  vim.api.nvim_buf_get_text(0, ls-1, cs-1, le-1, ce, {})
  text = table.concat(text, "\n")

  loadstring(text)()
end

local copy_buf = function (dir)

  local buf_this = vim.api.nvim_get_current_buf()
  -- local win_this = vim.api.nvim_get_current_win()
  -- local buf_other = vim.fn.getbufinfo(vim.fn.expand('#'))
  local _, line, col = unpack(vim.fn.getpos("."))

  vim.cmd("wincmd " .. dir) -- Move in the desired direction

  -- vim.print(vim.api.nvim_buf_get_option(0, "filetype"))

  local win_tgt = vim.api.nvim_get_current_win()
  if
    win_this == win_tgt
    or 'neo-tree' == vim.api.nvim_buf_get_option(0, "filetype")
  then return end

  vim.api.nvim_win_set_buf(win_tgt,  buf_this)
  -- vim.api.nvim_win_set_buf(win_this, buf_other[1].bufnr)
  vim.fn.setpos(".", { 0, line, col, 0 })

end

local move_buf = function (dir)

  local buf_this = vim.api.nvim_get_current_buf()
  local win_this = vim.api.nvim_get_current_win()
  local buf_other = vim.fn.getbufinfo(vim.fn.expand('#'))
  local _, line, col = unpack(vim.fn.getpos("."))

  vim.cmd("wincmd " .. dir) -- Move in the desired direction

  -- vim.print(vim.api.nvim_buf_get_option(0, "filetype"))

  local win_tgt = vim.api.nvim_get_current_win()
  if
    win_this == win_tgt
    or 'neo-tree' == vim.api.nvim_buf_get_option(0, "filetype")
  then return end

  vim.api.nvim_win_set_buf(win_tgt,  buf_this)
  vim.api.nvim_win_set_buf(win_this, buf_other[1].bufnr)
  vim.fn.setpos(".", { 0, line, col, 0 })

end

local hover_action = function ()
  local dap = require('dap')
  if next(dap.sessions()) ~= nil then
    local view = require('dap.ui.widgets').hover()
    vim.keymap.set('n', 'q', view.close, { buffer = view.buf, desc = "Close inspector" })
    vim.keymap.set(
      'n', 'g', "<Cmd>lua require('dap.ui').trigger_actions({ mode = 'first' })<CR>", 
      { buffer = view.buf, desc = "Expand", nowait = true })
    vim.print(view)
  else
    vim.lsp.buf.hover()
  end
end

M.keys = {
  common = {
    mk_map("n", "<esc>", ":noh<cr><esc>", "Escape and clear hlsearch"),
    -- mk_map("n", "<C-Space>", function () require('cmp').mapping.complete() end, "Autocomplete", "cmp"),
    mk_map("n", "<C-\\>", function () require("which-key").show_command(nil, "n") end, "Which key"),
    mk_map("v", "<C-\\>", function () require("which-key").show_command(nil, "v") end, "Which key"),
    mk_map("i", "<C-\\>", function () require("which-key").show_command(nil, "i") end, "Which key"),
    mk_map("o", "<C-\\>", function () require("which-key").show_command(nil, "o") end, "Which key"),
    mk_map("nvo", "<M-h>", function () move_buf("h") end , "Delete buffer"),
    mk_map("nvo", "<M-l>", function () move_buf("l") end , "Delete buffer"),
    mk_map("v", "<", "<gv", "Indent more"),
    mk_map("v", ">", ">gv", "Indent less"),
    mk_map("nvo", "<M-,>", "<C-o>", "Back"),
    mk_map("nvo", "<M-.>", "<C-i>", "Forward"),
    -- mk_map("n", "<C-'>", "m", "Set mark"),
    mk_map("vi", "<C-s>", "<cmd>w<cr>", "Write"),
    -- mk_map("n", "<C-I>", "<cmd>IconPickerNormal<cr>", "Insert symbol", "icons"),
    -- mk_map("i", "<C-i>", "<cmd>IconPickerInsert<cr>", "Insert symbol", "icons"),
    mk_map("nvio", "<C-q>", function () vim.lsp.buf.signature_help() end, "Signature help", 'lsp'),
    mk_map("nivo", "<C-s>", "<cmd>w<cr><esc>", "Write buffer"),
    mk_map("nvio",   "<C-z>", "u", "Undo"),
    mk_map("nvio",   "<S-z>", "<C-r>", "Redo"),

    -- Section: hjkl
    mk_map({ "n", "i" }, "<C-l>", "<esc><C-w><C-l>", "To right window"),
    mk_map({ "n", "i" }, "<C-h>", "<esc><C-w><C-h>", "To left window"),
    mk_map({ "n", "i" }, "<C-j>", "<esc><C-w><C-j>", "To lower window"),
    mk_map({ "n", "i" }, "<C-k>", "<esc><C-w><C-k>", "To upper window"),
    mk_map("nvoi", "<A-u>", "<C-y>", "Scroll up"),
    mk_map("nvoi", "<A-m>", "<C-e>", "Scroll down"),


    mk_map("nv",  "0", "col('.') == 1 ? '^' : '0'", { desc = "Home", expr = true }),
    mk_map("nvo", "u", "<C-u>", "Scroll up"),
    mk_map("nvo", "m", "<C-d>", "Scroll down"),
    mk_map("nvo", "q", hover_action, "Symbol info", 'lsp'),

    mk_map("nvo", "w", "b", "Previous word"),
    mk_map("nvo", "W", "B", "Previous WORD"),

    -- Move Lines
    mk_map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" }),
    mk_map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" }),
    mk_map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" }),
    mk_map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" }),
    mk_map("v", "<A-j>", ":m '>+1<cr><cr>gv=gv", { desc = "Move down", silent = true }),
    mk_map("v", "<A-k>", ":m '<-2<cr><cr>gv=gv", { desc = "Move up", silent = true }),

    -- mk_map({ "n", "v", "o" }, "q",  "<cmd>IconPickerNormal<cr>", "Symbol info", 'lsp'),

    -- Section: g
    -- mk_map({ "n" }, "gd", function() vim.lsp.buf.definition() end, "Go to definition", "lsp"),
    mk_map("n", "gm", "m", "Set mark"),
    mk_map("n", "gh", "<cmd>Telescope lsp_references<cr>", "Go to references", "lsp"),
    mk_map("n", "gj", "<cmd>Telescope lsp_definitions<cr>", "Go to definitions", "lsp"),
    mk_map("n", "gk", "<cmd>Telescope lsp_implementations<cr>", "Go to implementations", "lsp"),
    mk_map("n", "gl", "<cmd>Telescope lsp_type_definitions<cr>", "Go to type definitions", "lsp"),

    -- Section: <leader>b
    mk_map("nvo", "<leader>bb", "<cmd>b#<cr>", "Other buffer"),
    mk_map("nvo", "<leader>bd", "<cmd>bn | bd #<cr>", "Delete buffer"),
    mk_map("nvo", "<leader>bf", "<cmd>Telescope buffers sort_mru=true<cr>", "Find buffer", "telescope"),
    mk_map("nvo", "<leader>bh", function () copy_buf("h") end , "Delete buffer"),
    mk_map("nvo", "<leader>bl", function () copy_buf("l") end , "Delete buffer"),

    -- Section: <leader>c
    mk_map("n", "<leader>ca", function() vim.lsp.buf.code_action() end, "Code action", "lsp"),
    mk_map("n", "<leader>cd", function() vim.diagnostic.open_float({ source = true, border = 'rounded' }) end, "Show diagnostics"),
    mk_map("nvo", "<leader>cc", function () vim.lsp.buf.signature_help() end, "Symbol info", 'lsp'),
    mk_map("n", "<leader>cf", "<cmd>Telescope lsp_document_symbols<cr>", "Search symbols", "lsp"),
    mk_map("n", "<leader>ch", "<cmd>TroubleToggle lsp_references<cr>", "List references", "trouble"),
    mk_map("n", "<leader>cj", "<cmd>TroubleToggle lsp_definitions<cr>", "List definitions", "trouble"),
    mk_map("n", "<leader>ck", "<cmd>TroubleToggle lsp_type_definitions<cr>", "List type definitionsni", "trouble"),
    mk_map("n", "<leader>co", ":Neotree document_symbols<cr>", "Source outline", "neo-tree"),
    mk_map("n", "<leader>cr", vim.lsp.buf.rename, "Rename", "lsp"),
    mk_map("n", "<leader>cs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Search symbols", "lsp"),
    mk_map("n", "<leader>cx", "<cmd>TroubleToggle document_diagnostics<cr>", "Document diagnostics", "trouble"),
    mk_map("n", "<leader>cX", "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace diagnostics", "trouble"),

    -- Section: <leader>d
    mk_map("n", "<leader>da", function() require("dap").continue() end, "Continue", "dap"),
    mk_map("n", "<leader>de", function() require("dap").run_to_cursor() end, "Run to cursor", "dap"),
    mk_map("n", "<leader>dd", function() require("dap").step_over() end, "Step over", "dap"),
    mk_map("n", "<leader>df", function() require("dap").step_into() end, "Step into", "dap"),
    mk_map("n", "<leader>dg", function() require("dap").step_out() end, "Step out", "dap"),
    mk_map("n", "<leader>dr", function() require("dap").restart() end, "Pause", "dap"),
    mk_map("n", "<leader>ds", function() require("dap").pause() end, "Pause", "dap"),
    mk_map("n", "<leader>du", function() require("dapui").toggle() end, "Toggle debug ui", "dap-ui"),
    mk_map("n", "<leader>dv", function() require("dap").toggle_breakpoint() end, "Toggle breakpoint", "dap"),
    mk_map("n", "<leader>dt", function() require("dap").terminate() end, "Continue", "dap"),

    -- Section: <leader>f
    mk_map({ "n", "v" }, "<leader>fb", ":Telescope buffers<cr>", "Find buffer", "telescope"),
    mk_map({ "n", "v" }, "<leader>fe", ":Neotree toggle<cr>", "Explorer", "neo-tree"),
    mk_map({ "n", "v" }, "<leader>ff", ":Telescope find_files<cr>", "Find file", "telescope"),
    mk_map({ "n", "v" }, "<leader>fF", ":Telescope oldfiles<cr>", "Previous files", "telescope"),
    mk_map({ "n", "v" }, "<leader>fq", ":Explore<cr>", "Explorer (built-in)"),
    mk_map({ "n", "v" }, "<leader>fr", ":Neotree reveal<cr>", "Reveal current", "neo-tree"),
    mk_map({ "n", "v" }, "<leader>fw", ":Telescope jumplist<cr>", "Jump list", "telescope"),

    -- Section: <leader>m
    mk_map({ "n", "v" }, "<leader>mh", ":Telescope help_tags<cr>", "Search help tags", "telescope"),
    mk_map({ "n", "v" }, "<leader>ml", "<cmd>Lazy<cr>", "Plugin mgmt"),
    mk_map("v", "<leader>mr", run_lua_from_visual, "Plugin mgmt"),
    mk_map("nvo", "<leader>mq", "<cmd>qa<cr>", "Exit"),

    -- Section: <leader>s
    mk_map({ "n", "v" }, "<leader>sf", ":Telescope current_buffer_fuzzy_find<cr>", "Search here", "telescope"),
    mk_map({ "n", "v" }, "<leader>ss", ":Telescope live_grep<cr>", "Search in files", "telescope"),
    mk_map({ "n", "v" }, "<leader>sv", ":Telescope grep_string<cr>", "Search current term", "telescope"),

    -- Resize window
    mk_map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" }),
    mk_map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" }),
    mk_map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" }),
    mk_map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" }),

    -- Terminal Mappings
    mk_map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Normal Mode" }),
    mk_map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "To left window" }),
    mk_map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "To lower window" }),
    mk_map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "To upper window" }),
    mk_map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "To right window" }),
    mk_map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" }),
    mk_map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" }),
  },
}

function M.get_filtered(ctx)
  local r = {}

  for _, m in ipairs(M.keys.common) do
    if m.ctx == ctx then table.insert(r, m) end
  end

  return r
end

return M
