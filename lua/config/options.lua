-- Ensure ~/.local/bin and ~/.cargo/bin are in Neovim's PATH for tools like tree-sitter CLI
local local_bin = vim.fn.expand("~/.local/bin")
local cargo_bin = vim.fn.expand("~/.cargo/bin")
if vim.fn.isdirectory(local_bin) == 1 and not string.find(vim.env.PATH or "", local_bin, 1, true) then
  vim.env.PATH = local_bin .. ":" .. (vim.env.PATH or "")
end
if vim.fn.isdirectory(cargo_bin) == 1 and not string.find(vim.env.PATH or "", cargo_bin, 1, true) then
  vim.env.PATH = cargo_bin .. ":" .. (vim.env.PATH or "")
end

local opt = vim.opt
opt.termguicolors = true -- required for onedark.nvim to render correctly
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- keeps gutter stable for gitsigns / diagnostics
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.splitright = true
opt.splitbelow = true
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.updatetime = 200
opt.timeoutlen = 400
opt.mouse = "a"

-- ── System Clipboard Provider Setup ─────────────────────────────────────
-- PENTING: g:clipboard HARUS didefinisikan SEBELUM opt.clipboard di-set.
-- Neovim me-resolve & cache clipboard provider begitu opt.clipboard diaktifkan,
-- jadi kalau g:clipboard belum ada saat itu, provider bisa salah detect
-- (fallback ke xclip/xsel yang tidak berfungsi tanpa DISPLAY di server headless)
-- atau hasilnya ke-cache sebagai "no provider" dan tidak refresh lagi.
--
-- Prioritas OSC 52 jika sesi remote (SSH) agar copy dari remote Neovim
-- langsung masuk ke clipboard laptop lokal.
local is_ssh = (vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil)

if is_ssh then
  local osc52_ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if osc52_ok then
    vim.g.clipboard = {
      name = "OSC 52 (SSH Remote)",
      copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
      paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
    }
  end
elseif vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
    paste = {
      ["+"] = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).ToString().Replace(\"`r`n\", \"`n\"))",
      ["*"] = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).ToString().Replace(\"`r`n\", \"`n\"))",
    },
    cache_enabled = 0,
  }
elseif vim.fn.executable("wl-copy") == 1 then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = { ["+"] = "wl-copy --type text/plain", ["*"] = "wl-copy --type text/plain" },
    paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --no-newline" },
    cache_enabled = 1,
  }
elseif vim.fn.executable("xsel") == 1 then
  vim.g.clipboard = {
    name = "xsel",
    copy = { ["+"] = "xsel --nodetach -i -b", ["*"] = "xsel --nodetach -i -p" },
    paste = { ["+"] = "xsel -o -b", ["*"] = "xsel -o -p" },
    cache_enabled = 1,
  }
elseif vim.fn.executable("xclip") == 1 then
  vim.g.clipboard = {
    name = "xclip",
    copy = { ["+"] = "xclip -quiet -i -selection clipboard", ["*"] = "xclip -quiet -i -selection primary" },
    paste = {
      ["+"] = function()
        return vim.fn.systemlist("xclip -o -selection clipboard 2>/dev/null")
      end,
      ["*"] = function()
        return vim.fn.systemlist("xclip -o -selection primary 2>/dev/null")
      end,
    },
    cache_enabled = 1,
  }
else
  local osc52_ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if osc52_ok then
    vim.g.clipboard = {
      name = "OSC 52",
      copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
      paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
    }
  end
end

-- Set clipboard option SETELAH g:clipboard didefinisikan di atas
opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
