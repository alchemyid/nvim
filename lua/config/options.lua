-- Options configuration optimized for speed and modern editing on older hardware (ThinkPad X220)

local opt = vim.opt

-- UI Settings
opt.number = true             -- Show line numbers
opt.relativenumber = true     -- Relative line numbers for fast navigation
opt.signcolumn = "yes"        -- Always show sign column to prevent layout shifts
opt.termguicolors = true      -- True color support
opt.cursorline = true         -- Highlight the current line (low overhead)
opt.scrolloff = 8             -- Keep at least 8 lines above/below cursor
opt.sidescrolloff = 8         -- Keep at least 8 columns to the left/right of cursor

-- Speed & Performance
opt.updatetime = 250          -- Faster completion, diagnostic triggers, and git gutter updates (default 4000)
opt.timeoutlen = 300          -- Reduce wait time for mapped sequences to trigger (default 1000)
opt.ttimeoutlen = 10          -- Keycode timeout (reduces ESC key delay)
opt.swapfile = false          -- Disable swap files (SSD is fast, and we save disk write operations)
opt.backup = false            -- Disable backups
opt.writebackup = false       -- Disable write backups
opt.undofile = true           -- Enable persistent undo (extremely useful, saved to disk)
opt.undolevels = 10000        -- Max number of changes that can be undone

-- Indentation (Standard full-stack defaults)
opt.expandtab = true          -- Use spaces instead of tabs
opt.shiftwidth = 4            -- Indent by 4 spaces
opt.tabstop = 4               -- Show tabs as 4 spaces
opt.softtabstop = 4           -- Indent with 4 spaces when editing
opt.smartindent = true        -- Make indenting smart

-- Search Behavior
opt.ignorecase = true         -- Case-insensitive search
opt.smartcase = true          -- Case-sensitive search if capital letter is typed
opt.hlsearch = true           -- Highlight search matches
opt.incsearch = true          -- Incremental search

-- System Integration
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.mouse = "a"               -- Enable mouse support (great for quick scrolling)
opt.splitright = true         -- Force vertical splits to open to the right
opt.splitbelow = true         -- Force horizontal splits to open below
opt.completeopt = { "menuone", "noselect", "noinsert" } -- Optimized completion menu

-- Disable unused built-in providers to speed up startup time
-- Older laptops see noticeable startup improvements by skipping provider checks
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

-- Fast filetype detection (enabled by default in modern Nvim, but good to ensure)
vim.filetype.add({
  extension = {
    mdx = "markdown",
  },
})
