local M = {}

function M.bench_cursor_move()
  -- Measure time between consecutive CursorMoved events
  local ns = vim.api.nvim_create_namespace('bench')
  local last = vim.loop.hrtime()
  local hist, max = {}, 0
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    callback = function()
      local now = vim.loop.hrtime()
      local dt = (now - last) / 1e6          -- ms
      table.insert(hist, dt); last = now
      if dt > max then max = dt end
    end,
  })
  vim.api.nvim_create_user_command('BenchStop', function()
    local sum = 0; for _,v in ipairs(hist) do sum = sum + v end
    print(string.format(
      'samples=%d  avg=%.2f ms  p95=%.2f ms  max=%.2f ms',
      #hist, sum/#hist,
      vim.fn.sort(vim.deepcopy(hist))[math.floor(#hist*0.95)] or 0,
      max))
    vim.api.nvim_clear_autocmds{ group = ns }
  end, {})
end

function M.bench_autocmds()
  ------------------------------------------------------------
  --  autocommand tracer: logs any callback that takes >5 ms --
  ------------------------------------------------------------
  local THRESHOLD = 5          -- ms

  local function ms() return vim.loop.hrtime() / 1e6 end

  -- iterate over all existing augroups; wrap their callbacks
  for _, id in ipairs(vim.api.nvim_get_autocmds{}) do
    if id.callback then
      local orig = id.callback
      vim.api.nvim_del_autocmd(id.id)          -- replace with wrapper
      vim.api.nvim_create_autocmd(id.event, {
        group    = id.group,
        pattern  = id.pattern,
        desc     = id.desc,
        -- command  = id.command,
        once     = id.once,
        nested   = id.nested,
        callback = function(ev)
          local t0 = ms()
          local ok, err = pcall(orig, ev)
          local dt = ms() - t0
          if dt > THRESHOLD then
            vim.schedule(function()
              print(string.format(
                '[acmd] %-14s %-20s %6.1f ms  %s',
                ev.event, (id.pattern or '*'):sub(1,20), dt,
                ok and '' or ('⚠ '..err)))
              if id.callback and type(id.callback) == "function" then
                local info = debug.getinfo(id.callback, "Sl")
                if info and info.short_src then
                  print(string.format("%s:%d", info.short_src, info.linedefined or 0))
                end
              end
              if id.desc ~= nil then
                print("  "..id.desc)
              end
            end)
          end
        end,
      })
    end
  end
end

return M
