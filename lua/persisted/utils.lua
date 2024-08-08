local M = {}

---Get the directory pattern based on OS
---@return string
function M.dir_pattern()
  local pattern = "/"
  if vim.fn.has("win32") == 1 then
    pattern = "[\\:]"
  end
  return pattern
end

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

  local match = M.in_table(dir, dirs_table, function(pattern)
    return M.escape_dir_pattern(vim.fn.expand(pattern))
  end)

  return match
end

---Check if a string matches and entry in a given table
---@param val string
---@param tbl table
---@param callback function
---@return boolean
function M.in_table(val, tbl, callback)
  if val == nil then
    return false
  end

  return tbl
    and next(vim.tbl_filter(function(pattern)
      if pattern.exact then
        pattern = pattern[1]
        -- Stripping off the trailing backslash that a user might put here,
        -- but only if we aren't looking at the root directory
        if pattern:sub(-1) == M.dir_pattern() and pattern:len() > 1 then
          pattern = pattern:sub(1, -2)
        end
        return val == pattern
      else
        if callback and type(callback) == "function" then
          pattern = callback(pattern)
        end
        return val:match(pattern)
      end
    end, tbl))
end

return M
