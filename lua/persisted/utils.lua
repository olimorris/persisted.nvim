local M = {}

--- Escape special pattern matching characters in a string
---@param input string
---@return string
function M.escape_dir_pattern(input)
  local magic_chars = { "%", "(", ")", ".", "+", "-", "*", "?", "[", "^", "$" }

  for _, char in ipairs(magic_chars) do
    input = input:gsub("%" .. char, "%%" .. char)
  end

  return input
end

---Check if a target directory exists in a given table
---@param dir string
---@param dirs_table table
---@return boolean
function M.dirs_match(dir, dirs_table)
  dir = vim.fn.expand(dir)

  local match = M.table_match(dir, dirs_table, function(pattern)
    return M.escape_dir_pattern(vim.fn.expand(pattern))
  end)

  return match
end

---Check if a string matches and entry in a given table
---@param needle string
---@param haystack table
---@param callback function
---@return boolean
function M.table_match(needle, haystack, callback)
  if needle == nil then
    return false
  end

  local sep = vim.loop.os_uname().sysname:lower():match("windows") and "\\" or "/"

  return haystack
    and next(vim.tbl_filter(function(pattern)
      if pattern.exact then
        -- The pattern is actually a table
        pattern = pattern[1]
        -- Stripping off the trailing backslash that a user might put here,
        -- but only if we aren't looking at the root directory
        if pattern:sub(-1) == sep and pattern:len() > 1 then
          pattern = pattern:sub(1, -2)
        end
        return needle == pattern
      else
        if callback and type(callback) == "function" then
          pattern = callback(pattern)
        end
        return needle:match(pattern)
      end
    end, haystack))
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

return M
