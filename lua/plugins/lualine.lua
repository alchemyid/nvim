-- lua/plugins/lualine.lua
-- https://github.com/hoob3rt/lualine.nvim
-- theme = 'onedark' is the exact integration documented in onedark.nvim's README.

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "onedark",
      globalstatus = true,
    },
  },
}
