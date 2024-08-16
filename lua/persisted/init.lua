local utils = require("persisted.utils")

local M = {}

local config
local e = vim.fn.fnameescape
local uv = vim.uv or vim.loop

---Fire an event
---@param event string
function M.fire(event)
  vim.api.nvim_exec_autocmds("User", { pattern = "Persisted" .. event })
end

---Get the current session for the current working directory and git branch
---@param opts? {branch?: boolean}
---@return string
function M.current(opts)
  opts = opts or {}
  local name = utils.make_fs_safe(vim.fn.getcwd())

  if config.use_git_branch and opts.branch ~= false then
    local branch = M.branch()
    if branch then
      branch = utils.make_fs_safe(branch)
      name = name .. "@@" .. branch
    end
  end

  return config.save_dir .. name .. ".vim"
end

---Automatically load the session for the current dir
---@param opts? { force?: boolean }
function M.autoload(opts)
  opts = opts or {}

  if not opts.force and (vim.fn.argc() > 0 or vim.g.started_with_stdin) then
    return
  end

  if config.autoload and M.allowed_dir() then
    M.load({ autoload = true })
  end
end

---Load a session
---@param opts? { last?: boolean, autoload?: boolean, session?: string }
function M.load(opts)
  opts = opts or {}

  local session

  if opts.last then
    session = M.last()
  elseif opts.session then
    session = opts.session
  else
    session = M.current()
    if vim.fn.filereadable(session) == 0 then
      session = M.current({ branch = false })
    end
  end

  if session and vim.fn.filereadable(session) ~= 0 then
    vim.g.persisting_session = not config.follow_cwd and session or nil
    vim.g.persisted_loaded_session = session
    M.fire("LoadPre")
    vim.cmd("silent! source " .. e(session))
    M.fire("LoadPost")
  elseif opts.autoload and type(config.on_autoload_no_session) == "function" then
    config.on_autoload_no_session()
  end

  if config.autostart and M.allowed_dir() then
    M.start()
  end
end

---Start a session
function M.start()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("Persisted", { clear = true }),
    callback = function()
      M.save()
    end,
  })

  vim.g.persisting = true
  M.fire("Start")
end

---Stop a session
function M.stop()
  vim.g.persisting = false
  pcall(vim.api.nvim_del_augroup_by_name, "Persisted")
  M.fire("Stop")
end

---Save the session
---@param opts? { force?: boolean, session?: string }
function M.save(opts)
  opts = opts or {}

  -- Do not save the session if should_save evals to false...unless it's forced
  if type(config.should_save) == "function" and not config.should_save() and not opts.force then
    return
  end

  M.fire("SavePre")
  vim.cmd("mks! " .. e(opts.session or vim.g.persisting_session or M.current()))
  vim.cmd("sleep 10m")
  M.fire("SavePost")
end

---Delete the current session
---@param opts? { session?: string }
function M.delete(opts)
  opts = opts or {}
  local session = opts.session or M.current()

  if session and uv.fs_stat(session) ~= 0 then
    M.fire("DeletePre")
    vim.schedule(function()
      M.stop()
      vim.fn.system("rm " .. e(session))
    end)
    M.fire("DeletePost")
  end
end

---Get the current Git branch
---@return string?
function M.branch()
  if uv.fs_stat(".git") then
    local branch = vim.fn.systemlist("git branch --show-current")[1]
    return vim.v.shell_error == 0 and branch or nil
  end
end

---Determines whether to load, start or stop a session
function M.toggle()
  M.fire("Toggle")
  if vim.g.persisting == nil then
    return M.load()
  end
  if vim.g.persisting then
    return M.stop()
  end
  return M.start()
end

---Allow autosaving and autoloading for the given dir?
---@param opts? {dir?: string}
---@return boolean
function M.allowed_dir(opts)
  if next(config.allowed_dirs) == nil and next(config.ignored_dirs) == nil then
    return true
  end

  opts = opts or {}
  local dir = opts.dir or vim.fn.getcwd()

  return utils.dirs_match(dir, config.allowed_dirs) and not utils.dirs_match(dir, config.ignored_dirs)
end

---Get an ordered list of sessions, sorted by modified time
---@return string[]
function M.list()
  local sessions = vim.fn.glob(config.save_dir .. "*.vim", true, true)

  table.sort(sessions, function(a, b)
    return uv.fs_stat(a).mtime.sec > uv.fs_stat(b).mtime.sec
  end)

  return sessions
end

---Get the last session that was saved
---@return string
function M.last()
  return M.list()[1]
end

---Setup the plugin
---@param opts? table
function M.setup(opts)
  -- Account for old config options
  if opts and opts.autosave then
    opts.autostart = opts.autosave
  end
  if opts and opts.should_autosave then
    opts.should_save = opts.should_autosave
  end
  if opts and opts.allowed_dirs == nil then
    opts.allowed_dirs = {}
  end
  if opts and opts.ignored_dirs == nil then
    opts.ignored_dirs = {}
  end

  config = vim.tbl_deep_extend("force", require("persisted.config"), opts or {})
  M.config = config

  vim.fn.mkdir(config.save_dir, "p")

  if config.autostart and M.allowed_dir() and vim.g.persisting == nil then
    M.start()
  end
end

return M
