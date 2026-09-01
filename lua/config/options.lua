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
-- Prioritas deteksi clipboard:
-- 1. macOS: Biarkan Neovim menggunakan pbcopy/pbpaste bawaan.
-- 2. WSL: clip.exe / powershell.
-- 3. Wayland (dengan $WAYLAND_DISPLAY aktif): wl-copy / wl-paste.
-- 4. X11 (hanya jika $DISPLAY aktif): xsel / xclip.
-- 5. SSH / Headless Linux / Tmux (tanpa DISPLAY): OSC 52 (copy langsung ke clipboard laptop lokal).

local has_display = (vim.env.DISPLAY ~= nil and vim.env.DISPLAY ~= "")
local has_wayland = (vim.env.WAYLAND_DISPLAY ~= nil and vim.env.WAYLAND_DISPLAY ~= "")
local is_mac = (vim.fn.has("mac") == 1 or (vim.uv or vim.loop).os_uname().sysname == "Darwin")

local osc52_ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")

if is_mac then
  -- Di macOS, gunakan provider bawaan macOS (pbcopy/pbpaste)
  vim.g.clipboard = nil
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
elseif has_wayland and vim.fn.executable("wl-copy") == 1 then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = { ["+"] = "wl-copy --type text/plain", ["*"] = "wl-copy --type text/plain" },
    paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --no-newline" },
    cache_enabled = 1,
  }
elseif has_display and vim.fn.executable("xsel") == 1 then
  vim.g.clipboard = {
    name = "xsel",
    copy = { ["+"] = "xsel --nodetach -i -b", ["*"] = "xsel --nodetach -i -p" },
    paste = { ["+"] = "xsel -o -b", ["*"] = "xsel -o -p" },
    cache_enabled = 1,
  }
elseif has_display and vim.fn.executable("xclip") == 1 then
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
elseif osc52_ok then
  -- Fallback untuk Remote SSH / Headless Linux tanpa GUI Display: gunakan OSC 52
  vim.g.clipboard = {
    name = "OSC 52 (Remote SSH)",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
  }
end

-- Set clipboard option SETELAH g:clipboard didefinisikan di atas
opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
