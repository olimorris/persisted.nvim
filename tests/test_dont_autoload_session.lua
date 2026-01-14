local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()
local tmp_dir = vim.fn.tempname()
local session_dir = tmp_dir .. "/tests/dummy_data/"

local reset_session_dir = function()
  child.lua(
    [[
      vim.fn.delete(..., "rf")
      vim.fn.mkdir(..., "p")
    ]],
    { session_dir, session_dir }
  )
end

local create_session = function()
  child.lua([[
    vim.cmd("e tests/stubs/test_autoload.txt")
    vim.cmd("w")
    require("persisted").save()
  ]])
end

local T = new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "scripts/minimal_init.lua" })
      reset_session_dir()
    end,
    post_once = child.stop,
  },
})

T["is stopped if an ignored dir is present"] = function()
  child.lua(
    [[
      require("persisted").setup({
        save_dir = ...,
        autoload = true,
      })
    ]],
    { session_dir }
  )
  create_session()

  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua(
    [[
      require("persisted").setup({
        save_dir = ...,
        autoload = true,
        ignored_dirs = { vim.fn.getcwd() },
      })
      require("persisted").autoload({ force = true })
      vim.wait(1000, function()
        local content = vim.fn.getline(1, "$")
        return content[1] ~= ""
      end)
    ]],
    { session_dir }
  )

  eq(child.fn.getline(1, "$")[1], "")
end

return T
