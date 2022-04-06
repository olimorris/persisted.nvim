all: test

test:
	nvim --headless --noplugin -u tests/minimal.vim +Setup
	nvim --headless --noplugin -u tests/minimal.vim +TestAutoloading
	nvim --headless --noplugin -u tests/minimal.vim +Test
	nvim --headless --noplugin -u tests/minimal.vim +TearDown

check:
	stylua --color always --check .
