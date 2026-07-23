return {
  -- Lazydev: Configures Lua LSP for Neovim config and plugin development
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- LSP configuration and server setups
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Mason: Package manager for LSP servers, linters, and formatters
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Define diagnostic symbols in sign column
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Diagnostic display config (optimized for lower CPU overhead)
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix = "●",
        },
        underline = true,
        update_in_insert = false, -- Critical: Do NOT run diagnostics during typing
        severity_sort = true,
        float = {
          focused = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Set keymaps when LSP attaches to buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          local keymap = vim.keymap.set

          opts.desc = "Show LSP Hover Information"
          keymap("n", "K", vim.lsp.buf.hover, opts)

          opts.desc = "Go to Definition"
          keymap("n", "gd", vim.lsp.buf.definition, opts)

          opts.desc = "Go to Declaration"
          keymap("n", "gD", vim.lsp.buf.declaration, opts)

          opts.desc = "Go to Implementation"
          keymap("n", "gi", vim.lsp.buf.implementation, opts)

          opts.desc = "Go to References"
          keymap("n", "gr", vim.lsp.buf.references, opts)

          opts.desc = "Rename Symbol"
          keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)

          opts.desc = "Code Actions"
          keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

          opts.desc = "Show Diagnostics Float"
          keymap("n", "<leader>d", vim.diagnostic.open_float, opts)

          opts.desc = "Previous Diagnostic"
          keymap("n", "[d", vim.diagnostic.goto_prev, opts)

          opts.desc = "Next Diagnostic"
          keymap("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })

      -- Automatically set up LSPs installed via Mason
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local mason_lspconfig = require("mason-lspconfig")

      local handlers = {
        -- Default handler
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
          })
        end,

        -- Custom configurations (e.g. for Lua)
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  checkThirdParty = false,
                },
                telemetry = { enabled = false },
              },
            },
          })
        end,
      }

      mason_lspconfig.setup({
        ensure_installed = {
          "lua_ls",
        },
        handlers = handlers,
      })

      if mason_lspconfig.setup_handlers then
        mason_lspconfig.setup_handlers(handlers)
      end
    end,
  },

  -- Autocompletion Engine: Optimized for zero latency on typing
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        -- Typing optimization: Debounce autocomplete requests by 100ms
        -- and throttle processing to prevent CPU overload during fast typing
        performance = {
          debounce = 100,
          throttle = 50,
          fetching_timeout = 200,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Enter to confirm selection
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        -- Source priorities and max completion counts for faster renders
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000, max_item_count = 10 },
          { name = "luasnip", priority = 750, max_item_count = 5 },
          { name = "buffer", priority = 500, max_item_count = 5, keyword_length = 3 },
          { name = "path", priority = 250, max_item_count = 5 },
        }),
      })
    end,
  },
}
