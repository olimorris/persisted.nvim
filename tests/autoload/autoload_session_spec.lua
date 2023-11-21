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

  it("autoloads the a child directory of ignored_dirs exact", function()
    local co = coroutine.running()
    vim.defer_fn(function()
      coroutine.resume(co)
    end, 2000)
    
    local fp_sep = vim.loop.os_uname().sysname:lower():match('windows') and '\\' or '/' -- \ for windows, mac and linux both use \
    
    local session_dir = vim.fn.getcwd() .. "/test/dummy_data/"
    require("persisted").setup({
      save_dir = session_dir,
      autoload = true,
      autosave = true,
      ignored_dirs = {
        -- Setting the parent of our current to an ignored directory
        { 
          string.format("%s%s..%s", vim.fn.getcwd(), fp_sep, fp_sep),
          exact = true
        }
      }
    })
    coroutine.yield()

    local content = vim.fn.getline(1, "$")
    assert.equals("If you're reading this, I guess auto-loading works", content[1])

  end)
end)
