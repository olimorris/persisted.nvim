local util = require("plenary.async.util")

local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"
require("persisted").setup({
  save_dir = session_dir,
  autoload = true,
  autosave = true,
})

describe("Autoloading", function()
  it("autoloads a file", function()
    util.scheduler()
    local content = vim.fn.getline(1, "$")
    assert.equals(content[1], "If you're reading this, I guess auto-loading works")
  end)
end)
