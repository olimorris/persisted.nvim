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
  local magic_chars = { "%", "(", ")", "+", "-", "*", "?", "[", "^", "$" }

  for _, char in ipairs(magic_chars) do
    input = input:gsub("%" .. char, "%%" .. char)
  end

  return input
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
  dir = M.escape_dir_pattern(vim.fn.expand(dir))

  for _, search in ipairs(dirs) do
    if type(search) == "string" then
      search = M.escape_dir_pattern(vim.fn.expand(search))
      if M.is_subdirectory(search, dir) then
        return true
      end
    elseif type(search) == "table" then
      if search.exact then
        search = M.escape_dir_pattern(vim.fn.expand(search[1]))
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
