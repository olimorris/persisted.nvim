pcall(vim.fn.system, "rm -rf tests/dummy_data")

local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"
require("persisted").setup({
  save_dir = session_dir,
  autoload = true,
  autosave = true,
})

describe("As part of the setup", function()
  it("a session is created to autoload from", function()

    vim.cmd(":e tests/stubs/test_autoload.txt")
    vim.cmd(":w")

    require("persisted").save()
  end)
  -- it("autoloads a file", function()
  --   local content = vim.fn.getline(1, '$')
  --   assert.equals(content[1], "This is a test file for custom config")
  -- end)
end)
