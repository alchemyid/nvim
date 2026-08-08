-- lua/plugins/colorscheme.lua
-- Colorscheme configuration. Primary: vscode.nvim, Backup/Alternative: onedark.nvim

return {
  -- onedark.nvim (keep configured but set to lazy)
  {
    "navarasu/onedark.nvim",
    lazy = true,
    config = function()
      require("onedark").setup({
        -- Options: dark, darker, cool, deep, warm, warmer, light
        style = "darker",
        toggle_style_key = "<leader>ts",
        toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
        transparent = false,
        term_colors = true,
        ending_tildes = false,
        cmp_itemkind_reverse = false,
        code_style = {
          comments = "italic",
          keywords = "none",
          functions = "none",
          strings = "none",
          variables = "none",
        },
        lualine = {
          transparent = false,
        },
        highlights = {},
        diagnostics = {
          darker = true,
          undercurl = true,
          background = true,
        },
      })
    end,
  },

  -- vscode.nvim (Active Colorscheme)
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000, -- load before all other start plugins
    config = function()
      require("vscode").setup({
        -- Enable transparent background
        transparent = false,

        -- Enable italic comment
        italic_comments = true,

        -- Underline @markup.link.* variants
        underline_links = true,

        -- Disable nvim-tree background color to blend in
        disable_nvimtree_bg = true,

        -- Apply theme colors to terminal
        terminal_colors = true,
      })

      -- Load the theme
      require("vscode").load()
    end,
  },
}

