-- lua/plugins/ai-cli.lua
-- Integrasi CLI agent (Claude Code & Gemini CLI) ala ekstensi VSCode.
--
-- Claude Code: coder/claudecode.nvim memakai protokol IDE yang sama dengan
-- ekstensi VSCode resmi (WebSocket MCP): selection/buffer aktif otomatis
-- terlihat oleh Claude, diff edit dibuka di nvim (accept/deny), @-mention file.
-- Gemini CLI & CLI lain: lihat sidekick.lua (<leader>G*).
--
-- Keymap (prefix <leader>C = Claude, <leader>G = Gemini; <leader>a* = CodeCompanion):
--   <leader>Cc toggle Claude | Cf fokus | Cr resume | CC continue | Cm pilih model
--   <leader>Cb tambah buffer ke konteks | Cs kirim seleksi (visual)
--   <leader>Ca accept diff | Cd deny diff

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy",
    opts = {
      terminal = {
        split_side = "right",
        split_width_percentage = 0.40,
        provider = "snacks", -- terminal bawaan snacks; fallback "native" kalau perlu
      },
      diff_opts = {
        layout = "vertical",
        open_in_new_tab = false,
        keep_terminal_focus = false,
      },
    },
    keys = {
      { "<leader>C", nil, desc = "Claude Code" },
      { "<leader>Cc", "<cmd>ClaudeCode<CR>", desc = "Claude: toggle" },
      { "<leader>Cf", "<cmd>ClaudeCodeFocus<CR>", desc = "Claude: fokus" },
      { "<leader>Cr", "<cmd>ClaudeCode --resume<CR>", desc = "Claude: resume sesi" },
      { "<leader>CC", "<cmd>ClaudeCode --continue<CR>", desc = "Claude: continue sesi terakhir" },
      { "<leader>Cm", "<cmd>ClaudeCodeSelectModel<CR>", desc = "Claude: pilih model" },
      { "<leader>Cb", "<cmd>ClaudeCodeAdd %<CR>", desc = "Claude: tambah buffer ke konteks" },
      { "<leader>Cs", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Claude: kirim seleksi" },
      {
        "<leader>Cs",
        "<cmd>ClaudeCodeTreeAdd<CR>",
        desc = "Claude: tambah file dari tree",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      { "<leader>Ca", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "Claude: accept diff" },
      { "<leader>Cd", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "Claude: deny diff" },
    },
  },

  -- snacks hanya dipakai sebagai provider terminal untuk claudecode.nvim
  {
    "folke/snacks.nvim",
    lazy = true,
    opts = { terminal = { enabled = true } },
  },
}
