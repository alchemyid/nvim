-- lua/plugins/dashboard.lua
-- https://github.com/glepnir/dashboard-nvim

return {
  "glepnir/dashboard-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    theme = "hyper",
    config = {
      week_header = { enable = true },
      shortcut = {
        { desc = " Find File", group = "@property", action = "Telescope find_files", key = "f" },
        { desc = " Live Grep", group = "@property", action = "Telescope live_grep", key = "g" },
        { desc = " Quit", group = "@property", action = "quit", key = "q" },
      },
    },
  },
}
