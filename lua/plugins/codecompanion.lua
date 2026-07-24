-- lua/plugins/codecompanion.lua
-- AI Chat & Inline Edit berbasis Ollama, experience mirip VSCode Copilot Chat.
--
-- Fitur utama:
--   <leader>ac  → Toggle chat sidebar (persistent, no "press Enter" spam)
--   <leader>aa  → Actions palette (list semua aksi AI)
--   <leader>ai  → Inline edit langsung di buffer
--   <leader>ar/af/ax/ad/at/ao → Shortcut aksi koding (visual mode)
--
-- Di dalam chat buffer:
--   <C-s>  (insert)  → Kirim pesan
--   <CR>   (normal)  → Kirim pesan
--   q                → Hide/close chat
--   ga               → Ganti model / adapter

return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",  -- diperlukan untuk render Markdown di chat buffer
    },
    opts = {
        -- ─── Adapter: Ollama lokal ───────────────────────────────────────
        adapters = {
            ollama = function()
                return require("codecompanion.adapters").extend("ollama", {
                    name = "ollama",
                    env = {
                        url = "http://127.0.0.1:11434",
                    },
                    schema = {
                        model = {
                            default = "sorc/qwen3.5-claude-4.6-opus:latest",
                        },
                        num_ctx = {
                            default = 16384,
                        },
                    },
                })
            end,
        },

        -- ─── Strategi per mode ───────────────────────────────────────────
        strategies = {
            chat = {
                adapter = "ollama",
                -- Keymaps di dalam chat buffer
                keymaps = {
                    send = {
                        modes = { n = "<CR>", i = "<C-s>" },
                        description = "Kirim pesan",
                    },
                    close = {
                        modes = { n = "q" },
                        description = "Tutup chat",
                    },
                    stop = {
                        modes = { n = "<C-c>" },
                        description = "Stop generation",
                    },
                },
            },
            inline = {
                adapter = "ollama",
            },
            cmd = {
                adapter = "ollama",
            },
        },

        -- ─── Tampilan Chat Window ────────────────────────────────────────
        display = {
            chat = {
                -- Sidebar kanan, mirip Copilot Chat di VSCode
                window = {
                    layout = "vertical",   -- "vertical" | "horizontal" | "float" | "buffer"
                    position = "right",
                    width = 0.35,          -- 35% lebar layar
                    height = 1,
                    border = "rounded",
                    relative = "editor",
                },
                -- Tampilkan nama model di header chat
                show_header_separator = true,
                show_token_count = true,
                show_settings = false,
            },
            inline = {
                layout = "vertical",
            },
            action_palette = {
                width = 95,
                height = 10,
                prompt = "  Pilih Aksi AI > ",
                provider = "default",
            },
        },

        -- ─── Prompt Library (shortcut koding) ───────────────────────────
        prompt_library = {
            ["Review Code"] = {
                strategy = "chat",
                description = "Review kode secara mendalam",
                opts = {
                    short_name = "review",
                    auto_submit = true,
                },
                prompts = {
                    {
                        role = "user",
                        content = function(context)
                            local code = require("codecompanion.helpers.actions").get_code(
                                context.start_line,
                                context.end_line
                            )
                            return string.format(
                                "Review kode %s berikut secara mendalam. Identifikasi bug, isu performa, celah keamanan, dan beri saran perbaikan dengan penjelasan:\n\n```%s\n%s\n```",
                                context.filetype, context.filetype, code
                            )
                        end,
                        opts = { contains_code = true },
                    },
                },
            },
            ["Fix Code"] = {
                strategy = "inline",
                description = "Perbaiki bugs di kode yang dipilih",
                opts = {
                    short_name = "fix",
                    auto_submit = true,
                    placement = "replace",
                },
                prompts = {
                    {
                        role = "system",
                        content = "Kamu adalah expert programmer. Perbaiki bug dalam kode yang diberikan. Output HANYA kode yang sudah diperbaiki, tanpa penjelasan tambahan.",
                    },
                    {
                        role = "user",
                        content = function(context)
                            local code = require("codecompanion.helpers.actions").get_code(
                                context.start_line,
                                context.end_line
                            )
                            return string.format(
                                "Perbaiki bugs dalam kode %s berikut:\n\n```%s\n%s\n```",
                                context.filetype, context.filetype, code
                            )
                        end,
                        opts = { contains_code = true },
                    },
                },
            },
            ["Explain Code"] = {
                strategy = "chat",
                description = "Jelaskan kode yang dipilih",
                opts = {
                    short_name = "explain",
                    auto_submit = true,
                },
                prompts = {
                    {
                        role = "user",
                        content = function(context)
                            local code = require("codecompanion.helpers.actions").get_code(
                                context.start_line,
                                context.end_line
                            )
                            return string.format(
                                "Jelaskan kode %s berikut secara step-by-step dengan bahasa yang mudah dipahami:\n\n```%s\n%s\n```",
                                context.filetype, context.filetype, code
                            )
                        end,
                        opts = { contains_code = true },
                    },
                },
            },
            ["Add Documentation"] = {
                strategy = "inline",
                description = "Tambahkan komentar/dokumentasi ke kode",
                opts = {
                    short_name = "docs",
                    auto_submit = true,
                    placement = "replace",
                },
                prompts = {
                    {
                        role = "system",
                        content = "Tambahkan komentar dan dokumentasi yang jelas ke kode. Jaga kode asli tetap utuh, hanya tambahkan komentar. Output HANYA kode dengan komentar.",
                    },
                    {
                        role = "user",
                        content = function(context)
                            local code = require("codecompanion.helpers.actions").get_code(
                                context.start_line,
                                context.end_line
                            )
                            return string.format(
                                "Tambahkan dokumentasi ke kode %s berikut:\n\n```%s\n%s\n```",
                                context.filetype, context.filetype, code
                            )
                        end,
                        opts = { contains_code = true },
                    },
                },
            },
            ["Generate Tests"] = {
                strategy = "chat",
                description = "Generate unit tests untuk kode yang dipilih",
                opts = {
                    short_name = "tests",
                    auto_submit = true,
                },
                prompts = {
                    {
                        role = "user",
                        content = function(context)
                            local code = require("codecompanion.helpers.actions").get_code(
                                context.start_line,
                                context.end_line
                            )
                            return string.format(
                                "Generate unit tests yang komprehensif untuk kode %s berikut:\n\n```%s\n%s\n```",
                                context.filetype, context.filetype, code
                            )
                        end,
                        opts = { contains_code = true },
                    },
                },
            },
            ["Refactor Code"] = {
                strategy = "inline",
                description = "Refactor dan optimasi kode yang dipilih",
                opts = {
                    short_name = "refactor",
                    auto_submit = true,
                    placement = "replace",
                },
                prompts = {
                    {
                        role = "system",
                        content = "Refactor kode untuk keterbacaan, performa, dan maintainability yang lebih baik. Output HANYA kode yang sudah direfactor.",
                    },
                    {
                        role = "user",
                        content = function(context)
                            local code = require("codecompanion.helpers.actions").get_code(
                                context.start_line,
                                context.end_line
                            )
                            return string.format(
                                "Refactor kode %s berikut:\n\n```%s\n%s\n```",
                                context.filetype, context.filetype, code
                            )
                        end,
                        opts = { contains_code = true },
                    },
                },
            },
        },
    },
    keys = {
        -- Toggle chat sidebar (mirip Copilot Chat VSCode)
        { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>",  mode = { "n", "v" }, desc = "AI: Toggle chat sidebar" },
        -- Actions palette
        { "<leader>aa", "<cmd>CodeCompanionActions<CR>",      mode = { "n", "v" }, desc = "AI: Actions palette" },
        -- Inline edit di buffer
        { "<leader>ai", "<cmd>CodeCompanion<CR>",             mode = { "n", "v" }, desc = "AI: Inline edit" },
        -- Shortcut koding (visual mode)
        { "<leader>ar", "<cmd>CodeCompanionChat review<CR>",  mode = "v",          desc = "AI: Review code" },
        { "<leader>af", "<cmd>CodeCompanion fix<CR>",         mode = "v",          desc = "AI: Fix bugs" },
        { "<leader>ax", "<cmd>CodeCompanionChat explain<CR>", mode = "v",          desc = "AI: Explain code" },
        { "<leader>ad", "<cmd>CodeCompanion docs<CR>",        mode = "v",          desc = "AI: Add documentation" },
        { "<leader>at", "<cmd>CodeCompanionChat tests<CR>",   mode = "v",          desc = "AI: Generate tests" },
        { "<leader>ao", "<cmd>CodeCompanion refactor<CR>",    mode = "v",          desc = "AI: Refactor code" },
        -- Tambah buffer aktif ke chat sebagai context
        { "<leader>ab", "<cmd>CodeCompanionChat Add<CR>",     mode = { "n", "v" }, desc = "AI: Add buffer to chat" },
    },
}
