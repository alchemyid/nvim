-- lua/plugins/vscode-like.lua
-- Fitur khas VSCode: format on save, Problems panel, Outline, Tabs, Search/Replace,
-- Debugger (F5/F9/F10/F11), TODO highlight, restore session.

return {
  -- ── Format on save (Prettier/black/stylua/dll lewat Mason) ───────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" }, desc = "Format (conform/LSP)" },
    },
    init = function()
      vim.api.nvim_create_user_command("FormatToggle", function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify("Format on save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
      end, { desc = "Toggle format on save" })
    end,
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "black", stop_after_first = true },
        javascript = { "prettier" }, typescript = { "prettier" },
        javascriptreact = { "prettier" }, typescriptreact = { "prettier" },
        json = { "prettier" }, yaml = { "prettier" }, markdown = { "prettier" },
        html = { "prettier" }, css = { "prettier" },
        sh = { "shfmt" }, go = { "gofmt" }, rust = { "rustfmt" },
      },
      format_on_save = function()
        if vim.g.disable_autoformat then return end
        return { timeout_ms = 1500, lsp_format = "fallback" }
      end,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = { "stylua", "prettier", "ruff", "shfmt", "debugpy" },
      run_on_start = true,
    },
  },

  -- ── Problems panel (Ctrl+Shift+M) + References ───────────────────────────
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Problems (workspace)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Problems (buffer)" },
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "TODO list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix" },
    },
  },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- ── Outline (panel Outline VSCode) ───────────────────────────────────────
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    keys = { { "<leader>o", "<cmd>AerialToggle! right<CR>", desc = "Outline" } },
    opts = { layout = { default_direction = "right", min_width = 28 } },
  },

  -- ── Editor tabs ──────────────────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        offsets = { { filetype = "NvimTree", text = "Explorer", highlight = "Directory", separator = true } },
        close_command = function(n) require("mini.bufremove").delete(n, false) end,
      },
    },
    keys = {
      { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin tab" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close other tabs" },
      { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Close tab" },
    },
  },

  -- ── Search & Replace seluruh project (Ctrl+Shift+H) ──────────────────────
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", function() require("grug-far").open() end, mode = { "n", "v" }, desc = "Search & Replace (project)" },
      { "<leader>sw", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end,
        desc = "Replace word under cursor" },
    },
    opts = {},
  },

  -- ── Debugger: F5 continue, F9 breakpoint, F10 over, F11 into, S-F11 out ──
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: continue/start" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<S-F5>", function() require("dap").terminate() end, desc = "Debug: stop" },
      { "<leader>db", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Debug: conditional breakpoint" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Debug: eval" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      require("mason-nvim-dap").setup({ ensure_installed = { "python", "js" }, automatic_installation = true, handlers = {} })
      dapui.setup()
      require("nvim-dap-virtual-text").setup()
      local debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(vim.fn.executable(debugpy) == 1 and debugpy or "python3")

      -- .vscode/launch.json dibaca otomatis oleh nvim-dap (on-demand), tidak perlu setup tambahan

      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"] = function() dapui.close() end
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
    end,
  },

  -- ── Restore session per folder (VSCode reopen workspace) ─────────────────
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    },
  },
}
