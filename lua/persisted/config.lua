local M = {}

local defaults = {
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved
  silent = false, -- silent nvim message when sourcing session file
  use_git_branch = false, -- create session files based on the branch of the git enabled repository
  branch_separator = "@@", -- string used to separate session directory name from branch name
  autosave = true, -- automatically save session files when exiting Neovim
  should_autosave = nil, -- function to determine if a session should be autosaved (resolve to a boolean)

  -- TODO: Remove callbacks after deprecation notice ends
  before_save = nil, -- function to run before the session is saved to disk
  after_save = nil, -- function to run after the session is saved to disk
  before_source = nil, -- function to run before the session is sourced
  after_source = nil, -- function to run after the session is sourced
  --

  autoload = false, -- automatically load the session for the cwd on Neovim startup
  on_autoload_no_session = nil, -- function to run when `autoload = true` but there is no session to load

  follow_cwd = true, -- change session file name with changes in current working directory
  allowed_dirs = nil, -- table of dirs that the plugin will auto-save and auto-load from
  ignored_dirs = nil, -- table of dirs that are ignored for auto-saving and auto-loading

  telescope = { -- options for the telescope extension
    -- TODO: Remove callbacks after deprecation notice ends
    before_source = nil, -- function to run before the session is sourced via telescope
    after_source = nil, -- function to run after the session is sourced via telescope
    --
    reset_prompt_after_deletion = true, -- whether to reset prompt after session deleted
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  vim.fn.mkdir(M.options.save_dir, "p")

  if opts then
    if opts.before_source then
      require("persisted.deprecate").write(
        "----------\n",
        "The use of the ",
        { "before_source", "ErrorMsg" },
        " callback.\nPlease replace with the ",
        { "PersistedLoadPre", "WarningMsg" },
        { " user event. This will be removed from the plugin on " },
        { "2023-03-05", "WarningMsg" }
      )
    end
    if opts.after_source then
      require("persisted.deprecate").write(
        "----------\n",
        "The use of the ",
        { "after_source", "ErrorMsg" },
        " callback.\nPlease replace with the ",
        { "PersistedLoadPost", "WarningMsg" },
        { " user event. This will be removed from the plugin on " },
        { "2023-03-05", "WarningMsg" }
      )
    end
    if opts.before_save then
      require("persisted.deprecate").write(
        "----------\n",
        "The use of the ",
        { "before_save", "ErrorMsg" },
        " callback.\nPlease replace with the ",
        { "PersistedSavePre", "WarningMsg" },
        { " user event. This will be removed from the plugin on " },
        { "2023-03-05", "WarningMsg" }
      )
    end
    if opts.after_save then
      require("persisted.deprecate").write(
        "----------\n",
        "The use of the ",
        { "after_save", "ErrorMsg" },
        " callback.\nPlease replace with the ",
        { "PersistedSavePost", "WarningMsg" },
        { " user event. This will be removed from the plugin on " },
        { "2023-03-05", "WarningMsg" }
      )
    end

    -- Telescope
    if opts.telescope and opts.telescope.before_source then
      require("persisted.deprecate").write(
        "----------\n",
        "The use of the ",
        { "telescope.before_source", "ErrorMsg" },
        " callback.\nPlease replace with the ",
        { "PersistedTelescopeLoadPre", "WarningMsg" },
        { " user event. This will be removed from the plugin on " },
        { "2023-03-05", "WarningMsg" }
      )
    end
    if opts.telescope and opts.telescope.after_source then
      require("persisted.deprecate").write(
        "----------\n",
        "The use of the ",
        { "telescope.after_source", "ErrorMsg" },
        " callback.\nPlease replace with the ",
        { "PersistedTelescopeLoadPost", "WarningMsg" },
        { " user event. This will be removed from the plugin on " },
        { "2023-03-05", "WarningMsg" }
      )
    end
  end
end

return M
