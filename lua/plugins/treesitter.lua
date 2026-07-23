-- lua/plugins/treesitter.lua
-- Provides the syntax highlighting captures onedark.nvim styles.
-- https://github.com/nvim-treesitter/nvim-treesitter

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua", "vim", "vimdoc", "query",
        "bash", "json", "yaml", "markdown", "markdown_inline",
        "python", "javascript", "typescript", "tsx", "html", "css",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
