# 💾 Persisted

**Persisted** is a simple lua plugin for automated session management within Neovim.

The plugin was forked from the fantastic [Persistence.nvim](https://github.com/folke/persistence.nvim) as active development seems to have been paused and there were some useful pull requests.

## ✨ Features

- Automatically saves the active session under `.config/nvim/sessions` on exit
- Simple API to restore the current or last session
- Make use of sessions per git branch

## ⚡️ Requirements

- Neovim >= 0.5.0

## 📦 Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use({
  "olimorris/persisted.nvim",
  event = "BufReadPre", -- this will only start session saving when an actual file was opened
  module = "persisted",
  config = function()
    require("persisted").setup()
  end,
})
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
" Vim Script
Plug 'olimorris/persisted.nvim'

lua << EOF
  require("persisted").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
EOF
```

## ⚙️ Configuration

Persisted comes with the following defaults:

```lua
{
  dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved
  use_git_branch = false, -- create session files based on the branch of the git enabled repository
  autosave = true, -- automatically save session files
  options = { "buffers", "curdir", "tabpages", "winsize" }, -- session options used for saving
}
```

## 🚀 Usage

**Persisted** works well with plugins like `startify` or `dashboard`. It will never restore a session automatically, but you can of course write an autocmd that does exactly that.

Some example keybindings are contained below:
```lua
-- restore the session for the current directory and current branch (if `git_use_branch` is enabled)
vim.api.nvim_set_keymap("n", "<leader>qr", [[<cmd>lua require("persisted").load()<cr>]])

-- restore the last session
vim.api.nvim_set_keymap("n", "<leader>ql", [[<cmd>lua require("persisted").load({ last = true })<cr>]])

-- start persisted => if autosave is set to false
vim.api.nvim_set_keymap("n", "<leader>qs", [[<cmd>lua require("persisted").start()<cr>]])

-- stop persisted => session won't be saved on exit
vim.api.nvim_set_keymap("n", "<leader>qx", [[<cmd>lua require("persisted").stop()<cr>]])

-- toggle persisted => toggle a session
vim.api.nvim_set_keymap("n", "<leader>qt", [[<cmd>lua require("persisted").toggle()<cr>]])
```

### Helpers
**Persisted** sets a global variable, `vim.g.persisting`, which is set to `true` when the plugin is enabled. The author uses this to display an icon in their [statusline](https://github.com/olimorris/dotfiles/blob/0cdaee183c64f872778952f90f62b9366851101c/.config/nvim/lua/Oli/plugins/statusline.lua#L257).
