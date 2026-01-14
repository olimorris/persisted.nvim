local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local setup_child = function()
  child.restart({ "-u", "scripts/minimal_init.lua" })
end

local T = new_set({
  hooks = {
    pre_case = setup_child,
    post_once = child.stop,
  },
})

T["can match directories"] = function()
  local match = child.lua_get([[require("persisted.utils").dirs_match("~/Code/Neovim/persisted.nvim", { "~/Code" })]])
  eq(match, true)

  local no_match =
    child.lua_get([[require("persisted.utils").dirs_match("~/Code/Neovim/persisted.nvim", { "~/.dotfiles" })]])
  eq(no_match, false)
end

T["can work with exact directories"] = function()
  local no_match = child.lua_get(
    [[require("persisted.utils").dirs_match("~/Code/Neovim/persisted.nvim", { { "~/Code", exact = true } })]]
  )
  eq(no_match, false)

  local match = child.lua_get(
    [[require("persisted.utils").dirs_match("~/Code/Neovim/persisted.nvim", { { "~/Code/Neovim/persisted.nvim", exact = true } })]]
  )
  eq(match, true)
end

T["can handle only ignore directories"] = function()
  local result = child.lua_get([[
    (function()
      local utils = require("persisted.utils")
      local cwd = "~/Code/Neovim/persisted.nvim"
      local allowed_dirs = {}
      local ignored_dirs = { { "/tmp" } }
      local allowed_match = utils.dirs_match(cwd, allowed_dirs)
      local ignored_match = utils.dirs_match(cwd, ignored_dirs)
      return not allowed_match and not ignored_match
    end)()
  ]])
  eq(result, true)
end

return T
