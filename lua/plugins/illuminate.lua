-- lua/plugins/illuminate.lua
-- https://github.com/RRethy/vim-illuminate
-- Highlights other usages of the word under the cursor (LSP/treesitter/regex).

return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("illuminate").configure({
      providers = { "lsp", "regex" },
      delay = 150,
    })
  end,
}
