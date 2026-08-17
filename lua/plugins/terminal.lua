-- lua/plugins/terminal.lua
-- Terminal terintegrasi mirip VSCode, powered by toggleterm.nvim
--
-- Shortcut utama:
--   Leader + tt     → Toggle terminal horizontal di bawah (panel mirip VSCode)
--   Leader + tz     → Toggle terminal floating (popup di tengah)
--   Leader + tv     → Terminal vertikal (sidebar kanan)
--   Leader + tg     → Lazygit di terminal floating
--
-- Di dalam terminal:
--   Esc             → Kembali ke Normal mode (untuk navigasi)
--   Ctrl+h/j/k/l    → Pindah window tanpa keluar terminal
--
-- CATATAN: Ctrl+t tidak dipakai karena terminal emulator (GNOME Terminal,
-- Tilix, dll) mencurinya untuk "new tab" sebelum Neovim menerimanya.

return {
    "akinsho/toggleterm.nvim",
    version = "*",
    lazy = false,  -- load langsung supaya shortcut aktif dari awal
    config = function()
        require("toggleterm").setup({
            -- ── Default: panel bawah seperti VSCode ───────────────────────
            direction = "horizontal",
            size = function(term)
                if term.direction == "horizontal" then
                    return 15   -- tinggi panel bawah (mirip VSCode)
                elseif term.direction == "vertical" then
                    return math.floor(vim.o.columns * 0.35)
                end
            end,

            -- ── Tampilan ─────────────────────────────────────────────────
            border = "curved",
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = false,
            terminal_mappings = false,
            persist_size = true,
            persist_mode = true,
            close_on_exit = true,
            auto_scroll = true,

            -- ── Floating window ───────────────────────────────────────────
            float_opts = {
                border = "curved",
                width = function()
                    return math.floor(vim.o.columns * 0.85)
                end,
                height = function()
                    return math.floor(vim.o.lines * 0.80)
                end,
                winblend = 5,
            },
        })

        local Terminal = require("toggleterm.terminal").Terminal

        -- Leader shortcuts (hanya di Normal mode 'n' agar tidak mengganggu spasi saat mengetik di terminal)
        vim.keymap.set("n", "<leader>tt", function()
            require("toggleterm").toggle(1, nil, nil, "horizontal")
        end, { desc = "Terminal: Toggle bawah" })

        vim.keymap.set("n", "<leader>tz", function()
            require("toggleterm").toggle(2, nil, nil, "float")
        end, { desc = "Terminal: Toggle floating" })

        -- Leader+tv → terminal vertikal (sidebar kanan)
        vim.keymap.set("n", "<leader>tv", function()
            require("toggleterm").toggle(3, nil, nil, "vertical")
        end, { desc = "Terminal: Vertikal" })

        -- Leader+tg → Lazygit floating
        local lazygit = Terminal:new({
            cmd = "lazygit",
            direction = "float",
            float_opts = {
                border = "curved",
                width = function() return math.floor(vim.o.columns * 0.95) end,
                height = function() return math.floor(vim.o.lines * 0.90) end,
            },
            on_open = function(term)
                vim.cmd("startinsert!")
            end,
            hidden = true,
        })
        vim.keymap.set("n", "<leader>tg", function()
            lazygit:toggle()
        end, { desc = "Terminal: Lazygit" })

        -- ── Navigasi dari dalam terminal ─────────────────────────────────
        -- Gunakan <Esc><Esc> atau <C-\><C-n> untuk pindah ke Normal mode
        -- (Mencegah tombol Delete / sequence tombol di terminal memicu Esc & membatalkan mode insert)
        vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>",   { desc = "Terminal: Normal mode" })
        vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h",  { desc = "Terminal: Window kiri" })
        vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j",  { desc = "Terminal: Window bawah" })
        vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k",  { desc = "Terminal: Window atas" })
        vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l",  { desc = "Terminal: Window kanan" })
    end,
}
