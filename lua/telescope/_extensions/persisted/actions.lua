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
--@return nil
M.delete_session = function()
  local session = get_selected_session()
  local path = session.file_path

  if vim.fn.confirm("Delete [" .. session.name .. "]?", "&Yes\n&No") == 1 then
    vim.fn.delete(vim.fn.expand(path))
  end
end

---Change the branch of an existing session
---@param config table
---@return nil
M.change_branch = function(config)
  local session = get_selected_session()
  local path = session.file_path

  local branch = vim.fn.input("Branch name: ")

  if vim.fn.confirm("Add/update branch to [" .. branch .. "]?", "&Yes\n&No") == 1 then
    local ext = path:match("^.+(%..+)$")

    -- Check for existing branch in the filename
    local branch_separator = config.branch_separator or "@@"
    local pattern = "(.*)" .. branch_separator .. ".+" .. ext .. "$"
    local base = path:match(pattern) or path:sub(1, #path - #ext)

    -- Replace or add the new branch name
    local new_path = ""
    if branch == "" then
      new_path = base .. ext
    else
      new_path = base .. branch_separator .. branch .. ext
    end

    os.rename(path, new_path)
  end
end

---Copy an existing session
---@return nil
M.copy_session = function(config)
  local session = get_selected_session()
  local old_name = session.file_path:gsub(config.save_dir, "")

  local new_name = vim.fn.input("New session name: ", old_name)

  if vim.fn.confirm("Rename session from [" .. old_name .. "] to [" .. new_name .. "]?", "&Yes\n&No") == 1 then
    os.execute("cp " .. session.file_path .. " " .. config.save_dir .. new_name)
  end
end

return transform_mod(M)
