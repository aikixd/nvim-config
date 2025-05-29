local M = {}

M.server_settings = {
  -- Env for cargo
  extraEnv = { },
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  cargo = {
    -- allTargets = true, -- default
    -- features = "all"
  },
  cfg = {
    setTest = true
  },
  checkOnSave = true,
  check = {
    -- allTargets = false,
    enable = true,
    -- command = 'clippy',
    -- features = "all",
  },
  completion = {
    privateEditable = {
      enable = true
    }
  },
  procMacro = {
    enable = true,
  },
  trace = {
    -- server = "verbose"
  },
  inlayHints = { -- Placed to make toggling easier
    bindingModeHints = {
      enable = false
    },
    closureCaptureHints = {
      enable = false
    },
    discriminantHints = {
      enable = false
    },
    expressionAdjustmentHints = {
      enable = false
    },
    implicitDrops = {
      enable = false
    },
    lifetimeElisionHints = {
      enable = "never",
      useParameterNames = true
    },
  }
}

return M
