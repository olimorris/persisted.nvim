pcall(vim.fn.system, "rm -rf tests/git_branch_data")

local session_dir = vim.fn.getcwd() .. "/tests/git_branch_data/"
require("persisted").setup({
  save_dir = session_dir,
  use_git_branch = true,
})

describe("Git Branching", function()
  it("creates a session", function()
    vim.fn.system("mkdir tests/git_branch_data")
    vim.fn.system("cd tests/git_branch_data && git init")

    assert.equals(vim.fn.system("ls tests/git_branch_data | wc -l"):gsub("%s+", ""), "0")

    vim.cmd(":e tests/stubs/test_git_branching.txt")
    vim.cmd(":w tests/git_branch_data/test_git_branching.txt")

    require("persisted").save()
    assert.equals(vim.fn.system("ls tests/git_branch_data | wc -l"):gsub("%s+", ""), "2")
  end)

  it("ensures the session has the branch name in", function()
    if vim.fn.isdirectory(session_dir .. "/.git") == 0 then
      vim.fn.system("mkdir -p " .. session_dir)
      vim.fn.system("cd " .. session_dir .. " && git init")
    end

    local branch_name = require("persisted").branch()

    -- Check if branch_name is valid
    if not branch_name then
      print("Failed to get branch name.")
      branch_name = ""
    else
      branch_name = "@@" .. branch_name
    end

    -- Workout what the name should be
    local pattern = "/"
    local name = vim.fn.getcwd():gsub(pattern, "%%") .. branch_name .. ".vim"
    local session = vim.fn.glob(session_dir .. "*.vim", true, true)[1]

    session:gsub(session_dir .. "/", "")
    assert.equals(session, vim.fn.getcwd() .. "/tests/git_branch_data/" .. name)
    -- assert.equals(sessions[1]:gsub(pattern, "%%"), name)
  end)
end)
