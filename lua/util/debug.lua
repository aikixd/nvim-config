local util = require('util')

local function stringify_searcher(s)
  local t = type(s)
  if t ~= "function" then return ("<%s>"):format(t) end
  local ok, info = pcall(debug.getinfo, s, "Sln")
  if not ok then return "<function>" end
  local src = info.source or ""
  -- Try to classify common loaders
  local label = "function"
  if src:match("vim.loader") then
    label = "vim.loader"
  elseif src:match("cache_loader") then
    label = "cache_loader"
  elseif src:match("cache_loader_lib") then
    label = "cache_loader_lib"
  elseif src:match("package%.searchers") or src == "=[C]" then
    label = "C searcher"
  elseif src:match("runtime") or src:match("lua/vim") then
    label = "rtp searcher"
  end
  return string.format("%s (%s:%s)", label, src:gsub("^@", ""), info.linedefined or "?")
end

local function has_vimruntime_in_rtp()
  local rtp = vim.opt.rtp:get()
  for _, p in ipairs(rtp) do
    if p:match("/share/nvim/runtime/?$") then
      return true, p
    end
  end
  return false, nil
end

local function get_runtime_filetype_options()
  local paths = vim.api.nvim_get_runtime_file("lua/vim/filetype/options.lua", true)
  return paths
end

local function get_module_state(modname)
  local loaded = package.loaded[modname]
  local t = type(loaded)
  local state = (loaded == nil) and "nil"
    or (loaded == false) and "false"
    or (t == "table" and "table")
    or t
  return state, loaded
end

local function collect_loader_state()
  local lines = {}

  table.insert(lines, "=== package.searchers ===")
  local searchers = package.loaders -- legacy alias
  if not searchers then
    table.insert(lines, "No searchers table present")
  else
    for i, s in ipairs(searchers) do
      table.insert(lines, string.format("%2d: %s", i, stringify_searcher(s)))
    end
  end

  table.insert(lines, "")
  table.insert(lines, "=== runtimepath check ===")
  local ok, path = has_vimruntime_in_rtp()
  table.insert(lines, "Has $VIMRUNTIME on rtp: " .. (ok and "yes" or "no"))
  if ok then table.insert(lines, "Path: " .. path) end

  table.insert(lines, "")
  table.insert(lines, "=== module states ===")
  local names = {
    "vim.filetype",
    "vim.filetype.options",
    "vim.loader",
  }
  for _, n in ipairs(names) do
    local state = get_module_state(n)
    table.insert(lines, string.format("%-22s: %s", n, state))
  end

  table.insert(lines, "")
  table.insert(lines, "=== runtime lookup ===")
  local opts = get_runtime_filetype_options()
  table.insert(lines, "nvim_get_runtime_file('lua/vim/filetype/options.lua'): "
    .. ((opts and #opts > 0) and ("found " .. #opts) or "not found"))
  if opts and #opts > 0 then
    for _, p in ipairs(opts) do
      table.insert(lines, "  - " .. p)
    end
  end

  table.insert(lines, "")
  table.insert(lines, "=== env/version ===")
  table.insert(lines, "NVIM_VERSION: " .. (vim.version and vim.version().major and vim.version().major or "?"))
  table.insert(lines, "nightly: " .. tostring(vim.version and vim.version().prerelease == "dev"))
  table.insert(lines, "NVIM_PROFILE: " .. tostring(os.getenv("NVIM_PROFILE")))
  table.insert(lines, "LuaJIT: " .. tostring(jit and jit.version or "unknown"))

  return lines
end

function _G.DebugLoaderState()
  local buf = util.new_scratch("[Loader State]")
  local lines = collect_loader_state()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(buf)
end

-- If you want it as a util function:
-- In lua/util/init.lua, add:
--   M.debug_loader_state = function() _G.DebugLoaderState() end
-- so you can call:
--   :lua require('util').debug_loader_state()

-- Or call directly:
-- :lua DebugLoaderState()
