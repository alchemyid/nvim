return {
  -- Syntax Highlighting: Treesitter with file-size safeguards
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate" },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        return
      end
      configs.setup({
        -- Standard development parsers
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "query",
          "javascript",
          "typescript",
          "tsx",
          "html",
          "css",
          "python",
          "markdown",
          "markdown_inline",
          "json",
          "yaml",
          "bash",
        },
        highlight = {
          enable = true,
          -- Performance optimization: disable Treesitter on very large files
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
            
            -- Also disable if the buffer has too many lines to avoid scrolling lag
            local line_count = vim.api.nvim_buf_line_count(buf)
            if line_count > 5000 then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
}
