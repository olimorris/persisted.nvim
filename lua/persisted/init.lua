local config = require("persisted.config")
local utils = require("persisted.utils")

local M = {}

local start_args = vim.fn.argc() > 0 or vim.g.started_with_stdin

local e = vim.fn.fnameescape
local uv = vim.uv or vim.loop

---Fire an event
---@param event string
---@return nil
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
---@return nil
function M.autoload(opts)
  opts = opts or {}

  if not opts.force and start_args then
    return
  end

  if config.autoload and M.allowed_dir() then
    M.load({ autoload = true })
  end
end

---Load a session
---@param opts? { last?: boolean, autoload?: boolean, session?: string }
---@return nil
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

  if config.autostart and M.allowed_dir() and not start_args then
    M.start()
  end
end

---Start a session
---@return nil
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
---@return nil
function M.stop()
  vim.g.persisting = false
  pcall(vim.api.nvim_del_augroup_by_name, "Persisted")
  M.fire("Stop")
end

---Save the session
---@param opts? { force?: boolean, session?: string }
---@return nil
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

---Delete a session
---@param opts? { path?: string }
---@return nil
function M.delete(opts)
  opts = opts or {}
  local session = opts.path or M.current()

  if session and uv.fs_stat(session) ~= 0 then
    M.fire("DeletePre")
    vim.schedule(function()
      M.stop()
      vim.fn.delete(vim.fn.expand(session))
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

---Select a session to load
---@return nil
function M.select()
  local items = {} ---@type { session: string, dir: string, branch?: string }[]
  local found = {} ---@type table<string, boolean>
  for _, session in ipairs(M.list()) do
    if uv.fs_stat(session) then
      local file = session:sub(#config.save_dir + 1, -5)
      local dir, branch = unpack(vim.split(file, "@@", { plain = true }))
      dir = dir:gsub("%%", "/")
      if jit.os:find("Windows") then
        dir = dir:gsub("^(%w)/", "%1:/")
      end
      if not found[dir .. (branch or "")] then
        found[dir .. (branch or "")] = true
        items[#items + 1] = { session = session, dir = dir, branch = branch }
      end
    end
  end
  vim.ui.select(items, {
    prompt = "Load a session: ",
    format_item = function(item)
      local name = vim.fn.fnamemodify(item.dir, ":p:~")
      if item.branch then
        name = name .. " (" .. item.branch .. ")"
      end
      return name
    end,
  }, function(item)
    if item then
      M.fire("SelectPre")
      vim.fn.chdir(item.dir)
      M.load()
      M.fire("SelectPost")
    end
  end)
end

---Determines whether to load, start or stop a session
---@return nil
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
  opts = opts or {}
  local dir = opts.dir or vim.fn.getcwd()

  return (next(config.allowed_dirs) and utils.dirs_match(dir, config.allowed_dirs) or true)
    and not (next(config.ignored_dirs) and utils.dirs_match(dir, config.ignored_dirs) or false)
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
---@return nil
function M.setup(opts)
  config.setup(opts)

  vim.fn.mkdir(config.save_dir, "p")

  if config.autostart and M.allowed_dir() and vim.g.persisting == nil and not start_args then
    M.start()
  end
end

return M
