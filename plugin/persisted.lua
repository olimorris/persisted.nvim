if vim.g.loaded_persisted then
  return
end

local persisted = require("persisted")

---Get the names of any sessions which were saved with a name
---@return string[]
local function names()
  local found = {}

  for _, session in ipairs(persisted.list()) do
    local name = persisted.session_info(session).name
    if name then
      found[#found + 1] = name
    end
  end

  return found
end

local subcommands = {
  start = persisted.start,
  stop = persisted.stop,
  save = function(name)
    persisted.save({ force = true, name = name })
  end,
  load = function(name)
    persisted.load({ name = name })
  end,
  load_last = function()
    persisted.load({ last = true })
  end,
  toggle = persisted.toggle,
  select = persisted.select,
  delete = function(name)
    if name then
      return persisted.delete_current({ name = name })
    end
    persisted.delete()
  end,
  delete_current = function()
    persisted.delete_current()
  end,
  clean = function()
    persisted.clean()
  end,
}

---Subcommands which accept the name of a session
local has_name_param = { delete = true, load = true, save = true }

vim.api.nvim_create_user_command("Persisted", function(opts)
  local subcommand = opts.fargs[1]
  local handler = subcommands[subcommand]
  if not handler then
    vim.notify("Unknown Persisted subcommand: `" .. subcommand .. "`", vim.log.levels.ERROR)
    return
  end

  local name = table.concat(opts.fargs, " ", 2)
  handler(name ~= "" and name or nil)
end, {
  nargs = "+",
  complete = function(arg_lead, line)
    local args = vim.split(vim.trim(line), "%s+")

    -- Complete the name of a session once a subcommand has been given
    local candidates = vim.tbl_keys(subcommands)
    if #args > 2 or (#args == 2 and line:match("%s$")) then
      candidates = has_name_param[args[2]] and names() or {}
    end

    local matches = vim.tbl_filter(function(candidate)
      return vim.startswith(candidate, arg_lead)
    end, candidates)

    table.sort(matches)
    return matches
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = persisted.autoload,
})

vim.g.loaded_persisted = true
