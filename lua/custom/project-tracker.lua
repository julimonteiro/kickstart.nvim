local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup('ProjectTracker', { clear = true })

  vim.api.nvim_create_autocmd('VimEnter', {
    group = group,
    callback = function()
      if vim.fn.argc() > 0 then return end -- Skip if files opened

      local cwd = vim.fn.getcwd()
      local history_file = vim.fn.stdpath('config') .. '/.dashboard-history'

      -- Read existing history
      local projects = {}
      if vim.fn.filereadable(history_file) == 1 then
        for line in io.lines(history_file) do
          local path, count = line:match("(.+)|(.+)")
          if path and count then
            projects[path] = tonumber(count) or 0
          end
        end
      end

      -- Update current project
      projects[cwd] = (projects[cwd] or 0) + 1

      -- Write back (limit to 20 projects)
      local lines = {}
      local sorted = {}
      for path, count in pairs(projects) do
        table.insert(sorted, { path = path, count = count })
      end
      table.sort(sorted, function(a, b) return a.count > b.count end)

      for i, item in ipairs(sorted) do
        if i > 20 then break end
        table.insert(lines, item.path .. '|' .. item.count)
      end

      vim.fn.writefile(lines, history_file)
    end
  })
end

return M
