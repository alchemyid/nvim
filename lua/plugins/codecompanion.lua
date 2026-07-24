-- lua/plugins/codecompanion.lua
-- AI Chat & Inline Edit berbasis Ollama, experience mirip VSCode Copilot Chat.
--
-- Fitur utama:
--   <leader>ac  → Toggle chat sidebar (persistent, no "press Enter" spam)
--   <leader>aa  → Actions palette (list semua aksi AI)
--   <leader>ai  → Inline edit langsung di buffer
--   <leader>ab  → Kirim buffer file aktif ke chat sebagai context
--   <leader>aD  → Kirim semua file dalam directory ke chat (tambah ! untuk rekursif)
--   <leader>ar/af/ae/ad/at/ao → Shortcut aksi koding (normal & visual mode)
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
        "nvim-treesitter/nvim-treesitter",           -- diperlukan untuk render Markdown di chat buffer
        "ravitemer/codecompanion-history.nvim",      -- history: save, browse & restore chat sessions
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
            anthropic = function()
                return require("codecompanion.adapters").extend("anthropic", {
                    env = {
                        api_key = "ANTHROPIC_API_KEY",
                    },
                })
            end,
        },

        -- ─── Strategi per mode ───────────────────────────────────────────
        strategies = {
            chat = {
                adapter = "ollama", -- Ganti ke "anthropic" jika ingin menggunakan Claude
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
                adapter = "ollama", -- Ganti ke "anthropic" jika ingin menggunakan Claude
            },
            cmd = {
                adapter = "ollama", -- Ganti ke "anthropic" jika ingin menggunakan Claude
            },
        },

        -- ─── Chat History (auto-save & restore) ──────────────────────────
        extensions = {
            history = {
                enabled = true,
                opts = {
                    -- gh → buka history browser dari dalam chat buffer
                    keymap = "gh",
                    -- sc → simpan chat secara manual (jika auto_save = false)
                    save_chat_keymap = "sc",
                    -- Simpan otomatis setiap kali ada response dari AI
                    auto_save = true,
                    -- Hapus otomatis setelah N hari (0 = tidak pernah dihapus)
                    expiration_days = 30,
                    -- Gunakan Telescope untuk browse history
                    picker = "telescope",
                    -- Generate judul otomatis dari isi percakapan
                    auto_generate_title = true,
                    title_generation_opts = {
                        -- Pakai model yang sama dengan chat
                        adapter = nil,
                        model = nil,
                        -- Refresh judul setiap 3 prompt (0 = tidak pernah refresh)
                        refresh_every_n_prompts = 0,
                        max_refreshes = 1,
                    },
                    -- Lanjutkan chat terakhir saat buka Neovim
                    continue_last_chat = false,
                    -- Hapus dari history saat chat di-clear dengan gx
                    delete_on_clearing_chat = false,
                    -- Lokasi penyimpanan history
                    dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
                    enable_logging = false,
                },
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
                    alias = "review",
                    auto_submit = true,
                },
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
                opts = {
                    alias = "fix",
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
                opts = {
                    alias = "explain",
                    auto_submit = true,
                },
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
                opts = {
                    alias = "docs",
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
                opts = {
                    alias = "tests",
                    auto_submit = true,
                },
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
                opts = {
                    alias = "refactor",
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
        -- Toggle chat sidebar (mirip Copilot Chat VSCode)
        { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>",  mode = { "n", "v" }, desc = "AI: Toggle chat sidebar" },
        -- Actions palette
        { "<leader>aa", "<cmd>CodeCompanionActions<CR>",      mode = { "n", "v" }, desc = "AI: Actions palette" },
        -- Inline edit di buffer
        { "<leader>ai", "<cmd>CodeCompanion<CR>",             mode = { "n", "v" }, desc = "AI: Inline edit" },
        -- Toggle adapter antara Ollama dan Claude (Anthropic)
        {
            "<leader>aT",
            function()
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
        -- Shortcut koding (Normal & Visual mode)
        { "<leader>ar", function() require("codecompanion").prompt("review") end,   mode = { "n", "v" }, desc = "AI: Review code" },
        { "<leader>af", function() require("codecompanion").prompt("fix") end,      mode = { "n", "v" }, desc = "AI: Fix bugs" },
        { "<leader>ae", function() require("codecompanion").prompt("explain") end,  mode = { "n", "v" }, desc = "AI: Explain code" },
        { "<leader>ad", function() require("codecompanion").prompt("docs") end,     mode = { "n", "v" }, desc = "AI: Add documentation" },
        { "<leader>at", function() require("codecompanion").prompt("tests") end,    mode = { "n", "v" }, desc = "AI: Generate tests" },
        { "<leader>ao", function() require("codecompanion").prompt("refactor") end, mode = { "n", "v" }, desc = "AI: Refactor code" },
        -- Tambah file code ke chat sebagai context (baca konten langsung, bypass bug Add)
        {
            "<leader>ab",
            function()
                local run_add
                run_add = function(is_retry)
                    -- ── Tentukan buffer mana yang akan disertakan ────────────────
                    local target_buf, target_win
                    local cur_buf = vim.api.nvim_get_current_buf()

                    -- Cek apakah buffer saat ini adalah buffer kode normal (buftype kosong & filetype bukan utility/special)
                    local function is_code_buffer(buf)
                        local ft = vim.bo[buf].filetype
                        local bt = vim.bo[buf].buftype
                        return ft ~= "codecompanion"
                            and ft ~= ""
                            and bt == ""
                            and ft ~= "neo-tree"
                            and ft ~= "NvimTree"
                            and ft ~= "toggleterm"
                            and ft ~= "qf"
                            and ft ~= "help"
                    end

                    if is_code_buffer(cur_buf) then
                        -- Sedang fokus di file code → pakai buffer ini
                        target_buf = cur_buf
                    else
                        -- Sedang di chat/utility → cari file code di window lain
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
                        vim.notify(
                            "⚠  Buka file code di split (`:vsp file`) dulu,\n" ..
                            "lalu tekan <leader>ab. Atau ketik /buffer di dalam chat.",
                            vim.log.levels.WARN,
                            { title = "CodeCompanion" }
                        )
                        return
                    end

                    -- ── Baca isi buffer langsung ─────────────────────────────────
                    local lines    = vim.api.nvim_buf_get_lines(target_buf, 0, -1, false)
                    local filepath = vim.api.nvim_buf_get_name(target_buf)
                    local filename = vim.fn.fnamemodify(filepath, ":~:.")  -- path relatif
                    local ft       = vim.bo[target_buf].filetype

                    -- ── Temukan chat buffer dan suntikkan konten ─────────────────
                    local chat_win
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "codecompanion" then
                            chat_win = win
                            break
                        end
                    end

                    if not chat_win then
                        -- Belum ada chat terbuka → buka dulu
                        vim.cmd("CodeCompanionChat Toggle")
                        vim.defer_fn(function()
                            -- Panggil ulang setelah chat terbuka
                            run_add(true)
                        end, 300)
                        return
                    end

                    local chat_buf = vim.api.nvim_win_get_buf(chat_win)

                    -- Append code block ke akhir chat buffer (area input user)
                    local code_lines = vim.list_extend(
                        { "", "File: `" .. filename .. "`", "```" .. ft },
                        lines
                    )
                    vim.list_extend(code_lines, { "```", "" })

                    local last = vim.api.nvim_buf_line_count(chat_buf)
                    vim.api.nvim_buf_set_lines(chat_buf, last, -1, false, code_lines)

                    -- Fokus ke chat, cursor ke akhir
                    vim.api.nvim_set_current_win(chat_win)
                    vim.api.nvim_win_set_cursor(chat_win, { vim.api.nvim_buf_line_count(chat_buf), 0 })
                    vim.cmd("startinsert!")

                    vim.notify(
                        "✓ " .. filename .. " disertakan ke chat",
                        vim.log.levels.INFO,
                        { title = "CodeCompanion" }
                    )
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
                -- ── Helper: inject satu file ke chat buffer ──────────────────
                local function inject_file_to_chat(chat_buf, chat_win, filepath)
                    -- Baca isi file langsung dari disk (bukan via buffer)
                    local lines = vim.fn.readfile(filepath)
                    if not lines or #lines == 0 then return false end

                    local relpath = vim.fn.fnamemodify(filepath, ":~:.")
                    local ext     = vim.fn.fnamemodify(filepath, ":e")
                    -- Mapping ekstensi → filetype untuk code fence
                    local ft_map  = {
                        lua="lua", py="python", js="javascript", ts="typescript",
                        tsx="tsx", jsx="jsx", sh="bash", go="go", rs="rust",
                        toml="toml", yaml="yaml", yml="yaml", json="json",
                        md="markdown", html="html", css="css", c="c", cpp="cpp",
                    }
                    local ft = ft_map[ext] or ext or "text"

                    local code_lines = { "", "File: `" .. relpath .. "`", "```" .. ft }
                    vim.list_extend(code_lines, lines)
                    vim.list_extend(code_lines, { "```", "" })

                    local last = vim.api.nvim_buf_line_count(chat_buf)
                    vim.api.nvim_buf_set_lines(chat_buf, last, -1, false, code_lines)
                    return true
                end

                -- ── Helper: kumpulkan file dari directory ────────────────────
                local function collect_files(dir, recursive)
                    local cmd = recursive
                        and string.format("find '%s' -type f -not -path '*/.git/*' | sort", dir)
                        or  string.format("find '%s' -maxdepth 1 -type f | sort", dir)
                    local output = vim.fn.systemlist(cmd)
                    return output
                end

                -- ── Pastikan chat terbuka ────────────────────────────────────
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
                    vim.notify(
                        "Chat dibuka. Tekan <leader>aD lagi untuk memilih direktori.",
                        vim.log.levels.INFO,
                        { title = "CodeCompanion" }
                    )
                    return
                end

                -- ── Minta path directory dari user ───────────────────────────
                -- Default: directory dari file yang sedang aktif sebelum switch ke chat
                local default_dir = vim.fn.getcwd()
                local function is_code_buffer(buf)
                    local ft = vim.bo[buf].filetype
                    local bt = vim.bo[buf].buftype
                    return ft ~= "codecompanion"
                        and ft ~= ""
                        and bt == ""
                        and ft ~= "neo-tree"
                        and ft ~= "NvimTree"
                        and ft ~= "toggleterm"
                        and ft ~= "qf"
                        and ft ~= "help"
                end

                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local wbuf = vim.api.nvim_win_get_buf(win)
                    if is_code_buffer(wbuf) then
                        local wpath = vim.api.nvim_buf_get_name(wbuf)
                        if wpath ~= "" then
                            default_dir = vim.fn.fnamemodify(wpath, ":h")
                        end
                        break
                    end
                end

                vim.ui.input({
                    prompt    = "📁 Directory path (tambahkan ! di akhir untuk rekursif): ",
                    default   = default_dir,
                    completion = "dir",
                }, function(input)
                    if not input or input == "" then return end

                    -- Cek apakah rekursif (diakhiri dengan !)
                    local recursive = vim.endswith(input, "!")
                    local dir_path  = recursive and input:sub(1, -2) or input
                    dir_path        = vim.fn.expand(dir_path)  -- expand ~ dll

                    -- Validasi: harus directory
                    if vim.fn.isdirectory(dir_path) == 0 then
                        vim.notify(
                            "⚠  Bukan direktori yang valid: " .. dir_path,
                            vim.log.levels.ERROR,
                            { title = "CodeCompanion" }
                        )
                        return
                    end

                    -- Kumpulkan file
                    local files = collect_files(dir_path, recursive)
                    if #files == 0 then
                        vim.notify(
                            "⚠  Tidak ada file ditemukan di: " .. dir_path,
                            vim.log.levels.WARN,
                            { title = "CodeCompanion" }
                        )
                        return
                    end

                    -- Inject header directory ke chat
                    local rel_dir = vim.fn.fnamemodify(dir_path, ":~:.")
                    local mode    = recursive and " (rekursif)" or " (flat)"
                    local header  = {
                        "",
                        "---",
                        "📁 **Directory: `" .. rel_dir .. "`**" .. mode
                            .. " — " .. #files .. " file(s)",
                        "---",
                        "",
                    }
                    local last = vim.api.nvim_buf_line_count(chat_buf)
                    vim.api.nvim_buf_set_lines(chat_buf, last, -1, false, header)

                    -- Inject setiap file
                    local injected = 0
                    local skipped  = {}
                    for _, fpath in ipairs(files) do
                        -- Skip file biner (lebih dari 1MB atau tidak bisa dibaca)
                        local fsize = vim.fn.getfsize(fpath)
                        if fsize > 0 and fsize < 1024 * 1024 then
                            if inject_file_to_chat(chat_buf, chat_win, fpath) then
                                injected = injected + 1
                            end
                        else
                            table.insert(skipped, vim.fn.fnamemodify(fpath, ":t"))
                        end
                    end

                    -- Fokus ke chat, cursor ke akhir
                    vim.api.nvim_set_current_win(chat_win)
                    vim.api.nvim_win_set_cursor(chat_win, {
                        vim.api.nvim_buf_line_count(chat_buf), 0
                    })
                    vim.cmd("startinsert!")

                    -- Notifikasi ringkasan
                    local msg = string.format(
                        "✓ %d file dari `%s` disertakan ke chat",
                        injected, rel_dir
                    )
                    if #skipped > 0 then
                        msg = msg .. "\n⚠  Dilewati (" .. #skipped .. " file besar/biner): "
                            .. table.concat(skipped, ", ")
                    end
                    vim.notify(msg, vim.log.levels.INFO, { title = "CodeCompanion" })
                end)
            end,
            mode = { "n", "v" },
            desc = "AI: Add directory files to chat",
        },
    },
}
