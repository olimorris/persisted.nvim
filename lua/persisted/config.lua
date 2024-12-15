local defaults = {
  autostart = true, -- Automatically start the plugin on load?

  -- Function to determine if a session should be saved
  ---@type fun(): boolean
  should_save = function()
    return true
  end,

  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- Directory where session files are saved

  follow_cwd = true, -- Change the session file to match any change in the cwd?
  use_git_branch = false, -- Include the git branch in the session file name?
  autoload = false, -- Automatically load the session for the cwd on Neovim startup?

  -- Function to run when `autoload = true` but there is no session to load
  ---@type fun(): any
  on_autoload_no_session = function() end,

  allowed_dirs = {}, -- Table of dirs that the plugin will start and autoload from
  ignored_dirs = {}, -- Table of dirs that are ignored for starting and autoloading

  telescope = {
    mappings = { -- Mappings for managing sessions in Telescope
      copy_session = "<C-c>",
      change_branch = "<C-b>",
      delete_session = "<C-d>",
    },
    icons = { -- icons displayed in the Telescope picker
      selected = " ",
      dir = "  ",
      branch = " ",
    },
  },
}

local M = {
  config = vim.deepcopy(defaults),
}

---@param opts? table
M.setup = function(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts)
end

return setmetatable(M, {
  __index = function(_, key)
    if key == "setup" then
      return M.setup
    end
    return rawget(M.config, key)
  end,
})
