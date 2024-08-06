---Escapes special characters before performing string substitution
---@param str string
---@param pattern string
---@param replace string
---@param n? integer
---@return string
---@return integer
local function escape_pattern(str, pattern, replace, n)
  pattern = string.gsub(pattern, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
  replace = string.gsub(replace, "[%%]", "%%%%") -- escape replacement

  return string.gsub(str, pattern, replace, n)
end

---List all of the sessions
---@return table
function M.list()
  local save_dir = config.save_dir
  local session_files = vim.fn.glob(save_dir .. "*.vim", true, true)
  local branch_separator = config.branch_separator
  local dir_separator = utils.get_dir_pattern()

  local sessions = {}
  for _, session in pairs(session_files) do
    local session_name = escape_pattern(session, save_dir, "")
      :gsub("%%", dir_separator)
      :gsub(vim.fn.expand("~"), dir_separator)
      :gsub("//", "")
      :sub(1, -5)

    if vim.fn.has("win32") == 1 then
      -- format drive letter (no trailing separator)
      session_name = escape_pattern(session_name, dir_separator, ":", 1)
      -- format remaining filepath separator(s)
      session_name = escape_pattern(session_name, dir_separator, "\\")
    end

    local branch, dir_path

    if string.find(session_name, branch_separator, 1, true) then
      local splits = vim.split(session_name, branch_separator, { plain = true })
      branch = table.remove(splits, #splits)
      dir_path = vim.fn.join(splits, branch_separator)
    else
      dir_path = session_name
    end

    table.insert(sessions, {
      ["name"] = session_name,
      ["file_path"] = session,
      ["branch"] = branch,
      ["dir_path"] = dir_path,
    })
  end

  return sessions
end
