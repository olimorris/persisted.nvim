local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local setup_child = function()
  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua([[
    session_dir = vim.fn.tempname() .. "/tests/default_data/"
    vim.fn.delete(session_dir, "rf")
    vim.fn.mkdir(session_dir, "p")
    require("persisted").setup({ save_dir = session_dir })
    vim.ui.select = function(items, _, on_choice)
      on_choice(items[1])
    end
  ]])
end

local create_session = function()
  child.lua([[
    vim.cmd("e tests/stubs/test.txt")
    vim.cmd("w")
    require("persisted").save()
  ]])
end

local T = new_set({
  hooks = {
    pre_case = setup_child,
    post_once = child.stop,
  },
})

T["saves a session"] = function()
  eq(child.fn.system(string.format("ls %s | wc -l", child.lua_get([[session_dir]]))):gsub("%s+", ""), "0")

  create_session()

  eq(child.lua_get("vim.g.persisting"), true)
  eq(child.fn.system(string.format("ls %s | wc -l", child.lua_get([[session_dir]]))):gsub("%s+", ""), "1")
end

T["loads a session"] = function()
  create_session()

  child.lua([[require("persisted").load()]])
  local content = child.fn.getline(1, "$")

  eq(content[1], "This is a test file")
  eq(child.lua_get("vim.g.persisting"), true)
end

T["stops a session"] = function()
  child.lua([[require("persisted").start()]])
  child.lua([[require("persisted").stop()]])

  eq(child.lua_get("vim.g.persisting"), false)
end

T["starts a session"] = function()
  child.lua([[require("persisted").start()]])

  eq(child.lua_get("vim.g.persisting"), true)
end

T["lists sessions"] = function()
  create_session()

  local exists = child.lua([[
    local sessions = require("persisted").list()
    return vim.loop.fs_stat(sessions[1]) ~= nil
  ]])

  eq(exists, true)
end

T["deletes a session"] = function()
  create_session()

  child.lua([[
    require("persisted").delete()
    vim.wait(1000, function()
      return vim.fn.empty(vim.fn.glob("tests/default_data/*")) == 1
    end)
  ]])

  eq(child.fn.glob("tests/default_data/*"), "")
end

return T
