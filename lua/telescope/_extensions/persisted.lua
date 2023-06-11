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
            reset_prompt = config.telescope.reset_prompt_after_deletion,
          })
        end

        _actions.delete_session:enhance({ post = refresh_sessions })

        map("i", "<c-d>", _actions.delete_session)

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
    telescope_opts = topts
  end,
  exports = {
    persisted = search_sessions,
  },
})
