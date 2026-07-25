# Neovim Config Template — onedark.nvim

Template konfigurasi Neovim (Lua, plugin manager [lazy.nvim](https://github.com/folke/lazy.nvim))
dengan colorscheme [onedark.nvim](https://github.com/navarasu/onedark.nvim), lengkap dengan
semua plugin yang secara eksplisit disebutkan "Supported" di README onedark.nvim, sudah
dikonfigurasi agar warnanya konsisten.

## Requirement

- **Neovim >= 0.12** (wajib — menggunakan built-in treesitter, bukan plugin
  `nvim-treesitter` yang sudah di-archive). Untuk fitur LSP semantic tokens, dsb.
- `git` terpasang di PATH (dipakai lazy.nvim untuk clone plugin).
- `tree-sitter` CLI (dipakai `tree-sitter-manager.nvim` untuk compile parser bahasa).
  Install via: ```bash
npm install -g tree-sitter-cli
```
- `gcc` atau `clang` (C compiler untuk build parser).
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

## Instalasi & Persiapan Graphify (Tool Eksternal)

Graphify berfungsi untuk mengekstrak seluruh arsitektur proyek (_codebase_) menjadi teks ringan yang bisa dipahami AI tanpa membebani memori.

1.  Install uv di terminal laptop Anda: curl -LsSf \[https://astral.sh/uv/install.sh\](https://astral.sh/uv/install.sh) | sh
    
2.  Install Graphify (versi terintegrasi Ollama): uv tool install "graphifyy\[ollama\]"

3.  Beri tahu Graphify di mana lokasi Ollama Anda berada **export OLLAMA_BASE_URL="http://192.168.0.100:11434/v1"**

4.  Setiap kali memulai project, masuk ke folder root project kemudian execute **graphify extact . --backend ollama** agar graphify menggunakan ollama local.

5.  Sugest pertama kali dengan prompt berikut :
````shell
Anda adalah asisten coding yang presisi dan disiplin. Ikuti aturan berikut secara ketat:

1. DESAIN: Sebelum menulis kode, pikirkan struktur/arsitektur singkat (2-3 kalimat) jika perubahan menyentuh lebih dari satu fungsi. Prioritaskan solusi paling sederhana yang benar (KISS), bukan yang paling "pintar".
2. OUTPUT: Jangan mengulang kode yang tidak berubah. Tunjukkan hanya bagian yang diedit (diff/patch style) kecuali diminta full file.
3. TIDAK BOLEH BERHALUSINASI: Jika tidak yakin tentang API/library/fungsi tertentu, katakan "tidak yakin" — jangan mengarang nama fungsi atau parameter.
4. HENTIKAN SAAT SELESAI: Setelah jawaban lengkap, berhenti. Jangan mengulang penjelasan yang sama dengan kalimat berbeda, jangan menambah rekap di akhir.
5. FORMAT: Kode dalam satu blok bahasa yang jelas. Tidak perlu penjelasan panjang kecuali diminta.
6. Jika instruksi ambigu, buat satu asumsi wajar, sebutkan singkat, lalu lanjutkan — jangan bertanya balik kecuali benar-benar tidak bisa dilanjutkan.
````

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
        ├── treesitter.lua        -- Built-in TreeSitter + tree-sitter-manager
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
        ├── illuminate.lua         -- vim-illuminate
        ├── terminal.lua           -- toggleterm.nvim (terminal terintegrasi, mirip VSCode)
        ├── completion.lua         -- nvim-cmp (autocomplete engine + snippets & AI integration)
        └── codecompanion.lua      -- codecompanion.nvim (AI chat & inline edit via Ollama)
```

Setiap file di `lua/plugins/` adalah satu spec `lazy.nvim` yang otomatis ter-load lewat
`{ import = "plugins" }` di `lua/config/lazy.lua` — tinggal tambah file baru untuk plugin
baru, tanpa perlu edit file lain.

## Plugin yang di-cover onedark.nvim, dan status di template ini

| Plugin (README onedark.nvim) | Status | Catatan |
|---|---|---|
| TreeSitter | ✅ Aktif | `treesitter.lua` — built-in Neovim 0.12 + `tree-sitter-manager.nvim` (pengganti `nvim-treesitter` yang sudah archived) |
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
| codecompanion.nvim (Ollama) | ✅ Aktif | `codecompanion.lua`, AI chat sidebar + inline edit via Ollama lokal (experience mirip VSCode Copilot Chat) |
| toggleterm.nvim | ✅ Aktif | `terminal.lua`, terminal terintegrasi dengan toggle shortcut mirip VSCode (`Ctrl+\``) |
| nvim-cmp | ✅ Aktif | `completion.lua`, autocomplete engine untuk LSP, buffer, path, dan perintah AI chat |

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

#### Terminal Terintegrasi (toggleterm.nvim)
| Shortcut | Mode | Deskripsi |
|---|---|---|
| `Leader + tt` | Normal / Terminal | **Toggle terminal di bawah** — panel horizontal mirip VSCode |
| `Leader + tz` | Normal / Terminal | Toggle terminal floating (popup di tengah layar) |
| `Leader + tv` | Normal | Buka terminal vertikal (sidebar kanan) |
| `Leader + tg` | Normal | Buka **Lazygit** di floating terminal |

> `Ctrl+t` tidak dipakai karena terminal emulator (GNOME Terminal, Tilix, dll) mencurinya untuk membuka tab baru sebelum Neovim sempat menerimanya.

**Di dalam terminal:**
| Shortcut | Deskripsi |
|---|---|
| `Esc` | Masuk Normal mode (untuk navigasi atau copy-paste) |
| `Ctrl + h/j/k/l` | Pindah ke window Neovim lain tanpa keluar terminal |

#### AI Coding Assistant (codecompanion.nvim + Ollama & Claude)

> Plugin: [`codecompanion.nvim`](https://github.com/olimorris/codecompanion.nvim) — experience mirip VSCode Copilot Chat.
> **Pilihan Adapter:**
> - **Claude 3.7 (Anthropic) [DEFAULT]**: Model utama dengan kemampuan penalaran & agentic tool calling terbaik. Pastikan `export ANTHROPIC_API_KEY="sk-ant-..."` telah dieksekusi di shell Anda.
> - **Ollama (Lokal)**: Model `qwen2.5-coder:7b` lokal (`http://192.168.0.100:11434`). Tekan `<leader>aT` untuk beralih instan dari Claude ke Ollama.

**Chat & General (Input Context & Setup)**
| Shortcut | Mode | Deskripsi |
|---|---|---|
| `Leader + ac` | Normal / Visual | **Toggle chat sidebar** — buka/tutup panel chat AI di sebelah kanan |
| `Leader + aa` | Normal / Visual | Actions palette — daftar semua aksi AI yang tersedia |
| `Leader + ai` | Normal / Visual | Inline edit — minta AI tulis/edit langsung di buffer |
| `Leader + aT` | Normal / Visual | Toggle adapter antara Ollama (Lokal) / Claude (Anthropic) secara instan |
| `Leader + ab` | Normal / Visual | Tambah buffer file aktif sebagai context ke chat |
| `Leader + aD` | Normal / Visual | Tambah semua file dalam direktori ke chat (akhiri dengan `!` untuk rekursif) |
| `Leader + ag` | Normal / Visual | Tambah laporan arsitektur Graphify (`GRAPH_REPORT.md`) ke chat |

**Shortcut Aksi Koding (Bekerja pada seluruh file aktif atau kode terseleksi)**
| Shortcut | Mode | Deskripsi |
|---|---|---|
| `Leader + ar` | Normal / Visual | Review code — analisis bug, performa, keamanan (tampil di chat) |
| `Leader + af` | Normal / Visual | Fix bugs — perbaiki error (langsung menimpa/replace kode) |
| `Leader + ae` | Normal / Visual | Explain code — jelaskan kode langkah demi langkah (tampil di chat) |
| `Leader + ad` | Normal / Visual | Add documentation — tambahkan komentar/dokumentasi (langsung replace) |
| `Leader + at` | Normal / Visual | Generate tests — buat unit test untuk kode (tampil di chat) |
| `Leader + ao` | Normal / Visual | Refactor code — optimasi readability & performa (langsung replace) |

**Menerapkan / Menolak Hasil Edit Inline (Diff View)**
| Shortcut | Mode | Deskripsi |
|---|---|---|
| `ga` | Normal | **Accept change** — Setujui dan terapkan langsung hasil edit ke buffer kode Anda |
| `gr` | Normal | **Reject change** — Batalkan dan tolak saran edit inline |

**Shortcut di dalam Chat Buffer**
| Shortcut | Mode | Deskripsi |
|---|---|---|
| `Ctrl + s` | Insert | Kirim pesan ke AI |
| `Enter` | Normal | Kirim pesan ke AI |
| `Ctrl + c` | Normal | Stop generation AI |
| `q` | Normal | Tutup / sembunyikan chat sidebar |
| `Tab` / `S-Tab` | Insert | Pilih item pelengkap otomatis (autocomplete) berikutnya / sebelumnya |

> **Autocomplete di Chat Buffer:**
> Saat berada di dalam chat buffer (mode Insert), Anda mendapatkan pelengkapan otomatis secara real-time:
> - Ketik **`/`** untuk memicu autocomplete *Slash Commands* (misal: `/buffer`, `/file`).
> - Ketik **`#`** untuk memicu autocomplete variabel/konteks (misal: `#buffer`, `#clipboard`).
> - Ketik **`@`** untuk memicu autocomplete *Tools* bantu.
>
> **Tips Inline Edit:**
> - Tekan `<leader>ai` (atau shortcut `<leader>af`, `<leader>ad`, `<leader>ao`) di Normal/Visual mode.
> - Setelah AI selesai membuat perbaikan, tekan **`ga`** untuk langsung mengaplikasikannya ke berkas kode Anda.

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
