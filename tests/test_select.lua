local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality ---@type function

local child = MiniTest.new_child_neovim()

local setup_child = function()
  child.restart({ "-u", "scripts/minimal_init.lua" })
  child.lua([[
    session_dir = vim.fn.tempname() .. "/tests/select_data/"
    vim.fn.delete(session_dir, "rf")
    vim.fn.mkdir(session_dir, "p")

    require("persisted").setup({
      save_dir = session_dir,
    })

    -- Create a session file for a given directory and, optionally, a branch
    create_session = function(dir, branch)
      local utils = require("persisted.utils")
      local name = utils.make_fs_safe(dir)
      if branch then
        name = name .. "@@" .. utils.make_fs_safe(branch)
      end
      vim.fn.writefile({ "" }, session_dir .. name .. ".vim")
    end

    -- Capture what the picker would show the user, without selecting anything
    shown = function()
      local items = {}
      vim.ui.select = function(list, opts)
        for _, item in ipairs(list) do
          items[#items + 1] = opts.format_item(item)
        end
      end
      require("persisted").select()
      return items
    end
  ]])
end

local T = new_set({
  hooks = {
    pre_case = setup_child,
    post_once = child.stop,
  },
})

T["shows the git branch with its path separators restored"] = function()
  child.lua([[
    create_session("/tmp/persisted_select_test", "feat/file-filters")
    items = shown()
  ]])

  eq(child.lua_get("#items"), 1)
  eq(child.lua_get([[items[1]:match("%((.+)%)$")]]), "feat/file-filters")
end

T["shows named sessions by their name"] = function()
  child.lua([[
    vim.fn.writefile({ "" }, session_dir .. "TestSession.vim")
    items = shown()
  ]])

  eq(child.lua_get("items"), { "TestSession" })
end

return T
