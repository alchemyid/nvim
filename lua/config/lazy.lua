-- lua/config/lazy.lua
-- Bootstraps lazy.nvim (plugin manager) then loads every spec file under
-- lua/plugins/*.lua automatically via the { import = "plugins" } directive.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "vscode", "onedark" } },
  checker = { enabled = true, notify = false }, -- auto check for plugin updates
  change_detection = { notify = false },
  git = {
    timeout = 300, -- Naikkan timeout menjadi 5 menit agar plugin besar (seperti copilot.lua) tidak stuck saat koneksi lambat
  },
  performance = {
    rtp = {
      -- disable some unused built-in vim plugins for faster startup
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin", -- disabled since nvim-tree/neo-tree replace netrw
      },
    },
  },
})
