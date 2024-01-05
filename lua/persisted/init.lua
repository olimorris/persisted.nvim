local utils = require("persisted.utils")
local config = require("persisted.config")

local M = {}

local e = vim.fn.fnameescape

---Escapes special characters before performing string substitution
---@param str string
---@param pattern string
---@param replace string
---@param n? integer
---@return string
---@return integer
local function escape_pattern(str, pattern, replace, n)
  pattern = string.gsub(pattern, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
  replace = string.gsub(replace, "[%%]", "%%%%") -- escape replacement

  return string.gsub(str, pattern, replace, n)
end

---Gets the directory from the file/path argument passed to Neovim if there's
---exactly one and it resolves to a valid directory
---@return string|nil
local function args_path()
  if vim.fn.argc() ~= 1 then
    return nil
  end

  -- Use expand() to resolve '~' and use fs_realpath to resolve both '.' and
  -- relative paths passed as arguments. Note that argv() will only ever return
  -- paths/files passed as arguments and does not include other
  -- parameters/arguments. fs_realpath() returns nil if the path doesn't exist.
  -- Use isdirectory to validate it's a directory and not a file.
  local dir = vim.loop.fs_realpath(vim.fn.expand(vim.fn.argv(0)))
  if dir ~= nil and vim.fn.isdirectory(dir) ~= 0 then
    return dir
  end
  return nil
end

---Check any arguments passed to Neovim and verify if they're a directory
---@return boolean
local function args_check()
  -- Args are valid if a single directory was resolved or if no args were used.
  return args_path() ~= nil or vim.fn.argc() == 0
end

---Get the directory to be used for the session
---@return string
local function session_dir()
  -- Use specified directory from arguments or the working directory otherwise.
  return args_path() or vim.fn.getcwd()
end

---Does the current working directory allow for the auto-saving and loading?
---@param dir string Directory to be used for the session
---@return boolean
local function allow_dir(dir)
  local allowed_dirs = config.options.allowed_dirs

  if allowed_dirs == nil then
    return true
  end

  return utils.dirs_match(dir, allowed_dirs)
end

---Is the current working directory ignored for auto-saving and loading?
---@param dir string Directory to be used for the session
---@return boolean
local function ignore_dir(dir)
  local ignored_dirs = config.options.ignored_dirs

  if ignored_dirs == nil then
    return false
  end

  return utils.dirs_match(dir, ignored_dirs)
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
---@param dir? string Directory to be used for the session
---@return string|nil
function M.get_branch(dir)
  dir = dir or session_dir()

  if config.options.use_git_branch then
    vim.fn.system('git -C "' .. dir .. '" rev-parse 2>/dev/null')

    local git_enabled = (vim.v.shell_error == 0)

    if git_enabled then
      local git_branch = vim.fn.systemlist('git -C "' .. dir .. '" rev-parse --abbrev-ref HEAD 2>/dev/null')

      if vim.v.shell_error == 0 then
        local branch = config.options.branch_separator .. git_branch[1]:gsub("/", "%%")
        local branch_session = config.options.save_dir .. dir:gsub(utils.get_dir_pattern(), "%%") .. branch .. ".vim"

        -- Try to load the session for the current branch
        if vim.fn.filereadable(branch_session) ~= 0 then
          return branch
        else
          vim.api.nvim_echo({
            { "[Persisted.nvim]\n", "Question" },
            { "Could not load a session for branch " },
            { git_branch[1] .. "\n", "WarningMsg" },
            { "Trying to load a session for branch " },
            { config.options.default_branch, "Title" },
            { " ..." },
          }, true, {})

          vim.g.persisted_branch_session = branch_session
          return config.options.branch_separator .. config.options.default_branch
        end
      end
    end
  end
end

---Get the current session for the current working directory and git branch
---@param dir string Directory to be used for the session
---@return string
local function get_current(dir)
  local name = dir:gsub(utils.get_dir_pattern(), "%%")
  local branch = M.get_branch(dir)

  return config.options.save_dir .. name .. (branch or "") .. ".vim"
end

---Determine if a session for the current wording directory, exists
---@param dir? string Directory to be used for the session
---@return boolean
function M.session_exists(dir)
  dir = dir or session_dir()

  return vim.fn.filereadable(get_current(dir)) ~= 0
end

---Setup the plugin
---@param opts? table
---@return nil
function M.setup(opts)
  config.setup(opts)
  local dir = session_dir()

  if
    config.options.autosave
    and (allow_dir(dir) and not ignore_dir(dir) and vim.g.persisting == nil)
    and args_check()
  then
    M.start()
  end
end

---Load a session
---@param opt? table
---@param dir? string Directory to be used for the session
---@return nil
function M.load(opt, dir)
  opt = opt or {}
  dir = dir or session_dir()

  local session = opt.session or (opt.last and get_last() or get_current(dir))

  local session_exists = vim.fn.filereadable(session) ~= 0

  if session then
    if session_exists then
      vim.g.persisting_session = config.options.follow_cwd and nil or session
      utils.load_session(session, config.options.silent)
    elseif type(config.options.on_autoload_no_session) == "function" then
      config.options.on_autoload_no_session()
    end
  end

  if config.options.autosave and (allow_dir(dir) and not ignore_dir(dir)) then
    M.start()
  end
end

---Automatically load the session for the current dir
---@return nil
function M.autoload()
  local dir = session_dir()

  if config.options.autoload and args_check() then
    if allow_dir(dir) and not ignore_dir(dir) then
      M.load({}, dir)
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

---Write the session to disk
---@param session string
---@return nil
local function write(session)
  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedSavePre" })
  vim.cmd("mks! " .. e(session))
  vim.g.persisting = true
  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedSavePost" })
end

---Save the session
---@param opt? table
---@param dir? string Directory to be used for the session
---@return nil
function M.save(opt, dir)
  opt = opt or {}
  dir = dir or session_dir()

  if not opt.session then
    -- Do not save the session if the user has manually stopped it...unless it's forced
    if (vim.g.persisting == false or vim.g.persisting == nil) and not opt.force then
      return
    end

    -- Do not save the session if autosave is turned off...unless it's forced
    if not config.options.autosave and not opt.force then
      return
    end

    -- Do not save the session if the callback returns false...unless it's forced
    if type(config.options.should_autosave) == "function" and not config.options.should_autosave() then
      return
    end
  end

  local session = opt.session or (vim.g.persisted_branch_session or vim.g.persisting_session or get_current(dir))
  write(session)
end

---Delete the current session
---@param dir? string Directory to be used for the session
---@return nil
function M.delete(dir)
  dir = dir or session_dir()
  local session = get_current(dir)

  if session and vim.loop.fs_stat(session) ~= 0 then
    local session_data = utils.make_session_data(session)

    vim.api.nvim_exec_autocmds("User", { pattern = "PersistedDeletePre", data = session_data })

    vim.schedule(function()
      M.stop()
      vim.fn.system("rm " .. e(session))
    end)

    vim.api.nvim_exec_autocmds("User", { pattern = "PersistedDeletePost", data = session_data })
  end
end

---Determines whether to load, start or stop a session
---@param dir? string The directory whose associated session saving should be toggled. If not set, the current working directory is used.
---@return nil
function M.toggle(dir)
  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedToggled" })

  dir = dir or session_dir()

  if vim.g.persisting == nil then
    return M.load({}, dir)
  end

  if vim.g.persisting then
    return M.stop()
  end

  return M.start()
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
