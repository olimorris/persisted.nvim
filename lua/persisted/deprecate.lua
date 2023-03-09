---[[
--Courtesy of the awesome work in Nightfox.nvim
--https://github.com/EdenEast/nightfox.nvim/blob/main/lua/nightfox/lib/deprecation.lua
--]
local M = {
  _list = { { "[Persisted.nvim]\n", "Question" }, { "The following have been " }, { "deprecated:\n", "WarningMsg" } },
  _has_registered = false,
}

function M.write(...)
  for _, e in ipairs({ ... }) do
    table.insert(M._list, type(e) == "string" and { e } or e)
  end

  M._list[#M._list][1] = M._list[#M._list][1] .. "\n"

  if not M._has_registered then
    vim.cmd([[
            augroup PersistedDeprecations
                au!
                autocmd VimEnter * ++once lua require("persisted.deprecate").flush()
            augroup END
        ]])
    M._has_registered = true
  end
end

function M.flush()
  M.write(
    "----------\n",
    "See ",
    { "https://github.com/olimorris/persisted.nvim/issues/51", "Title" },
    " for more information."
  )
  vim.api.nvim_echo(M._list, true, {})
end

return M
