local diag_win = nil

local M = { }

M.invoke = function ()
  if diag_win ~= nil then
    vim.api.nvim_set_current_win(diag_win)
    return
  end

  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local diags = vim.diagnostic.get(0, { lnum = row - 1 })
  
  if #diags == 0 then return end

  local opts = {};

  for _, v in ipairs(diags) do
    table.insert(opts, v.code .. ": " .. v.message)
  end

  vim.ui.select(opts, {
    prompt = 'Select the diagnostic',
  }, function(_, i)

      if i == nil then return end

      local text = {}
      local lines = 0

      for line in diags[i].user_data.lsp.data.rendered:gmatch("([^\n]*)\n?") do
        table.insert(text, line)
        lines = lines + 1
      end

      local max_h = vim.api.nvim_win_get_height(0) / 2 - 4 -- A bit smaller than half

      if lines > max_h then lines = max_h end

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines( buf, 0, -1, true, text)

      local win_w = vim.api.nvim_win_get_width(0)
      local sign_col_pad = 1
      local right_pad = 0

      local number_w = math.ceil(math.log(vim.api.nvim_buf_line_count(0), 10)) + 1

      if number_w < vim.wo.numberwidth then number_w = vim.wo.numberwidth end

      local sign_col_w = tonumber(vim.wo.signcolumn:match("^yes:(%d+)"))

      if sign_col_w == nil then
        if vim.wo.signcolumn:match("^yes$") then sign_col_w = 2
        else                                     sign_col_w = 0
        end
      end

      local win = vim.api.nvim_open_win(buf, true, {
        relative = "win",
        row = 3,
        col = sign_col_w + number_w + sign_col_pad,
        width = win_w - sign_col_w - sign_col_pad - number_w - right_pad,
        height = lines,
        style = "minimal",
        border = { "", "─", "", "", "", "─", "", "" }
      })

      vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
        callback = function ()
          diag_win = nil
          vim.cmd("q")
        end
      })
      vim.api.nvim_win_set_option(win, "number", false)
      vim.api.nvim_win_set_option(win, "relativenumber", false)

      diag_win = win
    end)
end

return M
