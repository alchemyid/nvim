-- Bootstrap lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim with performance options for older systems
require("lazy").setup({
  spec = {
    -- Import all plugin modules from lua/plugins/
    { import = "plugins" },
  },
  defaults = {
    -- By default, all plugins are lazy-loaded unless specified otherwise
    lazy = true,
  },
  install = {
    colorscheme = { "catppuccin" },
  },
  checker = {
    enabled = false, -- Disable background plugin update checking to save network/CPU
  },
  performance = {
    rtp = {
      -- Disable heavy/unused vim builtins to shave off startup time
      disabled_plugins = {
        "gzip",
        "matchit",
        "netrwPlugin", -- Oil.nvim will replace this entirely
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
