-- lua/plugins/which-key.lua
-- https://github.com/folke/which-key.nvim

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    require("which-key").setup({})
  end,
}
