local session_dir = vim.fn.getcwd() .. "/tests/default_data/"
local utils = require("persisted.utils")

describe("Directory utilities:", function()
  it("can match directories", function()
    local cwd = "~/Code/Neovim/persisted.nvim"

    local allowed_dirs = { "~/Code" }
    local match = utils.dirs_match(cwd, allowed_dirs)
    assert.equals(true, match)

    allowed_dirs = { "~/.dotfiles" }
    match = utils.dirs_match(cwd, allowed_dirs)
    assert.equals(false, match)
  end)

  it("can work with exact directories", function()
    local cwd = "~/Code/Neovim/persisted.nvim"
    local allowed_dirs = { { "~/Code", exact = true } }
    local match = utils.dirs_match(cwd, allowed_dirs)
    assert.equals(false, match)

    cwd = "~/Code/Neovim/persisted.nvim"
    allowed_dirs = { { "~/Code/Neovim/persisted.nvim", exact = true } }
    match = utils.dirs_match(cwd, allowed_dirs)
    assert.equals(true, match)
  end)

  it("can handle only ignore directories", function()
    local cwd = "~/Code/Neovim/persisted.nvim"
    local allowed_dirs = {}
    local ignored_dirs = { { "/tmp" } }
    local allowed_match = utils.dirs_match(cwd, allowed_dirs)
    local ignored_match = utils.dirs_match(cwd, ignored_dirs)
    -- This looks weird, I know. That is because we expect dirs_match to return
    -- false for allowed_dirs since allowed dirs is empty.
    -- Therefore this is actually testing to ensure we are getting false and false
    -- This test specifically addresses the change added in
    -- https://github.com/olimorris/persisted.nvim/pull/152
    assert.equals(true, not allowed_match and not ignored_match)
  end)
end)
