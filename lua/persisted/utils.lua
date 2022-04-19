local M = {}

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

return M
