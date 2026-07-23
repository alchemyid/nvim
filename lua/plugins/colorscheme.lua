-- lua/plugins/colorscheme.lua
-- https://github.com/navarasu/onedark.nvim
-- Requires Neovim >= 0.9. Loaded with high priority + lazy=false so it's
-- active before any other UI plugin (lualine, nvim-tree, etc.) renders.

return {
  "navarasu/onedark.nvim",
  lazy = false,
  priority = 1000, -- load before all other start plugins
  config = function()
    require("onedark").setup({
      -- Options: dark, darker, cool, deep, warm, warmer, light
      style = "deep",

      -- Toggle style in-editor with <leader>ts (also mapped in keymaps.lua)
      toggle_style_key = "<leader>ts",
      toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },

      transparent = false, -- show/hide background
      term_colors = true, -- change terminal colors
      ending_tildes = false, -- show the end-of-buffer tildes
      cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

      -- Change code style: comments, keywords, functions, strings, variables
      code_style = {
        comments = "italic",
        keywords = "none",
        functions = "none",
        strings = "none",
        variables = "none",
      },

      -- Lualine theme integration
      lualine = {
        transparent = false,
      },

      -- Custom Highlights: extend or override highlight groups
      colors = {},
      highlights = {},

      -- Diagnostics config
      diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
      },
    })

    require("onedark").load()
  end,
}
