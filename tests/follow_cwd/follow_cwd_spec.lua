pcall(vim.fn.system, "rm -rf tests/dummy_data")

local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"

-- follow_cwd = true
require("persisted").setup({
  save_dir = session_dir,
  follow_cwd = true,
})

describe("Follow cwd change", function()
  it("creates two sessions with change in cwd", function()
    vim.cmd(":e tests/stubs/test_autoload.txt")
    vim.cmd(":w")

    require("persisted").save()
    vim.cmd(":cd tests/stubs")
    vim.cmd(":w")
    require("persisted").save()
    vim.cmd(":bdelete")
  end)
  it("ensures both sessions were created", function()
    require("persisted").load()

    local pattern = "/"
    local branch1 = require("persisted").get_branch()
    local name1 = vim.fn.getcwd():gsub(pattern, "%%") .. (branch1 or "") .. ".vim"
    vim.cmd(":cd ../..")
    local branch2 = require("persisted").get_branch()
    local name2 = vim.fn.getcwd():gsub(pattern, "%%") .. (branch2 or "") .. ".vim"

    local sessions = vim.fn.readdir(session_dir)
    assert.equals(sessions[1], name1)
    assert.equals(sessions[2], name2)
  end)
end)

-- follow_cwd = false
pcall(vim.fn.system, "rm -rf tests/dummy_data")
require("persisted").setup({
  save_dir = session_dir,
  follow_cwd = false,
})

describe("Don't follow cwd change", function()
  it("creates two sessions with change in cwd", function()
    vim.cmd(":e tests/stubs/test_autoload.txt")
    vim.cmd(":w")
    require("persisted").save()
    require("persisted").load()
    vim.cmd(":cd tests/stubs")
    vim.cmd(":w")
    require("persisted").save()
    vim.cmd(":bdelete")
  end)
  it("ensures only one session was created", function()
    local pattern = "/"
    vim.cmd(":cd ../..")
    local branch = require("persisted").get_branch()
    local name = vim.fn.getcwd():gsub(pattern, "%%") .. (branch or "") .. ".vim"

    local sessions = vim.fn.readdir(session_dir)
    assert.equals(#sessions, 1)
    assert.equals(name, sessions[1])
  end)
end)
