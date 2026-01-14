local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()
local tmp_dir = vim.fn.tempname()
local session_dir = tmp_dir .. "/tests/dummy_data/"

local setup_child = function()
  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua(
    [[
      vim.fn.delete(..., "rf")
      vim.fn.mkdir(..., "p")
      require("persisted").setup({
        save_dir = ...,
        autoload = true,
        autosave = true,
        allowed_dirs = { vim.loop.cwd() },
      })
    ]],
    { session_dir, session_dir }
  )
end

local T = new_set({
  hooks = {
    pre_case = setup_child,
    post_once = child.stop,
  },
})

T["autoloads a file with allowed_dirs config option present"] = function()
  child.lua([[
    vim.cmd("e tests/stubs/test_autoload.txt")
    vim.cmd("w")
    require("persisted").save()
  ]])

  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua(
    [[
      require("persisted").setup({
        save_dir = ...,
        autoload = true,
        autosave = true,
        allowed_dirs = { vim.loop.cwd() },
      })
      require("persisted").autoload({ force = true })
      vim.wait(1000, function()
        local content = vim.fn.getline(1, "$")
        return content[1] == "If you're reading this, I guess auto-loading works"
      end)
    ]],
    { session_dir }
  )

  eq(child.fn.getline(1, "$")[1], "If you're reading this, I guess auto-loading works")
end

return T
