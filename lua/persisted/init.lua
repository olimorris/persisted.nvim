local config = require("persisted.config")

local M = {}

local e = vim.fn.fnameescape
local echo = vim.api.nvim_echo

local echoerr = function(msg, error)
  echo({
    { "[persisted.nvim]: ", "ErrorMsg" },
    { msg, "WarningMsg" },
    { error, "Normal" },
  }, true, {})
end

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

---Check if a target directory exists in a given table
---@param dir_target string
---@param dir_table table
---@return boolean
local function dirs_match(dir_target, dir_table)
  for _, dir in pairs(dir_table) do
    dir = string.gsub(vim.fn.expand(dir), "/+$", "")
    if dir_target == dir then
      return true
    end
  end
  return false
end

---Does the current working directory allow for the auto-saving and loading?
---@return boolean
local function allow_dir()
  local allowed_dirs = config.options.allowed_dirs

  if allowed_dirs == nil then
    return true
  end
  return dirs_match(vim.fn.getcwd(), allowed_dirs)
end

---Is the current working directory ignored for auto-saving and loading?
---@return boolean
local function ignore_dir()
  local ignored_dirs = config.options.ignored_dirs

  if ignored_dirs == nil then
    return false
  end
  return dirs_match(vim.fn.getcwd(), ignored_dirs)
end

---Get the session that was saved last
---@return string
local function get_last()
  local sessions = M.list()
  table.sort(sessions, function(a, b)
    return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec
  end)
  return sessions[1]
end

---Get the current Git branch
---@return string
local function get_branch()
  local git_enabled = (vim.fn.isdirectory(vim.fn.getcwd() .. "/.git") == 1)

  if config.options.use_git_branch and git_enabled then
    local branch = vim.api.nvim_exec([[!git rev-parse --abbrev-ref HEAD 2>/dev/null]], true)

    -- The branch command returns two lines. We only need the second one
    local lines = {}
    for s in branch:gmatch("[^\r\n]+") do
      table.insert(lines, "_" .. s)
    end

    return lines[#lines]:gsub("/", "%%")
  end

  return ""
end

---Get the current session for the current working directory and git branch
---@return string
local function get_current()
  local pattern = "/"
  if vim.fn.has("win32") == 1 then
    pattern = "[\\:]"
  end
  local name = vim.fn.getcwd():gsub(pattern, "%%")
  return config.options.dir .. name .. get_branch() .. ".vim"
end

---Setup the plugin based on the intersect of the default and the user's config
---@param opts table
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
---@param opt table
---@return nil
function M.load(opt)
  opt = opt or {}
  local session = opt.last and get_last() or get_current()

  if session and vim.fn.filereadable(session) ~= 0 then
    local ok, result = pcall(vim.cmd, "source " .. e(session))
    if not ok then
      echoerr("Error loading the session! ", result)
    end
  end

  if config.options.autosave and (allow_dir() and not ignore_dir()) then
    M.start()
  end
end

---Start recording a session and write it to disk when exiting Neovim
---@return nil
function M.start()
  vim.cmd([[
    augroup Persisted
      autocmd!
      autocmd VimLeavePre * lua require("persisted").save()
    augroup end
  ]])
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
end

---Save the session to disk
---@return nil
function M.save()
  config.options.before_save()

  vim.cmd("mks! " .. e(get_current()))
  vim.g.persisting = true

  config.options.after_save()
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

---List all of the sessions in the session directory
---@return table
function M.list()
  return vim.fn.glob(config.options.dir .. "*.vim", true, true)
end

---Determines whether to load, start or stop a session
---@return function
function M.toggle()
  if vim.g.persisting == nil then
    return M.load()
  end
  if vim.g.persisting then
    return M.stop()
  end
  return M.start()
end

return M
