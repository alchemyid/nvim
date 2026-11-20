-- lua/plugins/lsp.lua
-- Native LSP (nvim 0.11+ API) + Mason. Banyak bahasa terpasang otomatis, mirip VSCode.

local servers = {
  lua_ls = {
    settings = { Lua = { diagnostics = { globals = { "vim" } }, hint = { enable = true } } },
  },
  pyright = {}, -- settings python path diisi dinamis di bawah
  ts_ls = {},
  html = {},
  cssls = {},
  jsonls = {},
  yamlls = {},
  bashls = {},
  gopls = {},
  rust_analyzer = {},
  marksman = {},
  copilot = {}, -- diaktifkan di copilot.lua (inline completion + sidekick NES)
  taplo = {},
}

local function get_python_path()
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end
  local cwd = vim.fn.getcwd()
  for _, dir in ipairs({ ".venv", "venv", "pyenv", "env" }) do
    local p = cwd .. "/" .. dir .. "/bin/python"
    if vim.fn.executable(p) == 1 then
      return p
    end
  end
  return "python3"
end

return {
  { "williamboman/mason.nvim", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = vim.tbl_keys(servers), -- termasuk copilot (copilot-language-server)
      automatic_enable = false, -- kita enable manual di bawah supaya config per-server terpakai
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-lspconfig.nvim" },
    config = function()
      vim.diagnostic.config({
        virtual_text = { spacing = 2, prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = true },
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end
      capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } -- nvim-ufo

      servers.pyright.settings = {
        python = {
          pythonPath = get_python_path(),
          analysis = { autoSearchPaths = true, useLibraryCodeForTypes = true, diagnosticMode = "workspace" },
        },
      }

      for name, cfg in pairs(servers) do
        if name == "copilot" then goto continue end
        vim.lsp.config(name, vim.tbl_deep_extend("force", { capabilities = capabilities }, cfg))
        vim.lsp.enable(name)
        ::continue::
      end

      -- Keymap hanya aktif di buffer yang punya LSP (gaya VSCode)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(ev)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          local tb = function(fn) return function() require("telescope.builtin")[fn]() end end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")        -- F12
          map("n", "<F12>", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gr", tb("lsp_references"), "References")                -- Shift+F12
          map("n", "<S-F12>", tb("lsp_references"), "References")
          map("n", "gi", tb("lsp_implementations"), "Implementations")
          map("n", "gy", tb("lsp_type_definitions"), "Type definition")
          map("n", "K", vim.lsp.buf.hover, "Hover docs")
          map("i", "<C-s>", vim.lsp.buf.signature_help, "Signature help")
          map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")             -- F2
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action") -- Ctrl+.
          map("n", "<leader>cs", tb("lsp_document_symbols"), "Document symbols")  -- Ctrl+Shift+O
          map("n", "<leader>cS", tb("lsp_dynamic_workspace_symbols"), "Workspace symbols") -- Ctrl+T
          map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
          map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("n", "<leader>ci", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
            end, "Toggle inlay hints")
          end
        end,
      })

      vim.keymap.set("n", "<C-LeftMouse>", function()
        local mouse = vim.fn.getmousepos()
        if mouse.winid ~= 0 then
          vim.api.nvim_set_current_win(mouse.winid)
          vim.api.nvim_win_set_cursor(mouse.winid, { mouse.line, mouse.column - 1 })
          vim.lsp.buf.definition()
        end
      end, { desc = "Go to definition (Ctrl+Click)" })
    end,
  },
}
