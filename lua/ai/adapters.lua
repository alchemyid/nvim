-- lua/ai/adapters.lua
-- Definisi adapter CodeCompanion (ACP: claude_code, gemini_cli, hermes; HTTP: anthropic, copilot, ollama).
-- Nilai spesifik mesin (host SSH, IP Ollama) dibaca dari lua/ai/local.lua (tidak ikut git).

local LOCAL = require("ai.local_config")

return {
            acp = {
                -- Claude Code via ACP: npm i -g @zed-industries/claude-code-acp (butuh `claude login`)
                claude_code = function()
                    return require("codecompanion.adapters").extend("claude_code", {})
                end,
                -- Gemini CLI via ACP: npm i -g @google/gemini-cli (jalan dengan --experimental-acp)
                gemini_cli = function()
                    return require("codecompanion.adapters").extend("gemini_cli", {})
                end,
                hermes = function()
                    local hostname = (vim.uv or vim.loop).os_gethostname()
                    local is_homelab_server = hostname == LOCAL.hermes.homelab_hostname or vim.env.HERMES_REMOTE == "1"

                    local hermes_bin
                    if vim.fn.executable("hermes") == 1 then
                        hermes_bin = "hermes"
                    elseif vim.fn.executable(vim.fn.expand("~/.local/bin/hermes")) == 1 then
                        hermes_bin = vim.fn.expand("~/.local/bin/hermes")
                    end

                    local cmd
                    if is_homelab_server and hermes_bin then
                        -- Nvim dieksekusi langsung di dalam server Homelab
                        cmd = { hermes_bin, "acp", "--accept-hooks" }
                    else
                        -- Nvim dieksekusi dari laptop lokal (remote over SSH)
                        cmd = {
                            "ssh",
                            "-i", LOCAL.hermes.ssh.identity,
                            "-o", "IdentitiesOnly=yes",
                            "-q",
                            "-l", LOCAL.hermes.ssh.user,
                            LOCAL.hermes.ssh.host,
                            "hermes", "acp", "--accept-hooks",
                        }
                    end

                    local helpers = require("codecompanion.adapters.acp.helpers")
                    return {
                        name = "hermes",
                        formatted_name = "Hermes Agent (ACP)",
                        type = "acp",
                        roles = {
                            llm = "assistant",
                            user = "user",
                        },
                        opts = {
                            vision = true,
                        },
                        commands = {
                            default = cmd,
                        },
                        defaults = {
                            mcpServers = vim.empty_dict(),
                            timeout = 30000,
                        },
                        parameters = {
                            protocolVersion = 1,
                            clientCapabilities = {
                                fs = { readTextFile = true, writeTextFile = true },
                            },
                            clientInfo = {
                                name = "CodeCompanion.nvim",
                                version = "1.0.0",
                            },
                        },
                        handlers = {
                            setup = function(self)
                                return true
                            end,
                            auth = function(self)
                                return true
                            end,
                            form_messages = function(self, messages, capabilities)
                                return helpers.form_messages(self, messages, capabilities)
                            end,
                            on_exit = function(self, code) end,
                        },
                    }
                end,
            },
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
                            url = LOCAL.ollama_url,
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
}
