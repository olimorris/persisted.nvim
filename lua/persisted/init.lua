local utils = require("persisted.utils")
local config = require("persisted.config")

local M = {}

local e = vim.fn.fnameescape
local default_branch = "main"

---Does the current working directory allow for the auto-saving and loading?
---@return boolean
local function allow_dir()
  local allowed_dirs = config.options.allowed_dirs

  if allowed_dirs == nil then
    return true
  end
  return utils.dirs_match(vim.fn.getcwd(), allowed_dirs)
end

---Is the current working directory ignored for auto-saving and loading?
---@return boolean
local function ignore_dir()
  local ignored_dirs = config.options.ignored_dirs

  if ignored_dirs == nil then
    return false
  end
  return utils.dirs_match(vim.fn.getcwd(), ignored_dirs)
end

---Get the session that was saved last
---@return string
local function get_last()
  local sessions = vim.fn.glob(config.options.save_dir .. "*.vim", true, true)
  table.sort(sessions, function(a, b)
    return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec
  end)
  return sessions[1]
end

---Get the current Git branch
---@return string
function M.get_branch()
  vim.fn.system([[git rev-parse 2> /dev/null]])
  local git_enabled = (vim.v.shell_error == 0)

  if config.options.use_git_branch and git_enabled then
    local branch = vim.fn.systemlist([[git rev-parse --abbrev-ref HEAD 2>/dev/null]])
    if vim.v.shell_error == 0 then
      return config.options.branch_separator .. branch[1]:gsub("/", "%%")
    end
  end

  return config.options.branch_separator .. default_branch
end

---Get the current session for the current working directory and git branch
---@return string
local function get_current()
  local name = vim.fn.getcwd():gsub(utils.get_dir_pattern(), "%%")
  return config.options.save_dir .. name .. M.get_branch() .. ".vim"
end

---Setup the plugin
---@param opts? table
---@return nil
function M.setup(opts)
  config.setup(opts)

  if
    config.options.autosave
    and (allow_dir() and not ignore_dir() and vim.g.persisting == nil)
    and vim.fn.argc() == 0
  then
    M.start()
  end
end

---Load a session
---@param opt? table
---@return nil
function M.load(opt)
  opt = opt or {}
  local session = opt.session or (opt.last and get_last() or get_current())

  if session then
    if vim.fn.filereadable(session) ~= 0 then
      vim.g.persisting_session = config.options.follow_cwd and nil or session
      -- TODO: Alter this function call after deprecation notice ends
      utils.load_session(session, config.options.before_source, config.options.after_source, config.options.silent)
      --
    elseif type(config.options.on_autoload_no_session) == "function" then
      config.options.on_autoload_no_session()
    end
  end

  if config.options.autosave and (allow_dir() and not ignore_dir()) then
    M.start()
  end
end

---Automatically load the session for the current dir
---@return nil
function M.autoload()
  -- Ensure that no arguments have been passed to Neovim
  if config.options.autoload and vim.fn.argc() == 0 then
    if allow_dir() and not ignore_dir() then
      M.load()
    end
  end
end

---Start recording a session
---@return nil
function M.start()
  vim.g.persisting = true
  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedStateChange", data = { action = "start" } })
end

---Stop recording a session
---@return nil
function M.stop()
  vim.g.persisting = false
  vim.g.persisting_session = nil
  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedStateChange", data = { action = "stop" } })
end

---Save the session
---@param opt? table
---@return nil
function M.save(opt)
  opt = opt or {}

  -- If the user has stopped the session, then do not save
  if vim.g.persisting == false then
    return
  end

  --TODO: Remove this after deprecation notice period ends
  if type(config.options.before_save) == "function" then
    config.options.before_save()
  end
  --

  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedSavePre" })

  -- Autosave config option takes priority unless it's overriden
  if not config.options.autosave and not opt.override then
    return
  end

  if type(config.options.should_autosave) == "function" and not config.options.should_autosave() then
    return
  end

  vim.cmd("mks! " .. e(vim.g.persisting_session or get_current()))
  vim.g.persisting = true

  --TODO: Remove this after deprecation notice period ends
  if type(config.options.after_save) == "function" then
    config.options.after_save()
  end
  --

  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedSavePost" })
end

---Delete the current session
---@return nil
function M.delete()
  local session = get_current()
  if session and vim.loop.fs_stat(session) ~= 0 then
    vim.api.nvim_exec_autocmds("User", { pattern = "PersistedDeletePre", data = { name = session } })

    vim.schedule(function()
      M.stop()
      vim.fn.system("rm " .. e(session))
    end)

    vim.api.nvim_exec_autocmds("User", { pattern = "PersistedDeletePost", data = { name = session } })
  end
end

---Determines whether to load, start or stop a session
---@return nil
function M.toggle()
  if vim.g.persisting == nil then
    return M.load()
  end
  if vim.g.persisting then
    return M.stop()
  end
  return M.start()
end

---Escapes special characters before performing string substitution
---@param str string
---@param pattern string
---@param replace string
---@param n? integer
---@return string
---@return integer count
local function escape_pattern(str, pattern, replace, n)
  pattern = string.gsub(pattern, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
  replace = string.gsub(replace, "[%%]", "%%%%") -- escape replacement
  return string.gsub(str, pattern, replace, n)
end

---List all of the sessions
---@return table
function M.list()
  local save_dir = config.options.save_dir
  local session_files = vim.fn.glob(save_dir .. "*.vim", true, true)
  local branch_separator = config.options.branch_separator
  local dir_separator = utils.get_dir_pattern()

  local sessions = {}
  for _, session in pairs(session_files) do
    local session_name = escape_pattern(session, save_dir, "")
      :gsub("%%", dir_separator)
      :gsub(vim.fn.expand("~"), dir_separator)
      :gsub("//", "")
      :sub(1, -5)

    if vim.fn.has("win32") == 1 then
      -- format drive letter (no trailing separator)
      session_name = escape_pattern(session_name, dir_separator, ":", 1)
      -- format remaining filepath separator(s)
      session_name = escape_pattern(session_name, dir_separator, "\\")
    end

    local branch, dir_path

    if string.find(session_name, branch_separator, 1, true) then
      local splits = vim.split(session_name, branch_separator, { plain = true })
      branch = table.remove(splits, #splits)
      dir_path = vim.fn.join(splits, branch_separator)
    else
      dir_path = session_name
    end

    table.insert(sessions, {
      ["name"] = session_name,
      ["file_path"] = session,
      ["branch"] = branch,
      ["dir_path"] = dir_path,
    })
  end
  return sessions
end

return M
