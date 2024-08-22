if vim.g.loaded_persisted then
  return
end

vim.cmd([[command! SessionStart :lua require("persisted").start()]])
vim.cmd([[command! SessionStop :lua require("persisted").stop()]])
vim.cmd([[command! SessionSave :lua require("persisted").save({ force = true })]])
vim.cmd([[command! SessionLoad :lua require("persisted").load()]])
vim.cmd([[command! SessionLoadLast :lua require("persisted").load({ last = true })]])
vim.cmd([[command! SessionDelete :lua require("persisted").delete()]])
vim.cmd([[command! SessionToggle :lua require("persisted").toggle()]])
vim.cmd([[command! SessionSelect :lua require("persisted").select()]])

local persisted = require("persisted")

vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = persisted.autoload,
})

vim.g.loaded_persisted = true
