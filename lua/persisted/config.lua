local M = {}

---@class PersistedOptions
local defaults = {
  dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved
  use_git_branch = false, -- create session files based on the branch of the git enabled repository
  autosave = true, -- automatically save session files
  options = { "buffers", "curdir", "tabpages", "winsize" }, -- session options used for saving
  before_save = function() end, -- function to run before the session is saved to disk
  after_save = function() end, -- function to run after the session is saved to disk
}

---@type PersistedOptions
M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  vim.fn.mkdir(M.options.dir, "p")
end

return M
