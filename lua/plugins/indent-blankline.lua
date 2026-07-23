-- lua/plugins/indent-blankline.lua
-- https://github.com/lukas-reineke/indent-blankline.nvim
--
-- NOTE: This is an ALTERNATIVE to indentmini.nvim (see indentmini.lua,
-- disabled by default). Both are supported/styled by onedark.nvim; pick one.

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    indent = { char = "│" },
    scope = { enabled = true },
  },
}
