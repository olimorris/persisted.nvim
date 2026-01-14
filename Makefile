all: format docs test

docs: deps/panvimdoc
	@echo Generating Docs...
	@LUA_PATH="deps/panvimdoc/?.lua;;" pandoc \
		README.md \
		--metadata="project:persisted.nvim" \
		--metadata="description:Simple session management for Neovim" \
		--metadata="titledatepattern:%Y %B %d" \
		--metadata="toc:true" \
		--metadata="incrementheadinglevelby:0" \
		--metadata="treesitter:true" \
		--metadata="dedupsubheadings:true" \
		--metadata="ignorerawblocks:true" \
		--metadata="docmapping:false" \
		--metadata="docmappingproject:true" \
		--lua-filter deps/panvimdoc/scripts/include-files.lua \
		--lua-filter deps/panvimdoc/scripts/skip-blocks.lua \
		--lua-filter deps/panvimdoc/scripts/remove-emojis.lua \
		-t deps/panvimdoc/scripts/panvimdoc.lua \
		-o doc/persisted.nvim.txt

format:
	@echo Formatting...
	@stylua tests/ lua/ -f ./stylua.toml

test: deps
	@echo Testing...
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

test_file: deps
	@echo Testing File...
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"

deps: deps/mini.nvim deps/panvimdoc
	@echo Pulling...

deps/mini.nvim:
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/echasnovski/mini.nvim $@

deps/panvimdoc:
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/kdheepak/panvimdoc $@

