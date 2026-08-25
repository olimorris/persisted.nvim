local config = require("persisted.config")
local utils = require("persisted.utils")

local M = {}

local start_args = vim.fn.argc() > 0 or vim.g.started_with_stdin

local e = vim.fn.fnameescape
local fmt = string.format
local uv = vim.uv or vim.loop

---Warn the user that a named session doesn't exist
---@param name string
---@return nil
local function no_session(name)
  vim.notify(fmt("There is no session named `%s`", name), vim.log.levels.WARN, { title = "persisted.nvim" })
end

---Fire an event
---@param event string
---@param data? table
---@return nil
function M.fire(event, data)
  data = data or {}
  vim.api.nvim_exec_autocmds("User", { pattern = "Persisted" .. event, data = data })
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

---Get the session for a given name
---@param name string
---@return string
function M.named(name)
  return config.save_dir .. utils.make_fs_safe(name) .. ".vim"
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
---@param opts? { autoload?: boolean, last?: boolean, name?: string, session?: string }
---@return nil
function M.load(opts)
  opts = opts or {}

  local session

  if opts.last then
    session = M.last()
  elseif opts.name then
    session = M.named(opts.name)
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
    vim.schedule(function()
      M.fire("LoadPre")
      vim.cmd("silent! source " .. e(session))
      M.fire("LoadPost")
    end)
  elseif opts.name then
    no_session(opts.name)
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
---@param opts? { force?: boolean, name?: string, session?: string }
---@return nil
function M.save(opts)
  opts = opts or {}

  -- Do not save the session if should_save evals to false...unless it's forced
  if type(config.should_save) == "function" and not config.should_save() and not opts.force then
    return
  end

  local session = opts.session or (opts.name and M.named(opts.name)) or vim.g.persisting_session or M.current()

  M.fire("SavePre")
  vim.cmd("mks! " .. e(session))
  vim.cmd("sleep 10m")
  M.fire("SavePost")
end

---Delete a session
---@param opts? { name?: string, path?: string }
---@return nil
function M.delete_current(opts)
  opts = opts or {}
  local session = opts.path or (opts.name and M.named(opts.name)) or M.current()

  if session and uv.fs_stat(session) then
    M.fire("DeletePre", { path = session })
    vim.schedule(function()
      -- Only stop if we've deleted the session which is currently being persisted
      if session == (vim.g.persisting_session or M.current()) then
        M.stop()
      end
      vim.fn.delete(vim.fn.expand(session))
    end)
    M.fire("DeletePost", { path = session })
  elseif opts.name then
    no_session(opts.name)
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

---Get the directory and Git branch which a session file relates to
---@param session string The path to the session file
---@return { branch?: string, dir: string, name?: string, session: string }
function M.session_info(session)
  local file = session:sub(#config.save_dir + 1, -5)
  local dir, branch = unpack(vim.split(file, "@@", { plain = true }))
  dir = dir:gsub("%%", "/")
  if jit.os:find("Windows") then
    dir = dir:gsub("^(%w)/", "%1:/")
  end

  -- Sessions which aren't keyed by a directory were saved with a name
  local name = not utils.is_absolute(dir) and file or nil

  return { branch = branch, dir = dir, name = name, session = session }
end

---Handle the vim.ui.select behaviour
---@param opts { prompt: string, handler: function}
---@return nil
function M.handle_selected(opts)
  local items = {} ---@type table[]
  local found = {} ---@type table<string, boolean>
  for _, session in ipairs(M.list()) do
    if uv.fs_stat(session) then
      local item = M.session_info(session)
      if not found[item.dir .. (item.branch or "")] then
        found[item.dir .. (item.branch or "")] = true
        items[#items + 1] = item
      end
    end
  end
  vim.ui.select(items, {
    prompt = opts.prompt,
    format_item = function(item)
      if item.name then
        return item.name
      end

      local name = vim.fn.fnamemodify(item.dir, ":p:~")
      if item.branch then
        name = name .. " (" .. item.branch .. ")"
      end
      return name
    end,
  }, function(item)
    if item then
      opts.handler(item)
    end
  end)
end

---Load a session from the list
---@return nil
function M.select()
  M.handle_selected({
    prompt = "Load a session: ",
    handler = function(item)
      M.fire("SelectPre")
      if item.name then
        M.load({ session = item.session })
      else
        vim.fn.chdir(item.dir)
        M.load()
      end
      M.fire("SelectPost")
    end,
  })
end

---Delete a session from the list
---@return nil
function M.delete()
  M.handle_selected({
    prompt = "Delete a session: ",
    handler = function(item)
      M.delete_current({ path = item.session })
    end,
  })
end

---Delete the given sessions
---@param sessions table[]
---@return table[] deleted
local function delete_sessions(sessions)
  M.fire("CleanPre", { sessions = sessions })
  for _, item in ipairs(sessions) do
    vim.fn.delete(item.session)
  end
  M.fire("CleanPost", { sessions = sessions })

  vim.notify(
    fmt("Deleted %d orphaned session%s", #sessions, #sessions == 1 and "" or "s"),
    vim.log.levels.INFO,
    { title = "persisted.nvim" }
  )

  return sessions
end

---Delete any sessions whose directory, or Git branch, no longer exists
---@param opts? { confirm?: boolean, branches?: boolean }
---@return table[] deleted Empty whilst awaiting confirmation from the user
function M.clean(opts)
  opts = vim.tbl_extend("keep", opts or {}, { confirm = true, branches = true })

  local branches = {} ---@type table<string, string[]|false>
  local orphaned = {} ---@type table[]

  for _, session in ipairs(M.list()) do
    local item = M.session_info(session) ---@type table

    -- Ignore any files in the save_dir which the plugin didn't create
    if utils.is_absolute(item.dir) then
      if vim.fn.isdirectory(item.dir) == 0 then
        item.reason = "directory no longer exists"
      elseif opts.branches and item.branch then
        if branches[item.dir] == nil then
          branches[item.dir] = utils.branches(item.dir) or false
        end
        if branches[item.dir] and not utils.in_table(item.branch, branches[item.dir]) then
          item.reason = "branch no longer exists"
        end
      end

      if item.reason then
        orphaned[#orphaned + 1] = item
      end
    end
  end

  if not next(orphaned) then
    vim.notify("There are no sessions to clean", vim.log.levels.INFO, { title = "persisted.nvim" })
    return {}
  end

  if not opts.confirm then
    return delete_sessions(orphaned)
  end

  vim.ui.select({ "Yes", "No" }, {
    prompt = fmt("Delete %d orphaned session%s?", #orphaned, #orphaned == 1 and "" or "s"),
  }, function(choice)
    if choice == "Yes" then
      delete_sessions(orphaned)
    end
  end)

  return {}
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
