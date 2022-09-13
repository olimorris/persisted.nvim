local M = {}

---@class PersistedOptions
local defaults = {
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved
  command = "VimLeavePre", -- the autocommand for which the session is saved
  silent = false, -- silent nvim message when sourcing session file
  use_git_branch = false, -- create session files based on the branch of the git enabled repository
  branch_separator = "_", -- string used to separate session directory name from branch name
  autosave = true, -- automatically save session files when exiting Neovim
  autoload = false, -- automatically load the session for the cwd on Neovim startup
  allowed_dirs = nil, -- table of dirs that the plugin will auto-save and auto-load from
  ignored_dirs = nil, -- table of dirs that are ignored for auto-saving and auto-loading
  before_save = nil, -- function to run before the session is saved to disk
  after_save = nil, -- function to run after the session is saved to disk
  before_source = nil, -- function to run before the session is sourced
  after_source = nil, -- function to run after the session is sourced
  telescope = { -- options for the telescope extension
    before_source = nil, -- function to run before the session is sourced via telescope
    after_source = nil, -- function to run after the session is sourced via telescope
  },
}

---@type PersistedOptions
M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  if M.options.options then
    vim.cmd(
      'echohl WarningMsg | echom "Persisted.nvim: The `option` config variable has now been replaced by vim.o.sessionoptions" | echohl NONE'
    )
    vim.cmd('echohl WarningMsg | echom "Persisted.nvim: Please set vim.o.sessionoptions accordingly" | echohl NONE')
  end
  -- if M.options.dir then
  --   vim.cmd('echohl WarningMsg | echom "Persisted.nvim: The `dir` config option has now been replaced by `save_dir`. This will continue to be supported for the time being" | echohl NONE')
  -- end
  vim.fn.mkdir(M.options.dir or M.options.save_dir, "p")
end

return M
