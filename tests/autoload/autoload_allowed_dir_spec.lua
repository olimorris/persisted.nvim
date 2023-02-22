local session_dir = vim.loop.cwd() .. "/tests/dummy_data/"
require("persisted").setup({
  save_dir = session_dir,
  autoload = true,
  autosave = true,
  allowed_dirs = { vim.loop.cwd() },
})

describe("Autoloading", function()
  it("autoloads a file with allowed_dirs config option present", function()
    local co = coroutine.running()

    vim.defer_fn(function()
      coroutine.resume(co)

      local content = vim.fn.getline(1, "$")
      assert.equals("If you're reading this, I guess auto-loading works", content[1])
    end, 1000)

    coroutine.yield()
  end)
end)
