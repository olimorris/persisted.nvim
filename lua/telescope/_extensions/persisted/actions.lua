local actions_state = require("telescope.actions.state")
local transform_mod = require("telescope.actions.mt").transform_mod

local persisted = require("persisted")
local config = persisted.config

local M = {}

---Fire an event
---@param event string
local function fire(event)
  vim.api.nvim_exec_autocmds("User", { pattern = "Persisted" .. event })
end

---Get the selected session from Telescope
---@return table
local function get_selected_session()
  return actions_state.get_selected_entry()
end

---Load the selected session
---@param session table
function M.load_session(session)
  fire("TelescopeLoadPre")
  vim.schedule(function()
    persisted.load({ session = session.file_path })
  end)
  fire("TelescopeLoadPost")
end

---Delete the selected session from disk
function M.delete_session()
  local session = get_selected_session()

  if vim.fn.confirm("Delete [" .. session.name .. "]?", "&Yes\n&No") == 1 then
    vim.fn.delete(vim.fn.expand(session.file_path))
  end
end

---Change the branch of an existing session
function M.change_branch()
  local session = get_selected_session()
  local path = session.file_path

  local branch = vim.fn.input("Branch name: ")

  if vim.fn.confirm("Add/update branch to [" .. branch .. "]?", "&Yes\n&No") == 1 then
    local ext = path:match("^.+(%..+)$")

    -- Check for existing branch in the filename
    local pattern = "(.*)@@.+" .. ext .. "$"
    local base = path:match(pattern) or path:sub(1, #path - #ext)

    -- Replace or add the new branch name
    local new_path = ""
    if branch == "" then
      new_path = base .. ext
    else
      new_path = base .. "@@" .. branch .. ext
    end

    os.rename(path, new_path)
  end
end

---Copy an existing session
function M.copy_session()
  local session = get_selected_session()
  local old_name = session.file_path:gsub(config.save_dir, "")

  local new_name = vim.fn.input("New session name: ", old_name)

  if vim.fn.confirm("Rename session from [" .. old_name .. "] to [" .. new_name .. "]?", "&Yes\n&No") == 1 then
    os.execute("cp " .. session.file_path .. " " .. config.save_dir .. new_name)
  end
end

return transform_mod(M)
