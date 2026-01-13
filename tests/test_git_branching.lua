local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local setup_child = function()
  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua([[
    session_dir = vim.fn.tempname() .. "/tests/git_branch_data/"
    vim.fn.delete(session_dir, "rf")
    vim.fn.mkdir(session_dir, "p")
    require("persisted").setup({
      save_dir = session_dir,
      use_git_branch = true,
    })
  ]])
end

local create_session = function()
  child.lua([[
    vim.fn.system(string.format("cd %s && git init", session_dir))
    vim.cmd("e tests/stubs/test_git_branching.txt")
    vim.cmd(string.format("w %s/test_git_branching.txt", session_dir))
    require("persisted").save()
  ]])
end

local T = new_set({
  hooks = {
    pre_case = setup_child,
    post_once = child.stop,
  },
})

T["creates a session"] = function()
  create_session()

  eq(child.fn.system(string.format("ls %s | wc -l", child.lua_get([[session_dir]]))):gsub("%s+", ""), "2")
end

T["ensures the session has the branch name in"] = function()
  create_session()

  child.lua([[
    local branch_name = require("persisted").branch()
    if not branch_name then
      branch_name = ""
    else
      branch_name = "@@" .. require("persisted.utils").make_fs_safe(branch_name)
    end
    local name = vim.fn.getcwd():gsub("/", "%%") .. branch_name .. ".vim"
    local session = vim.fn.glob(session_dir .. "*.vim", true, true)[1]
    _G.__persisted_branch_result = {
      session = session,
      expected = session_dir .. name,
    }
  ]])

  local result = child.lua_get("_G.__persisted_branch_result")
  eq(result.session, result.expected)
end

return T
