local M = {}

function M.config_nvim()
  -- vim.g.loaded_matchparen = 1
end

function M.config_profile_nvim()
  local plugin = vim.fn.stdpath("config") .. "/lua/external/profile.nvim"
  vim.opt.rtp:append(plugin)

  local should_profile = os.getenv("NVIM_PROFILE")
  if should_profile then
    require("profile").instrument_autocmds()
    if should_profile:lower():match("^start") then
      require("profile").start("*")
    else
      require("profile").instrument("*")
    end
  end

  local function toggle_profile()
    local prof = require("profile")
    if prof.is_recording() then
      prof.stop()
      vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
        if filename then
          prof.export(filename)
          vim.notify(string.format("Wrote %s", filename))
        end
      end)
    else
      prof.start("*")
    end
  end
  vim.keymap.set("", "<f1>", toggle_profile)
end

return M
