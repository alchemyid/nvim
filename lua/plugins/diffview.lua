-- lua/plugins/diffview.lua
-- https://github.com/sindrets/diffview.nvim

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview open" },
    { "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview file history" },
  },
}
