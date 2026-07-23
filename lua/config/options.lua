-- lua/config/options.lua
-- Basic sane defaults. Requires Neovim >= 0.9 (needed by onedark.nvim's
-- TreeSitter/LSP semantic token support).

local opt = vim.opt

opt.termguicolors = true -- required for onedark.nvim to render correctly
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- keeps gutter stable for gitsigns / diagnostics
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.splitright = true
opt.splitbelow = true

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"

opt.updatetime = 200
opt.timeoutlen = 400

opt.clipboard = "unnamedplus"
opt.mouse = "a"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
