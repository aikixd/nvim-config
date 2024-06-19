local qol = require('ext/qol')
local M = {}

M.rust = {}

local toggle_setting = function(toggle_fn)
  -- https://www.reddit.com/r/neovim/comments/19dodgd/how_can_i_dynamicly_change_lsp_configuration/

  local clients = vim.lsp.get_clients({ name = "rust-analyzer" })

  for _, c in ipairs(clients) do
    local inlay_enabled = vim.lsp.inlay_hint.is_enabled()
    if inlay_enabled then vim.lsp.inlay_hint.enable(false) end

    local settings = c.config.settings["rust-analyzer"]

    toggle_fn(settings)

    -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_didChangeConfiguration
    c.notify("workspace/didChangeConfiguration", { settings = settings })

    -- Defer the inlay to be enabled after nvim finishes processing the udpate
    if inlay_enabled then vim.defer_fn(function () vim.lsp.inlay_hint.enable(true) end, 0) end

  end
end

function M.rust.toggle_captures()
  local toggle_fn = function (settings)
    if settings.inlayHints.closureCaptureHints.enable == false then
      settings.inlayHints.closureCaptureHints.enable = true
    else
      settings.inlayHints.closureCaptureHints.enable = false
    end
  end

  toggle_setting(toggle_fn)
end

function M.rust.toggle_lifetimes()
  local toggle_fn = function (settings)
    -- Global settings have the field chain defined.
    if settings.inlayHints.lifetimeElisionHints.enable == "never" then
      settings.inlayHints.lifetimeElisionHints.enable = "always"
    else
      settings.inlayHints.lifetimeElisionHints.enable = "never"
    end
  end

  toggle_setting(toggle_fn)
end

return M
