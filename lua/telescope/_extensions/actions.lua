local actions_state = require("telescope.actions.state")
local transform_mod = require("telescope.actions.mt").transform_mod

local M = {}

---Get the selected session from Telescope
---@return table
local get_selected_session = function()
  return actions_state.get_selected_entry()
end

---Delete the selected session from disk
--@return string
M.delete_session = function()
  -- local session = get_selected_session().file_path
  local session = get_selected_session()
  local path = session.file_path

  local confirm = vim.fn.input("Delete " .. session.name .. "? ", "yes"):lower()
  if confirm == "yes" or confirm == "y" then
    os.remove(path)
    print("Session deleted: " .. path)
  end
end

return transform_mod(M)
