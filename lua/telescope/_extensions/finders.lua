local finders = require("telescope.finders")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")

local M = {}

M.session_finder = function(sessions)
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
  local make_display = function(session)
    return displayer({
      session.name,
      session.branch,
    })
  end

  return finders.new_table({
    results = sessions,
    entry_maker = function(session)
      session.ordinal = session.name
      session.display = make_display
      session.name = session.name
      session.branch = session.branch
      session.file_path = session.file_path

      return session
    end,
  })
end

return M
