-- lua/plugins/neo-tree.lua
-- https://github.com/nvim-neo-tree/neo-tree.nvim
--
-- NOTE: This is an ALTERNATIVE to nvim-tree (lua/plugins/nvim-tree.lua).
-- Both are supported/styled by onedark.nvim, but you generally only need
-- one file-explorer plugin. This spec is mapped to <leader>E so it won't
-- collide with nvim-tree's <leader>e. Delete whichever one you don't want.

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>E", "<cmd>Neotree toggle<CR>", desc = "Toggle Neo-tree" },
  },
  opts = {
    filesystem = {
      filtered_items = { visible = true, hide_dotfiles = false },
    },
  },
}
