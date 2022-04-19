local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local action_state = require("telescope.actions.state")

local config = require("persisted.config").options
local sessions = require("persisted").list()

local function search_sessions(opts)
  local displayer = entry_display.create({
    separator = " │ ",
    items = {
      { width = 50 },
      { width = 10 },
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
      pwd = item.pwd,
      file_path = item.file_path,
    }
  end

  pickers.new(opts, {
    prompt_title = "Sessions",
    sorter = conf.generic_sorter(opts),
    finder = finders.new_table({
      results = sessions,
      entry_maker = make_entry,
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local session = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        pcall(require("persisted").stop(), "")
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
