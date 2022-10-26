if !isdirectory('plenary.nvim')
  !git clone https://github.com/nvim-lua/plenary.nvim.git plenary.nvim
  " !git -C plenary.nvim reset --hard 4b7e52044bbb84242158d977a50c4cbcd85070c7
endif

set runtimepath+=plenary.nvim,.
set noswapfile
set noundofile

runtime plugin/plenary.vim
command Setup PlenaryBustedDirectory tests/setup {minimal_init = 'tests/minimal.vim'}
command TestAutoloading PlenaryBustedDirectory tests/autoload {minimal_init = 'tests/minimal.vim'}
command TestGitBranching PlenaryBustedDirectory tests/git_branching {minimal_init = 'tests/minimal.vim'}
command TestFollowCwd PlenaryBustedDirectory tests/follow_cwd/follow_cwd.lua {minimal_init = 'tests/minimal.vim'}
command TestDefaults PlenaryBustedFile tests/default_settings_spec.lua
command TearDown PlenaryBustedFile tests/teardown/clean_up_dirs.lua
