-- Set mapleader to space before loading lazy.nvim
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core configurations
require("config.options")
require("config.lazy")
require("config.keymaps")
