local qol = require('ext/qol')
local M = {}

local function tab_action()
  local blink = require('blink.cmp')
  -- local copilot = require('copilot.suggestion')
  local ok, copilot = pcall(require, "copilot.suggestion")
  if ok == false then
    copilot = nil
  end

  if blink.is_visible() then
    blink.accept()
    return
  end

  if copilot and copilot.is_visible() then
    copilot.accept()
    return
  end

  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", true)
end

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
  { "g", group = "goto", mode = { "n", "v", "o" } },
  {
    mode = { "n", "v" },
    { "<leader>", group = "select" },
    { "<leader>c", group = "code" },
    { "<leader>f", group = "find/fs" },
    { "<leader>m", group = "meta" },
    { "<leader>mp", group = "profiler" },
    { "<leader>s", group = "search" },
    { "z", group = "generic" },
  },
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

local switch_buf_last = function ()
  local bufnr = vim.fn.bufnr('#')
  if bufnr == -1 then return end
  if vim.fn.getbufinfo(bufnr)[1].listed == 1 then
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
  else
    vim.lsp.buf.hover()
  end
end

function toggle_diag_virt_text()
  local current = vim.diagnostic.config().virtual_text
  -- If it's a table (custom settings) treat that as "on"
  if current == nil then current = true end
  vim.diagnostic.config({ virtual_text = not current })
end


M.keys = {
  common = {
    mk_map("n", "<esc>", ":noh<cr><esc>", "Escape and clear hlsearch"),
    mk_map("i", "<M-Space>", "<space><left>", "abc"),
    mk_map("n", "<C-_>", function () Snacks.picker.lines() end, "Search for line"),
    mk_map("n", "<C-\\>", function () require("which-key").show() end, "Which key"),
    mk_map("v", "<C-\\>", function () require("which-key").show() end, "Which key"),
    mk_map("i", "<C-\\>", function () require("which-key").show() end, "Which key"),
    mk_map("s", "<C-\\>", function () require("which-key").show() end, "Which key"),
    mk_map("nv", "<M-h>", function () qol.move_buf("h") end , "Move buffer left"),
    mk_map("nv", "<M-l>", function () qol.move_buf("l") end , "Move buffer right"),

    mk_map("i", "<Tab>", tab_action, "Smart tab"),

    mk_map("v", "<", "<gv", "Indent more"),
    mk_map("v", ">", ">gv", "Indent less"),

    mk_map("nv", "<M-,>", "<C-o>", "Back"),
    mk_map("nv", "<M-.>", "<C-i>", "Forward"),
    mk_map("n", "<C-i>", "<cmd>IconPickerNormal<cr>", "Insert symbol", "icons"),
    -- mk_map("i", "<C-i>", "<cmd>IconPickerInsert<cr>", "Insert symbol", "icons"),
    -- mk_map("vi", "<C-s>", "<cmd>w<cr>", "Write buffer"),
    mk_map("niv", "<C-s>", "<cmd>w<cr><esc>", "Write buffer"),
    mk_map("nv", "<C-z>", "u",     "Undo"),
    mk_map("nv", "<S-z>", "<C-r>", "Redo"),

    mk_map("i", "<M-[>", "[]<left>");
    mk_map("i", "<M-]>", "[<cr>]<esc><S-o>");
    mk_map("i", "<M-{>", "{}<left>");
    mk_map("i", "<M-}>", "{<cr>}<esc><S-o>");
    mk_map("i", "<M-9>", "()<left>");
    mk_map("i", "<M-0>", "(<cr>)<esc><S-o>");

    -- Section: Symbols
    mk_map("nv", "]d", function () vim.diagnostic.goto_next() end, "Next diagnostic"),
    mk_map("nv", "[d", function () vim.diagnostic.goto_prev() end, "Next diagnostic"),
    mk_map("nv", "]e", function () vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, "Next error"),
    mk_map("nv", "[e", function () vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, "Next error"),
    mk_map("nv", "[g", function () require('gitsigns').prev_hunk() end, "Previous git hunk", "gitsigns"),
    mk_map("nv", "]g", function () require('gitsigns').next_hunk() end, "Next git hunk", "gitsigns"),
    -- If we set the map globally, it would be overriden by an ft plugin. So
    -- we're hacking here, to allow the plugin to register it at later time.
    mk_map("n", "]]", function () --[[ dummy --]] end, "Next occurence", "illuminate"),
    mk_map("n", "[[", function () --[[ dummy --]] end, "Prev occurence", "illuminate"),

    -- Section: hjkl
    mk_map("ni", "<C-l>", "<esc><C-w><C-l>", "To right window"),
    mk_map("ni", "<C-h>", "<esc><C-w><C-h>", "To left window"),
    mk_map("ni", "<C-j>", "<esc><C-w><C-j>", "To lower window"),
    mk_map("ni", "<C-k>", "<esc><C-w><C-k>", "To upper window"),
    -- Nav/scroll
    mk_map("nvi", "<A-u>", "<C-y>", "Scroll up"),
    mk_map("nvi", "<A-m>", "<C-e>", "Scroll down"),
    mk_map("nx", "u", "<C-u>", "Scroll up"),
    mk_map("nx", "m", "<C-d>", "Scroll down"),

    mk_map("nv", "0", "col('.') == 1 ? '^' : '0'", { desc = "Home", expr = true }),

    -- Signature help
    mk_map("n", "q", hover_action, "Symbol info", 'lsp'),
    mk_map("v", "q", function() vim.cmd.RustLsp { 'hover', 'range' } end, "Code action", "lsp-rust"),
    mk_map("ni", "<C-q>", function () vim.lsp.buf.signature_help() end, "Signature help", 'lsp'),

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
    mk_map("n", "gh", function () Snacks.picker.lsp_references() end, "Go to references", "lsp"),
    mk_map("n", "gi", "<cmd>Telescope hierarchy incoming_calls<cr>", "Go to incoming calls", "lsp"),
    mk_map("n", "gj", function () Snacks.picker.lsp_definitions() end, "Go to definitions", "lsp"),
    mk_map("n", "gJ", function () vim.lsp.buf.declaration() end, "Go to type definitions", "lsp"),
    mk_map("n", "gk", function () Snacks.picker.lsp_implementations() end, "Go to implementations", "lsp"),
    mk_map("n", "gl", function () Snacks.picker.lsp_type_definitions() end, "Go to type definitions", "lsp"),
    mk_map("n", "go", "<cmd>Telescope hierarchy outgoing_calls<cr>", "Go to outgoing calls", "lsp"),
    mk_map("n", "gr", "q", "Macro records"),

    mk_map("nv", "<C-p>", "\"0p", "Paste after"),
    mk_map("nv", "<C-S-p>", "\"0P", "Paste before"),
    mk_map("nxo", "s", function() require("flash").jump() end, "Flash", "flash"),
    mk_map("nxo", "S", function() require("flash").treesitter() end, "Flash treesitter", "flash"),
    mk_map("n", "U", "a<cr><esc>^", "Break line"),
    mk_map("n", "<C-S-u>", "<left>a<cr><esc>", "Break line before"),
    mk_map("nvo", "w", "b", "Previous word"),
    mk_map("nvo", "W", "B", "Previous WORD"),

    -- Section: <leader>a
    mk_map("nv", "<leader>aa", ":CodeCompanionActions<cr>", "CodeCompanion actions", "code-companion"),
    mk_map("nv", "<leader>ac", ":CodeCompanionChat Toggle<cr>", "CodeCompanion actions", "code-companion"),

    -- Section: <leader>b
    mk_map("nv", "<leader>bb", switch_buf_last, "Other buffer"),
    mk_map("nv", "<leader>bd", "<cmd>bn | bd #<cr>", "Delete buffer"),
    mk_map("nv", "<leader>bf", function () Snacks.picker.buffers() end, "Find buffer", "snacks"),
    mk_map("nv", "<leader>bh", function () qol.show_buf("h") end , "Show in window to the left"),
    mk_map("nv", "<leader>bl", function () qol.show_buf("l") end , "Show in window to the right"),

    -- Section: <leader>c
    mk_map("n", "<leader>ca", function() vim.lsp.buf.code_action() end, "Code action", "lsp"),
    mk_map("nv", "<leader>ca", "<cmd>RustLsp codeAction<cr>", "Code action", "lsp-rust"),
    -- mk_map("v", "<leader>ca", "<cmd>RustLsp hover range<cr>", "Code action", "lsp-rust"),
    mk_map("n", "<leader>cd", function() vim.diagnostic.open_float({ source = true, border = 'rounded' }) end, "Show diagnostics"),
    mk_map("n", "<leader>cD", function() vim.diagnostic.open_float({ source = true, severity = { min = vim.diagnostic.severity.HINT }, border = 'rounded' }) end, "Show diagnostics"),
    mk_map("n", "<leader>ce", function() vim.cmd.RustLsp('explainError') end, "Explain error", "lsp-rust"),
    mk_map("n", "<leader>cf", function() Snacks.picker.lsp_symbols() end, "Search document symbols", "lsp"),
    mk_map("n", "<leader>ch", "<cmd>TroubleToggle lsp_references<cr>", "List references", "trouble"),
    mk_map("n", "<leader>ci", function() vim.cmd.RustLsp('renderDiagnostic', 'current') end, "Rendered error", "lsp-rust"),
    mk_map("n", "<leader>cj", "<cmd>TroubleToggle lsp_definitions<cr>", "List definitions", "trouble"),
    mk_map("n", "<leader>ck", "<cmd>TroubleToggle lsp_type_definitions<cr>", "List type definitionsni", "trouble"),
    mk_map("n", "<leader>cme", "<cmd>RustLsp expandMacro <cr>", "Code action", "lsp-rust"),
    mk_map("nv", "<leader>cmrb", require('ext/lang').rust.toggle_binding_mode, "Toggle binding mode display"),
    mk_map("nv", "<leader>cmrl", require('ext/lang').rust.toggle_lifetimes, "Toggle lifetimes display"),
    mk_map("nv", "<leader>cmrd", require('ext/lang').rust.toggle_discriminants, "Toggle discriminants display"),
    mk_map("nv", "<leader>cmrc", require('ext/lang').rust.toggle_captures, "Toggle closure captures display"),
    mk_map("nv", "<leader>cmre", require('ext/lang').rust.toggle_expression_adjustments, "Toggle expression adjustments display"),
    mk_map("nv", "<leader>cmrr", require('ext/lang').rust.toggle_drops, "Toggle implicit drops display"),
    mk_map("n", "<leader>cml", require('ext/lsp').lsp_actions, "LSP actions"),
    mk_map("n", "<leader>cmv", toggle_diag_virt_text, "Toggle diagnostics VT"),
    mk_map("n", "<leader>cn", function () require('dropbar.api').pick() end, "Bread-crumbs"),
    mk_map("n", "<leader>co", ":Neotree document_symbols<cr>", "Source outline", "neo-tree"),
    mk_map("n", "<leader>cq", function() vim.cmd.RustLsp('hover', 'actions') end, "Explain error", "lsp-rust"),
    mk_map("n", "<leader>cr", vim.lsp.buf.rename, "Rename", "lsp"),
    mk_map("n", "<leader>cs", function () Snacks.picker.lsp_workspace_symbols() end, "Search symbols", "lsp"),
    mk_map("n", "<leader>cu", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, "Toogle inlay", "lsp-rust"),
    mk_map("n", "<leader>cx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Document diagnostics", "trouble"),
    mk_map("n", "<leader>cX", "<cmd>Trouble diagnostics toggle<cr>", "Workspace diagnostics", "trouble"),

    -- Section: <leader>d
    mk_map("n", "<leader>da", function() require("dap").continue() end, "Continue", "dap"),
    mk_map("n", "<leader>de", function() require("dap").run_to_cursor() end, "Run to cursor", "dap"),
    -- TODO: `dd` should start last debugging session (with recompilation) if no active session. 
    mk_map("n", "<leader>dd", function() require("dap").step_over() end, "Step over", "dap"),
    mk_map("n", "<leader>df", function() require("dap").step_into() end, "Step into", "dap"),
    mk_map("n", "<leader>dg", function() require("dap").step_out() end, "Step out", "dap"),
    mk_map("n", "<leader>dr", function() require("dap").restart() end, "Restart", "dap"),
    mk_map("n", "<leader>ds", function() require("dap").pause() end, "Pause", "dap"),
    mk_map("n", "<leader>du", function() require("dapui").toggle() end, "Toggle debug ui", "dap-ui"),
    mk_map("n", "<leader>dv", function() require("dap").toggle_breakpoint() end, "Toggle breakpoint", "dap"),
    mk_map("n", "<leader>dt", function() require("dap").terminate() end, "Continue", "dap"),

    -- Section: <leader>f
    mk_map({ "n", "v" }, "<leader>fb", function () Snacks.picker.buffers() end, "Find buffer", "snacks"),
    mk_map({ "n", "v" }, "<leader>fe", ":Neotree toggle<cr>", "Explorer", "neo-tree"),
    mk_map({ "n", "v" }, "<leader>ff", function () Snacks.picker.files() end, "Find file", "snacks"),
    mk_map({ "n", "v" }, "<leader>fq", ":Explore<cr>", "Explorer (built-in)"),
    mk_map({ "n", "v" }, "<leader>fr", ":Neotree reveal<cr>", "Reveal current", "neo-tree"),
    mk_map({ "n", "v" }, "<leader>fs", function () Snacks.picker.smart() end, "Smart finder", "snacks"),
    mk_map({ "n", "v" }, "<leader>fw", function () Snacks.picker.jumps() end, "Jump list", "snacks"),

    -- Section: <leader>g
    mk_map("n", "<leader>ga", function() require("ext/git").gitsigns_actions() end, "Git actions", "gitsigns"),
    mk_map("nv", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle line blame", "gitsigns"),
    mk_map("nv", "<leader>gg", function() require("ext/git").toggle_extended_info() end, "Toggle details"),
    mk_map("nv", "<leader>gc", function() require("gitsigns").setloclist() end, "See local hunks", "gitsigns"),
    mk_map("nv", "<leader>gC", function() require("gitsigns").setqflist("all") end, "See all hunks", "gitsigns"),
    mk_map("nv", "<leader>gd", "<cmd>DiffviewOpen -- %<cr>", "Diff current buffer", "diffview"),
    mk_map("nv", "<leader>gD", "<cmd>DiffviewOpen<cr>", "Diff all", "diffview"),
    mk_map("n", "<leader>gf", function() require("gitsigns").stage_buffer() end, "Stage buffer", "gitsigns"),
    mk_map("n", "<leader>gF", function() require("gitsigns").reset_buffer_index() end, "Reset buffer", "gitsigns"),
    mk_map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", "Diff HEAD history", "diffview"),
    mk_map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", "Diff HEAD history", "diffview"),
    mk_map("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, "Stage hunk", "gitsigns"),
    mk_map("v", "<leader>gs", function() require("gitsigns").stage_hunk(qol.get_visual_line_range()) end, "Stage hunk", "gitsigns"),

    -- Section: <leader>m
    mk_map("nv", "<leader>dw", "", "Toggle diff white space"),
    mk_map("nv", "<leader>mh", function () Snacks.picker.help() end, "Search help tags", "snacks"),
    mk_map("nv", "<leader>ml", "<cmd>Lazy<cr>", "Plugin mgmt"),
    mk_map("nv", "<leader>mm", function () Snacks.notifier.show_history() end, "Search help tags", "snacks"),
    mk_map("n", "<leader>mpc", function() Snacks.profiler.scratch() end, "Profiler scratch buffer"),
    mk_map("n", "<leader>mpp", function() Snacks.profiler.toggle() end, "Toggle profiler"),
    mk_map("n", "<leader>mph", function() Snacks.profiler.highlight() end, "Toggle profiler hightlights"),
    mk_map("n", "<leader>mpr", function() Snacks.profiler.pick() end, "Open profiling results"),
    -- mk_map("n", "<leader>mpq", function() Snacks.profiler.toggle.profiler_highlights() end, "Toggle profiler hightlights"),
    mk_map("nv", "<leader>mq", "<cmd>qa<cr>", "Exit"),
    mk_map("v", "<leader>mr", run_lua_from_visual, "Run selected lua"),
    mk_map("nv", "<leader>ms", function() Snacks.picker() end, "Show all pickers", "snacks"),
    mk_map("n", "<leader>mz", "<cmd>sus<cr>", "Suspend"),

    -- Section: <leader>s
    mk_map({ "n", "v" }, "<leader>sb", function () Snacks.picker.grep_buffers() end, "Search in buffers", "snacks"),
    mk_map({ "n", "v" }, "<leader>ss", function () Snacks.picker.grep() end, "Search in files", "snacks"),
    mk_map({ "n", "v" }, "<leader>sw", function () Snacks.picker.grep_word() end, "Search current term", "snacks"),

    -- Resize window
    mk_map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" }),
    mk_map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" }),
    mk_map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" }),
    mk_map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" }),

    -- Terminal Mappings
    mk_map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "which_key_ignore" }),
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
