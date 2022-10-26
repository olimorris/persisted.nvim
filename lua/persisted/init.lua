local utils = require("persisted.utils")
local config = require("persisted.config")

local M = {}

local e = vim.fn.fnameescape
local default_branch = "main"

---Setup the plugin's commands
---@return nil
local function setup_commands()
  vim.cmd([[
    command! SessionStart :lua require("persisted").start()
    command! SessionStop :lua require("persisted").stop()
    command! SessionSave :lua require("persisted").save()
    command! SessionLoad :lua require("persisted").load()
    command! SessionLoadLast :lua require("persisted").load({ last = true })
    command! SessionDelete :lua require("persisted").delete()
    command! SessionToggle :lua require("persisted").toggle()
  ]])
end

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
  return (config.options.save_dir) .. name .. M.get_branch() .. ".vim"
end

---Setup the plugin based on the intersect of the default and the user's config
---@param opts table
---@param opts? table
---@return nil
function M.setup(opts)
  config.setup(opts)
  setup_commands()

  if config.options.autoload and (allow_dir() and not ignore_dir()) and vim.fn.argc() == 0 then
    M.load()
  end

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
  local session = opt.last and get_last() or get_current()

  if session then
    if vim.fn.filereadable(session) ~= 0 then
      if config.options.follow_cwd then
        vim.g.persisting_session = nil
      else
        vim.g.persisting_session = session
      end
      utils.load_session(session, config.options.before_source, config.options.after_source, config.options.silent)
    elseif type(config.options.on_autoload_no_session) == "function" then
      config.options.on_autoload_no_session()
    end
  end

  if config.options.autosave and (allow_dir() and not ignore_dir()) then
    vim.schedule(function()
      M.start()
    end)
  end
end

---Start recording a session and write to disk on a specific autocommand
---@return nil
function M.start()
  vim.api.nvim_create_augroup("Persisted", { clear = true })
  vim.api.nvim_create_autocmd(config.options.command, {
    group = "Persisted",
    callback = function()
      require("persisted").save()
    end,
  })
  vim.g.persisting = true
end

---Stop recording a session
---@return nil
function M.stop()
  vim.cmd([[
    autocmd! Persisted
    augroup! Persisted
  ]])
  vim.g.persisting = false
  vim.g.persisting_session = nil
end

---Save the session to disk
---@return nil
function M.save()
  if type(config.options.before_save) == "function" then
    config.options.before_save()
  end

  if
    (config.options.autosave and type(config.options.should_autosave) == "function")
    and not config.options.should_autosave()
  then
    return
  end

  if vim.g.persisting_session == nil then
    vim.cmd("mks! " .. e(get_current()))
  else
    vim.cmd("mks! " .. e(vim.g.persisting_session))
  end

  vim.g.persisting = true

  if type(config.options.after_save) == "function" then
    config.options.after_save()
  end
end

---Delete the current session from disk
---@return nil
function M.delete()
  local session = get_current()
  if session and vim.loop.fs_stat(session) ~= 0 then
    M.stop()
    vim.fn.system("rm " .. e(session))
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

---List all of the sessions in the session directory
---@return table
function M.list()
  local save_dir = config.options.save_dir
  local session_files = vim.fn.glob(save_dir .. "*.vim", true, true)
  local branch_separator = config.options.branch_separator

  local sessions = {}
  for _, session in pairs(session_files) do
    local session_name = session
      :gsub(save_dir, "")
      :gsub("%%", utils.get_dir_pattern())
      :gsub(vim.fn.expand("~"), utils.get_dir_pattern())
      :gsub("//", "")
      :sub(1, -5)

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
