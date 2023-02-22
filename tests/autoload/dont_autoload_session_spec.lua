local session_dir = vim.fn.getcwd() .. "/tests/dummy_data/"
require("persisted").setup({
  save_dir = session_dir,
  autoload = true,
  ignored_dirs = { vim.fn.getcwd() },
})

describe("Autoloading", function()
  it("is stopped if an ignored dir is present", function()
    local co = coroutine.running()

    vim.defer_fn(function()
      coroutine.resume(co)
    end, 1000)

    coroutine.yield()
    local content = vim.fn.getline(1, "$")
    assert.equals(content[1], "")
  end)
end)
