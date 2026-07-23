-- lua/plugins/barbecue.lua
-- https://github.com/utilyre/barbecue.nvim
-- VS Code-like winbar breadcrumbs, driven by LSP + treesitter (already
-- configured in lsp.lua / treesitter.lua).

return {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    -- barbecue derives its colors from current highlight groups automatically,
    -- so 'auto' picks up onedark's colors without extra config.
    theme = "auto",
  },
}
