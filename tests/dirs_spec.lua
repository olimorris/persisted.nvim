local session_dir = vim.fn.getcwd() .. "/tests/default_data/"
local utils = require("persisted.utils")

describe("Directory utilities:", function()
  it("can match directories", function()
    local cwd = "~/Code/Neovim/persisted.nvim"
    local allowed_dirs = { "~/Code" }

    local match = utils.dirs_match(cwd, allowed_dirs)
    assert.equals(true, match)
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
end)
