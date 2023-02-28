if vim.g.loaded_persisted then
  return
end

local persisted = require("persisted")

-- Create the user commands
vim.cmd([[command! SessionStart :lua require("persisted").start()]])
vim.cmd([[command! SessionStop :lua require("persisted").stop()]])
vim.cmd([[command! SessionSave :lua require("persisted").save({ override = true })]])
vim.cmd([[command! SessionLoad :lua require("persisted").load()]])
vim.cmd([[command! SessionLoadLast :lua require("persisted").load({ last = true })]])
vim.cmd([[command! -nargs=1 SessionLoadFromFile :lua require("persisted").load({ session = <f-args> })]])
vim.cmd([[command! SessionDelete :lua require("persisted").delete()]])
vim.cmd([[command! SessionToggle :lua require("persisted").toggle()]])

-- Create the autocmds
local group = vim.api.nvim_create_augroup("Persisted", {})

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = group,
  nested = true,
  callback = persisted.autoload,
})
vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
  group = group,
  nested = true,
  callback = persisted.save,
})

vim.g.loaded_persisted = true
