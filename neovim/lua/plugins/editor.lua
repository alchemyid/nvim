return {
  -- Fuzzy Finder: Fzf-lua (much faster and lighter than Telescope on old hardware)
  {
    "ibhagwan/fzf-lua",
    -- Load on commands or keymaps
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help Tags" },
      { "<leader>fs", "<cmd>FzfLua grep_cword<cr>", desc = "Search Current Word" },
      { "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume Last Search" },
    },
    opts = {
      -- Clean, compact layout
      winopts = {
        height = 0.85,
        width = 0.80,
        preview = {
          hidden = "nohidden",
          vertical = "down:45%",
          horizontal = "right:50%",
          layout = "flex",
        },
      },
      files = {
        formatter = "path.filename_first",
      },
    },
  },

  -- File Explorer: Oil.nvim (lets you edit directory trees like a text buffer)
  -- Extremely fast, zero lag, replaces heavy sidebar file trees
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open Parent Directory" },
    },
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "actions.select_vsplit",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
      },
      use_default_keymaps = false,
      view_options = {
        show_hidden = false,
      },
    },
  },

  -- Auto Pairs: Automatically inserts matching pairs of brackets/quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true, -- Check Treesitter integration
      ts_config = {
        lua = { "string" }, -- Don't add pairs in lua string treesitter nodes
        javascript = { "template_string" },
      },
    },
  },

  -- Sidebar File Explorer: Neo-tree (configured for lazy loading)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle left<cr>", desc = "Toggle Explorer (Neo-tree)" },
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true, -- High performance filesystem watcher
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = "none", -- Disable space to prevent conflict with leader key
        },
      },
    },
  },
}
