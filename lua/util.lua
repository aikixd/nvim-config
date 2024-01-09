local debugging = false;

local M = { }

function M.key_canon_to_lazy(map)
  return { map.lhs, map.rhs, mode = map.mode, desc = map.opts.desc } 
end

function M.map(tbl, fn)
  local r = {}
  for _, x in ipairs(tbl) do table.insert(r, fn(x)) end
  return r
end

function M.dbg(msg)
  if debugging then 
    if type(msg) == "table" then
      vim.print("dbg:")
      vim.print(msg)
    else
      vim.print("dbg: " .. msg) 
    end
  end
end

return M
