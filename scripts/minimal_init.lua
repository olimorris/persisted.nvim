vim.cmd([[let &rtp.=','.getcwd()]])
vim.cmd("set rtp+=deps/mini.nvim")

require("mini.test").setup()

-- Ensure consistent rendering
vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd("colorscheme default")
