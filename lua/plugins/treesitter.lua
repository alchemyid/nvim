-- lua/plugins/treesitter.lua
-- Neovim 0.12+ sudah punya treesitter built-in. Plugin nvim-treesitter sudah
-- di-archive (April 2026) dan tidak dikembangkan lagi.
--
-- Konfigurasi ini menggunakan:
-- 1. Built-in vim.treesitter untuk highlight & indent (auto-aktif untuk parser
--    yang sudah tersedia)
-- 2. tree-sitter-manager.nvim sebagai pengganti ringan untuk install parser
--    bahasa tambahan yang tidak dibundel oleh Neovim
-- 3. nvim-treesitter hanya sebagai parser provider untuk plugin lain
--    (codecompanion.nvim butuh ini untuk render Markdown di chat buffer)
--
-- Requirement: tree-sitter CLI + gcc/clang (untuk compile parser)
--   Install CLI: sudo apt install tree-sitter-cli
--                atau: cargo install tree-sitter-cli
--                atau: npm install -g tree-sitter-cli

return {
  -- ── 1. Parser manager utama ──────────────────────────────────────────
  {
    "romus204/tree-sitter-manager.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("tree-sitter-manager").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "query",
          "bash", "json", "yaml", "markdown", "markdown_inline",
          "python", "javascript", "typescript", "tsx", "html", "css",
        },
        auto_install = true,  -- otomatis install parser saat buka file baru
      })

      -- Aktifkan treesitter highlight & indent bawaan Neovim untuk semua filetype
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("NativeTreesitter", { clear = true }),
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      -- Treesitter-based folding (opsional, uncomment kalau mau)
      -- vim.opt.foldmethod = "expr"
      -- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      -- vim.opt.foldenable = false  -- buka semua fold saat buka file
    end,
  },

  -- ── 2. nvim-treesitter: hanya untuk dependency plugin lain ───────────
  -- (codecompanion.nvim membutuhkan ini untuk render Markdown di chat buffer)
  -- Highlight DINONAKTIFKAN agar tidak konflik dengan native treesitter.
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,  -- hanya dimuat saat dibutuhkan plugin lain
    build = ":TSUpdate",
    opts = {
      highlight = { enable = false },  -- native treesitter sudah menangani ini
      indent = { enable = false },
    },
    config = function(_, opts)
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup(opts)
      end
    end,
  },
}
