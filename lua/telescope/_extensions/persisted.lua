local actions = require("telescope.actions")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")

local _actions = require("telescope._extensions.persisted.actions")
local _finders = require("telescope._extensions.persisted.finders")

local telescope_opts = {}

local function search_sessions(opts)
  local config = require("persisted.config").options
  opts = vim.tbl_extend("force", telescope_opts, opts or {})

  pickers
    .new(opts, {
      prompt_title = "Sessions",
      sorter = conf.generic_sorter(opts),
      finder = _finders.session_finder(require("persisted").list()),
      attach_mappings = function(prompt_bufnr, map)
        local refresh_sessions = function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          picker:refresh(_finders.session_finder(require("persisted").list()), {
            -- INFO: Account for users who are still using the old API
            reset_prompt = config.telescope.reset_prompt or config.telescope.reset_prompt_after_deletion,
          })
        end

        _actions.change_branch:enhance({ post = refresh_sessions })
        _actions.copy_session:enhance({ post = refresh_sessions })
        _actions.delete_session:enhance({ post = refresh_sessions })

        local change_session_branch = function()
          return _actions.change_branch(config)
        end
        local copy_session = function()
          return _actions.copy_session(config)
        end
        map("i", config.telescope.mappings.change_branch, change_session_branch)
        map("i", config.telescope.mappings.copy_session, copy_session)
        map("i", config.telescope.mappings.delete_session, _actions.delete_session)

        actions.select_default:replace(function()
          local session = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          _actions.load_session(session, config)
        end)
        return true
      end,
    })
    :find()
end

return require("telescope").register_extension({
  setup = function(topts)
    vim.api.nvim_set_hl(0, "TelescopePersistedIsCurrent", { link = "TelescopeResultsOperator" })
    vim.api.nvim_set_hl(0, "TelescopePersistedDir", { link = "TelescopeResultsNormal" })
    vim.api.nvim_set_hl(0, "TelescopePersistedDirIcon", { link = "Directory" })
    vim.api.nvim_set_hl(0, "TelescopePersistedBranch", { link = "TelescopeResultsIdentifier" })
    telescope_opts = topts
  end,
  exports = {
    persisted = search_sessions,
  },
})
