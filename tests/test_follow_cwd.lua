local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local setup_child = function(follow_cwd)
  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua(string.format(
    [[
      session_dir = vim.fn.tempname() .. "/tests/dummy_data/"
      vim.fn.delete(session_dir, "rf")
      vim.fn.mkdir(session_dir, "p")
      require("persisted").setup({
        save_dir = session_dir,
        follow_cwd = %s,
      })
    ]],
    follow_cwd and "true" or "false"
  ))
end

local T = new_set({
  hooks = {
    post_once = child.stop,
  },
})

T["follow_cwd true creates two sessions"] = function()
  setup_child(true)

  local result = child.lua_get([[
    (function()
      local root = vim.fn.getcwd()
      vim.cmd("e tests/stubs/test_autoload.txt")
      vim.cmd("w")
      require("persisted").save()
      vim.cmd("cd tests/stubs")
      vim.cmd("w")
      require("persisted").save()
      vim.cmd("bdelete")

      local name_root = root:gsub("/", "%%") .. ".vim"
      local name_stubs = (root .. "/tests/stubs"):gsub("/", "%%") .. ".vim"
      local sessions = vim.fn.readdir(session_dir)
      table.sort(sessions)
      local expected = { name_root, name_stubs }
      table.sort(expected)
      return { sessions = sessions, expected = expected }
    end)()
  ]])

  eq(result.sessions, result.expected)
end

T["follow_cwd false keeps single session"] = function()
  setup_child(false)

  local result = child.lua_get([[
    (function()
      local root = vim.fn.getcwd()
      vim.cmd("e tests/stubs/test_autoload.txt")
      vim.cmd("w")
      require("persisted").save()
      require("persisted").load()
      vim.cmd("cd tests/stubs")
      vim.cmd("w")
      require("persisted").save()
      vim.cmd("bdelete")

      local name_root = root:gsub("/", "%%") .. ".vim"
      local sessions = vim.fn.readdir(session_dir)
      table.sort(sessions)
      return { sessions = sessions, name_root = name_root }
    end)()
  ]])

  eq(#result.sessions, 1)
  eq(result.sessions[1], result.name_root)
end

return T
