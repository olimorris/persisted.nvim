local util = require("plenary.async.util")
local async = require("plenary.async.tests")

local e = vim.fn.fnameescape
local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"
require("persisted").setup({
  save_dir = session_dir,
  autoload = true,
  autosave = true,
  allowed_dirs = { vim.fn.getcwd() },
})

async.describe("Autoloading", function()
  -- after_each(function()
  --   vim.fn.system("rm -rf " .. e(session_dir))
  -- end)

  async.it("autoloads a file with allowed_dirs config option present", function()
    util.scheduler()
    local content = vim.fn.getline(1, "$")
    assert.equals(content[1], "If you're reading this, I guess auto-loading works")
  end)
end)
