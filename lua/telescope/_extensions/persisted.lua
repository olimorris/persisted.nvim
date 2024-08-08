local actions = require("telescope.actions")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")

local _actions = require("telescope._extensions.persisted.actions")
local _finders = require("telescope._extensions.persisted.finders")

local persisted = require("persisted")
local utils = require("persisted.utils")

local config = persisted.config

local telescope_opts = {}

---Escapes special characters before performing string substitution
---@param str string
---@param pattern string
---@param replace string
---@param n? integer
---@return string
---@return integer
local function escape_pattern(str, pattern, replace, n)
  pattern = string.gsub(pattern, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
  replace = string.gsub(replace, "[%%]", "%%%%") -- escape replacement

  return string.gsub(str, pattern, replace, n)
end

---List all of the available sessions
local function list_sessions()
  local sep = utils.dir_pattern()

  local sessions = {}
  for _, session in pairs(persisted.list()) do
    local session_name = escape_pattern(session, config.save_dir, "")
      :gsub("%%", sep)
      :gsub(vim.fn.expand("~"), sep)
      :gsub("//", "")
      :sub(1, -5)

    if vim.fn.has("win32") == 1 then
      session_name = escape_pattern(session_name, sep, ":", 1)
      session_name = escape_pattern(session_name, sep, "\\")
    end

    local branch, dir_path

    if string.find(session_name, "@@", 1, true) then
      local splits = vim.split(session_name, "@@", { plain = true })
      branch = table.remove(splits, #splits)
      dir_path = vim.fn.join(splits, "@@")
    else
      dir_path = session_name
    end

    table.insert(sessions, {
      ["name"] = session_name,
      ["file_path"] = session,
      ["branch"] = branch,
      ["dir_path"] = dir_path,
    })
  end
  return sessions
end

---Search through the Persisted sessions
---@param opts table
local function search_sessions(opts)
  opts = vim.tbl_extend("force", telescope_opts, opts or {})

  pickers
    .new(opts, {
      prompt_title = "Sessions",
      sorter = conf.generic_sorter(opts),
      finder = _finders.session_finder(list_sessions()),
      attach_mappings = function(prompt_bufnr, map)
        local refresh_sessions = function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          picker:refresh(_finders.session_finder(list_sessions()), {
            reset_prompt = true,
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
    vim.api.nvim_set_hl(0, "PersistedTelescopeSelected", { link = "TelescopeResultsOperator", default = true })
    vim.api.nvim_set_hl(0, "PersistedTelescopeDir", { link = "Directory", default = true })
    vim.api.nvim_set_hl(0, "PersistedTelescopeBranch", { link = "TelescopeResultsIdentifier", default = true })
    telescope_opts = topts
  end,
  exports = {
    persisted = search_sessions,
  },
})
