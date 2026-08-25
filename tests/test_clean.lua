local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality ---@type function

local child = MiniTest.new_child_neovim()

local setup_child = function()
  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua([[
    session_dir = vim.fn.tempname() .. "/tests/clean_data/"
    vim.fn.delete(session_dir, "rf")
    vim.fn.mkdir(session_dir, "p")

    require("persisted").setup({
      save_dir = session_dir,
    })

    -- Create a session file for a given directory and, optionally, a branch
    create_session = function(dir, branch)
      local name = require("persisted.utils").make_fs_safe(dir)
      if branch then
        name = name .. "@@" .. require("persisted.utils").make_fs_safe(branch)
      end
      vim.fn.writefile({ "" }, session_dir .. name .. ".vim")
    end

    sessions = function()
      local files = vim.fn.glob(session_dir .. "*.vim", true, true)
      return vim.tbl_map(function(file)
        return vim.fn.fnamemodify(file, ":t")
      end, files)
    end
  ]])
end

local T = new_set({
  hooks = {
    pre_case = setup_child,
    post_once = child.stop,
  },
})

T["deletes sessions whose directory no longer exists"] = function()
  child.lua([[
    create_session(vim.fn.getcwd())
    create_session("/tmp/persisted_does_not_exist")
    deleted = require("persisted").clean({ confirm = false })
  ]])

  eq(child.lua_get("#deleted"), 1)
  eq(child.lua_get("deleted[1].reason"), "directory no longer exists")
  eq(child.lua_get("#sessions()"), 1)
end

T["deletes sessions whose git branch no longer exists"] = function()
  child.lua([[
    create_session(vim.fn.getcwd(), "persisted_does_not_exist")
    deleted = require("persisted").clean({ confirm = false })
  ]])

  eq(child.lua_get("#deleted"), 1)
  eq(child.lua_get("deleted[1].reason"), "branch no longer exists")
  eq(child.lua_get("sessions()"), {})
end

T["keeps sessions whose git branch still exists"] = function()
  child.lua([[
    local branch = require("persisted").branch()
    create_session(vim.fn.getcwd(), branch)
    deleted = require("persisted").clean({ confirm = false })
  ]])

  eq(child.lua_get("#deleted"), 0)
  eq(child.lua_get("#sessions()"), 1)
end

T["ignores git branches when told to"] = function()
  child.lua([[
    create_session(vim.fn.getcwd(), "persisted_does_not_exist")
    deleted = require("persisted").clean({ confirm = false, branches = false })
  ]])

  eq(child.lua_get("#deleted"), 0)
  eq(child.lua_get("#sessions()"), 1)
end

T["ignores files which the plugin didn't create"] = function()
  child.lua([[
    vim.fn.writefile({ "" }, session_dir .. "not_a_session.vim")
    deleted = require("persisted").clean({ confirm = false })
  ]])

  eq(child.lua_get("#deleted"), 0)
  eq(child.lua_get("sessions()"), { "not_a_session.vim" })
end

return T
