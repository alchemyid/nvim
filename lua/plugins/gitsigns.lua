-- lua/plugins/gitsigns.lua
-- https://github.com/lewis6991/gitsigns.nvim
-- Modern replacement for vim-gitgutter (also supported by onedark.nvim, but
-- gitsigns is the actively maintained option and is recommended).

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    current_line_blame = false,
  },
}
