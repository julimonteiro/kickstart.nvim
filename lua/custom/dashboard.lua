local M = {}

local function get_recent_projects()
  -- Read from tracking file
  local history_file = vim.fn.stdpath('config') .. '/.dashboard-history'
  local projects = {}

  if vim.fn.filereadable(history_file) == 1 then
    local lines = vim.fn.readfile(history_file)
    for _, line in ipairs(lines) do
      local parts = vim.split(line, '|')
      if #parts == 2 then
        table.insert(projects, {
          path = parts[1],
          count = tonumber(parts[2]) or 0
        })
      end
    end
  end

  -- Sort by count (frequency) descending
  table.sort(projects, function(a, b) return a.count > b.count end)

  return projects
end

local function get_project_info(path)
  -- Get git branch
  local branch = "no git"
  local git_cmd = string.format("cd '%s' && git rev-parse --abbrev-ref HEAD 2>/dev/null", path)
  local handle = io.popen(git_cmd)
  if handle then
    branch = handle:read("*a"):gsub("\n", "")
    handle:close()
    if branch == "" then branch = "no git" end
  end

  -- Get file count
  local count_cmd = string.format("find '%s' -type f 2>/dev/null | wc -l", path)
  local handle_count = io.popen(count_cmd)
  local file_count = "?"
  if handle_count then
    file_count = handle_count:read("*a"):gsub("\n", "")
    handle_count:close()
  end

  return {
    branch = branch,
    files = file_count
  }
end

function M.setup()
  local alpha = require('alpha')
  local dashboard = require('alpha.themes.dashboard')

  -- Header
  dashboard.section.header.val = {
    "  ⚡ Welcome to Neovim",
    "",
  }

  -- Recent projects section
  local projects = get_recent_projects()
  local project_buttons = {}

  if #projects > 0 then
    table.insert(project_buttons, { type = "text", val = "  Recent Projects:" })
    table.insert(project_buttons, { type = "padding", val = 1 })

    for i, project in ipairs(projects) do
      if i > 5 then break end -- Limit to 5 recent projects

      local info = get_project_info(project.path)
      local button_text = string.format("  %s  [%s | %s files]", project.path, info.branch, info.files)

      table.insert(project_buttons, {
        type = "button",
        val = button_text,
        on_press = function()
          vim.cmd('cd ' .. project.path)
          vim.cmd('Telescope find_files')
        end,
        opts = {
          noremap = true,
          nowait = true,
          position = "center",
        }
      })
    end
  else
    table.insert(project_buttons, { type = "text", val = "  No recent projects yet. Open a project to get started!" })
  end

  dashboard.section.buttons.val = project_buttons

  alpha.setup(dashboard.opts)
end

return M
