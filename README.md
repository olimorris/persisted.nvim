<!-- panvimdoc-ignore-start -->

<p align="center">
<img src="https://user-images.githubusercontent.com/9512444/179085825-7c3bc1f7-c86b-4119-96e2-1a581e9bfffc.png" alt="Persisted.nvim" />
</p>

<h1 align="center">Persisted.nvim</h1>

<p align="center">
<a href="https://github.com/olimorris/persisted.nvim/stargazers"><img src="https://img.shields.io/github/stars/olimorris/persisted.nvim?color=c678dd&logoColor=e06c75&style=for-the-badge"></a>
<a href="https://github.com/olimorris/persisted.nvim/issues"><img src="https://img.shields.io/github/issues/olimorris/persisted.nvim?color=%23d19a66&style=for-the-badge"></a>
<a href="https://github.com/olimorris/persisted.nvim/blob/main/LICENSE"><img src="https://img.shields.io/github/license/olimorris/persisted.nvim?style=for-the-badge"></a>
<a href="https://github.com/olimorris/persisted.nvim/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/olimorris/persisted.nvim/ci.yml?branch=main&label=tests&style=for-the-badge"></a>
</p>

<p align="center">
<b>Persisted.nvim</b> is a simple lua plugin for working with sessions in Neovim<br>
(Forked from <a href="https://github.com/folke/persistence.nvim">Persistence.nvim</a>)
</p>

<!-- panvimdoc-ignore-end -->

## :sparkles: Features

- :evergreen_tree: Supports sessions across multiple git branches
- :telescope: Telescope extension to manage sessions
- :tickets: Custom events which users can hook into for tighter integrations
- :memo: Simple API to save/stop/restore/delete/list the current session(s)
- :open_file_folder: Supports autosaving and autoloading of sessions with allowed/ignored directories
- :floppy_disk: Automatically saves the active session under `.local/share/nvim/sessions` on exiting Neovim

## :zap: Requirements

- Neovim >= 0.8.0

## :package: Installation

Install and configure the plugin with your preferred package manager:

**[Lazy.nvim](https://github.com/folke/lazy.nvim)**

```lua
-- Lua
{
  "olimorris/persisted.nvim",
  lazy = false, -- make sure the plugin is always loaded at startup
  config = true
}
```

> [!NOTE]
> Setting `lazy = true` option may be useful if you use a dashboard

**[Packer](https://github.com/wbthomason/packer.nvim)**

```lua
-- Lua
use({
  "olimorris/persisted.nvim",
  config = function()
    require("persisted").setup()
  end,
})
```

**[Vim Plug](https://github.com/junegunn/vim-plug)**

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

If you wish to use session _autoloading_ alongside a dashboard plugin, it is recommended that you give this plugin a greater loading priority. With **Packer** the `after` config option can be used and in **Lazy.nvim**, the `priority` property.

**Telescope extension**

Ensure that the telescope extension is loaded with:

```lua
require("telescope").load_extension("persisted")
```

The layout can then be customised from within Telescope:

```lua
require('telescope').setup({
  defaults = {
    …
  },
  extensions = {
    persisted = {
      layout_config = { width = 0.55, height = 0.55 }
    }
  }
})
```

## :rocket: Usage

**Commands**

The plugin comes with a number of commands:

- `:SessionToggle` - Determines whether to load, start or stop a session
- `:SessionStart` - Start recording a session. Useful if `autostart = false`
- `:SessionStop` - Stop recording a session
- `:SessionSave` - Save the current session
- `:SessionLoad` - Load the session for the current directory and current branch (if `git_use_branch = true`)
- `:SessionLoadLast` - Load the most recent session
- `:SessionLoadFromFile` - Load a session from a given path
- `:SessionDelete` - Delete the current session

**Telescope extension**

<!-- panvimdoc-ignore-start -->

<p align="center">
<img src="https://github.com/user-attachments/assets/3ff91790-b61a-4089-b87d-432e8b4969c2" alt="Telescope">
</p>

<!-- panvimdoc-ignore-end -->

The Telescope extension may be opened via `:Telescope persisted`. The default actions are:

- `<CR>` - Open/source the session file
- `<C-b>` - Add/update the git branch for the session file
- `<C-c>` - Copy the session file
- `<C-d>` - Delete the session file

**Global variables**

The plugin sets a number of global variables throughout its lifecycle:

- `vim.g.persisting` - (bool) Determines if the plugin is active for the current session
- `vim.g.persisting_session` - (string) The file path to the current session (if `follow_cwd` is false)
- `vim.g.persisted_loaded_session` - (string) The file path to the last loaded session

## :wrench: Configuration

**Defaults**

The plugin comes with the following defaults:

```lua
{
  autostart = true, -- Automatically start the plugin on load?

  -- Function to determine if a session should be saved
  ---@type fun(): boolean
  should_save = function()
    return true
  end,

  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- Directory where session files are saved

  follow_cwd = true, -- Change the session file to match any change in the cwd?
  use_git_branch = false, -- Include the git branch in the session file name?
  autoload = false, -- Automatically load the session for the cwd on Neovim startup?

  -- Function to run when `autoload = true` but there is no session to load
  ---@type fun(): any
  on_autoload_no_session = function() end,

  allowed_dirs = {}, -- Table of dirs that the plugin will start and autoload from
  ignored_dirs = {}, -- Table of dirs that are ignored for starting and autoloading

  telescope = {
    mappings = { -- Mappings for managing sessions in Telescope
      copy_session = "<C-c>",
      change_branch = "<C-b>",
      delete_session = "<C-d>",
    },
    icons = { -- icons displayed in the Telescope picker
      selected = " ",
      dir = "  ",
      branch = " ",
    },
  },
}
```

**What is saved in the session?**

As the plugin uses Vim's `:mksession` command then you may change the `vim.o.sessionoptions` value to determine what to write into the session. Please see `:h sessionoptions` for more information.

> [!NOTE]
> The author uses: `vim.o.sessionoptions = "buffers,curdir,folds,globals,tabpages,winpos,winsize"`

**Session save location**

The location of the session files may be changed by altering the `save_dir` configuration option. For example:

```lua
require("persisted").setup({
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- Resolves to ~/.local/share/nvim/sessions/
})
```

> [!NOTE]
> The plugin may be unable to find existing sessions if the `save_dir` value is changed

**Git branching**

One of the plugin's core features is the ability to have multiple session files for a given project, by using git branches. To enable git branching:

```lua
require("persisted").setup({
  use_git_branch = true,
})
```

**Autostart**

By default, the plugin will automatically start when the setup function is called. This results in a Neovim session being saved to disk when the `VimLeavePre` event is triggered. This can be disabled by:

```lua
require("persisted").setup({
  autostart = false,
})
```

Autostarting can be further controlled for certain directories by specifying `allowed_dirs` and `ignored_dirs`.

**`should_save`**

There may be occasions when you do not wish to save the session; perhaps when a dashboard or a certain filetype is present. To handle this, the `should_save` function may be used which should return a boolean value.

```lua
require("persisted").setup({
  ---@return bool
  should_save = function()
    -- Do not save if the alpha dashboard is the current filetype
    if vim.bo.filetype == "alpha" then
      return false
    end
    return true
  end,
})
```

Of course, if you wish to manually save the session the `:SessionSave` command can be used.

**Autoloading**

The plugin can be enabled to automatically load sessions when Neovim is started. Whilst off by default, this can be turned on by:

```lua
require("persisted").setup({
  autoload = true,
})
```

You can also provide a function to run when `autoload = true` and there is no session to load:

```lua
require("persisted").setup({
  autoload = true,
  on_autoload_no_session = function()
    vim.notify("No existing session to load.")
  end
})
```

Autoloading can be further controlled for directories in the `allowed_dirs` and `ignored_dirs` config tables.

> [!IMPORTANT]
> By design, the plugin will not autoload a session when any arguments are passed to Neovim such as `nvim my_file.py`

**Allowed directories**

You may specify a table of directories for which the plugin will start and/or autoload from. For example:

```lua
require("persisted").setup({
  allowed_dirs = {
    "~/.dotfiles",
    "~/Code",
  },
})
```

Specifying `~/Code` will start and autoload from that directory as well as all its sub-directories.

> [!NOTE]
> If `allowed_dirs` is left at its default value and `autostart` and/or `autoload` are set to `true`, then the plugin will start and autoload from _any_ directory

**Ignored directories**

You may specify a table of directories for which the plugin will **never** start and autoload from. For example:

```lua
require("persisted").setup({
  ignored_dirs = {
    "~/.config",
    "~/.local/nvim"
  },
})
```

Specifying `~/.config` will prevent any autosaving and autoloading from that directory as well as all its sub-directories.

You can also specify exact directory matches to ignore. In this case, unlike the default behavior which ignores all children of the ignored directory, this will ignore only the specified child. For example:

```lua
require("persisted").setup({
  ignored_dirs = {
    "~/.config",
    "~/.local/nvim",
    { "/", exact = true },
    { "/tmp", exact = true }
  },
})
```

In this setup, `~/.config` and `~/.local/nvim` are still going to behave in their default setting (ignoring all listed directory and its children), however `/` and `/tmp` will only ignore those directories exactly.

**Events / Callbacks**

The plugin fires events at various points during its lifecycle:

- `PersistedLoadPre` - For _before_ a session is loaded
- `PersistedLoadPost` - For _after_ a session is loaded
- `PersistedTelescopeLoadPre` - For _before_ a session is loaded via Telescope
- `PersistedTelescopeLoadPost` - For _after_ a session is loaded via Telescope
- `PersistedSavePre` - For _before_ a session is saved
- `PersistedSavePost` - For _after_ a session is saved
- `PersistedDeletePre` - For _before_ a session is deleted
- `PersistedDeletePost` - For _after_ a session is deleted
- `PersistedStart` - For when a session has _started_
- `PersistedStop` - For when a session has _stopped_
- `PersistedToggle` - For when a session is toggled

These events can be consumed anywhere within your configuration by utilising the `vim.api.nvim_create_autocmd` function.

A commonly requested example is to use the Telescope extension to load a session, saving the current session before clearing all of the open buffers:

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "PersistedTelescopeLoadPre",
  callback = function(session)
    -- Save the currently loaded session using the global variable
    require("persisted").save({ session = vim.g.persisted_loaded_session })

    -- Delete all of the open buffers
    vim.api.nvim_input("<ESC>:%bd!<CR>")
  end,
})
```

**Highlights**

The plugin also comes with pre-defined highlight groups for the Telescope implementation:

- `PersistedTelescopeSelected`
- `PersistedTelescopeDir`
- `PersistedTelescopeBranch`

## :building_construction: Extending the Plugin

The plugin has been designed to be fully extensible. All of the functions in the [init.lua](https://github.com/olimorris/persisted.nvim/blob/main/lua/persisted/init.lua) and [utils.lua](https://github.com/olimorris/persisted.nvim/blob/main/lua/persisted/utils.lua) file are public.

Consider a user who wishes to autoload a session if arguments are passed to Neovim. A custom autocmd can be created which forces the autoload:

```lua
local persisted = require("persisted")

persisted.setup({
  autoload = true
})

vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = function()
    -- Add more complex logic here
    if vim.fn.argc() > 0 then
      -- Leverage the plugin's ability to resolve allowed_dirs and ignored_dirs
      require("persisted").autoload({ force = true })
    end
  end,
})
```

Or, a user who wishes to check whether the current branch is in a table of branches to be ignored:

```lua
local persisted = require("persisted")
local utils = require("persisted.utils")

persisted.setup({
  autostart = false,
  use_git_branch = true,
})

local ignored_branches = {
  "feature_branch"
}

if not utils.in_table(persisted.branch(), ignored_branches) then
  persisted.load()
  persisted.start()
end
```
