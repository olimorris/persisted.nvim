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

Install the plugin with your preferred package manager:

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
- `:SessionStart` - Start recording a session. Useful if `autosave = false`
- `:SessionStop` - Stop recording a session
- `:SessionSave` - Save the current session
- `:SessionLoad` - Load the session for the current directory and current branch (if `git_use_branch = true`)
- `:SessionLoadLast` - Load the most recent session
- `:SessionLoadFromFile` - Load a session from a given path
- `:SessionDelete` - Delete the current session

**Telescope extension**

<!-- panvimdoc-ignore-start -->

<p align="center">
<img src="https://github.com/olimorris/persisted.nvim/assets/9512444/5bfd6f94-ff70-4f2b-9193-53cdf7140d75" alt="Telescope">
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
- `vim.g.persisting_session` - (string) The file path to the current session

## :wrench: Configuration

**Defaults**

The plugin comes with the following defaults:

```lua
{
  save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved

  use_git_branch = false, -- create session files based on the branch of a git enabled repository

  autosave = true, -- automatically save session files when exiting Neovim
  should_autosave = nil, -- function to determine if a session should be autosaved (resolve to a boolean)
  autoload = false, -- automatically load the session for the cwd on Neovim startup
  on_autoload_no_session = nil, -- function to run when `autoload = true` but there is no session to load

  change_with_cwd = true, -- change the name of the session file if the cwd changes?
  allowed_dirs = nil, -- table of dirs that the plugin will autosave and autoload from
  ignored_dirs = nil, -- table of dirs that are ignored for autosaving and autoloading

  telescope = {
    mappings = {
      change_branch = "<C-b>",
      copy_session = "<C-c>",
      delete_session = "<C-d>",
    },
    icons = { -- icons displayed in the picker
      selected = " ",
      dir = "  ",
      branch = " ",
    },
  }
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

**Autosaving**

By default, the plugin will automatically save a Neovim session to disk when the `VimLeavePre` event is triggered. Autosaving can be turned off by:

```lua
require("persisted").setup({
  autosave = false,
})
```

Autosaving can be further controlled for certain directories by specifying `allowed_dirs` and `ignored_dirs`.

There may be occasions when you do not wish to autosave; perhaps when a dashboard or a certain buftype is present. To control this, a callback function, `should_autosave`, may be used which should return a boolean value.

```lua
require("persisted").setup({
  should_autosave = function()
    -- do not autosave if the alpha dashboard is the current filetype
    if vim.bo.filetype == "alpha" then
      return false
    end
    return true
  end,
})
```

Of course, if you wish to manually save the session when autosaving is disabled, the `:SessionSave` command can be used.

> [!NOTE]
> If `autosave = false` then the `should_autosave` callback will not be executed.

**Autoloading**

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

> [!NOTE]
> Autoloading will not occur if the plugin is lazy loaded or a user opens Neovim with arguments. Consider using autocmds in your config if you'd like to handle this use case.

**Allowed directories**

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

> [!NOTE]
> If `allowed_dirs` is left at its default value and `autosave` and/or `autoload` are set to `true`, then the plugin will autoload/autosave from _any_ directory

**Ignored directories**

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
    require("persisted").save({ session = vim.g.persisting_session })

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

## :page_with_curl: License

[MIT](https://github.com/olimorris/persisted.nvim/blob/main/LICENSE)
