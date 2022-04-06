local e = vim.fn.fnameescape
local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"
require("persisted").setup({
  dir = session_dir,
  autoload = true,
  autosave = true,
})

describe("With custom settings:", function()

  it("autoloads a file", function()
    local content = vim.fn.getline(1, '$')
    assert.equals(content[1], "If you're reading this, I guess auto-loading works")
  end)

end)
