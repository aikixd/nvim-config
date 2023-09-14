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

M.keys = {
  common = {
    mk_map("n", "<esc>", ":noh<cr><esc>", "Escape and clear hlsearch"),
    -- mk_map("i", "<C-Space>", function () require('cmp').mapping.complete() end, "Autocomplete", "cmp"),
    mk_map("n", "<C-\\>", function () require("which-key").show_command(nil, "n") end, "Which key"),
    mk_map("v", "<C-\\>", function () require("which-key").show_command(nil, "v") end, "Which key"),
    mk_map("i", "<C-\\>", function () require("which-key").show_command(nil, "i") end, "Which key"),
    mk_map("o", "<C-\\>", function () require("which-key").show_command(nil, "o") end, "Which key"),
    mk_map("vi", "<C-s>", "<cmd>w<cr>", "Write"),
    mk_map("n", "<C-I>", "<cmd>IconPickerNormal<cr>", "Insert symbol", "icons"),
    mk_map("i", "<C-i>", "<cmd>IconPickerInsert<cr>", "Insert symbol", "icons"),
    mk_map({ "n", "i", "v", "o" }, "<C-s>", "<cmd>w<cr><esc>", "Write buffer"),

    -- Section: hjkl
    mk_map({ "n", "i" }, "<C-l>", "<esc><C-w><C-l>", "To right window"),
    mk_map({ "n", "i" }, "<C-h>", "<esc><C-w><C-h>", "To left window"),
    mk_map({ "n", "i" }, "<C-j>", "<esc><C-w><C-j>", "To lower window"),
    mk_map({ "n", "i" }, "<C-k>", "<esc><C-w><C-k>", "To upper window"),
    mk_map("nvoi", "<A-u>", "<C-y>", "Scroll up"),
    mk_map("nvoi", "<A-m>", "<C-e>", "Scroll down"),


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

    mk_map("nvio", "<C-k>", function () vim.lsp.buf.signature_help() end, "Signature help", 'lsp'),
    mk_map("nvo", "K", function () vim.lsp.buf.hover() end, "Symbol info", 'lsp'),
    -- mk_map({ "n", "v", "o" }, "q",  "<cmd>IconPickerNormal<cr>", "Symbol info", 'lsp'),

    -- Section: g
    mk_map({ "n" }, "gd", function() vim.lsp.buf.definition() end, "Go to definition", "lsp"),
    mk_map("n", "gh", "<cmd>Telescope lsp_references<cr>", "Go to references", "lsp"),
    mk_map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", "Go to implementations", "lsp"),
    mk_map("n", "gj", "<cmd>Telescope lsp_definitions<cr>", "Go to definitions", "lsp"),
    mk_map("n", "gk", "<cmd>Telescope lsp_type_definitions<cr>", "Go to type definitions", "lsp"),

    -- Section: <leader>b
    mk_map("nvo", "<leader>bb", "<cmd>b#<cr>", "Other buffer"),
    mk_map("nvo", "<leader>bd", "<cmd>bn | bd #<cr>", "Delete buffer"),
    mk_map("nvo", "<leader>bf", ":Telescope buffers<cr>", "Find buffer", "telescope"),

    -- Section: <leader>c
    mk_map({ "n" }, "<leader>ca", function() vim.lsp.buf.code_action() end, "Code action", "lsp"),
    mk_map({ "n" }, "<leader>cd", function() vim.diagnostic.open_float({ source = true, border = 'rounded' }) end, "Show diagnostics"),
    mk_map({ "n", "v", "o" }, "<leader>cc", function () vim.lsp.buf.signature_help() end, "Symbol info", 'lsp'),
    mk_map({ "n" }, "<leader>co", ":Neotree document_symbols<cr>", "Source outline", "neo-tree"),
    mk_map("n", "<leader>ch", "<cmd>TroubleToggle lsp_references<cr>", "List references", "trouble"),
    mk_map("n", "<leader>cj", "<cmd>TroubleToggle lsp_definitions<cr>", "List definitions", "trouble"),
    mk_map("n", "<leader>ck", "<cmd>TroubleToggle lsp_type_definitions<cr>", "List type definitionsni", "trouble"),
    mk_map("n", "<leader>cx", "<cmd>TroubleToggle document_diagnostics<cr>", "Document diagnostics", "trouble"),
    mk_map("n", "<leader>cX", "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace diagnostics", "trouble"),

    -- Section: <leader>d
    mk_map("n", "<leader>da", function() require("dap").continue() end, "Continue", "dap"),
    mk_map("n", "<leader>de", function() require("dap").run_to_cursor() end, "Run to cursor", "dap"),
    mk_map("n", "<leader>dd", function() require("dap").step_over() end, "Step over", "dap"),
    mk_map("n", "<leader>df", function() require("dap").step_into() end, "Step into", "dap"),
    mk_map("n", "<leader>dg", function() require("dap").step_out() end, "Step out", "dap"),
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
