local utils = require("persisted.utils")

local M = {}

local config
local e = vim.fn.fnameescape
local uv = vim.uv or vim.loop

---Does the cwd allow for autosaving and autoloading?
local function allowed_dir()
  if config.allowed_dirs == nil and config.ignored_dirs == nil then
    return true
  end

  return (
    utils.dirs_match(vim.fn.getcwd(), config.allowed_dirs) == true
    and utils.dirs_match(vim.fn.getcwd(), config.ignored_dirs) == false
  )
end

---Fire an event
---@param event string
---@return nil
local function fire(event)
  vim.api.nvim_exec_autocmds("User", { pattern = "Persisted" .. event })
end

---Get the current session for the cwd and git branch
---@return string
function M.current()
  local name = vim.fn.getcwd():gsub("[\\/:]+", "%%")
  local branch = M.branch()

  if branch then
    branch = "@@" .. branch
  end

  return config.save_dir .. name .. (branch or "") .. ".vim"
end

---Get the session that was saved last
---@return string
function M.last()
  local sessions = vim.fn.glob(config.save_dir .. "*.vim", true, true)

  table.sort(sessions, function(a, b)
    return uv.fs_stat(a).mtime.sec > uv.fs_stat(b).mtime.sec
  end)

  return sessions[1]
end

---Load a session
---@param opts? table
---@return nil
function M.load(opts)
  opts = opts or {}

  local session

  if opts.last then
    session = M.last()
  else
    session = M.current()
  end

  if session and vim.fn.filereadable(session) ~= 0 then
    fire("LoadPre")
    vim.cmd("silent! source " .. e(session))
    fire("LoadPost")
  end

  if config.autosave and allowed_dir() then
    M.start()
  end
end

---Automatically load the session for the current dir
---@return nil
function M.autoload()
  if config.autoload and allowed_dir() then
    M.load()
  end
end

---Start a session
---@return nil
function M.start()
  vim.g.persisting = true
  fire("StateChange")
end

---Stop a session
---@return nil
function M.stop()
  vim.g.persisting = false
  fire("StateChange")
end

---Save the session
---@param opts? table
---@return nil
function M.save(opts)
  opts = opts or {}

  -- Do not save the session if the user has manually stopped it...unless it's forced
  if vim.g.persisting ~= true and not opts.force then
    return
  end
  -- Do not save the session if autosave is turned off...unless it's forced
  if not config.autosave and not opts.force then
    return
  end
  -- Do not save the session if should_autosave evals to false...unless it's forced
  if type(config.should_autosave) == "function" and not config.should_autosave() and not opts.force then
    return
  end

  fire("SavePre")
  vim.cmd("mks! " .. e(M.current()))
  fire("SavePost")
end

---Delete the current session
---@return nil
function M.delete()
  local session = M.current()

  if session and uv.fs_stat(session) ~= 0 then
    fire("DeletePre")

    vim.schedule(function()
      M.stop()
      vim.fn.system("rm " .. e(session))
    end)

    fire("DeletePost")
  end
end

---Get the current Git branch
---@return string|nil
function M.branch()
  if config.use_git_branch then
    if uv.fs_stat(".git") then
      local branch = vim.fn.systemlist("git branch --show-current")[1]
      return vim.v.shell_error == 0 and branch or nil
    end
  end
end

---Determines whether to load, start or stop a session
---@return nil
function M.toggle()
  fire("Toggled")

  if vim.g.persisting == nil then
    return M.load({})
  end

  if vim.g.persisting then
    return M.stop()
  end

  return M.start()
end

---Setup the plugin
---@param opts? table
---@return nil
function M.setup(opts)
  config = vim.tbl_deep_extend("force", require("persisted.config"), opts or {})
  vim.fn.mkdir(config.save_dir, "p")

  if config.autosave and allowed_dir() and vim.g.persisting == nil then
    M.start()
  end
end

return M
