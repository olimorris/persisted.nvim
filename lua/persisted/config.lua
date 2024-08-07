return {
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved

  use_git_branch = false, -- create session files based on the branch of a git enabled repository

  autosave = true, -- automatically save session files when exiting Neovim
  should_autosave = nil, -- function to determine if a session should be autosaved (resolve to a boolean)
  autoload = false, -- automatically load the session for the cwd on Neovim startup
  on_autoload_no_session = nil, -- function to run when `autoload = true` but there is no session to load

  change_with_cwd = true, -- change the name of the session file if the cwd changes?
  allowed_dirs = nil, -- table of dirs that the plugin will autosave and autoload from
  ignored_dirs = nil, -- table of dirs that are ignored for autosaving and autoloading

  telescope = {
    mappings = {
      change_branch = "<C-b>",
      copy_session = "<C-c>",
      delete_session = "<C-d>",
    },
    icons = { -- icons displayed in the picker
      branch = " ",
      dir = "  ",
      selected = " ",
    },
  },
}
