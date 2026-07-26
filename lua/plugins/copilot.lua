-- lua/plugins/copilot.lua
-- GitHub Copilot Ghost Text (Autocomplete samar di buffer)

return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
        suggestion = {
            enabled = true,
            auto_trigger = true,
            debounce = 75,
            keymap = {
                accept = "<M-l>",      -- Alt + l untuk Menerima saran ghost text
                accept_word = "<M-w>", -- Alt + w untuk Menerima 1 kata
                accept_line = "<M-a>", -- Alt + a untuk Menerima 1 baris
                next = "<M-]>",        -- Alt + ] untuk Saran berikutnya
                prev = "<M-[>",        -- Alt + [ untuk Saran sebelumnya
                dismiss = "<C-]>",     -- Ctrl + ] untuk Batalkan saran
            },
        },
        panel = {
            enabled = false,
        },
        filetypes = {
            yaml = true,
            markdown = true,
            help = false,
            gitcommit = false,
            gitrebase = false,
            hgcommit = false,
            svn = false,
            cvs = false,
            ["."] = false,
        },
    },
}
