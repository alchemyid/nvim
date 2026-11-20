-- lua/plugins/copilot.lua
-- GitHub Copilot lewat copilot-language-server (resmi) + inline completion bawaan Neovim 0.12
-- (vim.lsp.inline_completion). Sidekick memakai LSP yang sama untuk Next Edit Suggestions.
-- Login sekali: :LspCopilotSignIn

return {
  {
    "neovim/nvim-lspconfig", -- lsp/copilot.lua dari lspconfig dipakai di sini
    optional = true,
    init = function()
      -- pastikan binary dari Mason ada di PATH sebelum LSP di-enable
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
      if not vim.env.PATH:find(mason_bin, 1, true) then
        vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
      end

      vim.lsp.enable("copilot")
      vim.lsp.inline_completion.enable(true)

      local function map(lhs, fn, desc)
        vim.keymap.set("i", lhs, fn, { desc = desc })
      end
      -- Keymap sama dengan copilot.vim sebelumnya
      map("<M-l>", function()
        if not vim.lsp.inline_completion.get() then return end
      end, "Copilot: accept ghost text")
      map("<M-]>", function() vim.lsp.inline_completion.select({ count = 1 }) end, "Copilot: next suggestion")
      map("<M-[>", function() vim.lsp.inline_completion.select({ count = -1 }) end, "Copilot: prev suggestion")
      map("<C-]>", function() vim.lsp.inline_completion.enable(false); vim.lsp.inline_completion.enable(true) end,
        "Copilot: dismiss")
    end,
  },
}
