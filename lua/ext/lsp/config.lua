local M = {}

M.client_do = function (fn)
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  if #clients == 0 then
    clients = vim.lsp.get_clients()
  end

  if #clients == 0 then
    vim.notify("No LSPs attached.", vim.log.levels.INFO)
    return
  end

  if #clients == 1 then
    fn(clients[1])
  else
    vim.ui.select(
      clients,
      {
        format_item = function (x)
          return x.name
        end
      },
      fn
    )
  end
end

M.set_target_arch = function ()
  local rustc = require("rustaceanvim.rustc")
  rustc.with_rustc_target_architectures(function (targets)
    local keys = {}
    for k, _ in pairs(targets) do
      table.insert(keys, k)
    end

    vim.schedule(function ()
      vim.ui.select(keys, nil, function (target)
        dd(target)
        require("rustaceanvim.lsp").set_target_arch(nil, target)
      end)
    end)
  end)
end

return M
