local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality ---@type function

local child = MiniTest.new_child_neovim()

local setup_child = function()
  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua([[
    session_dir = vim.fn.tempname() .. "/tests/before_save_data/"
    vim.fn.delete(session_dir, "rf")
    vim.fn.mkdir(session_dir, "p")

    calls = {}

    require("persisted").setup({
      save_dir = session_dir,
      before_save = function(opts)
        table.insert(calls, opts)
      end,
    })
  ]])
end

local T = new_set({
  hooks = {
    pre_case = setup_child,
    post_once = child.stop,
  },
})

T["is not called when should_save returns false"] = function()
  child.lua([[
    require("persisted").setup({
      save_dir = session_dir,
      should_save = function()
        return false
      end,
      before_save = function()
        table.insert(calls, {})
      end,
    })
    require("persisted").save()
  ]])

  eq(child.lua_get("#calls"), 0)
end

T["receives auto = false for a manual save"] = function()
  child.lua([[require("persisted").save()]])

  eq(child.lua_get("#calls"), 1)
  eq(child.lua_get("calls[1].auto"), false)
end

T["receives auto = true for the save on exit"] = function()
  child.lua([[
    require("persisted").start()
    vim.api.nvim_exec_autocmds("VimLeavePre", { group = "Persisted" })
  ]])

  eq(child.lua_get("#calls"), 1)
  eq(child.lua_get("calls[1].auto"), true)
end

T["can remove buffers from the session"] = function()
  child.lua([[
    vim.o.sessionoptions = "buffers,curdir,folds,tabpages,winpos,winsize"

    require("persisted").setup({
      save_dir = session_dir,
      before_save = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buftype == "terminal" then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end,
    })

    vim.cmd("e tests/stubs/test.txt")
    vim.cmd("terminal")
    require("persisted").save()
  ]])

  local session = table.concat(child.fn.readfile(child.lua_get([[require("persisted").current()]])), "\n")

  eq(session:find("test.txt", 1, true) ~= nil, true)
  eq(session:find("term://", 1, true), nil)
end

return T
