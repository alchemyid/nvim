-- lua/plugins/indentmini.lua
-- https://github.com/nvimdev/indentmini.nvim
--
-- ALTERNATIVE to indent-blankline.nvim (a lighter-weight indent-guide plugin).
-- Disabled by default to avoid running two indent-guide plugins at once.
-- To use this instead of indent-blankline: set enabled = true here and
-- enabled = false (or delete the file) in indent-blankline.lua.

return {
  "nvimdev/indentmini.nvim",
  enabled = false,
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("indentmini").setup({})
  end,
}
