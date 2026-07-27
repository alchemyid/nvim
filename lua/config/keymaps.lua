-- lua/config/keymaps.lua
-- Minimal keymaps. Plugin-specific keymaps live inside each plugin spec
-- under lua/plugins/*.lua (see the `keys = {...}` tables), which is the
-- idiomatic lazy.nvim pattern for lazy-loading on keypress.

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })

-- Onedark style toggle (also configurable via toggle_style_key, see colorscheme.lua)
map("n", "<leader>ts", "<cmd>lua require('onedark').toggle()<CR>", { desc = "Toggle onedark style" })

-- Better indenting in visual mode (preserves visual selection)
map("v", "<Tab>", ">gv", { desc = "Indent selected block" })
map("v", "<S-Tab>", "<gv", { desc = "Outdent selected block" })
map("v", ">", ">gv", { desc = "Indent selected block" })
map("v", "<", "<gv", { desc = "Outdent selected block" })

