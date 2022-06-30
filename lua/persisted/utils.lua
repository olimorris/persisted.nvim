local M = {}
local e = vim.fn.fnameescape

--- Split a string into a table
---@param input string
---@param sep string
---@return table
function M.split_str(input, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(input, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

--- Get the last element in a table
---@param table table
---@return string
function M.get_last_item(table)
  for i, v in pairs(table) do
    last = #table - 0
  end
  return table[last]
end

---Check if a target directory exists in a given table
---@param dir_target string
---@param dir_table table
---@return boolean
function M.dirs_match(dir, dirs_table)
  local dir = vim.fn.expand(dir)
  return dirs_table
    and next(vim.tbl_filter(function(pattern)
      return dir:match(vim.fn.expand(pattern))
    end, dirs_table))
end

---Get the directory pattern based on OS
---@return string
function M.get_dir_pattern()
  local pattern = "/"
  if vim.fn.has("win32") == 1 then
    pattern = "[\\:]"
  end
  return pattern
end

---Print an error message
--@param msg string
--@param error string
--@return string
function M.echoerr(msg, error)
  vim.api.nvim_echo({
    { "[persisted.nvim]: ", "ErrorMsg" },
    { msg, "WarningMsg" },
    { error, "Normal" },
  }, true, {})
end

---Load the given session
---@param session table
---@param before_callback function
---@param after_callback function
function M.load_session(session, before_callback, after_callback)
  vim.schedule(function()
    if type(before_callback) == "function" then
      before_callback()
    end
    local ok, result = pcall(vim.cmd, "source " .. e(session))
    if not ok then
      return M.echoerr("Error loading the session! ", result)
    end
    if type(after_callback) == "function" then
      after_callback()
    end
  end)
end

return M
