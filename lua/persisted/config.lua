local M = {}

local defaults = {
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved
  silent = false, -- silent nvim message when sourcing session file
  use_git_branch = false, -- create session files based on the branch of the git enabled repository
  branch_separator = "@@", -- string used to separate session directory name from branch name
  autosave = true, -- automatically save session files when exiting Neovim
  autosave_when_session_exists = false, -- automatically save session files only when session exists
  should_autosave = nil, -- function to determine if a session should be autosaved (resolve to a boolean)

  autoload = false, -- automatically load the session for the cwd on Neovim startup
  on_autoload_no_session = nil, -- function to run when `autoload = true` but there is no session to load

  follow_cwd = true, -- change session file name with changes in current working directory
  allowed_dirs = nil, -- table of dirs that the plugin will auto-save and auto-load from
  ignored_dirs = nil, -- table of dirs that are ignored for auto-saving and auto-loading

  telescope = { -- options for the telescope extension
    reset_prompt_after_deletion = true, -- whether to reset prompt after session deleted
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  vim.fn.mkdir(M.options.save_dir, "p")
end

return M
