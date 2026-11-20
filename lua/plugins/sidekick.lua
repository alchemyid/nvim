-- lua/plugins/sidekick.lua
-- folke/sidekick.nvim:
--   * Next Edit Suggestions (NES) dari Copilot -- saran edit multi-baris di mana saja (Tab untuk jump/apply)
--   * Terminal AI CLI: Claude, Gemini, Codex, dll dengan konteks otomatis ({file}, {this}, {selection}, diagnostics)
-- Prefix keymap: <leader>G (Gemini/CLI lain), <leader>K (Sidekick umum). Claude IDE-native tetap <leader>C (claudecode.nvim).

return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    nes = { enabled = true },
    cli = {
      watch = true, -- reload otomatis file yang diubah CLI agent
      -- Sesi CLI hidup di tmux: tetap jalan walau panel ditutup / nvim keluar, lalu di-attach lagi
      mux = { backend = "tmux", enabled = true },
      win = { layout = "right", split = { width = 80 } },
      tools = {
        gemini = { cmd = { "gemini" } },
        claude = { cmd = { "claude" } },
      },
    },
  },
  keys = {
    { "<leader>K", "", desc = "Sidekick" },
    { "<leader>Kn", function() require("sidekick.nes").toggle() end, desc = "Toggle NES (Next Edit Suggestion)" },
    { "<leader>Ku", function() require("sidekick.nes").update() end, desc = "Request NES sekarang" },
    { "<leader>Kc", function() require("sidekick.nes").clear() end, desc = "Clear NES" },
    { "<leader>Gg", function() require("sidekick.cli").toggle({ name = "gemini", focus = true }) end, desc = "Gemini: toggle" },
    { "<leader>Gc", function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end, desc = "Claude (sidekick): toggle" },
    { "<leader>Gs", function() require("sidekick.cli").select({ filter = { installed = true } }) end, desc = "Pilih AI CLI" },
    { "<leader>Gd", function() require("sidekick.cli").close() end, desc = "Detach sesi CLI" },
    { "<leader>Gt", function() require("sidekick.cli").send({ msg = "{this}" }) end, mode = { "n", "x" }, desc = "Kirim posisi/seleksi" },
    { "<leader>Gf", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "Kirim file" },
    { "<leader>Gv", function() require("sidekick.cli").send({ msg = "{selection}" }) end, mode = "x", desc = "Kirim seleksi" },
    { "<leader>Gx", function() require("sidekick.cli").send({ msg = "{diagnostics}" }) end, desc = "Kirim diagnostics file" },
    { "<leader>Gp", function() require("sidekick.cli").prompt() end, mode = { "n", "x" }, desc = "Prompt library" },
    { "<C-.>", function() require("sidekick.cli").focus() end, mode = { "n", "t", "i", "x" }, desc = "Fokus AI CLI" },
  },
}
