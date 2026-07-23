-- lua/plugins/mini.lua
-- https://github.com/echasnovski/mini.nvim
-- A collection of independent modules; enabling a small curated subset here.
-- Add more `require('mini.X').setup()` calls as needed.

return {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
  config = function()
    require("mini.pairs").setup({}) -- autoclose brackets/quotes
    require("mini.comment").setup({}) -- gcc / gc to comment
    require("mini.surround").setup({}) -- sa/sd/sr to add/delete/replace surroundings
    require("mini.indentscope").setup({}) -- animated indent scope guide
  end,
}
