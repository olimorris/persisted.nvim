set rtp+=.
set rtp+=./misc/plenary

runtime! plugin/plenary.vim
command Setup PlenaryBustedDirectory tests/setup {minimal_init = 'tests/minimal.vim'}
command TestAutoloading PlenaryBustedDirectory tests/autoload {minimal_init = 'tests/minimal.vim'}
command TestGitBranching PlenaryBustedDirectory tests/git_branching {minimal_init = 'tests/minimal.vim'}
command TestFollowCwd PlenaryBustedDirectory tests/follow_cwd {minimal_init = 'tests/minimal.vim'}
command TestDefaults PlenaryBustedFile tests/default_settings_spec.lua
command TestDirs PlenaryBustedFile tests/dirs_spec.lua
command TearDown PlenaryBustedFile tests/teardown/clean_up_dirs.lua
