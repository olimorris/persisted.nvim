local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local setup_child = function()
  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua([[
    local tmp = vim.fn.tempname()
    session_dir = tmp.. "/tests/dummy_data/"
    vim.fn.delete(session_dir, "rf")
    vim.fn.mkdir(session_dir, "p")

    require("persisted").setup({
      save_dir = session_dir,
      autoload = true,
      autosave = true,
    })
  ]])
end

local T = new_set({
  hooks = {
    pre_case = setup_child,
    post_once = child.stop,
  },
})

T["creates a session to autoload from"] = function()
  child.lua([[
    vim.cmd("e tests/stubs/test_autoload.txt")
    vim.cmd("w")
    require("persisted").save()
  ]])

  eq(child.fn.system(string.format("ls %s | wc -l", child.lua_get([[session_dir]]))):gsub("%s+", ""), "1")
end

return T
