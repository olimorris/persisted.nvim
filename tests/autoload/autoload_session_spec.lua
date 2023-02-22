describe("Autoloading", function()
  it("autoloads a file", function()
    local co = coroutine.running()
    vim.defer_fn(function()
      coroutine.resume(co)
    end, 2000)

    local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"
    require("persisted").setup({
      save_dir = session_dir,
      autoload = true,
      autosave = true,
    })

    coroutine.yield()

    local content = vim.fn.getline(1, "$")
    assert.equals("If you're reading this, I guess auto-loading works", content[1])
  end)
end)
