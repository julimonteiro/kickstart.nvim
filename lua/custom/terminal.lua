local M = {}

local terminal_buf = nil
local terminal_win = nil

local function get_project_root()
  -- Check for common project markers
  local markers = { '.git', 'go.mod', 'package.json', '.root' }
  local current = vim.fn.getcwd()

  for _, marker in ipairs(markers) do
    if vim.fn.filereadable(current .. '/' .. marker) == 1 or
       vim.fn.isdirectory(current .. '/' .. marker) == 1 then
      return current
    end
  end

  return current
end

function M.toggle()
  -- Close existing window if open
  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    vim.api.nvim_win_hide(terminal_win)
    terminal_win = nil
    return
  end

  -- Create or reuse terminal buffer
  if not terminal_buf or not vim.api.nvim_buf_is_valid(terminal_buf) then
    terminal_buf = vim.api.nvim_create_buf(false, true)

    -- Set buffer options
    vim.api.nvim_buf_set_option(terminal_buf, 'buftype', 'terminal')
    vim.api.nvim_buf_set_option(terminal_buf, 'buflisted', false)

    -- Start terminal
    local project_root = get_project_root()
    vim.fn.termopen('cd ' .. project_root .. ' && $SHELL', {
      on_exit = function()
        terminal_buf = nil
        terminal_win = nil
      end
    })
  end

  -- Open in floating window
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  terminal_win = vim.api.nvim_open_win(terminal_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  -- Enter terminal mode
  vim.cmd('startinsert')
end

function M.setup()
  vim.api.nvim_create_user_command('ToggleTerminal', M.toggle, {})
end

return M
