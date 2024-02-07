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

local switch_buf_last = function ()
  if vim.fn.getbufinfo(vim.fn.bufnr('#'))[1].listed == 1 then
    vim.cmd("b#")
    return
  end

  local bufs =
    vim
      .iter(vim.api.nvim_list_bufs())
      :map(function (b) return { b, vim.fn.getbufinfo(b)[1] } end)
      :filter(function (x) return x[2].listed == 1 end)
      :filter(function (x) return x[2].hidden == 1 end)
      :filter(function (x) return x[1] ~= vim.api.nvim_get_current_buf() end)
      :totable()

  table.sort(bufs, function(a, b)
    return a[2].lastused > b[2].lastused
  end)

  if #bufs == 0 then return end

  vim.api.nvim_set_current_buf(bufs[1][1])
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
    mk_map("i", "<M-Space>", "<space><left>", "abc"),
    mk_map("n", "<C-\\>", function () require("which-key").show_command(nil, "n") end, "Which key"),
    mk_map("v", "<C-\\>", function () require("which-key").show_command(nil, "v") end, "Which key"),
    mk_map("i", "<C-\\>", function () require("which-key").show_command(nil, "i") end, "Which key"),
    mk_map("o", "<C-\\>", function () require("which-key").show_command(nil, "o") end, "Which key"),
    mk_map("nvo", "<M-h>", function () move_buf("h") end , "Move buffer left"),
    mk_map("nvo", "<M-l>", function () move_buf("l") end , "Move buffer right"),
    mk_map("v", "<", "<gv", "Indent more"),
    mk_map("v", ">", ">gv", "Indent less"),
    mk_map("nvo", "<M-,>", "<C-o>", "Back"),
    mk_map("nvo", "<M-.>", "<C-i>", "Forward"),
    mk_map("vi", "<C-s>", "<cmd>w<cr>", "Write buffer"),
    mk_map("n", "<C-i>", "<cmd>IconPickerNormal<cr>", "Insert symbol", "icons"),
    mk_map("i", "<C-i>", "<cmd>IconPickerInsert<cr>", "Insert symbol", "icons"),
    mk_map("ni", "<C-q>", function () vim.lsp.buf.signature_help() end, "Signature help", 'lsp'),
    mk_map("niv", "<C-s>", "<cmd>w<cr><esc>", "Write buffer"),
    -- mk_map("nvio", "<C-w>", "<cmd>q<cr>", "Close window"),
    mk_map("nvi", "<C-z>", "u", "Undo"),
    mk_map("nv",  "<S-z>", "<C-r>", "Redo"),

    -- Section: Symbols
    mk_map("nv", "]d", function () vim.diagnostic.goto_next() end, "Next diagnostic"),
    mk_map("nv", "[d", function () vim.diagnostic.goto_prev() end, "Next diagnostic"),
    mk_map("nv", "]e", function () vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, "Next error"),
    mk_map("nv", "[e", function () vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, "Next error"),
    mk_map("nv", "[g", function () require('gitsigns').prev_hunk() end, "Previous git hunk", "gitsigns"),
    mk_map("nv", "]g", function () require('gitsigns').next_hunk() end, "Next git hunk", "gitsigns"),

    -- Section: hjkl
    mk_map("ni", "<C-l>", "<esc><C-w><C-l>", "To right window"),
    mk_map("ni", "<C-h>", "<esc><C-w><C-h>", "To left window"),
    mk_map("ni", "<C-j>", "<esc><C-w><C-j>", "To lower window"),
    mk_map("ni", "<C-k>", "<esc><C-w><C-k>", "To upper window"),
    mk_map("nvoi", "<A-u>", "<C-y>", "Scroll up"),
    mk_map("nvoi", "<A-m>", "<C-e>", "Scroll down"),


    mk_map("nv",  "0", "col('.') == 1 ? '^' : '0'", { desc = "Home", expr = true }),
    mk_map("nvo", "u", "<C-u>", "Scroll up"),
    mk_map("nvo", "m", "<C-d>", "Scroll down"),
    mk_map("n", "q", hover_action, "Symbol info", 'lsp'),
    mk_map("v", "q", function() vim.cmd.RustLsp { 'hover', 'range' } end, "Code action", "lsp-rust"),

    -- Move Lines
    mk_map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" }),
    mk_map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" }),
    mk_map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" }),
    mk_map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" }),
    mk_map("v", "<A-j>", ":m '>+1<cr><cr>gv=gv", { desc = "Move down", silent = true }),
    mk_map("v", "<A-k>", ":m '<-2<cr><cr>gv=gv", { desc = "Move up", silent = true }),

    -- Section: g
    mk_map("n", "gd", function () require('gitsigns').toggle_deleted() end, "Show deleted lines", "gitsigns"),
    mk_map("n", "gm", "m", "Set mark"),
    mk_map("n", "gh", "<cmd>Telescope lsp_references<cr>", "Go to references", "lsp"),
    mk_map("n", "gj", "<cmd>Telescope lsp_definitions<cr>", "Go to definitions", "lsp"),
    mk_map("n", "gk", "<cmd>Telescope lsp_implementations<cr>", "Go to implementations", "lsp"),
    mk_map("n", "gl", "<cmd>Telescope lsp_type_definitions<cr>", "Go to type definitions", "lsp"),
    mk_map("n", "gr", "q", "Macro records"),

    mk_map("nv", "<C-p>", "\"0p", "Paste after"),
    mk_map("nv", "<C-S-p>", "\"0P", "Paste before"),
    mk_map("nxo", "s", function() require("flash").jump() end, "Flash", "flash"),
    mk_map("nxo", "S", function() require("flash").treesitter() end, "Flash treesitter", "flash"),
    mk_map("n", "U", "a<cr><esc>^", "Break line"),
    mk_map("n", "<C-S-u>", "<left>a<cr><esc>", "Break line before"),
    mk_map("nvo", "w", "b", "Previous word"),
    mk_map("nvo", "W", "B", "Previous WORD"),

    -- Section: <leader>b
    -- mk_map("nvo", "<leader>bb", "<cmd>b#<cr>", "Other buffer"),
    mk_map("nvo", "<leader>bb", switch_buf_last, "Other buffer"),
    mk_map("nvo", "<leader>bd", "<cmd>bn | bd #<cr>", "Delete buffer"),
    mk_map("nvo", "<leader>bf", "<cmd>Telescope buffers sort_mru=true<cr>", "Find buffer", "telescope"),
    mk_map("nvo", "<leader>bh", function () copy_buf("h") end , "Delete buffer"),
    mk_map("nvo", "<leader>bl", function () copy_buf("l") end , "Delete buffer"),

    -- Section: <leader>c
    mk_map("n", "<leader>ca", function() vim.lsp.buf.code_action() end, "Code action", "lsp"),
    mk_map("n", "<leader>ca", "<cmd>RustLsp codeAction<cr>", "Code action", "lsp-rust"),
    mk_map("n", "<leader>cd", function() vim.diagnostic.open_float({ source = true, border = 'rounded' }) end, "Show diagnostics"),
    mk_map("n", "<leader>cD", function() vim.diagnostic.open_float({ source = true, severity = { min = vim.diagnostic.severity.HINT }, border = 'rounded' }) end, "Show diagnostics"),
    mk_map("n", "<leader>ce", function() vim.cmd.RustLsp('explainError') end, "Explain error", "lsp-rust"),
    mk_map("n", "<leader>cf", "<cmd>Telescope lsp_document_symbols<cr>", "Search document symbols", "lsp"),
    mk_map("n", "<leader>ch", "<cmd>TroubleToggle lsp_references<cr>", "List references", "trouble"),
    mk_map("n", "<leader>ci", function() vim.cmd.RustLsp('renderDiagnostic') end, "Rendered error", "lsp-rust"),
    mk_map("n", "<leader>cj", "<cmd>TroubleToggle lsp_definitions<cr>", "List definitions", "trouble"),
    mk_map("n", "<leader>ck", "<cmd>TroubleToggle lsp_type_definitions<cr>", "List type definitionsni", "trouble"),
    mk_map("n", "<leader>cn", function () require('dropbar.api').pick() end, "Bread-crumbs"),
    mk_map("n", "<leader>co", ":Neotree document_symbols<cr>", "Source outline", "neo-tree"),
    mk_map("n", "<leader>cq", function() vim.cmd.RustLsp('hover', 'actions') end, "Explain error", "lsp-rust"),
    mk_map("n", "<leader>cr", vim.lsp.buf.rename, "Rename", "lsp"),
    mk_map("n", "<leader>cs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Search symbols", "lsp"),
    mk_map("n", "<leader>cu", function() vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled()) end, "Toogle inlay", "lsp-rust"),
    mk_map("n", "<leader>cx", "<cmd>TroubleToggle document_diagnostics<cr>", "Document diagnostics", "trouble"),
    mk_map("n", "<leader>cX", "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace diagnostics", "trouble"),

    -- Section: <leader>d
    mk_map("n", "<leader>da", function() require("dap").continue() end, "Continue", "dap"),
    mk_map("n", "<leader>de", function() require("dap").run_to_cursor() end, "Run to cursor", "dap"),
    -- TODO: `dd` should start last debugging session (with recompilation) if no active session. 
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

    -- Section: <leader>g
    mk_map("nv", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle line blame", "gitsigns"),
    mk_map("nv", "<leader>gc", function() require("gitsigns").setloclist() end, "See local hunks", "gitsigns"),
    mk_map("nv", "<leader>gC", function() require("gitsigns").setqflist("all") end, "See all hunks", "gitsigns"),
    mk_map("nv", "<leader>gd", "<cmd>DiffviewOpen -- %<cr>", "Diff current buffer", "diffview"),
    mk_map("nv", "<leader>gD", "<cmd>DiffviewOpen<cr>", "Diff all", "diffview"),

    -- Section: <leader>m
    mk_map({ "n", "v" }, "<leader>mh", ":Telescope help_tags<cr>", "Search help tags", "telescope"),
    mk_map({ "n", "v" }, "<leader>ml", "<cmd>Lazy<cr>", "Plugin mgmt"),
    mk_map("v", "<leader>mr", run_lua_from_visual, "Run selected lua"),
    mk_map("nv", "<leader>mq", "<cmd>qa<cr>", "Exit"),

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
