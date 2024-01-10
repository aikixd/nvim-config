local M = {
  debugging = false
}

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

return M
