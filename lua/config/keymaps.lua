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

-- Toggle light/dark background style (dynamic theme switching)
map("n", "<leader>tc", function()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
  vim.cmd("colorscheme vscode")
end, { desc = "Toggle vscode dark/light theme" })

-- Better indenting in visual mode (preserves visual selection)
map("v", "<Tab>", ">gv", { desc = "Indent selected block" })
map("v", "<S-Tab>", "<gv", { desc = "Outdent selected block" })
map("v", ">", ">gv", { desc = "Indent selected block" })
map("v", "<", "<gv", { desc = "Outdent selected block" })


-- ── Gaya VSCode ────────────────────────────────────────────────────────────
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save (Ctrl+S)" })
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
map("n", "<A-S-j>", "<cmd>t.<CR>", { desc = "Duplicate line down" })
map("n", "<C-a>", "ggVG", { desc = "Select all" })
map("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })
map("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+yy', { desc = "Yank line to system clipboard" })
-- Ctrl+/ untuk comment (terminal mengirim <C-_>); memakai mini.comment
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<C-_>", "gc", { remap = true, desc = "Toggle comment" })
map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })
-- Pecah/gabung window
map("n", "<leader>\\", "<cmd>vsplit<CR>", { desc = "Split right" })
map("n", "<leader>-", "<cmd>split<CR>", { desc = "Split below" })
