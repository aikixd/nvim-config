local M = {
  debugging = false,
  fs = require('util.fs')
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

  -- Returns "file:line" where the highlight group was last set, or nil
  local set_from_cache = {}
  local function get_last_set_from(name)
    local cached = set_from_cache[name]
    if cached ~= nil then return cached end

    local ok, out = pcall(vim.fn.execute, 'silent verbose hi ' .. name)
    if not ok or type(out) ~= 'string' then
      set_from_cache[name] = nil
      return nil
    end
    local src = out:match('Last set from%s+([^\n]+)')
    set_from_cache[name] = src
    return src
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
        base = s,
        set_src = get_last_set_from(name),
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

    local base = string.format("%-" .. max_length .."s fg: %s bg: %s", name, fg, bg)
    local line = { base = base, set_src = get_last_set_from(name), hl_g = name, hl_s = 0, hl_e = #name }

    table.insert(lines, line)

    vim.list_extend(lines, render_children(deats, 1))

    ::continue::
  end

  -- Align the trailing "| set:" column by padding base to the maximum width
  local max_base = 0
  for _, line_info in ipairs(lines) do
    if line_info.base and #line_info.base > max_base then max_base = #line_info.base end
  end

  local formatted_lines = {}
  for _, line_info in ipairs(lines) do
    local base = line_info.base or line_info.formatted or ""
    local pad = string.rep(" ", math.max(1, max_base - #base + 1))
    local suffix = line_info.set_src and ("| set: " .. line_info.set_src) or ""
    table.insert(formatted_lines, base .. pad .. suffix)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted_lines)

  local ns = vim.api.nvim_create_namespace("")

  for i, line_info in ipairs(lines) do
    vim.hl.range(buf, ns, line_info.hl_g, { i - 1, line_info.hl_s }, { i - 1, line_info.hl_e })
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

function M.print_buf(obj)
  local long_string = vim.inspect(obj)
  vim.cmd [[ new ]]
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(long_string, '\n'))
end

function M.get_user_bufs()
    local bufs = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(b) and vim.fn.buflisted(b) == 1 then
        local name = vim.api.nvim_buf_get_name(b)
        if name ~= "" then
          local ft = (vim.api.nvim_buf_get_option(b, "filetype") or "")
          local base = vim.fn.fnamemodify(name, ":.")
            table.insert(bufs, base .. (ft ~= "" and (" (" .. ft .. ")") or ""))
        end
      end
    end
    table.sort(bufs)
    return table.concat(bufs, ", ")
end

-- ---------------------------------------------------------------------------
-- internal: make a scratch buffer and return its handle
-- ---------------------------------------------------------------------------
function M.new_scratch(name)
  vim.cmd("enew")                             -- :enew = new empty buffer
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, name or "")  -- give it a nice title
  vim.bo.buftype   = "nofile"                 -- don't touch the filesystem
  vim.bo.bufhidden = "wipe"                   -- discard on close
  vim.bo.swapfile  = false                    -- no swapfile
  return buf
end

-- ---------------------------------------------------------------------------
-- 1.  Show every autocommand (+ declaration location) in a new buffer
-- ---------------------------------------------------------------------------
function M.show_autocmds(event)
  -- `verbose autocmd` already includes the defining script & line number
  local output
  if event == nil then
    output = vim.fn.execute("verbose autocmd")
  else
    output = vim.fn.execute("verbose autocmd "..event)
  end
  local lines  = vim.split(output, "\n", { plain = true })
  local buf    = M.new_scratch("[Autocmds]")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- ---------------------------------------------------------------------------
-- 2.  Show every active job / channel in a new buffer
-- ---------------------------------------------------------------------------
function M.show_channels()
  local lines = { "id  mode    pid   argv" }
  for _, ch in ipairs(vim.api.nvim_list_chans()) do
    local info = vim.api.nvim_get_chan_info(ch.id)
    -- stringify argv if present (jobs; nil for RPC clients without argv)
    local argv = info.argv and table.concat(info.argv, " ") or ""
    table.insert(
      lines,
      string.format("%3d %-7s %-5s %s", info.id, info.mode, info.pid or "-", argv)
    )
  end
  local buf = M.new_scratch("[Channels]")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- ---------------------------------------------------------------------------
-- Copy the current file path and line number to the system clipboard
-- ---------------------------------------------------------------------------
function M.copy_current_location_to_plus()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = vim.fn.expand('%:p')
  end
  local ln = vim.fn.line('.')
  vim.fn.setreg('+', ("%s:%d"):format(path, ln))
end

return M
