-- lua/plugins/copilot.lua
-- Official GitHub Copilot plugin (Super ringan < 1 MB, stabil & resmi dari GitHub)

return {
    "github/copilot.vim",
    cmd = "Copilot",
    event = "InsertEnter",
    init = function()
        -- Nonaktifkan pemetaan tab bawaan agar tidak bentrok dengan indentasi atau cmp
        vim.g.copilot_no_tab_map = true

        -- Shortcut yang sama persis seperti sebelumnya:
        vim.keymap.set("i", "<M-l>", 'copilot#Accept("\\<CR>")', {
            expr = true,
            replace_keycodes = false,
            desc = "Copilot: Accept ghost text",
        })
        vim.keymap.set("i", "<M-w>", "copilot#AcceptWord()", {
            expr = true,
            replace_keycodes = false,
            desc = "Copilot: Accept 1 word",
        })
        vim.keymap.set("i", "<M-a>", "copilot#AcceptLine()", {
            expr = true,
            replace_keycodes = false,
            desc = "Copilot: Accept 1 line",
        })
        vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { desc = "Copilot: Next suggestion" })
        vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", { desc = "Copilot: Prev suggestion" })
        vim.keymap.set("i", "<C-]>", "<Plug>(copilot-dismiss)", { desc = "Copilot: Dismiss" })
    end,
}

