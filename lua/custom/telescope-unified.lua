local M = {}

local telescope = require('telescope.builtin')

function M.setup()
  -- Create custom command for unified search
  vim.api.nvim_create_user_command('TelescopeUnified', function()
    -- Create picker with multiple search modes
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    local function files_picker()
      telescope.find_files()
    end

    local function symbols_picker()
      telescope.lsp_document_symbols()
    end

    local function commands_picker()
      -- Get all available commands
      local commands = {}
      for cmd, _ in pairs(vim.api.nvim_get_commands({})) do
        table.insert(commands, cmd)
      end
      table.sort(commands)

      local picker = pickers.new({}, {
        prompt_title = '[ Nvim Commands ]',
        finder = finders.new_table({ results = commands }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              vim.cmd(':' .. selection.value)
            end
          end)
          return true
        end,
      }):find()
    end

    -- Create mode selector
    local modes = {
      { name = 'Files', fn = files_picker },
      { name = 'Symbols', fn = symbols_picker },
      { name = 'Commands', fn = commands_picker },
    }

    local picker = pickers.new({}, {
      prompt_title = '[ Select Search Mode ]',
      finder = finders.new_table({
        results = modes,
        entry_maker = function(entry)
          return { value = entry.fn, display = entry.name, ordinal = entry.name }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            selection.value()
          end
        end)
        return true
      end,
    }):find()
  end, {})
end

return M
