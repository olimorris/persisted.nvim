local session_dir = vim.fn.getcwd() .. "/tests/default_data/"
require("persisted").setup({
  save_dir = session_dir,
})

describe("With default settings:", function()
  after_each(function()
    -- vim.fn.system("rm -rf " .. e(session_dir))
  end)

  it("it saves a session", function()
    -- Check no file exists
    assert.equals(vim.fn.system("ls tests/default_data | wc -l"):gsub("%s+", ""), "0")

    -- Edit a buffer
    vim.cmd(":e tests/stubs/test.txt")
    vim.cmd(":w")

    -- Save the session
    require("persisted").save()

    -- Check that the session is written to disk
    assert.equals(vim.g.persisting, true)
    assert.equals("1", vim.fn.system("ls tests/default_data | wc -l"):gsub("%s+", ""))
  end)

  it("it loads a session", function()
    -- Load a session
    require("persisted").load()

    -- Read the buffers contents
    local content = vim.fn.getline(1, "$")

    assert.equals("This is a test file", content[1])
    assert.equals(vim.g.persisting, true)
  end)

  it("it stops a session", function()
    require("persisted").stop()

    assert.equals(vim.g.persisting, false)
  end)

  it("it starts a session", function()
    require("persisted").start()

    assert.equals(vim.g.persisting, true)
  end)

  it("it lists sessions", function()
    local sessions = require("persisted").list()
    local path = require("plenary.path"):new(sessions[1].file_path)

    assert.equals(path:is_path(), true)
  end)
end)

local async = require("plenary.async.tests")
local util = require("plenary.async.util")

async.describe("With default settings:", function()
  async.it("it deletes a session", function()
    require("persisted").delete()
    util.scheduler()

    assert.equals("0", vim.fn.system("ls tests/default_data | wc -l"):gsub("%s+", ""))
  end)
end)
