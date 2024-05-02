local M = {}
local e = vim.fn.fnameescape
local fp_sep = vim.loop.os_uname().sysname:lower():match("windows") and "\\" or "/" -- \ for windows, mac and linux both use \

---Print an error message
--@param msg string
--@param error string
--@return string
local function echoerr(msg, error)
  vim.api.nvim_echo({
    { "[Persisted.nvim]: ", "ErrorMsg" },
    { msg, "WarningMsg" },
    { error, "Normal" },
  }, true, {})
end

--- Escape special pattern matching characters in a string
---@param input string
---@return string
local function escape_pattern(input)
  local magic_chars = { "%", "(", ")", ".", "+", "-", "*", "?", "[", "^", "$" }

  for _, char in ipairs(magic_chars) do
    input = input:gsub("%" .. char, "%%" .. char)
  end

  return input
end

---Form a table of session data
---@param session string
---@return table|nil
function M.make_session_data(session)
  local config = require("persisted.config").options

  local home = os.getenv("HOME") or os.getenv("USERPROFILE") or ""

  -- Split the session string into path and branch parts
  local separator_index = session:find(config.branch_separator)
  if not separator_index then
    return nil
  end

  local branch = session:sub(separator_index + 2):gsub("%.vim$", ""):gsub("%%", "/")

  -- Removing the home directory from the path and cleaning leading `/`
  local name = session:gsub(config.save_dir, ""):gsub("%%", "/"):gsub(home, "")
  -- Remove the .vim extension
  name = name:sub(1, #name - 4)
  if name:sub(1, 1) == "/" then
    name = name:sub(2)
  end

  local dir_path = name:gsub(branch, ""):gsub(config.branch_separator, ""):gsub(home, "")

  return {
    name = name,
    dir_path = dir_path,
    file_path = session,
    branch = branch,
  }
end

--- Get the last element in a table
---@param table table
---@return string
function M.get_last_item(table)
  local last
  for _, _ in pairs(table) do
    last = #table - 0
  end
  return table[last]
end

---Check if a target directory exists in a given table
---@param dir string
---@param dirs_table table
---@return boolean
function M.dirs_match(dir, dirs_table)
  dir = vim.fn.expand(dir)
  return M.table_match(dir, dirs_table, function(pattern)
    return escape_pattern(vim.fn.expand(pattern))
  end)
end

---Check if a string matches and entry in a given table
---@param needle string
---@param heystack table
---@return boolean
function M.table_match(needle, heystack, escape_fct)
  if needle == nil then
    return false
  end
  return heystack
    and next(vim.tbl_filter(function(pattern)
      if pattern.exact then
        -- The pattern is actually a table
        pattern = pattern[1]
        -- Stripping off the trailing backslash that a user might put here,
        -- but only if we aren't looking at the root directory
        if pattern:sub(-1) == fp_sep and pattern:len() > 1 then
          pattern = pattern:sub(1, -2)
        end
        return needle == pattern
      else
        if escape_fct then
          pattern = escape_fct(pattern)
        end
        return needle:match(pattern)
      end
    end, heystack))
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

---Load the given session
---@param session string
---@param silent boolean Load the session silently?
---@return nil|string
function M.load_session(session, silent)
  local session_data = M.make_session_data(session)

  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedLoadPre", data = session_data })

  local ok, result = pcall(vim.cmd, (silent and "silent " or "") .. "source " .. e(session))
  if not ok then
    return echoerr("Error loading the session! ", result)
  end

  vim.g.persisted_exists = true
  vim.g.persisted_loaded_session = session

  vim.api.nvim_exec_autocmds("User", { pattern = "PersistedLoadPost", data = session_data })
end

return M
