local M = { }

---@class FsItem
---@field name string
---@field type string
local FsItem = {}; FsItem.__index = FsItem

function FsItem:new(name, type)
  local obj = {
    name = name,
    type = type
  }

  setmetatable(obj, FsItem)

  return obj
end

function FsItem:to_string()
  if self.type == "directory" then
    return self.name .. "/"
  else
    return self.name
  end
end

function M.list_entries(dir, limit)
  local iter = vim.loop.fs_scandir(dir)
  if not iter then
    return {} end

  local entries = {}

  local count = 0
  while true do
    local name, t = vim.loop.fs_scandir_next(iter)
    if not name then break end

    table.insert(entries, FsItem:new(name, t))

    count = count + 1
    if count >= limit then break end

  end
  -- table.sort(entries)
  -- return table.concat(entries, ", ")

  return entries
end

return M
