-- lua/plugins/codecompanion.lua
-- AI Chat & Inline Edit berbasis Ollama, experience mirip VSCode Copilot Chat.
--
-- MIGRATED: skema `strategies` (lama) -> `interactions` (v19+, commit cedbead8 / 2026-07-24).
-- Requirement: Neovim >= 0.11.0 untuk versi ini (naik dari 0.9 di versi lama).
-- Cek dengan: nvim --version
--
-- Fitur utama:
--   <leader>ac  → Toggle chat sidebar (persistent, no "press Enter" spam)
--   <leader>aa  → Actions palette (list semua aksi AI)
--   <leader>ai  → Inline edit langsung di buffer
--   <leader>ab  → Kirim buffer file aktif ke chat sebagai context
--   <leader>aD  → Kirim semua file dalam directory ke chat (tambah ! untuk rekursif)
--   <leader>ag  → Kirim laporan Graphify (GRAPH_REPORT.md) ke chat sebagai context
--   <leader>ar/af/ae/ad/at/ao → Shortcut aksi koding (normal & visual mode)
--
-- Di dalam chat buffer:
--   <C-s>  (insert)  → Kirim pesan
--   <CR>   (normal)  → Kirim pesan
--   q                → Hide/close chat
--   ga               → Accept inline diff edit
--   gr               → Reject inline diff edit

-- Instruksi tambahan yang di-append ke system prompt setiap prompt library
-- ber-strategy "inline" (Fix Code, Add Documentation, Refactor Code).
-- NOTE: codecompanion TIDAK punya `interactions.inline.opts.system_prompt`
-- global (sudah dicek ke dokumentasi resmi, key itu tidak ada) — jadi ini
-- satu-satunya cara resmi menyuntikkan instruksi tambahan untuk inline edit,
-- yaitu per-prompt lewat prompt_library. `<leader>ai` polos (:CodeCompanion
-- tanpa alias) TIDAK ikut kena rules ini karena tidak lewat prompt_library.
local INLINE_RULES = [[

Instruksi tambahan:
1. Perhatikan nomor baris bisa bergeser setelah tiap edit pada multi-edit di satu file.
2. Jika tidak yakin soal API/library/parameter, katakan eksplisit — jangan mengarang.
3. Jika instruksi ambigu, ambil satu asumsi wajar, sebutkan singkat, lalu lanjutkan.]]

return {
    "olimorris/codecompanion.nvim",
    -- NOTE resmi dari maintainer: "To avoid breaking changes, it is
    -- recommended to pin the plugin to a specific release." Kalau tidak
    -- di-pin, config ini bisa lagi-lagi rusak diam-diam di rename API
    -- berikutnya. Uncomment baris di bawah untuk pin ke versi ini:
    -- version = "^19.0.0",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",           -- diperlukan untuk render Markdown di chat buffer
        "ravitemer/codecompanion-history.nvim",      -- history: save, browse & restore chat sessions
    },
    opts = {
        -- ─── Adapter: Ollama lokal ───────────────────────────────────────
        -- (struktur adapters.http TIDAK berubah di rename strategies->interactions)
        adapters = {
            http = {
                ollama = function()
                    return require("codecompanion.adapters").extend("ollama", {
                        name = "ollama",
                        env = {
                            url = "http://192.168.0.100:11434",
                        },
                        schema = {
                            model = {
                                -- Menggunakan model 7B agar 100% offload ke GPU 8GB (kinerja kilat)
                                default = "qwen2.5-coder:14b",
                            },
                            num_ctx = {
                                -- Diturunkan ke 8192 agar tidak memakan sisa VRAM berlebih
                                default = 8192,
                            },
                        },
                    })
                end,
                anthropic = function()
                    return require("codecompanion.adapters").extend("anthropic", {
                        env = {
                            api_key = "ANTHROPIC_API_KEY",
                        },
                    })
                end,
            },
        },

        -- ─── Interactions per mode (dulu bernama `strategies`) ────────────
        interactions = {
            chat = {
                adapter = "ollama", -- Ganti ke "anthropic" jika ingin menggunakan Claude

                -- System prompt untuk chat buffer & agentic tool-calling (@editor dll).
                -- Ini yang benar-benar dibaca plugin (bukan sejajar dengan `chat`,
                -- tapi nested di dalamnya) — lihat interactions.chat.opts.system_prompt
                -- di dokumentasi resmi.
                opts = {
                    system_prompt = function(ctx)
                        return ctx.default_system_prompt .. [[

Instruksi tambahan:
1. Untuk task yang menyentuh >1 file/fungsi, buat rencana singkat sebelum eksekusi.
2. Perhatikan nomor baris bisa bergeser setelah tiap edit pada multi-edit di satu file.
3. Jika tidak yakin soal API/library/parameter, katakan eksplisit — jangan mengarang.
4. Jika instruksi ambigu, ambil satu asumsi wajar, sebutkan singkat, lalu lanjutkan.
5. Setelah selesai, berhenti — jangan mengulang rekap dengan kalimat berbeda.
]]
                    end,
                },

                -- Keymaps di dalam chat buffer (send/close/stop) TETAP di sini,
                -- tidak ikut pindah ke `shared` — hanya keymap accept/reject
                -- diff yang pindah ke interactions.shared.keymaps di bawah.
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
            -- Accept/reject keymap untuk diff hasil edit (inline & agentic tools).
            -- Sebelumnya default lama adalah ga/gr untuk inline — dipertahankan
            -- eksplisit di sini supaya tidak berubah walau ada rename lanjutan.
            shared = {
                keymaps = {
                    accept_change = {
                        callback = "keymaps.accept_change",
                        modes = { n = "ga" },
                        description = "Accept the suggested change",
                    },
                    reject_change = {
                        callback = "keymaps.reject_change",
                        modes = { n = "gr" },
                        opts = { nowait = true },
                        description = "Reject the suggested change",
                    },
                },
            },
        },

        -- ─── Chat History (auto-save & restore) ──────────────────────────
        -- (tidak terdampak rename strategies->interactions)
        extensions = {
            history = {
                enabled = true,
                opts = {
                    keymap = "gh",
                    save_chat_keymap = "sc",
                    auto_save = true,
                    expiration_days = 30,
                    picker = "telescope",
                    auto_generate_title = true,
                    title_generation_opts = {
                        adapter = nil,
                        model = nil,
                        refresh_every_n_prompts = 0,
                        max_refreshes = 1,
                    },
                    continue_last_chat = false,
                    delete_on_clearing_chat = false,
                    dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
                    enable_logging = false,
                },
            },
        },

        -- ─── Tampilan Chat Window ────────────────────────────────────────
        display = {
            chat = {
                window = {
                    layout = "vertical",
                    position = "right",
                    width = 0.35,
                    height = 1,
                    border = "rounded",
                    relative = "editor",
                },
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
                opts = { alias = "review", auto_submit = true },
                prompts = {
                    {
                        role = "user",
                        content = function(context)
                            local start_line = context.is_visual and context.start_line or 1
                            local end_line = context.is_visual and context.end_line or vim.api.nvim_buf_line_count(context.bufnr)
                            local code = require("codecompanion.helpers.code").get_code(start_line, end_line)
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
                opts = { alias = "fix", auto_submit = true, placement = "replace" },
                prompts = {
                    {
                        role = "system",
                        content = "Kamu adalah expert programmer. Perbaiki bug dalam kode yang diberikan. Output HANYA kode yang sudah diperbaiki, tanpa penjelasan tambahan." .. INLINE_RULES,
                    },
                    {
                        role = "user",
                        content = function(context)
                            local start_line = context.is_visual and context.start_line or 1
                            local end_line = context.is_visual and context.end_line or vim.api.nvim_buf_line_count(context.bufnr)
                            local code = require("codecompanion.helpers.code").get_code(start_line, end_line)
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
                opts = { alias = "explain", auto_submit = true },
                prompts = {
                    {
                        role = "user",
                        content = function(context)
                            local start_line = context.is_visual and context.start_line or 1
                            local end_line = context.is_visual and context.end_line or vim.api.nvim_buf_line_count(context.bufnr)
                            local code = require("codecompanion.helpers.code").get_code(start_line, end_line)
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
                opts = { alias = "docs", auto_submit = true, placement = "replace" },
                prompts = {
                    {
                        role = "system",
                        content = "Tambahkan komentar dan dokumentasi yang jelas ke kode. Jaga kode asli tetap utuh, hanya tambahkan komentar. Output HANYA kode dengan komentar." .. INLINE_RULES,
                    },
                    {
                        role = "user",
                        content = function(context)
                            local start_line = context.is_visual and context.start_line or 1
                            local end_line = context.is_visual and context.end_line or vim.api.nvim_buf_line_count(context.bufnr)
                            local code = require("codecompanion.helpers.code").get_code(start_line, end_line)
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
                opts = { alias = "tests", auto_submit = true },
                prompts = {
                    {
                        role = "user",
                        content = function(context)
                            local start_line = context.is_visual and context.start_line or 1
                            local end_line = context.is_visual and context.end_line or vim.api.nvim_buf_line_count(context.bufnr)
                            local code = require("codecompanion.helpers.code").get_code(start_line, end_line)
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
                opts = { alias = "refactor", auto_submit = true, placement = "replace" },
                prompts = {
                    {
                        role = "system",
                        content = "Refactor kode untuk keterbacaan, performa, dan maintainability yang lebih baik. Output HANYA kode yang sudah direfactor." .. INLINE_RULES,
                    },
                    {
                        role = "user",
                        content = function(context)
                            local start_line = context.is_visual and context.start_line or 1
                            local end_line = context.is_visual and context.end_line or vim.api.nvim_buf_line_count(context.bufnr)
                            local code = require("codecompanion.helpers.code").get_code(start_line, end_line)
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
        { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>",  mode = { "n", "v" }, desc = "AI: Toggle chat sidebar" },
        { "<leader>aa", "<cmd>CodeCompanionActions<CR>",      mode = { "n", "v" }, desc = "AI: Actions palette" },
        { "<leader>ai", "<cmd>CodeCompanion<CR>",             mode = { "n", "v" }, desc = "AI: Inline edit" },
        {
            "<leader>aT",
            function()
                -- Ini SEKARANG konsisten dengan opts.interactions di atas
                -- (sebelumnya file ini baca/tulis config.interactions padahal
                -- setup()-nya masih pakai key `strategies` -> toggle tidak
                -- benar-benar mengubah adapter aktif).
                local config = require("codecompanion.config")
                local current = config.interactions.chat.adapter
                local target = (current == "ollama") and "anthropic" or "ollama"

                config.interactions.chat.adapter = target
                config.interactions.inline.adapter = target
                config.interactions.cmd.adapter = target

                local name = (target == "ollama") and "Ollama (Qwen)" or "Claude (Anthropic)"
                vim.notify("AI Adapter switched to: " .. name, vim.log.levels.INFO, { title = "CodeCompanion" })
            end,
            mode = { "n", "v" },
            desc = "AI: Toggle Ollama / Claude",
        },
        { "<leader>ar", function() require("codecompanion").prompt("review") end,   mode = { "n", "v" }, desc = "AI: Review code" },
        { "<leader>af", function() require("codecompanion").prompt("fix") end,      mode = { "n", "v" }, desc = "AI: Fix bugs" },
        { "<leader>ae", function() require("codecompanion").prompt("explain") end,  mode = { "n", "v" }, desc = "AI: Explain code" },
        { "<leader>ad", function() require("codecompanion").prompt("docs") end,     mode = { "n", "v" }, desc = "AI: Add documentation" },
        { "<leader>at", function() require("codecompanion").prompt("tests") end,    mode = { "n", "v" }, desc = "AI: Generate tests" },
        { "<leader>ao", function() require("codecompanion").prompt("refactor") end, mode = { "n", "v" }, desc = "AI: Refactor code" },

        -- Tambah file code ke chat sebagai context
        {
            "<leader>ab",
            function()
                local run_add
                run_add = function(is_retry)
                    local target_buf, target_win
                    local cur_buf = vim.api.nvim_get_current_buf()

                    local function is_code_buffer(buf)
                        local ft = vim.bo[buf].filetype
                        local bt = vim.bo[buf].buftype
                        return ft ~= "codecompanion" and ft ~= "" and bt == "" 
                            and ft ~= "neo-tree" and ft ~= "NvimTree" and ft ~= "toggleterm" 
                            and ft ~= "qf" and ft ~= "help"
                    end

                    if is_code_buffer(cur_buf) then
                        target_buf = cur_buf
                    else
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            local wbuf = vim.api.nvim_win_get_buf(win)
                            if is_code_buffer(wbuf) then
                                target_buf = wbuf
                                target_win = win
                                break
                            end
                        end
                    end

                    if not target_buf then
                        vim.notify("⚠ Buka file code di split dulu, lalu tekan <leader>ab.", vim.log.levels.WARN, { title = "CodeCompanion" })
                        return
                    end

                    local lines    = vim.api.nvim_buf_get_lines(target_buf, 0, -1, false)
                    local filepath = vim.api.nvim_buf_get_name(target_buf)
                    local filename = vim.fn.fnamemodify(filepath, ":~:.")
                    local ft       = vim.bo[target_buf].filetype

                    local chat_win
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "codecompanion" then
                            chat_win = win
                            break
                        end
                    end

                    if not chat_win then
                        vim.cmd("CodeCompanionChat Toggle")
                        vim.defer_fn(function() run_add(true) end, 300)
                        return
                    end

                    local chat_buf = vim.api.nvim_win_get_buf(chat_win)
                    local code_lines = vim.list_extend({ "", "File: `" .. filename .. "`", "```" .. ft }, lines)
                    vim.list_extend(code_lines, { "```", "" })

                    local last = vim.api.nvim_buf_line_count(chat_buf)
                    vim.api.nvim_buf_set_lines(chat_buf, last, -1, false, code_lines)

                    vim.api.nvim_set_current_win(chat_win)
                    vim.api.nvim_win_set_cursor(chat_win, { vim.api.nvim_buf_line_count(chat_buf), 0 })
                    vim.cmd("startinsert!")

                    vim.notify("✓ " .. filename .. " disertakan ke chat", vim.log.levels.INFO, { title = "CodeCompanion" })
                end
                run_add(false)
            end,
            mode = { "n", "v" },
            desc = "AI: Add buffer to chat",
        },

        -- Tambah SEMUA file dalam sebuah directory ke chat sebagai context
        {
            "<leader>aD",
            function()
                local function inject_file_to_chat(chat_buf, chat_win, filepath)
                    local lines = vim.fn.readfile(filepath)
                    if not lines or #lines == 0 then return false end
                    local relpath = vim.fn.fnamemodify(filepath, ":~:.")
                    local ext     = vim.fn.fnamemodify(filepath, ":e")
                    local ft_map  = { lua="lua", py="python", js="javascript", ts="typescript", tsx="tsx", jsx="jsx", sh="bash", go="go", rs="rust", toml="toml", yaml="yaml", yml="yaml", json="json", md="markdown", html="html", css="css", c="c", cpp="cpp" }
                    local ft = ft_map[ext] or ext or "text"

                    local code_lines = { "", "File: `" .. relpath .. "`", "```" .. ft }
                    vim.list_extend(code_lines, lines)
                    vim.list_extend(code_lines, { "```", "" })

                    local last = vim.api.nvim_buf_line_count(chat_buf)
                    vim.api.nvim_buf_set_lines(chat_buf, last, -1, false, code_lines)
                    return true
                end

                local function collect_files(dir, recursive)
                    local cmd = recursive and string.format("find '%s' -type f -not -path '*/.git/*' | sort", dir) or string.format("find '%s' -maxdepth 1 -type f | sort", dir)
                    return vim.fn.systemlist(cmd)
                end

                local chat_win, chat_buf
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "codecompanion" then
                        chat_win = win
                        chat_buf = vim.api.nvim_win_get_buf(win)
                        break
                    end
                end

                if not chat_win then
                    vim.cmd("CodeCompanionChat Toggle")
                    vim.notify("Chat dibuka. Tekan <leader>aD lagi untuk memilih direktori.", vim.log.levels.INFO, { title = "CodeCompanion" })
                    return
                end

                local default_dir = vim.fn.getcwd()
                vim.ui.input({ prompt = "📁 Directory path (tambahkan ! di akhir untuk rekursif): ", default = default_dir, completion = "dir" }, function(input)
                    if not input or input == "" then return end

                    local recursive = vim.endswith(input, "!")
                    local dir_path  = recursive and input:sub(1, -2) or input
                    dir_path        = vim.fn.expand(dir_path)

                    if vim.fn.isdirectory(dir_path) == 0 then
                        vim.notify("⚠ Bukan direktori valid: " .. dir_path, vim.log.levels.ERROR, { title = "CodeCompanion" })
                        return
                    end

                    local files = collect_files(dir_path, recursive)
                    if #files == 0 then
                        vim.notify("⚠ Tidak ada file di: " .. dir_path, vim.log.levels.WARN, { title = "CodeCompanion" })
                        return
                    end

                    local rel_dir = vim.fn.fnamemodify(dir_path, ":~:.")
                    local mode    = recursive and " (rekursif)" or " (flat)"
                    local header  = { "", "---", "📁 **Directory: `" .. rel_dir .. "`**" .. mode .. " — " .. #files .. " file(s)", "---", "" }
                    local last = vim.api.nvim_buf_line_count(chat_buf)
                    vim.api.nvim_buf_set_lines(chat_buf, last, -1, false, header)

                    local injected, skipped = 0, {}
                    for _, fpath in ipairs(files) do
                        local fsize = vim.fn.getfsize(fpath)
                        if fsize > 0 and fsize < 1024 * 1024 then
                            if inject_file_to_chat(chat_buf, chat_win, fpath) then injected = injected + 1 end
                        else
                            table.insert(skipped, vim.fn.fnamemodify(fpath, ":t"))
                        end
                    end

                    vim.api.nvim_set_current_win(chat_win)
                    vim.api.nvim_win_set_cursor(chat_win, { vim.api.nvim_buf_line_count(chat_buf), 0 })
                    vim.cmd("startinsert!")

                    local msg = string.format("✓ %d file dari `%s` disertakan ke chat", injected, rel_dir)
                    if #skipped > 0 then msg = msg .. "\n⚠ Dilewati (" .. #skipped .. " file besar/biner): " .. table.concat(skipped, ", ") end
                    vim.notify(msg, vim.log.levels.INFO, { title = "CodeCompanion" })
                end)
            end,
            mode = { "n", "v" },
            desc = "AI: Add directory files to chat",
        },

        -- ─── INJEKSI GRAPHIFY KE CHAT ─────────────────────────────
        {
            "<leader>ag",
            function()
                local graph_file = vim.fn.getcwd() .. "/graphify-out/GRAPH_REPORT.md"

                if vim.fn.filereadable(graph_file) == 0 then
                    vim.notify(
                        "⚠ GRAPH_REPORT.md tidak ditemukan! Jalankan `graphify .` di terminal (root project) terlebih dahulu.",
                        vim.log.levels.WARN,
                        { title = "CodeCompanion" }
                    )
                    return
                end

                local lines = vim.fn.readfile(graph_file)
                if not lines or #lines == 0 then return end

                local chat_win, chat_buf
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "codecompanion" then
                        chat_win = win
                        chat_buf = vim.api.nvim_win_get_buf(win)
                        break
                    end
                end

                if not chat_win then
                    vim.cmd("CodeCompanionChat Toggle")
                    vim.defer_fn(function()
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>ag", true, false, true), "m", true)
                    end, 300)
                    return
                end

                local code_lines = {
                    "",
                    "---",
                    "📊 **Context: Graphify Architecture Report**",
                    "---",
                    "Saya melampirkan laporan arsitektur codebase ini. Tolong jadikan sebagai referensi utama untuk memahami relasi antar modul sebelum saya memberikan instruksi selanjutnya.",
                    ""
                }

                vim.list_extend(code_lines, lines)
                vim.list_extend(code_lines, { "", "---", "" })

                local last = vim.api.nvim_buf_line_count(chat_buf)
                vim.api.nvim_buf_set_lines(chat_buf, last, -1, false, code_lines)

                vim.api.nvim_set_current_win(chat_win)
                vim.api.nvim_win_set_cursor(chat_win, { vim.api.nvim_buf_line_count(chat_buf), 0 })
                vim.cmd("startinsert!")

                vim.notify("✓ Laporan Graphify berhasil ditambahkan ke chat", vim.log.levels.INFO, { title = "CodeCompanion" })
            end,
            mode = { "n", "v" },
            desc = "AI: Add Graphify Report to chat",
        },
    },
}
