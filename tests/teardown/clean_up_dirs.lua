describe("As part of the teardown", function()
  it("dummy data is deleted", function()
    pcall(vim.fn.system, "rm -rf tests/dummy_data")
    pcall(vim.fn.system, "rm -rf tests/git_branch_data")
    pcall(vim.fn.system, "rm -rf tests/default_data")
  end)
end)