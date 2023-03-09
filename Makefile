PANVIMDOC_DIR = misc/panvimdoc
PANVIMDOC_URL = https://github.com/kdheepak/panvimdoc
PLENARY_DIR = misc/plenary
PLENARY_URL = https://github.com/nvim-lua/plenary.nvim

all: format test docs

docs: $(PANVIMDOC_DIR)
	@cd $(PANVIMDOC_DIR) && \
	pandoc \
		--metadata="project:persisted.nvim" \
		--metadata="description:Simple session management for Neovim" \
		--metadata="toc:true" \
		--metadata="incrementheadinglevelby:0" \
		--metadata="treesitter:true" \
		--lua-filter scripts/skip-blocks.lua \
		--lua-filter scripts/include-files.lua \
		--lua-filter scripts/remove-emojis.lua \
		-t scripts/panvimdoc.lua \
		../../README.md \
		-o ../../doc/persisted.nvim.txt

$(PANVIMDOC_DIR):
	git clone --depth=1 --no-single-branch $(PANVIMDOC_URL) $(PANVIMDOC_DIR)
	@rm -rf doc/panvimdoc/.git

check:
	stylua --check lua/ tests/ -f ./stylua.toml

format:
	stylua lua/ tests/ -f ./stylua.toml

test: $(PLENARY_DIR)
	nvim --headless --noplugin -u tests/minimal.vim +Setup
	# nvim --headless --noplugin -u tests/minimal.vim +TestAutoloading
	nvim --headless --noplugin -u tests/minimal.vim +TestGitBranching
	nvim --headless --noplugin -u tests/minimal.vim +TestDefaults
	nvim --headless --noplugin -u tests/minimal.vim +TearDown

$(PLENARY_DIR):
	git clone --depth=1 --no-single-branch $(PLENARY_URL) $(PLENARY_DIR)
	@rm -rf $(PLENARY_DIR)/.git
