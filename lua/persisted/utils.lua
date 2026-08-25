local M = {}

local uv = vim.uv or vim.loop

--- Escapes the given text to be safe for use in file-system paths/names,
--- accounting for cross-platform use.
---@param text string
function M.make_fs_safe(text)
  return text:gsub("[\\/:]+", "%%")
end

---@param text string
---@return string
function M.replace_separators(text)
  return (text:gsub("%%", "/"))
end

---Get the directory pattern based on OS
---@return string
function M.dir_pattern()
  local pattern = "/"
  if vim.fn.has("win32") == 1 then
    pattern = "[\\:]"
  end
  return pattern
end

---Check if a directory is a Git repository
---@param dir string
---@return boolean
function M.is_git_repo(dir)
  return uv.fs_stat(dir .. "/.git") ~= nil
end

---Get the Git branches for a given directory
---@param dir string
---@return string[]? branches Nil if the branches could not be determined
function M.branches(dir)
  if not M.is_git_repo(dir) then
    return nil
  end

  local branches = vim.fn.systemlist({ "git", "-C", dir, "branch", "--format=%(refname:short)" })
  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- An unborn branch (a new repository with no commits) has no ref to list
  local current = vim.fn.systemlist({ "git", "-C", dir, "branch", "--show-current" })[1]
  if current then
    branches[#branches + 1] = current
  end

  return vim.tbl_map(function(branch)
    return M.make_fs_safe(branch)
  end, branches)
end

---Has the directory or Git branch created an orphaned session?
---@param args { item: table, branches: table<string, string[]|false>, check_branches: boolean }
---@return boolean
function M.is_orphaned(args)
  local item, branches = args.item, args.branches

  if vim.fn.isdirectory(item.dir) == 0 then
    return true
  end

  if not args.check_branches or not item.branch then
    return false
  end

  -- A branch keyed session can't be valid if the directory isn't a repository anymore
  if not M.is_git_repo(item.dir) then
    return true
  end

  if branches[item.dir] == nil then
    branches[item.dir] = M.branches(item.dir) or false
  end

  -- Git couldn't tell us the branches, so leave the session alone
  if not branches[item.dir] then
    return false
  end

  return not M.in_table(item.branch, branches[item.dir])
end

---Check if a path is absolute, accounting for cross-platform use
---@param path string
---@return boolean
function M.is_absolute(path)
  if vim.fn.has("win32") == 1 then
    return path:match("^%a:[\\/]") ~= nil
  end
  return vim.startswith(path, "/")
end

---Check if a directory is a subdirectory of another
---@param parent string
---@param child string
---@return boolean
function M.is_subdirectory(parent, child)
  return vim.startswith(child, parent)
end

---Check if a directory exists in the given table of directories
---@param dir string The directory to check
---@param dirs table The table of directories to search in
---@return boolean
function M.dirs_match(dir, dirs)
  dir = M.make_fs_safe(vim.fn.expand(dir))

  for _, search in ipairs(dirs) do
    if type(search) == "string" then
      search = M.make_fs_safe(vim.fn.expand(search))
      if M.is_subdirectory(search, dir) then
        return true
      end
    elseif type(search) == "table" then
      if search.exact then
        search = M.make_fs_safe(vim.fn.expand(search[1]))
        if dir == search then
          return true
        end
      end
    end
  end

  return false
end

---Check if a value exists in a table
---@param val any The value to search for
---@param tbl table The table to search in
---@return boolean
function M.in_table(val, tbl)
  for _, v in pairs(tbl) do
    if v == val then
      return true
    end
  end
  return false
end

return M
