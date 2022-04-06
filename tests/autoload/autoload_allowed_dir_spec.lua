local e = vim.fn.fnameescape
local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"
require("persisted").setup({
  dir = session_dir,
  autoload = true,
  autosave = true,
  allowed_dirs = { vim.fn.getcwd() },
})

describe("With custom settings:", function()

  -- after_each(function()
  --   vim.fn.system("rm -rf " .. e(session_dir))
  -- end)

  it("autoloads a file with allowed_dirs", function()
    local content = vim.fn.getline(1, '$')
    assert.equals(content[1], "If you're reading this, I guess auto-loading works")
  end)

end)
