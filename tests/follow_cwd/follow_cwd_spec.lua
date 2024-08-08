local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"

pcall(vim.fn.system, "rm -rf tests/dummy_data")
require("persisted").setup({
  save_dir = session_dir,
  follow_cwd = true,
})

describe("Follow cwd", function()
  it("creates two sessions", function()
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
    local name1 = vim.fn.getcwd():gsub(pattern, "%%") .. ".vim"

    vim.cmd(":cd ../..")
    local name2 = vim.fn.getcwd():gsub(pattern, "%%") .. ".vim"

    local sessions = vim.fn.readdir(session_dir)
    assert.equals(sessions[1], name1)
    assert.equals(sessions[2], name2)
  end)
end)

pcall(vim.fn.system, "rm -rf tests/dummy_data")
require("persisted").setup({
  save_dir = session_dir,
  follow_cwd = false,
})

describe("Follow a cwd change", function()
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

    local name = vim.fn.getcwd():gsub(pattern, "%%") .. ".vim"

    local sessions = vim.fn.readdir(session_dir)
    assert.equals(#sessions, 1)
    assert.equals(sessions[1], name)
  end)
end)
