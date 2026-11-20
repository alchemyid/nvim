-- lua/ai/local_config.lua
-- Loader pengaturan spesifik mesin. Salin lua/ai/local.example.lua menjadi lua/ai/local.lua
-- lalu isi nilai Anda. local.lua di-.gitignore sehingga host/IP/key path tidak masuk repo.

local defaults = {
  ollama_url = vim.env.OLLAMA_URL or "http://localhost:11434",
  hermes = {
    homelab_hostname = vim.env.HERMES_HOSTNAME or "",
    ssh = {
      identity = vim.env.HERMES_SSH_KEY or vim.fn.expand("~/.ssh/id_rsa"),
      user = vim.env.HERMES_SSH_USER or vim.env.USER or "",
      host = vim.env.HERMES_SSH_HOST or "",
    },
  },
}

local ok, user = pcall(require, "ai.local")
return vim.tbl_deep_extend("force", defaults, ok and user or {})
