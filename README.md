# Neovim Config Template — onedark.nvim

Template konfigurasi Neovim (Lua, plugin manager [lazy.nvim](https://github.com/folke/lazy.nvim))
dengan colorscheme [onedark.nvim](https://github.com/navarasu/onedark.nvim), lengkap dengan
semua plugin yang secara eksplisit disebutkan "Supported" di README onedark.nvim, sudah
dikonfigurasi agar warnanya konsisten.

## Requirement

- **Neovim >= 0.9** (wajib untuk onedark.nvim versi terbaru — treesitter captures modern,
  LSP semantic tokens, dst). Kalau masih pakai Neovim 0.5–0.8, lihat catatan di
  `lua/plugins/colorscheme.lua` untuk pin ke tag `v0.1.0`.
- `git` terpasang di PATH (dipakai lazy.nvim untuk clone plugin).
- Opsional: [Nerd Font](https://www.nerdfonts.com/) di terminal, supaya icon
  (nvim-web-devicons, dashboard, lualine, dll) tampil dengan benar.

## Instalasi

```bash
# backup config lama kalau ada
mv ~/.config/nvim ~/.config/nvim.bak

# clone/copy folder ini ke ~/.config/nvim
git clone [repo-anda] ~/.config/nvim
# atau kalau dari zip, extract langsung ke ~/.config/nvim

nvim
```

Saat pertama kali dibuka, `lazy.nvim` akan otomatis bootstrap dirinya sendiri lalu
install semua plugin di bawah ini. Tunggu sampai selesai, lalu restart nvim.

## Struktur folder

```
~/.config/nvim/
├── init.lua                      -- entry point
└── lua/
    ├── config/
    │   ├── options.lua           -- vim.opt defaults
    │   ├── keymaps.lua           -- keymap global (non plugin-specific)
    │   └── lazy.lua              -- bootstrap + loader lazy.nvim
    └── plugins/
        ├── colorscheme.lua       -- onedark.nvim (theme utama)
        ├── treesitter.lua        -- TreeSitter
        ├── lsp.lua                -- native LSP + mason (untuk LSPDiagnostics)
        ├── nvim-tree.lua          -- NvimTree
        ├── neo-tree.lua           -- Neo-tree (alternatif nvim-tree)
        ├── telescope.lua          -- Telescope
        ├── which-key.lua          -- WhichKey
        ├── dashboard.lua          -- Dashboard
        ├── lualine.lua            -- Lualine (theme = 'onedark')
        ├── gitsigns.lua           -- GitSigns (pengganti modern GitGutter)
        ├── fugitive.lua           -- VimFugitive
        ├── diffview.lua           -- DiffView
        ├── hop.lua                -- Hop
        ├── mini.lua               -- Mini.nvim (subset modul)
        ├── neotest.lua            -- Neotest
        ├── barbecue.lua           -- Barbecue
        ├── indent-blankline.lua   -- IndentBlankline
        ├── indentmini.lua         -- indentmini (alternatif, nonaktif default)
        └── illuminate.lua         -- vim-illuminate
```

Setiap file di `lua/plugins/` adalah satu spec `lazy.nvim` yang otomatis ter-load lewat
`{ import = "plugins" }` di `lua/config/lazy.lua` — tinggal tambah file baru untuk plugin
baru, tanpa perlu edit file lain.

## Plugin yang di-cover onedark.nvim, dan status di template ini

| Plugin (README onedark.nvim) | Status | Catatan |
|---|---|---|
| TreeSitter | ✅ Aktif | `treesitter.lua` |
| LSP Diagnostics | ✅ Aktif | `lsp.lua` (native `vim.diagnostic` + mason) |
| NvimTree | ✅ Aktif | `nvim-tree.lua`, `<leader>e` |
| Telescope | ✅ Aktif | `telescope.lua`, `<leader>ff/fg/fb/fh` |
| WhichKey | ✅ Aktif | `which-key.lua` |
| Dashboard | ✅ Aktif | `dashboard.lua` |
| Lualine | ✅ Aktif | `lualine.lua`, theme diset `onedark` sesuai dokumentasi resmi |
| GitGutter | ⚪ Diganti | Digantikan `gitsigns.lua` (maintained, sama-sama didukung skema) |
| GitSigns | ✅ Aktif | `gitsigns.lua` |
| VimFugitive | ✅ Aktif | `fugitive.lua`, `<leader>gs` |
| DiffView | ✅ Aktif | `diffview.lua`, `<leader>gd` |
| Hop | ✅ Aktif | `hop.lua`, `<leader>hw/hl` |
| Mini | ✅ Aktif | `mini.lua` (pairs, comment, surround, indentscope) |
| Neo-tree | ⚪ Opsional | `neo-tree.lua`, `<leader>E` — alternatif NvimTree, pilih salah satu |
| Neotest | ✅ Aktif | `neotest.lua`, `<leader>tn/tf/to/ts` (tambahkan adapter bahasa sendiri) |
| Barbecue | ✅ Aktif | `barbecue.lua` |
| IndentBlankline | ✅ Aktif | `indent-blankline.lua` |
| vim-illuminate | ✅ Aktif | `illuminate.lua` |
| indentmini | ⚪ Opsional | `indentmini.lua`, nonaktif default — alternatif indent-blankline |

Yang ditandai "Opsional" sengaja dibuat sebagai alternatif berdampingan (bukan
dijalankan bersamaan), karena fungsinya tumpang tindih dengan plugin lain yang sudah
aktif (dua file explorer / dua indent-guide sekaligus biasanya cuma bikin bentrok
keymap & visual). Tinggal aktifkan salah satu.

## Mengganti style onedark

Edit `style` di `lua/plugins/colorscheme.lua`:

```lua
style = "darker", -- dark | darker | cool | deep | warm | warmer | light
```

Atau toggle langsung di dalam nvim dengan `<leader>ts`.

## Menambah LSP server / test adapter

- LSP: tambahkan nama server di `ensure_installed` (`lsp.lua`) lalu tambahkan
  `lspconfig.<server>.setup({...})`.
- Neotest: install adapter yang sesuai (mis. `nvim-neotest/neotest-python`) sebagai
  dependency di `neotest.lua`, lalu daftarkan di tabel `adapters`.

## Daftar Shortcut (Keymaps)

Tombol **Leader** pada konfigurasi ini diset ke tombol **`Space`** (Spasi).

### 1. Custom Keymaps (Konfigurasi Template)

#### General & Navigasi Window
| Shortcut | Perintah | Deskripsi |
|---|---|---|
| `Leader + w` | `:w` | Simpan file (Save) |
| `Leader + q` | `:q` | Keluar window (Quit) |
| `Esc` | `:nohlsearch` | Bersihkan highlight hasil pencarian |
| `Ctrl + h` | `Ctrl + w` lalu `h` | Pindah fokus ke window sebelah kiri |
| `Ctrl + l` | `Ctrl + w` lalu `l` | Pindah fokus ke window sebelah kanan |
| `Ctrl + j` | `Ctrl + w` lalu `j` | Pindah fokus ke window bawah |
| `Ctrl + k` | `Ctrl + w` lalu `k` | Pindah fokus ke window atas |
| `Leader + ts` | Onedark toggle | Ganti style Onedark (`dark`, `darker`, `cool`, `deep`, `warm`, `warmer`, `light`) |

#### File Explorer & Fuzzy Finder (Telescope)
| Shortcut | Plugin | Deskripsi |
|---|---|---|
| `Leader + e` | NvimTree | Toggle sidebar file explorer |
| `Leader + E` | Neo-tree | Toggle Neo-tree (alternatif opsional) |
| `Leader + ff` | Telescope | Cari file berdasarkan nama (`find_files`) |
| `Leader + fg` | Telescope | Cari kata/teks di seluruh project (`live_grep`) |
| `Leader + fb` | Telescope | Cari daftar buffer yang sedang terbuka |
| `Leader + fh` | Telescope | Cari dokumentasi help tags |

#### LSP (Language Server Protocol)
| Shortcut | Perintah | Deskripsi |
|---|---|---|
| `gd` | `vim.lsp.buf.definition` | Lompat ke lokasi definisi fungsi/variabel |
| `K` | `vim.lsp.buf.hover` | Tampilkan pop-up dokumentasi/tipe di bawah kursor |
| `Leader + rn` | `vim.lsp.buf.rename` | Rename nama simbol di seluruh project |
| `Leader + ca` | `vim.lsp.buf.code_action` | Tampilkan menu saran perbaikan (code action) |
| `[d` | `vim.diagnostic.goto_prev` | Lompat ke error/diagnostic sebelumnya |
| `]d` | `vim.diagnostic.goto_next` | Lompat ke error/diagnostic berikutnya |

#### Hop (Navigasi Cepat Teks)
| Shortcut | Perintah | Deskripsi |
|---|---|---|
| `Leader + hw` | `HopWord` | Lompat cepat ke kata tertentu di dalam buffer |
| `Leader + hl` | `HopLine` | Lompat cepat ke baris tertentu |

#### Git Integration
| Shortcut | Plugin | Deskripsi |
|---|---|---|
| `Leader + gs` | Fugitive | Buka panel interaktif Git status (`:Git`) |
| `Leader + gd` | Diffview | Buka tampilan Git diff seluruh project |
| `Leader + gh` | Diffview | Buka histori commit & diff file saat ini |

#### Testing (Neotest)
| Shortcut | Perintah | Deskripsi |
|---|---|---|
| `Leader + tn` | `run.run()` | Jalankan unit test terdekat dari kursor |
| `Leader + tf` | `run.run(file)` | Jalankan semua test di file ini |
| `Leader + to` | `output.open()` | Buka window hasil/output eksekusi test |
| `Leader + ts` | `summary.toggle()` | Toggle panel ringkasan test |

#### Mini.nvim (Editing Utilities)
| Shortcut | Modul | Deskripsi |
|---|---|---|
| `gcc` | Mini.comment | Toggle komentar pada baris saat ini |
| `gc` | Mini.comment | Toggle komentar pada pilihan Visual mode |
| `sa` | Mini.surround | Tambahkan tanda kurung/kutip mengelilingi teks |
| `sd` | Mini.surround | Hapus tanda kurung/kutip pengeliling |
| `sr` | Mini.surround | Ganti tanda kurung/kutip pengeliling |

---

### 2. Shortcut Bawaan Neovim (Default Keymaps)

#### Navigasi Kursor & Layar
| Shortcut | Pergerakan / Fungsi |
|---|---|
| `h` / `j` / `k` / `l` | Kiri / Bawah / Atas / Kanan |
| `w` / `b` / `e` | Maju per kata / Mundur per kata / Ke akhir kata |
| `0` / `$` / `^` | Ke awal baris / Ke akhir baris / Ke karakter pertama non-spasi |
| `gg` / `G` | Ke awal dokumen (baris 1) / Ke paling akhir dokumen |
| `Ctrl + u` / `Ctrl + d` | Scroll setengah layar ke atas / ke bawah |
| `Ctrl + f` / `Ctrl + b` | Scroll satu layar penuh ke bawah / ke atas |
| `%` | Lompat ke kurung pasangannya `()`, `{}`, `[]` |

#### Editing & Manipulasi Teks
| Shortcut | Fungsi |
|---|---|
| `i` / `a` | Masuk Insert mode sebelum kursor / setelah kursor |
| `o` / `O` | Buat baris baru & masuk Insert mode di bawah / di atas baris |
| `x` / `dw` / `dd` | Hapus 1 karakter / Hapus 1 kata / Hapus 1 baris |
| `yy` / `y$` | Copy (yank) 1 baris / Copy dari kursor sampai akhir baris |
| `p` / `P` | Paste setelah kursor / sebelum kursor |
| `u` / `Ctrl + r` | Undo / Redo perubahan terakhir |
| `.` | Ulangi (repeat) perintah edit terakhir |

#### Mode Visual (Selection)
| Shortcut | Fungsi |
|---|---|
| `v` | Masuk Visual mode (pilihan karakter) |
| `V` | Masuk Visual Line mode (pilihan baris) |
| `Ctrl + v` | Masuk Visual Block mode (pilihan blok/kolom tegak lurus) |
| `y` / `d` / `c` | Copy / Delete / Change teks yang dipilih |

#### Pencarian & Penggantian (Search & Replace)
| Shortcut | Fungsi |
|---|---|
| `/pattern` | Cari `pattern` ke depan (`n` berikutnya, `N` sebelumnya) |
| `?pattern` | Cari `pattern` ke belakang |
| `*` / `#` | Cari kata di bawah kursor ke arah depan / belakang |
| `:%s/old/new/g` | Ganti semua kata `old` menjadi `new` di seluruh file |

#### Manajemen Window & Split
| Shortcut | Fungsi |
|---|---|
| `:sp` / `:vsp` | Split window secara horizontal / vertikal |
| `Ctrl + w` lalu `w` | Pindah fokus ke window berikutnya |
| `Ctrl + w` lalu `c` | Tutup window yang sedang aktif |
| `Ctrl + w` lalu `o` | Tutup semua window lain (Close Others) |
| `Ctrl + w` lalu `=` | Ratakan ukuran seluruh split window |
