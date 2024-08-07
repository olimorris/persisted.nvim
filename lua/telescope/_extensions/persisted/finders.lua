local config = require("persisted").config
local finders = require("telescope.finders")

local M = {}

local no_icons = {
  branch = "",
  dir = "",
  selected = "",
}

---Create a finder for persisted sessions
---@param sessions table
function M.session_finder(sessions)
  local icons = vim.tbl_extend("force", no_icons, config.telescope.icons or {})

  local custom_displayer = function(session)
    local final_str = ""
    local hls = {}

    local function append(str, hl)
      local hl_start = #final_str
      final_str = final_str .. str
      if hl then
        table.insert(hls, { { hl_start, #final_str }, hl })
      end
    end

    -- is current session
    append(session.file_path == vim.v.this_session and (icons.selected .. " ") or "   ", "PersistedTelescopeIsCurrent")

    -- session path
    append(icons.dir, "PersistedTelescopeDir")
    append(session.dir_path)

    -- branch
    if session.branch then
      append(" " .. icons.branch .. session.branch, "PersistedTelescopeBranch")
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
