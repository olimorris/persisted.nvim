pcall(vim.fn.system, "rm -rf tests/dummy_data")

local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"
require("persisted").setup({
  save_dir = session_dir,
  autoload = true,
  autosave = true,
})

describe("As part of the setup", function()
  it("creates a session to autoload from", function()
    vim.cmd(":e tests/stubs/test_autoload.txt")
    vim.cmd(":w")

    require("persisted").save()
  end)
end)
