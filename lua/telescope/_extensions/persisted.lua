local actions = require("telescope.actions")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")

local _actions = require("telescope._extensions.actions")
local _finders = require("telescope._extensions.finders")

local function search_sessions(opts)
  local config = require("persisted.config").options

  pickers.new(opts, {
    prompt_title = "Sessions",
    sorter = conf.generic_sorter(opts),
    finder = _finders.session_finder(require("persisted").list()),
    attach_mappings = function(prompt_bufnr, map)

      local refresh_sessions = function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        picker:refresh(_finders.session_finder(require("persisted").list()), { reset_prompt = true })
      end

      _actions.delete_session:enhance({ post = refresh_sessions })

      map("i", "<c-d>", _actions.delete_session)

      actions.select_default:replace(function()
        local session = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        config.telescope.before_source(session)
        pcall(vim.cmd, "source " .. vim.fn.fnameescape(session.file_path))
        config.telescope.after_source(session)
      end)
      return true
    end,
  }):find()
end

return require("telescope").register_extension({
  exports = {
    persisted = search_sessions,
  },
})
