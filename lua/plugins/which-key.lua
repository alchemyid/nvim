-- lua/plugins/which-key.lua
-- https://github.com/folke/which-key.nvim

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup({})
    wk.add({
      { "<leader>a", group = "AI (CodeCompanion)" },
      { "<leader>C", group = "Claude Code" },
      { "<leader>G", group = "Gemini" },
      { "<leader>b", group = "Buffer/Tab" },
      { "<leader>c", group = "Code/LSP" },
      { "<leader>d", group = "Debug" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Hunk / Hop" },
      { "<leader>q", group = "Session" },
      { "<leader>s", group = "Search/Replace" },
      { "<leader>t", group = "Terminal/Test" },
      { "<leader>x", group = "Problems" },
    })
  end,
}
