local M = {}

function M.invoke()
  -- Get current file and position (optional)
  local file = vim.fn.expand('%')

  -- Execute Claude Code CLI
  vim.fn.jobstart('claude-code', {
    detach = true,
    on_stderr = function(_, data, _)
      if data and data[1] and data[1] ~= '' then
        vim.notify('Claude Code: ' .. data[1], vim.log.levels.ERROR)
      end
    end,
  })
end

function M.setup()
  vim.api.nvim_create_user_command('ClaudeCode', M.invoke, {})
end

return M
