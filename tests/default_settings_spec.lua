local session_dir = vim.fn.getcwd() .. "/tests/default_data/"
require("persisted").setup({
  save_dir = session_dir
})

describe("With default settings:", function()
  after_each(function()
    -- vim.fn.system("rm -rf " .. e(session_dir))
  end)

  it("saves a session", function()
    -- Check no file exists
    assert.equals(vim.fn.system("ls tests/default_data | wc -l"), "0\n")

    -- Edit a buffer
    vim.cmd(":e tests/stubs/test.txt")
    vim.cmd(":w")

    -- Save the session
    require("persisted").save()

    -- Check that the session is written to disk
    assert.equals(vim.g.persisting, true)
    assert.equals(vim.fn.system("ls tests/default_data | wc -l"), "1\n")
  end)

  it("loads a session", function()
    -- Load a session
    require("persisted").load()

    -- Read the buffers contents
    local content = vim.fn.getline(1, '$')

    assert.equals(content[1], "This is a test file")
    assert.equals(vim.g.persisting, true)
  end)

  it("stops a session", function()
    require("persisted").stop()

    assert.equals(vim.g.persisting, false)
  end)

  it("starts a session", function()
    require("persisted").start()

    assert.equals(vim.g.persisting, true)
  end)

  it("lists sessions", function()
    local sessions = require("persisted").list()
    local path = require("plenary.path"):new(sessions[1])

    assert.equals(path:is_path(), true)
  end)

  it("deletes a session", function()
    require("persisted").delete()

    assert.equals(vim.fn.system("ls tests/default_data | wc -l"), "0\n")
  end)

end)
