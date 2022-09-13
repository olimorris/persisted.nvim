<p align="center">
<img src="https://user-images.githubusercontent.com/9512444/179085825-7c3bc1f7-c86b-4119-96e2-1a581e9bfffc.png" alt="Persisted.nvim" />
</p>

<h1 align="center">Persisted.nvim</h1>

<p align="center">
<a href="https://github.com/olimorris/persisted.nvim/stargazers"><img src="https://img.shields.io/github/stars/olimorris/persisted.nvim?color=c678dd&logoColor=e06c75&style=for-the-badge"></a>
<a href="https://github.com/olimorris/persisted.nvim/issues"><img src="https://img.shields.io/github/issues/olimorris/persisted.nvim?color=%23d19a66&style=for-the-badge"></a>
<a href="https://github.com/olimorris/persisted.nvim/blob/main/LICENSE"><img src="https://img.shields.io/github/license/olimorris/persisted.nvim?style=for-the-badge"></a>
<a href="https://github.com/olimorris/persisted.nvim/actions/workflows/ci.yml"><img src="https://img.shields.io/github/workflow/status/olimorris/persisted.nvim/Tests?label=tests&style=for-the-badge"></a>
</p>

<p align="center">
<b>Persisted.nvim</b> is a simple lua plugin for automated session management within Neovim<br>
Forked from <a href="https://github.com/folke/persistence.nvim">Persistence.nvim</a> as active development has stopped
</p>

## :book: Table of Contents

- [Features](#sparkles-features)
- [Requirements](#zap-requirements)
- [Installation](#package-installation)
- [Usage](#rocket-usage)
  - [Default commands](#default-commands)
  - [Telescope](#telescope)
  - [Helpers](#helpers)
- [Configuration](#wrench-configuration)
  - [Defaults](#defaults)
  - [Session options](#session-options)
  - [Session save location](#session-save-location)
  - [Git branching](#git-branching)
  - [Autosaving](#autosaving)
  - [Autoloading](#autoloading)
  - [Allowed directories](#allowed-directories)
  - [Ignored directories](#ignored-directories)
  - [Callbacks](#callbacks)
  - [Telescope extension](#telescope-extension)
- [License](#page_with_curl-license)

## :sparkles: Features

- Automatically saves the active session under `.local/share/nvim/sessions` on exiting Neovim
- Supports sessions across multiple git branches
- Supports auto saving and loading of sessions with allowed/ignored directories
- Simple API to save/stop/restore/delete/list the current session(s)
- Telescope extension to list all sessions

## :zap: Requirements

- Neovim >= 0.6.0

## :package: Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use({
  "olimorris/persisted.nvim",
  --module = "persisted", -- For lazy loading
  config = function()
    require("persisted").setup()
    require("telescope").load_extension("persisted") -- To load the telescope extension
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

### Lazy loading

The plugin is designed to work with startup screens like [vim-startify](https://github.com/mhinz/vim-startify) or [dashboard](https://github.com/glepnir/dashboard-nvim) out of the box. It will never load a session automatically by default.

However, to lazy load the plugin add the `module = "persisted"` line to packer.

## :rocket: Usage

### Default commands
The plugin comes with a number of commands:

- `:SessionToggle` - Determines whether to load, start or stop a session
- `:SessionStart` - Start recording a session. Useful if `autosave = false`
- `:SessionStop` - Stop recording a session
- `:SessionSave` - Save the current session
- `:SessionLoad` - Load the session for the current directory and current branch if `git_use_branch = true`
- `:SessionLoadLast` - Load the last session
- `:SessionDelete` - Delete the current session

> **Note:** The author only binds `:SessionToggle` to a keymap for simplicity.

### Telescope

The Telescope extension may be opened via `:Telescope persisted`.

Once opened, the available keymaps are:
* `<CR>` - Source the session file
* `<C-d>` - Delete the session file

### Helpers

The plugin sets a global variable, `vim.g.persisting`, which is set to `true` when a session is started. The author uses this to display an icon in their [statusline](https://github.com/olimorris/dotfiles/blob/0cdaee183c64f872778952f90f62b9366851101c/.config/nvim/lua/Oli/plugins/statusline.lua#L257).

## :wrench: Configuration

### Defaults

The plugin comes with the following defaults:

```lua
require("persisted").setup({
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved
  command = "VimLeavePre", -- the autocommand for which the session is saved
  silent = false, -- silent nvim message when sourcing session file
  use_git_branch = false, -- create session files based on the branch of the git enabled repository
  branch_separator = "_", -- string used to separate session directory name from branch name
  autosave = true, -- automatically save session files when exiting Neovim
  autoload = false, -- automatically load the session for the cwd on Neovim startup
  on_autoload_no_session = nil, -- function to run when `autoload = true` but there is no session to load
  allowed_dirs = nil, -- table of dirs that the plugin will auto-save and auto-load from
  ignored_dirs = nil, -- table of dirs that are ignored when auto-saving and auto-loading
  before_save = nil, -- function to run before the session is saved to disk
  after_save = nil, -- function to run after the session is saved to disk
  after_source = nil, -- function to run after the session is sourced
  telescope = { -- options for the telescope extension
    before_source = nil, -- function to run before the session is sourced via telescope
    after_source = nil, -- function to run after the session is sourced via telescope
  },
})
```

### Session options

As the plugin uses Vim's `:mksession` command then you may change the `vim.o.sessionoptions` value to determine what to write into the session. Please see `:h sessionoptions` for more information.

> **Note:** The author uses `vim.o.sessionoptions = "buffers,curdir,folds,winpos,winsize"`

### Session save location

The location of the session files may be changed by altering the `save_dir` configuration option. For example:

```lua
require("persisted").setup({
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- Resolves to ~/.local/share/nvim/sessions/
})
```

> **Note:** The plugin may be unable to find existing sessions if the `save_dir` value is changed

### Autocmd to save session

By default, a session is saved to disk when the `VimLeavePre` autocommand is triggered. This can be modified by:

```lua
require("persisted").setup({
  command = "VimLeavePre",
})
```

> **Note:** See `:h autocmds` for more information on possible autocmds
### Git branching

One of the plugin's core features is the ability to have multiple sessions files for a given project, by using git branches. To enable git branching:

```lua
require("persisted").setup({
  use_git_branch = true,
})
```

> **Note:** If git branching is enabled on a non git enabled repo, then `main` will be used as the default branch

### Autosaving

By default, the plugin will automatically save a Neovim session to disk when the `VimLeavePre` autocommand is triggered. Autosaving can be turned off by:

```lua
require("persisted").setup({
  autosave = false,
})
```

Autosaving can be further controlled for certain directories by specifying `allowed_dirs` and `ignored_dirs`.

### Autoloading

The plugin can be enabled to automatically load sessions when Neovim is started. Whilst off by default, this can be turned on by:

```lua
require("persisted").setup({
  autoload = true,
})
```

You can also provide a function to run when `autoload = true` but there is no session to be loaded:

```lua
require("persisted").setup({
  autoload = true,
  on_autoload_no_session = function()
    vim.notify("No existing session to load.")
  end
})
```


Autoloading can be further controlled for certain directories by specifying `allowed_dirs` and `ignored_dirs`.

> **Note:** Autoloading will not occur if a user opens Neovim with arguments. For example: `nvim some_file.rb`

### Allowed directories

You may specify a table of directories for which the plugin will autosave and/or autoload from. For example:

```lua
require("persisted").setup({
  allowed_dirs = {
    "~/.dotfiles",
    "~/Code",
  },
})
```

Specifying `~/Code` will autosave and autoload from that directory as well as all its sub-directories.

> **Note:** If `allowed_dirs` is left at its default value and `autosave` and/or `autoload` are set to `true`, then the plugin will autoload/autosave from *any* directory

### Ignored directories

You may specify a table of directories for which the plugin will **never** autosave and autoload from. For example:

```lua
require("persisted").setup({
  ignored_dirs = {
    "~/.config",
    "~/.local/nvim"
  },
})
```

Specifying `~/.config` will prevent any autosaving and autoloading from that directory as well as all its sub-directories.

### Callbacks

The plugin allows for *before* and *after* callbacks to be executed in relation to a session being saved. This is achieved via the `before_save` and `after_save` configuration options:

```lua
require("persisted").setup({
  before_save = function()
    pcall(vim.cmd, "bw minimap")
  end,
  after_save = function()
    print("Session was saved!")
  end,
})
```

> **Note:** The author uses a *before* callback to ensure that [minimap.vim](https://github.com/wfxr/minimap.vim) is not written into the session. Its presence prevents the exact buffer and cursor position from being restored when loading a session

The plugin allows for *before* and *after* callbacks to be executed in relation to a session being sourced:

```lua
require("persisted").setup({
  before_source = function()
    print("Sourcing...")
  end,
  after_source = function()
    -- Reload the LSP servers
    vim.lsp.stop_client(vim.lsp.get_active_clients())
  end
})
```

### Telescope extension

<p align="center">
<img src="https://user-images.githubusercontent.com/9512444/177375482-3bc9bd0d-42c8-4755-a36c-08ea5f954525.png" alt="Telescope">
</p>

The plugin contains an extension for [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) which allows the user to list all of the saved session files and source them via `:Telescope persisted`.

#### Telescope callbacks

The plugin allows for *before* and *after* callbacks to be used when sourcing a session via Telescope. For example:

```lua
require("persisted").setup({
  telescope = {
    before_source = function()
      -- Close all open buffers
      -- Thanks to https://github.com/avently
      vim.api.nvim_input("<ESC>:%bd<CR>")
    end,
    after_source = function(session)
      print("Loaded session " .. session.name)
    end,
  },
})
```
The callbacks can accept a *session* parameter which is a table that has the following properties:
* `name` - The filename of the session.
* `file_path` - The file path to the session.

## :page_with_curl: License

[MIT](https://github.com/olimorris/persisted.nvim/blob/main/LICENSE)
