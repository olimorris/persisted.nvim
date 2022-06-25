local util = require("plenary.async.util")
local async = require("plenary.async.tests")

local e = vim.fn.fnameescape
local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"
require("persisted").setup({
  save_dir = session_dir,
  autoload = true,
  autosave = true,
})

async.describe("Autoloading", function()

  async.it("autoloads a file", function()
    util.scheduler()
    local content = vim.fn.getline(1, '$')
    assert.equals(content[1], "If you're reading this, I guess auto-loading works")
  end)

end)
