local finders = require("telescope.finders")

local M = {}

M.session_finder = function(sessions)
  local custom_displayer = function(session)
    local final_str = ""
    local hls = {}

    local function append(str, hl)
      local hl_start = #final_str
      final_str = final_str .. str
      table.insert(hls, { { hl_start, #final_str }, hl })
    end

    -- is current session
    append(session.file_path == vim.v.this_session and "  " or "   ", "TelescopePersistedIsCurrent")

    -- session path
    append("󰉋 ", "TelescopePersistedDirIcon")
    append(session.dir_path, "TelescopePersistedDir")

    -- branch
    if session.branch then
      append(" 󰘬 " .. session.branch, "TelescopePersistedBranch")
    end

    return final_str, hls
  end

  return finders.new_table({
    results = sessions,
    entry_maker = function(session)
      session.ordinal = session.name
      session.display = custom_displayer
      session.name = session.name
      session.branch = session.branch
      session.file_path = session.file_path

      return session
    end,
  })
end

return M
