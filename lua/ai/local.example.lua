-- Salin ke lua/ai/local.lua lalu sesuaikan. Semua field opsional.
return {
    ollama_url = "http://localhost:11434",
    hermes = {
        homelab_hostname = "nama-host-server", -- jika nvim dijalankan langsung di server, hermes dipanggil lokal
        ssh = { identity = vim.fn.expand("~/.ssh/id_ed25519"), user = "user", host = "server.example.com" },
    },
}
