local finders = require("telescope.finders")
local entry_display = require("telescope.pickers.entry_display")

local M = {}

M.session_finder = function(sessions)
  -- Layout borrowed from:
  ---https://github.com/LinArcX/telescope-env.nvim/blob/master/lua/telescope/_extensions/env.lua

  local displayer = entry_display.create({
    items = {
      { remaining = true },
    },
  })

  local make_display = function(session)
    local str
    if session.branch then
      str = string.format("%s (branch: %s)", session.dir_path, session.branch)
    else
      str = session.dir_path
    end
    if session.file_path == vim.v.this_session then
      str = "* " ..str
    end
    return displayer({ str })
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
