-- Ensure ~/.local/bin and ~/.cargo/bin are in Neovim's PATH for tools like tree-sitter CLI
local local_bin = vim.fn.expand("~/.local/bin")
local cargo_bin = vim.fn.expand("~/.cargo/bin")
if vim.fn.isdirectory(local_bin) == 1 and not string.find(vim.env.PATH or "", local_bin, 1, true) then
  vim.env.PATH = local_bin .. ":" .. (vim.env.PATH or "")
end
if vim.fn.isdirectory(cargo_bin) == 1 and not string.find(vim.env.PATH or "", cargo_bin, 1, true) then
  vim.env.PATH = cargo_bin .. ":" .. (vim.env.PATH or "")
end

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
