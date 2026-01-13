if vim.g.loaded_persisted then
  return
end

local persisted = require("persisted")

local subcommands = {
  start = persisted.start,
  stop = persisted.stop,
  save = function()
    persisted.save({ force = true })
  end,
  load = persisted.load,
  load_last = function()
    persisted.load({ last = true })
  end,
  toggle = persisted.toggle,
  select = persisted.select,
  delete = persisted.delete,
  delete_current = persisted.delete_current,
}

vim.api.nvim_create_user_command("Persisted", function(opts)
  local subcommand = opts.fargs[1]
  local handler = subcommands[subcommand]
  if not handler then
    vim.notify("Unknown Persisted subcommand: `" .. subcommand .. "`", vim.log.levels.ERROR)
    return
  end
  handler()
end, {
  nargs = 1,
  complete = function(_, line)
    local matches = {}
    for name in pairs(subcommands) do
      if line:match("Persisted%s+%w*$") or name:find(vim.fn.expand("<cword>"), 1, true) then
        table.insert(matches, name)
      end
    end
    table.sort(matches)
    return matches
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = persisted.autoload,
})

vim.g.loaded_persisted = true
