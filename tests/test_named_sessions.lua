local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality ---@type function

local child = MiniTest.new_child_neovim()

local setup_child = function()
  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua([[
    session_dir = vim.fn.tempname() .. "/tests/named_data/"
    vim.fn.delete(session_dir, "rf")
    vim.fn.mkdir(session_dir, "p")

    require("persisted").setup({
      save_dir = session_dir,
    })

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

T["saves a session under the given name"] = function()
  child.lua([[
    vim.cmd("e tests/stubs/test.txt")
    vim.cmd("Persisted save before-refactor")
  ]])

  eq(child.lua_get("sessions()"), { "before-refactor.vim" })
end

T["loads a session by name"] = function()
  child.lua([[
    vim.cmd("e tests/stubs/test.txt")
    vim.cmd("Persisted save before-refactor")
    vim.cmd("%bwipeout!")

    vim.cmd("Persisted load before-refactor")
    vim.wait(1000, function()
      return vim.fn.getline(1) == "This is a test file"
    end)
  ]])

  eq(child.fn.getline(1), "This is a test file")
end

T["does not overwrite the session for the current directory"] = function()
  child.lua([[
    vim.cmd("e tests/stubs/test.txt")
    require("persisted").save()
    require("persisted").save({ name = "before-refactor" })
  ]])

  eq(child.lua_get("#sessions()"), 2)
  eq(child.lua_get([[vim.fn.filereadable(require("persisted").current()) ]]), 1)
end

T["deletes a session by name"] = function()
  child.lua([[
    vim.cmd("e tests/stubs/test.txt")
    require("persisted").save()
    vim.cmd("Persisted save before-refactor")
    vim.cmd("Persisted delete before-refactor")
    vim.wait(1000, function()
      return #sessions() == 1
    end)
  ]])

  eq(child.lua_get([[vim.fn.fnamemodify(require("persisted").current(), ":t")]]), child.lua_get("sessions()")[1])
end

T["keeps persisting when another session is deleted"] = function()
  child.lua([[
    vim.cmd("e tests/stubs/test.txt")
    require("persisted").start()
    vim.cmd("Persisted save before-refactor")
    vim.cmd("Persisted delete before-refactor")
    vim.wait(1000, function()
      return #sessions() == 0
    end)
  ]])

  eq(child.lua_get("vim.g.persisting"), true)
end

T["stops persisting when the current session is deleted"] = function()
  child.lua([[
    vim.cmd("e tests/stubs/test.txt")
    require("persisted").start()
    require("persisted").save()
    vim.cmd("Persisted delete_current")
    vim.wait(1000, function()
      return #sessions() == 0
    end)
  ]])

  eq(child.lua_get("vim.g.persisting"), false)
end

T["does not clean named sessions"] = function()
  child.lua([[
    vim.cmd("e tests/stubs/test.txt")
    require("persisted").save({ name = "before-refactor" })
    deleted = require("persisted").clean({ confirm = false })
  ]])

  eq(child.lua_get("#deleted"), 0)
  eq(child.lua_get("sessions()"), { "before-refactor.vim" })
end

return T
