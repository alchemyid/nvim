-- lua/plugins/codecompanion.lua
-- AI Assistant di Neovim berbasis Claude (Anthropic), GitHub Copilot, & Ollama (Lokal).
-- Menggunakan skema `interactions` (v19+).
--
-- Experience mirip VSCode Copilot Chat / Antigravity / Cursor:
-- 1. Chat Sidebar (`<leader>ac`): Chat AI interaktif dengan kemampuan Agentic Tools (@editor, @files).
-- 2. Inline Edit (`<leader>ai`): Minta AI membuat / mengedit / refactor kode langsung di buffer.
-- 3. Approvals (`ga` / `gr`):
---   - Tekan `ga` (Accept) di Normal mode untuk MENYETUJUI & menerapkan hasil edit langsung ke kode Anda.
---   - Tekan `gr` (Reject) untuk MENOLAK saran edit.
-- 4. Fast Toggle Adapter (`<leader>aT`): Beralih secara instan antara Claude 3.7 (Cloud), GitHub Copilot, dan Qwen 7B (Lokal).

local INLINE_RULES = [[

Instruksi tambahan:
1. Perhatikan nomor baris bisa bergeser setelah tiap edit pada multi-edit di satu file.
2. Jika tidak yakin soal API/library/parameter, katakan eksplisit — jangan mengarang.
3. Jika instruksi ambigu, ambil satu asumsi wajar, sebutkan singkat, lalu lanjutkan.]]

return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",           -- Render Markdown di chat buffer
        "ravitemer/codecompanion-history.nvim",      -- Chat History: save, browse & restore session
    },
    opts = {
        -- ─── Configuration Adapters (HTTP) ──────────────────────────────
        adapters = {
            http = {
                anthropic = function()
                    return require("codecompanion.adapters").extend("anthropic", {
                        name = "anthropic",
                        env = {
                            api_key = "ANTHROPIC_API_KEY",
                        },
                        schema = {
                            model = {
                                default = "claude-3-7-sonnet-20250219",
                            },
                        },
                    })
                end,
                copilot = function()
                    return require("codecompanion.adapters").extend("copilot", {
                        name = "copilot",
                        schema = {
                            model = {
                                default = "gpt-4o",
                            },
                        },
                    })
                end,
                ollama = function()
                    return require("codecompanion.adapters").extend("ollama", {
                        name = "ollama",
                        env = {
                            url = "http://192.168.0.100:11434",
                        },
                        schema = {
                            model = {
                                default = "qwen2.5-coder:7b",
                            },
                            num_ctx = {
                                default = 8192,
                            },
                        },
                        handlers = {
                            form_parameters = function(self, params, messages)
                                params = require("codecompanion.adapters.http.openai").handlers.form_parameters(self, params, messages)
                                if messages then
                                    for _, msg in ipairs(messages) do
                                        if msg.role == "system" and type(msg.content) == "string" and (msg.content:find("JSON") or msg.content:find("placement")) then
                                            params.format = "json"
                                            break
                                        end
                                    end
                                end
                                return params
                            end,
                        },
                    })
                end,
            },
        },

        -- ─── Interactions Configuration ──────────────────────────────────
        interactions = {
            chat = {
                adapter = "copilot", -- Default: GitHub Copilot

                opts = {
                    system_prompt = function(ctx)
                        return ctx.default_system_prompt .. [[

Instruksi tambahan:
1. Kamu adalah AI Agentic Assistant tingkat lanjut. Kamu dapat membaca file, mengedit kode, dan mencari arsitektur project.
2. Untuk task yang menyentuh >1 file/fungsi, buat rencana singkat sebelum eksekusi.
3. Perhatikan nomor baris bisa bergeser setelah tiap edit pada multi-edit di satu file.
4. Jika tidak yakin soal API/library/parameter, katakan eksplisit — jangan mengarang.
5. Jika instruksi ambigu, ambil satu asumsi wajar, sebutkan singkat, lalu lanjutkan.
6. Setelah selesai, berhenti — jangan mengulang rekap dengan kalimat berbeda.
]]
                    end,
                },

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
                adapter = "copilot", -- Default: GitHub Copilot
            },

            cmd = {
                adapter = "copilot", -- Default: GitHub Copilot
            },

            -- Keymap global untuk Approve (`ga`) / Reject (`gr`) hasil edit diff
            shared = {
                keymaps = {
                    accept_change = {
                        callback = "keymaps.accept_change",
                        modes = { n = "ga" },
                        description = "Accept the suggested change (Setujui & terapkan ke buffer)",
                    },
                    reject_change = {
                        callback = "keymaps.reject_change",
                        modes = { n = "gr" },
                        opts = { nowait = true },
                        description = "Reject the suggested change (Tolak edit)",
                    },
                },
            },
        },

        -- ─── Chat History ────────────────────────────────────────────────
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
                        adapter = "copilot",
                        model = nil,
                        refresh_every_n_prompts = 0,
                        max_refreshes = 1,
                    },
                    continue_last_chat = true, -- Auto-continue percakapan terakhir saat membuka chat
                    delete_on_clearing_chat = false,
                    dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
                    enable_logging = false,
                },
            },
        },

        -- ─── Display Window Config ──────────────────────────────────────
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

        -- ─── Prompt Library (Shortcut Koding) ───────────────────────────
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
            ["Beautify Code"] = {
                strategy = "inline",
                description = "Rapikan spacing, indentasi, dan keindahan kode (Code Beauty)",
                opts = { alias = "beautify", auto_submit = true, placement = "replace" },
                prompts = {
                    {
                        role = "system",
                        content = "Rapikan indentasi, spacing, style, penamaan, dan tata letak kode agar lebih bersih, mudah dibaca, dan mengikuti standar style guide bahasa pemrograman terkait. Output HANYA kode yang sudah dirapikan, tanpa penjelasan tambahan." .. INLINE_RULES,
                    },
                    {
                        role = "user",
                        content = function(context)
                            local start_line = context.is_visual and context.start_line or 1
                            local end_line = context.is_visual and context.end_line or vim.api.nvim_buf_line_count(context.bufnr)
                            local code = require("codecompanion.helpers.code").get_code(start_line, end_line)
                            return string.format(
                                "Rapikan spacing, indentasi, dan perindah kode %s berikut:\n\n```%s\n%s\n```",
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
        { "<leader>an", "<cmd>CodeCompanionChat<CR>",         mode = { "n", "v" }, desc = "AI: Open new chat session" },
        { "<leader>aa", "<cmd>CodeCompanionActions<CR>",      mode = { "n", "v" }, desc = "AI: Actions palette" },
        { "<leader>ai", "<cmd>CodeCompanion<CR>",             mode = { "n", "v" }, desc = "AI: Inline edit" },
        {
            "<leader>ah",
            function()
                require("codecompanion._extensions.history").exports.browse_chats()
            end,
            mode = { "n", "v" },
            desc = "AI: Browse chat history",
        },

        -- Toggle Adapter Instan antara Claude (Anthropic), Copilot (GitHub), & Ollama (Lokal)
        {
            "<leader>aT",
            function()
                local config = require("codecompanion.config")
                local current = config.interactions.chat.adapter

                local cycle = {
                    anthropic = { target = "copilot",   name = "GitHub Copilot (Cloud)" },
                    copilot   = { target = "ollama",    name = "Ollama 7B (Lokal)" },
                    ollama    = { target = "anthropic", name = "Claude 3.7 (Anthropic)" },
                }

                local info = cycle[current] or cycle["anthropic"]
                local target = info.target
                local name = info.name

                config.interactions.chat.adapter = target
                config.interactions.inline.adapter = target
                config.interactions.cmd.adapter = target

                vim.notify("AI Adapter switched to: " .. name, vim.log.levels.INFO, { title = "CodeCompanion" })
            end,
            mode = { "n", "v" },
            desc = "AI: Toggle Claude / Copilot / Ollama",
        },

        -- Switch Model Copilot via Menu (<leader>am) atau Toggle (<leader>aM)
        {
            "<leader>am",
            function()
                local models = {
                    { id = "gpt-4o",            name = "GPT-4o (OpenAI)" },
                    { id = "claude-3.5-sonnet", name = "Claude 3.5 Sonnet (Anthropic)" },
                    { id = "gemini-2.5-pro",    name = "Gemini 2.5 Pro (Google)" },
                    { id = "gpt-4o-mini",       name = "GPT-4o Mini (Cepat & Ringan)" },
                    { id = "o3-mini",           name = "o3-mini (Reasoning Model)" },
                    { id = "auto",              name = "Auto (Default GitHub Copilot)" },
                }

                vim.ui.select(models, {
                    prompt = "🤖 Pilih Model Copilot:",
                    format_item = function(item) return item.name .. " [" .. item.id .. "]" end,
                }, function(choice)
                    if not choice then return end

                    local config = require("codecompanion.config")
                    config.adapters.http.copilot = function()
                        return require("codecompanion.adapters").extend("copilot", {
                            name = "copilot",
                            schema = {
                                model = {
                                    default = choice.id,
                                },
                            },
                        })
                    end

                    vim.notify("Copilot Model set to: " .. choice.name, vim.log.levels.INFO, { title = "CodeCompanion" })
                end)
            end,
            mode = { "n", "v" },
            desc = "AI: Select Copilot model menu",
        },

        {
            "<leader>aM",
            function()
                local cycle = {
                    ["gpt-4o"]            = "claude-3.5-sonnet",
                    ["claude-3.5-sonnet"] = "gemini-2.5-pro",
                    ["gemini-2.5-pro"]    = "gpt-4o-mini",
                    ["gpt-4o-mini"]       = "o3-mini",
                    ["o3-mini"]           = "auto",
                    ["auto"]              = "gpt-4o",
                }

                local config = require("codecompanion.config")
                local current_adapter = type(config.adapters.http.copilot) == "function" and config.adapters.http.copilot() or config.adapters.http.copilot
                local current_model = (current_adapter and current_adapter.schema and current_adapter.schema.model and current_adapter.schema.model.default) or "gpt-4o"
                local next_model = cycle[current_model] or "gpt-4o"

                config.adapters.http.copilot = function()
                    return require("codecompanion.adapters").extend("copilot", {
                        name = "copilot",
                        schema = {
                            model = {
                                default = next_model,
                            },
                        },
                    })
                end

                vim.notify("Copilot Model toggled to: " .. next_model, vim.log.levels.INFO, { title = "CodeCompanion" })
            end,
            mode = { "n", "v" },
            desc = "AI: Cycle Copilot model",
        },

        { "<leader>ar", function() require("codecompanion").prompt("review") end,   mode = { "n", "v" }, desc = "AI: Review code" },
        { "<leader>af", function() require("codecompanion").prompt("fix") end,      mode = { "n", "v" }, desc = "AI: Fix bugs" },
        { "<leader>ae", function() require("codecompanion").prompt("explain") end,  mode = { "n", "v" }, desc = "AI: Explain code" },
        { "<leader>ad", function() require("codecompanion").prompt("docs") end,     mode = { "n", "v" }, desc = "AI: Add documentation" },
        { "<leader>at", function() require("codecompanion").prompt("tests") end,    mode = { "n", "v" }, desc = "AI: Generate tests" },
        { "<leader>ao", function() require("codecompanion").prompt("refactor") end, mode = { "n", "v" }, desc = "AI: Refactor code" },
        { "<leader>ay", function() require("codecompanion").prompt("beautify") end, mode = { "n", "v" }, desc = "AI: Beautify code" },

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
