local M = {}

--- Escapes the given text to be safe for use in file-system paths/names,
--- accounting for cross-platform use.
---@param text string
function M.make_fs_safe(text)
  return text:gsub("[\\/:]+", "%%")
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
