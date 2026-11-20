-- lua/ai/prompts.lua
-- Prompt library CodeCompanion (review, fix, explain, docs, tests, refactor, beautify).

local INLINE_RULES = [[

Instruksi tambahan:
1. Perhatikan nomor baris bisa bergeser setelah tiap edit pada multi-edit di satu file.
2. Jika tidak yakin soal API/library/parameter, katakan eksplisit — jangan mengarang.
3. Jika instruksi ambigu, ambil satu asumsi wajar, sebutkan singkat, lalu lanjutkan.
4. Hindari duplikasi kode (DRY) — kalau ada logika yang jelas berulang dalam scope yang diedit, ekstrak jadi fungsi/helper.
5. Ikuti gaya & konvensi kode yang sudah ada di file (indentasi, penamaan, struktur import, dll), jangan pakai gaya sendiri.
6. Jangan menambah dependency/library baru tanpa alasan jelas, dan jangan hapus fungsionalitas yang sudah ada kecuali memang diminta.]]

-- ─── Helper bersama: ambil kode yang dipilih (visual) atau seluruh buffer ──
local function get_selected_code(context)
    local start_line = context.is_visual and context.start_line or 1
    local end_line = context.is_visual and context.end_line or vim.api.nvim_buf_line_count(context.bufnr)
    return start_line, end_line, require("codecompanion.helpers.code").get_code(start_line, end_line)
end

-- Prompt-library generator: setiap prompt sebelumnya menduplikasi logika
-- "ambil kode terpilih lalu format jadi code block" — sekarang jadi satu factory.
local function code_prompt(template)
    return function(context)
        local _, _, code = get_selected_code(context)
        return string.format(template, context.filetype, context.filetype, code)
    end
end

return {
            ["Review Code"] = {
                strategy = "chat",
                description = "Review kode secara mendalam",
                opts = { alias = "review", auto_submit = true },
                prompts = {
                    {
                        role = "user",
                        content = code_prompt(
                            "Review kode %s berikut secara mendalam. Identifikasi bug, isu performa, celah keamanan, dan beri saran perbaikan dengan penjelasan:\n\n```%s\n%s\n```"
                        ),
                        opts = { contains_code = true },
                    },
                },
            },
            ["Fix Code"] = {
                strategy = "inline",
                description = "Perbaiki bugs di kode yang dipilih",
                opts = { alias = "fix", auto_submit = true, placement = "replace" },
                prompts = {
                    {
                        role = "system",
                        content = "Kamu adalah expert programmer. Perbaiki bug dalam kode yang diberikan tanpa mengubah bagian lain yang tidak terkait dengan bug tersebut. Output HANYA kode yang sudah diperbaiki, tanpa penjelasan tambahan." .. INLINE_RULES,
                    },
                    {
                        role = "user",
                        content = code_prompt("Perbaiki bugs dalam kode %s berikut:\n\n```%s\n%s\n```"),
                        opts = { contains_code = true },
                    },
                },
            },
            ["Explain Code"] = {
                strategy = "chat",
                description = "Jelaskan kode yang dipilih",
                opts = { alias = "explain", auto_submit = true },
                prompts = {
                    {
                        role = "user",
                        content = code_prompt(
                            "Jelaskan kode %s berikut secara step-by-step dengan bahasa yang mudah dipahami:\n\n```%s\n%s\n```"
                        ),
                        opts = { contains_code = true },
                    },
                },
            },
            ["Add Documentation"] = {
                strategy = "inline",
                description = "Tambahkan komentar/dokumentasi ke kode",
                opts = { alias = "docs", auto_submit = true, placement = "replace" },
                prompts = {
                    {
                        role = "system",
                        content = "Tambahkan komentar dan dokumentasi yang jelas ke kode. Jaga kode asli tetap utuh — jangan ubah logika, struktur, atau formatting, hanya tambahkan komentar. Output HANYA kode dengan komentar." .. INLINE_RULES,
                    },
                    {
                        role = "user",
                        content = code_prompt("Tambahkan dokumentasi ke kode %s berikut:\n\n```%s\n%s\n```"),
                        opts = { contains_code = true },
                    },
                },
            },
            ["Generate Tests"] = {
                strategy = "chat",
                description = "Generate unit tests untuk kode yang dipilih",
                opts = { alias = "tests", auto_submit = true },
                prompts = {
                    {
                        role = "user",
                        content = code_prompt(
                            "Generate unit tests yang komprehensif untuk kode %s berikut:\n\n```%s\n%s\n```"
                        ),
                        opts = { contains_code = true },
                    },
                },
            },
            ["Refactor Code"] = {
                strategy = "inline",
                description = "Refactor dan optimasi kode yang dipilih",
                opts = { alias = "refactor", auto_submit = true, placement = "replace" },
                prompts = {
                    {
                        role = "system",
                        content = "Refactor kode untuk keterbacaan, performa, dan maintainability yang lebih baik, termasuk menghilangkan duplikasi kode (DRY) jika ditemukan. Pertahankan behavior/fungsionalitas asli — jangan ubah logika bisnis. Output HANYA kode yang sudah direfactor." .. INLINE_RULES,
                    },
                    {
                        role = "user",
                        content = code_prompt("Refactor kode %s berikut:\n\n```%s\n%s\n```"),
                        opts = { contains_code = true },
                    },
                },
            },
            ["Beautify Code"] = {
                strategy = "inline",
                description = "Rapikan spacing, indentasi, dan keindahan kode (Code Beauty)",
                opts = { alias = "beautify", auto_submit = true, placement = "replace" },
                prompts = {
                    {
                        role = "system",
                        content = "Rapikan indentasi, spacing, style, penamaan, dan tata letak kode agar lebih bersih, mudah dibaca, dan mengikuti standar style guide bahasa pemrograman terkait, tanpa mengubah logika kode. Output HANYA kode yang sudah dirapikan, tanpa penjelasan tambahan." .. INLINE_RULES,
                    },
                    {
                        role = "user",
                        content = code_prompt("Rapikan spacing, indentasi, dan perindah kode %s berikut:\n\n```%s\n%s\n```"),
                        opts = { contains_code = true },
                    },
                },
            },
}
