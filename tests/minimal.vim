if !isdirectory('plenary.nvim')
  !git clone https://github.com/nvim-lua/plenary.nvim.git plenary.nvim
  !git -C plenary.nvim reset --hard 1338bbe8ec6503ca1517059c52364ebf95951458
endif

set runtimepath+=plenary.nvim,.
set noswapfile
set noundofile

runtime plugin/plenary.vim
command Setup PlenaryBustedFile tests/setup/create_sessions_spec.lua
command TestAutoloading PlenaryBustedDirectory tests/autoload {minimal_init = 'tests/minimal.vim'}
command Test PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}
command TearDown PlenaryBustedFile tests/teardown/clean_up_dirs.lua
