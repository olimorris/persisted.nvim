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

T["autoloads a file"] = function()
  child.lua(
    [[
      require("persisted").setup({
        save_dir = ...,
        autoload = true,
        autosave = true,
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
        autosave = true,
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

T["autoloads a child directory of ignored_dirs exact"] = function()
  child.lua(
    [[
      require("persisted").setup({
        save_dir = ...,
        autoload = true,
        autosave = true,
      })
    ]],
    { session_dir }
  )

  create_session()

  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua(
    [[
      local fp_sep = vim.loop.os_uname().sysname:lower():match("windows") and "\\" or "/"
      require("persisted").setup({
        save_dir = ...,
        autoload = true,
        autosave = true,
        ignored_dirs = {
          {
            string.format("%s%s..%s", vim.fn.getcwd(), fp_sep, fp_sep),
            exact = true,
          },
        },
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
