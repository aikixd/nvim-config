local qol = require('ext/qol')
local M = {}

M.rust = { }

-- Changes an inlay setting for lsp.
local toggle_setting = function(pre_fn, toggle_fn, post_fn)
  -- https://www.reddit.com/r/neovim/comments/19dodgd/how_can_i_dynamicly_change_lsp_configuration/

  local clients = vim.lsp.get_clients({ name = "rust-analyzer" })

  for _, c in ipairs(clients) do
    -- local inlay_enabled = vim.lsp.inlay_hint.is_enabled()
    -- if inlay_enabled then vim.lsp.inlay_hint.enable(false) end

    pre_fn()

    local settings = c.config.settings["rust-analyzer"]

    toggle_fn(settings)

    -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_didChangeConfiguration
    c.notify("workspace/didChangeConfiguration", { settings = settings })

    post_fn()

    -- -- Defer the inlay to be enabled after nvim finishes processing the udpate
    -- if inlay_enabled then vim.defer_fn(function () vim.lsp.inlay_hint.enable(true) end, 0) end

  end
end

local toggle_inlay_setting = function (toggle_fn)
  local inlay_enabled = vim.lsp.inlay_hint.is_enabled()

  local pre = function ()
    if inlay_enabled then vim.lsp.inlay_hint.enable(false) end
  end

  local post = function ()
    -- Defer the inlay to be enabled after nvim finishes processing the udpate
    if inlay_enabled then vim.defer_fn(function () vim.lsp.inlay_hint.enable(true) end, 0) end
  end

  toggle_setting(pre, toggle_fn, post)
end

function M.rust.toggle_set_test()
  if M.rust.config_override.cfg.setTest == false then
    M.rust.config_override.cfg.setTest = true
  else
    M.rust.config_override.cfg.setTest = false
  end

  vim.cmd("RustLsp reloadWorkspace")
end

function M.rust.toggle_binding_mode()
  local toggle_fn = function (settings)
    if settings.inlayHints.bindingModeHints.enable == false then
      settings.inlayHints.bindingModeHints.enable = true
    else
      settings.inlayHints.bindingModeHints.enable = false
    end
  end

  toggle_inlay_setting(toggle_fn)
end

function M.rust.toggle_captures()
  local toggle_fn = function (settings)
    if settings.inlayHints.closureCaptureHints.enable == false then
      settings.inlayHints.closureCaptureHints.enable = true
    else
      settings.inlayHints.closureCaptureHints.enable = false
    end
  end

  toggle_inlay_setting(toggle_fn)
end

function M.rust.toggle_discriminants()
  local toggle_fn = function (settings)
    if settings.inlayHints.discriminantHints.enable == false then
      settings.inlayHints.discriminantHints.enable = true
    else
      settings.inlayHints.discriminantHints.enable = false
    end
  end

  toggle_inlay_setting(toggle_fn)
end

function M.rust.toggle_expression_adjustments()
  local toggle_fn = function (settings)
    if settings.inlayHints.expressionAdjustmentHints.enable == false then
      settings.inlayHints.expressionAdjustmentHints.enable = true
    else
      settings.inlayHints.expressionAdjustmentHints.enable = false
    end
  end

  toggle_inlay_setting(toggle_fn)
end

function M.rust.toggle_drops()
  local toggle_fn = function (settings)
    if settings.inlayHints.implicitDrops.enable == false then
      settings.inlayHints.implicitDrops.enable = true
    else
      settings.inlayHints.implicitDrops.enable = false
    end
  end

  toggle_inlay_setting(toggle_fn)
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

  toggle_inlay_setting(toggle_fn)
end

return M
