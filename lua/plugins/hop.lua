-- lua/plugins/hop.lua
-- https://github.com/smoka7/hop.nvim

return {
  "smoka7/hop.nvim",
  version = "*",
  keys = {
    {
      "<leader>hw",
      function() require("hop").hint_words() end,
      desc = "Hop to word",
    },
    {
      "<leader>hl",
      function() require("hop").hint_lines() end,
      desc = "Hop to line",
    },
  },
  config = function()
    require("hop").setup({})
  end,
}
