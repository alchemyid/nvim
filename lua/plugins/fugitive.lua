-- lua/plugins/fugitive.lua
-- https://github.com/tpope/vim-fugitive

return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit" },
  keys = {
    { "<leader>gs", "<cmd>Git<CR>", desc = "Git status (fugitive)" },
  },
}
