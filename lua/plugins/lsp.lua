-- lua/plugins/lsp.lua
-- Native LSP + Mason. onedark.nvim styles LSP diagnostics out of the box
-- (see `diagnostics` table in colorscheme.lua) once diagnostics are enabled here.

return {
  {
    "williamboman/mason.nvim",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = { "lua_ls", "pyright" }, -- add servers you need, e.g. "pyright", "tsserver"
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-lspconfig.nvim" },
    config = function()
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
      end

      -- Lua configuration
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.enable("lua_ls")

      -- Python (pyright) configuration with virtualenv auto-detection
      local function get_python_path()
        -- 1. Check for active virtualenv in the terminal session
        if vim.env.VIRTUAL_ENV then
          return vim.env.VIRTUAL_ENV .. "/bin/python"
        end

        -- 2. Check for local .venv, venv, pyenv, or env folders in the current workspace directory
        local cwd = vim.fn.getcwd()
        local paths = {
          cwd .. "/.venv/bin/python",
          cwd .. "/venv/bin/python",
          cwd .. "/pyenv/bin/python",
          cwd .. "/env/bin/python",
        }
        for _, path in ipairs(paths) do
          if vim.fn.executable(path) == 1 then
            return path
          end
        end

        -- 3. Fallback to default python3
        return "python3"
      end

      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            pythonPath = get_python_path(),
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      vim.lsp.enable("pyright")

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
      vim.keymap.set("n", "<C-LeftMouse>", function ()
        local mouse = vim.fn.getmousepos()
        if mouse.winid ~= 0 then
          vim.api.nvim_set_current_win(mouse.winid)
          vim.api.nvim_win_set_cursor(mouse.winid, { mouse.line, mouse.column - 1 })
          vim.lsp.buf.definition()
        end
      end, { desc = "Go to definition (Ctrl+Click)"})

      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        vim.lsp.buf.format({ async = true })
      end, { desc = "Format code (LSP)" })
    end,
  },
}
