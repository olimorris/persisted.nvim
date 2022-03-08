local e = vim.fn.fnameescape
local session_dir = vim.fn.getcwd() .. "/tests/data/"
require("persisted").setup({
  dir = session_dir
})

describe("With default settings", function()
  after_each(function()
    -- vim.fn.system("rm -rf " .. e(session_dir))
  end)

  it("saves a session", function()
    -- Edit a buffer
    vim.cmd(":e tests/stubs/test.txt")
    vim.cmd(":w")

    -- Save the session
    require("persisted").save()

    -- Check that it is written to disk
    assert.equals(vim.g.persisting, true)
    assert.equals(vim.fn.system("ls tests/data | wc -l"), "1\n")
  end)

  it("loads a session", function()
    -- Load a session
    require("persisted").load()

    -- Read the buffers contents
    local content = vim.fn.getline(1, '$')

    assert.equals(content[1], "This is a test file")
  end)

end)
