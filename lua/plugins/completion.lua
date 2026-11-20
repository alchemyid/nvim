-- lua/plugins/completion.lua
-- Autocomplete engine: blink.cmp (cepat, binary Rust) + LSP, snippets, path, buffer, CodeCompanion.
-- Tab: snippet jump -> Copilot NES (sidekick) -> pilih item berikutnya.

return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- release tag => binary prebuilt otomatis diunduh
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "L3MON4D3/LuaSnip", "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = {
          "select_next",
          "snippet_forward",
          function() -- sidekick: Next Edit Suggestion (Copilot)
            local ok, sk = pcall(require, "sidekick")
            return ok and sk.nes_jump_or_apply() or false
          end,
          "fallback",
        },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
      },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 250, window = { border = "rounded" } },
        menu = { border = "rounded" },
        ghost_text = { enabled = false }, -- ghost text dipegang Copilot
      },
      signature = { enabled = true, window = { border = "rounded" } },
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
        providers = {
          codecompanion = {
            name = "CodeCompanion",
            module = "codecompanion.providers.completion.blink",
          },
        },
      },
      cmdline = { enabled = true },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
