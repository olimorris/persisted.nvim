local actions_state = require("telescope.actions.state")
local transform_mod = require("telescope.actions.mt").transform_mod

local utils = require("persisted.utils")
local M = {}

---Get the selected session from Telescope
---@return table
local get_selected_session = function()
  return actions_state.get_selected_entry()
end

M.load_session = function(session, config)
  utils.load_session(
    session.file_path,
    config.telescope.before_source and config.telescope.before_source(session) or _,
    config.telescope.after_source and config.telescope.after_source(session) or _
  )
end

---Delete the selected session from disk
--@return string
M.delete_session = function()
  local session = get_selected_session()
  local path = session.file_path

  local confirm = vim.fn.input("Delete [" .. session.name .. "]?: ", ""):lower()
  if confirm == "yes" or confirm == "y" then
    vim.fn.delete(vim.fn.expand(path))
  end
end

return transform_mod(M)
