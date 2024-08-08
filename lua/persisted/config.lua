return {
  ---@type string
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- Directory where session files are saved

  ---@type boolean
  use_git_branch = false, -- Include the git branch in the session file name?

  ---@type boolean
  autosave = true, -- Automatically save session files when exiting Neovim?
  ---@type fun(boolean)
  should_autosave = nil, -- Function to determine if a session should be autosaved
  ---@type boolean
  autoload = false, -- Automatically load the session for the cwd on Neovim startup?
  ---@type fun(boolean)
  on_autoload_no_session = nil, -- Function to run when `autoload = true` but there is no session to load

  ---@type boolean
  follow_cwd = true, -- Change session file name with changes in the cwd?
  ---@type table
  allowed_dirs = nil, -- Table of dirs that the plugin will autosave and autoload from
  ---@type table
  ignored_dirs = nil, -- Table of dirs that are ignored for autosaving and autoloading

  telescope = {
    mappings = { -- Mappings for managing sessions in Telescope
      change_branch = "<C-b>",
      copy_session = "<C-c>",
      delete_session = "<C-d>",
    },
    icons = { -- icons displayed in the Telescope picker
      selected = " ",
      dir = "  ",
      branch = " ",
    },
  },
}
