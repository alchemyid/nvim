-- lua/plugins/neotest.lua
-- https://github.com/nvim-neotest/neotest
-- Test runner framework. Add language-specific adapters as needed
-- (e.g. nvim-neotest/neotest-python, nvim-neotest/neotest-jest) in the
-- `dependencies` table and register them in `adapters` below.

return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/nvim-nio",
  },
  cmd = { "Neotest" },
  keys = {
    { "<leader>tn", function() require("neotest").run.run() end, desc = "Run nearest test" },
    { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
    { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        -- require("neotest-python"),
        -- require("neotest-jest"),
      },
    })
  end,
}
