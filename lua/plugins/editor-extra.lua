-- lua/plugins/editor-extra.lua
-- Peningkat produktivitas: oil (file seperti buffer), ufo (fold ala VSCode), sticky scroll,
-- flash (jump), multi-cursor, project switcher.

return {
  -- ── oil.nvim: edit direktori seperti buffer (rename/move/delete = edit teks lalu :w) ──
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- supaya `nvim .` / buka direktori langsung memakai oil
    keys = {
      { "<leader>E", function() require("oil").toggle_float() end, desc = "Oil: file manager (float)" },
      { "-", "<cmd>Oil<CR>", desc = "Oil: direktori induk" },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      keymaps = { ["<C-h>"] = false, ["<C-l>"] = false, ["q"] = "actions.close" },
    },
  },

  -- ── nvim-ufo: code folding ala VSCode (LSP + treesitter) ──
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    init = function()
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "Buka semua fold" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Tutup semua fold" },
      { "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
    },
    opts = {
      provider_selector = function() return { "lsp", "indent" } end,
    },
  },

  -- ── Sticky scroll: konteks fungsi/class tetap terlihat di atas ──
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { max_lines = 3, multiline_threshold = 1, trim_scope = "outer" },
    keys = {
      { "[C", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Ke konteks (fungsi/class) induk" },
    },
  },

  -- ── flash.nvim: jump cepat (menggantikan hop) ──
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { search = { enabled = false }, char = { enabled = false } } },
    keys = {
      { "<leader>j", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash: jump" },
      { "<leader>J", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash: pilih node treesitter" },
      { "<leader>hw", function() require("flash").jump({ pattern = ".", search = { mode = function(p) return "\\<" .. p end } }) end, desc = "Jump ke kata" },
      { "<leader>hl", function()
          require("flash").jump({ search = { mode = "search", max_length = 0 }, label = { after = { 0, 0 } }, pattern = "^" })
        end, desc = "Jump ke baris" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Flash: remote" },
    },
  },

  -- ── Multi-cursor: Ctrl+n pilih kata berikutnya (seperti Ctrl+D di VSCode) ──
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
    init = function()
      vim.g.VM_default_mappings = 1
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>",          -- Ctrl+n: pilih kata di bawah kursor / tambah kursor pada kemunculan berikutnya
        ["Find Subword Under"] = "<C-n>",
        ["Add Cursor Down"] = "<C-Down>",
        ["Add Cursor Up"] = "<C-Up>",
      }
    end,
  },

  -- ── Project switcher (Open Recent / Open Folder) ──
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = { { "<leader>fp", "<cmd>Telescope projects<CR>", desc = "Pindah project" } },
    config = function()
      require("project_nvim").setup({
        patterns = { ".git", "package.json", "pyproject.toml", "go.mod", "Cargo.toml", "Makefile" },
        silent_chdir = true,
      })
      require("telescope").load_extension("projects")
    end,
  },
}
