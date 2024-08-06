return {
  log_level = "ERROR", -- One of "TRACE", "DEBUG", "ERROR"
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved

  use_git_branch = false, -- create session files based on the branch of a git enabled repository

  autosave = true, -- automatically save session files when exiting Neovim
  autoload = false, -- automatically load the session for the cwd on Neovim startup
  should_autosave = nil, -- function to determine if a session should be autosaved (resolve to a boolean)

  allowed_dirs = nil, -- table of dirs that the plugin will auto-save and auto-load from
  ignored_dirs = nil, -- table of dirs that are ignored for auto-saving and auto-loading

  telescope = {
    reset_prompt = true, -- Reset prompt after a telescope action?
    mappings = {
      change_branch = "<c-b>",
      copy_session = "<c-c>",
      delete_session = "<c-d>",
    },
    icons = { -- icons displayed in the picker
      branch = " ",
      dir = " ",
      selected = " ",
    },
  },
}
