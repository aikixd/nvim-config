local M = {}

local qol = require("ext/qol")

M.list_clients = function (opts)
  local clients = vim.lsp.get_clients()

  local roots = {}

  for i, c in ipairs(clients) do
    local val
    if opts.full then
      val = c
    elseif opts.cargo then
      val = c.settings["rust-analyzer"].cargo
    else
      val = c.config.root_dir
    end
    table.insert(roots, { ix = i, client = val } )
  end

  qol.to_temp_buf(vim.inspect(roots))
end

M.query_status = function ()
  vim.lsp.buf_request(0, 'rust-analyzer/analyzerStatus', vim.empty_dict(), function(err, result, ctx, config)
    if err then
      qol.to_temp_buf(vim.inspect(err))
    else
      qol.to_temp_buf(vim.inspect(result))
    end
  end) 
end

local progress_handlers = {}

M.progress_handle_insert = function(key, handle)
  progress_handlers[key] = handle
end

M.progress_handle_take = function(key)
  local r = progress_handlers[key]
  progress_handlers[key] = nil
  return r
end

return M
