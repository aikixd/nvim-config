local M = { }
-- Function to yank file path and cursor position
function M.yank_location()
  -- Get the current file path and cursor position
  local file_path = vim.fn.expand('%:p')
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line, col = cursor_pos[1], cursor_pos[2] + 1  -- Adjust col to 1-based
  local yank_text = string.format('%s:%d:%d', file_path, line, col)

  vim.print(yank_text);

  -- Copy to the system clipboard
  vim.fn.setreg('+', yank_text)
end

function M.get_selection_line_range(offset)
  if offset == nil then offset = 0 end
  --
  -- Exit the visual mode to update the markers
  vim.api.nvim_feedkeys('\027', 'xt', false)

  local _, ls, _ = unpack(vim.fn.getpos('\'<'))
  local _, le, _ = unpack(vim.fn.getpos('\'>'))

  vim.print("taking range: " .. ls .. " " .. le);

  return { ls + offset, le + offset }
end

function M.to_temp_buf(text)
  -- TODO: handle deleting the buffer.
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n", { trimempty = true }))
  vim.api.nvim_set_current_buf(buf)
end

return M
