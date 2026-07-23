-- lua/plugins/nvim-tree.lua
-- https://github.com/kyazdani42/nvim-tree.lua
-- Explicitly supported/styled by onedark.nvim.

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
  },
  opts = {
    view = { width = 30 },
    renderer = { group_empty = true },
    filters = { dotfiles = false },
  },
}
