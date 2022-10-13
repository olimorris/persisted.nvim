if !isdirectory('plenary.nvim')
  !git clone https://github.com/nvim-lua/plenary.nvim.git plenary.nvim
  !git -C plenary.nvim reset --hard 1338bbe8ec6503ca1517059c52364ebf95951458
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
