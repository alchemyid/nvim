return {
  -- Colorscheme: Catppuccin with byte compilation enabled for sub-millisecond startup times
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Load this first
    lazy = false,    -- Startup plugin
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_line = false,
        dim_inactive = {
          enabled = false, -- can cause lag on older CPUs if active
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          treesitter = true,
          mason = true,
          fzf = true,
        },
      })

      -- Set the colorscheme
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Statusline: Lualine configured with minimal sections to save CPU cycles
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "catppuccin",
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "oil" },
        },
        globalstatus = true, -- Single statusline for all splits (looks better & faster)
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 } }, -- 1 show relative path
        lualine_x = { "diagnostics", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },

  -- Git decorations: Gitsigns (runs completely asynchronously in Lua)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        follow_files = true
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame` (keep off by default for performance)
      update_debounce = 200,
      max_file_length = 40000, -- Disable on longer files for speed
    },
  },
}
