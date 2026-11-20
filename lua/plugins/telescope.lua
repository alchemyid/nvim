-- lua/plugins/telescope.lua
-- https://github.com/nvim-telescope/telescope.nvim
-- Fuzzy finder; fzf-native untuk sorting cepat, ripgrep/fd dipakai otomatis bila terpasang.

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
    { "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Quick open file (Ctrl+P)" },
    { "<leader>p", "<cmd>Telescope commands<CR>", desc = "Command palette" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
    { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
    { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
    { "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search in file" },
    { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Git branches" },
    { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
    { "<leader>gS", "<cmd>Telescope git_status<CR>", desc = "Git status" },
  },
  config = function()
    local ts = require("telescope")
    ts.setup({
      defaults = {
        file_ignore_patterns = { "node_modules/", "%.git/", "__pycache__/", "%.venv/", "dist/", "build/" },
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
      },
      pickers = {
        find_files = { hidden = true },
        live_grep = { additional_args = { "--hidden" } },
      },
    })
    pcall(ts.load_extension, "fzf")
  end,
}
