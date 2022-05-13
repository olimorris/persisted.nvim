local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local action_state = require("telescope.actions.state")

local _actions = require("telescope._extensions.actions")

local function search_sessions(opts)
  local config = require("persisted.config").options

  -- Layout borrowed from:
  ---https://github.com/LinArcX/telescope-env.nvim/blob/master/lua/telescope/_extensions/env.lua
  local cols = vim.o.columns
  local telescope_width = conf.width
    or conf.layout_config.width
    or conf.layout_config[conf.layout_strategy].width
    or cols

  if type(telescope_width) == "function" then
    telescope_width = telescope_width(_, cols, _)
  end

  if telescope_width < 1 then
    telescope_width = math.floor(cols * telescope_width)
  end

  local branch_width = 30
  local name_width = math.floor(cols * 0.05)

  local displayer = entry_display.create({
    separator = " │ ",
    items = {
      { width = telescope_width - branch_width - name_width },
      { width = branch_width },
      { remaining = true },
    },
  })
  local make_display = function(entry)
    return displayer({
      entry.name,
      entry.branch,
    })
  end

  local make_entry = function(item)
    return {
      ordinal = item.name,
      display = make_display,

      name = item.name,
      branch = item.branch,
      file_path = item.file_path,
    }
  end

  pickers.new(opts, {
    prompt_title = "Sessions",
    sorter = conf.generic_sorter(opts),
    finder = finders.new_table({
      results = require("persisted").list(),
      entry_maker = make_entry,
    }),
    attach_mappings = function(prompt_bufnr, map)
      local refresh_sessions = function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local finder = require("persisted").list()
        picker:refresh(finder, { reset_prompt = true })
      end

      map("i", "<c-d>", _actions.delete_session)

      actions.select_default:replace(function()
        local session = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        config.telescope.before_source(session)
        pcall(vim.cmd, "source " .. vim.fn.fnameescape(session.file_path))
        config.telescope.after_source(session)
      end)
      return true
    end,
  }):find()
end

return require("telescope").register_extension({
  exports = {
    persisted = search_sessions,
  },
})
