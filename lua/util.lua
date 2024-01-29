local M = {
  debugging = false
}


local display_highlight_groups = function ()
  -- Get the name of the group used by ts groups based on the fallback logic.
  local get_ts_link
  get_ts_link = function (link)
    if link == nil then
      error("Can't find ts link item")
    end
    local r = vim.api.nvim_get_hl(0, { name = link })
    if next(r) ~= nil then
      return link
    else
      return get_ts_link(link:match("^(@.-)%.[^%.]*$"))
    end
  end

  local create_tree = function ()
    local index = vim.api.nvim_get_hl(0, {})

    for name, deats in pairs(index) do
      if deats.link then

        local link_name = deats.link
        if link_name:match("^@") ~= nil then
          link_name = get_ts_link(link_name)
        end

        local parent = index[link_name]

        if parent == nil then
          deats.orphan = true
          goto continue
        end

        if parent.children == nil then
          parent.children = {}
        end

        parent.children[name] = deats
      end

      ::continue::
    end

    return index
  end

  local tree = create_tree()

  local max_length = 0
  for name, _ in pairs(tree) do max_length = math.max(max_length, #name) end

  local render_children
  render_children = function(hl, level)
    if hl.children == nil then return {} end

    local indent_str = 2

    local indent = string.format("%-" .. level * indent_str .. "s", " ")

    local lines = {}

    for name, deats in vim.spairs(hl.children) do
      local s = string.format("%s%s -> %s", indent, name, deats.link)
      local line = {
        formatted = s,
        hl_g = name,
        hl_s = level * indent_str,
        hl_e = (level * indent_str) + #name
      }

      table.insert(lines, line)

      vim.list_extend(lines, render_children(deats, level + 1))
    end

    return lines
  end

  local lines = {}

  for name, deats in vim.spairs(tree) do
    if deats.link then goto continue end

    local fg = deats.fg and string.format("#%x", deats.fg) or "       "
    local bg = deats.bg and string.format("#%x", deats.bg) or ""

    local s = string.format(
      "%-" .. max_length .."s fg: %s bg: %s",
      name, fg, bg
    )

    local line = {
      formatted = s,
      hl_g = name,
      hl_s = 0,
      hl_e = #name
    }

    table.insert(lines, line)

    vim.list_extend(lines, render_children(deats, 1))

    ::continue::
  end

  local formatted_lines = {}
  for _, line_info in ipairs(lines) do
    table.insert(formatted_lines, line_info.formatted)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted_lines)

  for i, line_info in ipairs(lines) do
    vim.api.nvim_buf_add_highlight(buf, -1, line_info.hl_g, i - 1, line_info.hl_s, line_info.hl_e)
  end

  vim.api.nvim_set_current_buf(buf)
end


function M.key_canon_to_lazy(map)
  return { map.lhs, map.rhs, mode = map.mode, desc = map.opts.desc } 
end

function M.map(tbl, fn)
  local r = {}
  for _, x in ipairs(tbl) do table.insert(r, fn(x)) end
  return r
end

function M.dbg(msg, abbr)
  if M.debugging then 
    if type(msg) == "table" then
      abbr = abbr or ""
      vim.print(("dbg %s:"):format(abbr))
      vim.print(msg)
    else
      vim.print("dbg: " .. msg) 
    end
  end
end

function M.phl()
  display_highlight_groups()
end

return M
