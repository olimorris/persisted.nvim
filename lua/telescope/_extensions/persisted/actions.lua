local actions_state = require("telescope.actions.state")
local transform_mod = require("telescope.actions.mt").transform_mod

local utils = require("persisted.utils")
local M = {}

---Get the selected session from Telescope
---@return table
local get_selected_session = function()
  return actions_state.get_selected_entry()
end

---Load the selected session
---@param session table
---@param config table
---@return nil
M.load_session = function(session, config)
  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedTelescopeLoadPre", data = session })

  vim.schedule(function()
    utils.load_session(session.file_path, config.silent)
  end)

  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedTelescopeLoadPost", data = session })
end

---Delete the selected session from disk
--@return string
M.delete_session = function()
  local session = get_selected_session()
  local path = session.file_path

  if vim.fn.confirm("Delete [" .. session.name .. "]?", "&Yes\n&No") == 1 then
    vim.fn.delete(vim.fn.expand(path))
  end
end

return transform_mod(M)
