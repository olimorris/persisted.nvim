local actions_state = require("telescope.actions.state")

local M = {}

---Get the selected session from Telescope
---@return table
local get_selected_session = function()
  return actions_state.get_selected_entry()
end

---Delete the selected session from disk
--@return string
M.delete_session = function()
  print(get_selected_session().file_path)
end

return M
