# 💾 Persisted

**Persisted** is a simple lua plugin for automated session management within Neovim.

The plugin was forked from the fantastic [Persistence.nvim](https://github.com/folke/persistence.nvim) as active development seems to have been paused and there were some useful pull requests.

## ✨ Features

- Automatically saves the active session under `.local/share/nvim/sessions` on exiting Neovim
- Simple API to restore the current or last session
- Support for sessions across git branches
- Specify custom directory to save sessions
- Stop or even delete the current session

## ⚡️ Requirements

- Neovim >= 0.5.0

## 📦 Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use({
  "olimorris/persisted.nvim",
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

The plugin comes with the following defaults:

```lua
{
  dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved
  use_git_branch = false, -- create session files based on the branch of the git enabled repository
  autosave = true, -- automatically save session files
  autoload = false, -- automatically load the current session on Neovim startup
  options = { "buffers", "curdir", "tabpages", "winsize" }, -- session options used for saving
  before_save = function() end, -- function to run before the session is saved to disk
  after_save = function() end, -- function to run after the session is saved to disk
}
```

These can be overwritten by calling the `setup` method and passing in the appropriate value.

## 🚀 Usage

The plugin works well with others like [vim-startify](https://github.com/mhinz/vim-startify) or [dashboard](https://github.com/glepnir/dashboard-nvim). It will never restore a session automatically but the commands below, or a custom autocmd, may be used.

### Commands

- `SessionStart` - Start a session. Useful if `autosave = false`
- `SessionStop` - Stop recording a session
- `SessionSave` - Save the current session
- `SessionLoad` - Load the session for the current directory and current branch if `git_use_branch = true`
- `SessionLoadLast` - Load the last session
- `SessionDelete` - Delete the current session
- `SessionToggle` - Determines whether to load, start or stop a session

### Callbacks

The plugin allows for _before_ and _after_ callbacks to be executed relative to the session. This is achieved via the `before_save` and `after_save` configuration options.

> **Note:** The author uses a _before_ callback to ensure that [minimap.vim](https://github.com/wfxr/minimap.vim) is not written into the session. Its presence prevents the exact buffer and cursor position from being restored when loading a session.

### Lazy loading

To lazy load the plugin, consider adding the `module = "persisted"` option if you're using packer. The commands may then be called with `<cmd>lua require("persisted").toggle()<cr>` for example. The only command which is nuanced is `SessionLoadLast` which is called with `<cmd>lua require("persisted").load({ last = true })<cr>`.

### Helpers

The plugin sets a global variable, `vim.g.persisting`, which is set to `true` when a session is started. The author uses this to display an icon in their [statusline](https://github.com/olimorris/dotfiles/blob/0cdaee183c64f872778952f90f62b9366851101c/.config/nvim/lua/Oli/plugins/statusline.lua#L257).

A table of saved sessions can be returned by the `lua require("persisted").list()` command. The author uses this to display a list of sessions in their [config](https://github.com/olimorris/dotfiles/blob/9e06f00a878710aefc8c28904d2322ea46e3eaea/.config/nvim/lua/Oli/core/functions.lua#L3).
