-- Keybindings optimized for workflow speed and ergonomics
local keymap = vim.keymap.set
local opts = { silent = true }

-- Better window navigation (use Ctrl + h/j/k/l to switch panes)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Buffer navigation (Shift + h/l to cycle open files/buffers)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<S-l>", ":bnext<CR>", opts)

-- Resize windows with Ctrl + arrow keys
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Clear search highlight on ESC or <leader>h
keymap("n", "<Esc>", ":nohlsearch<CR>", opts)
keymap("n", "<leader>h", ":nohlsearch<CR>", opts)

-- Stay in visual mode when indenting code blocks
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down in visual/visual-block mode
-- (Vim equivalent to Alt-Up/Alt-Down in VS Code)
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)
keymap("x", "J", ":m '>+1<CR>gv=gv", opts)
keymap("x", "K", ":m '<-2<CR>gv=gv", opts)

-- Keep cursor centered when page jumping
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Quick buffer actions
keymap("n", "<leader>w", ":w<CR>", { desc = "Save File" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit File" })
keymap("n", "<leader>c", ":bd<CR>", { desc = "Close Buffer" })

-- Terminal mode escaping (Esc Esc to return to normal mode in terminal)
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", opts)
