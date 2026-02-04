local M = {}

-- local root_files = { ".qmlls.ini", "CMakeLists.txt", ".git" }
-- local root_dir = util.root_pattern(unpack(root_files))

M.lspconfig = {
  cmd =  { "qmlls", "-E", "-d", "/usr/share/doc/qt6", "--log-file", "~/temp/qmlls.log", "-v" },
  root_dir = vim.loop.cwd(),
  on_attach = function (client, bufnr)

    _G.dd("qml attach")

    local prev_handler = vim.lsp.handlers["textDocument/hover"]

    _G.dd("prev_handler")
    _G.dd(prev_handler)

    vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
      vim.print("here")
      _G.dd("handler")
      if not (result and result.contents) then return end

      prev_handler(err, result, ctx, config)
    end
  end
}

return M
