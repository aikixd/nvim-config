local M = { }
-- Function to yank file path and cursor position
function M.yank_location(reg)
  -- Get the current file path and cursor position
  local file_path = vim.fn.expand('%:p')
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line, col = cursor_pos[1], cursor_pos[2] + 1  -- Adjust col to 1-based
  local yank_text = string.format('%s:%d:%d', file_path, line, col)

  vim.fn.setreg(reg, yank_text)
end

function M.get_visual_line_range(offset)
  if offset == nil then offset = 0 end
  --
  -- Exit the visual mode to update the markers
  vim.api.nvim_feedkeys('\027', 'xt', false)

  local _, ls, _ = unpack(vim.fn.getpos('\'<'))
  local _, le, _ = unpack(vim.fn.getpos('\'>'))

  vim.print("taking range: " .. ls .. " " .. le);

  return { ls + offset, le + offset }
end

-- Open a temp buffer with the provided text
function M.to_temp_buf(text)
  -- TODO: handle deleting the buffer.
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n", { trimempty = true }))
  vim.api.nvim_set_current_buf(buf)
end

function M.move_buf(dir)

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

-- Shows the buffer in the window in the provided direction.
function M.show_buf(dir)

  local buf_this = vim.api.nvim_get_current_buf()
  local _, line, col = unpack(vim.fn.getpos("."))

  -- Move focus in the desired direction
  vim.cmd("wincmd " .. dir)

  local win_tgt = vim.api.nvim_get_current_win()
  if
    'neo-tree' == vim.api.nvim_get_option_value("filetype", { buf = 0 })
    -- 'neo-tree' == vim.api.nvim_buf_get_option(0, "filetype")
  then return end

  -- Show the buffer.
  vim.api.nvim_win_set_buf(win_tgt,  buf_this)
  -- Set cursot to the position we've started from.
  vim.fn.setpos(".", { 0, line, col, 0 })

end
return M
