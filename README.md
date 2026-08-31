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
  Install via:
  ```bash
  npm install -g tree-sitter-cli
  # atau via Rust Cargo:
  cargo install tree-sitter-cli
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

3. **Pilihan Backend Graphify saat Memulai Project**:
   Masuk ke folder root project Anda, lalu jalankan salah satu perintah berikut:

   - **A. Menggunakan Claude (Anthropic)**:
     ```bash
     export ANTHROPIC_API_KEY="sk-ant-..."
     graphify extract . --backend claude
     ```

   - **B. Menggunakan OpenAI / Copilot API**:
     ```bash
     export OPENAI_API_KEY="sk-..."
     graphify extract . --backend openai
     ```

   - **C. Menggunakan Ollama (Lokal)**:
     ```bash
     export OLLAMA_BASE_URL="http://192.168.0.100:11434/v1"
     export OLLAMA_API_KEY="ollama"
     graphify extract . --backend ollama
     ```

   - **D. Tanpa LLM / AST Code-Only (Gratis, Instan & Cepat tanpa kuota API)**:
     ```bash
     graphify extract . --code-only
     ```

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

## Panduan Lengkap Penggunaan AI Coding Assistant (Manual AI)

Bagian ini menjelaskan langkah-langkah praktis untuk menggunakan **[codecompanion.lua](file:///home/x/.config/nvim/lua/plugins/codecompanion.lua)** dalam alur kerja harian Anda.

### 1. Memilih dan Mengganti Model AI (Model Switching)
Anda memiliki fleksibilitas penuh untuk mengganti model AI (seperti GPT-4o, Claude, Gemini, dll) atau adapter (Copilot Cloud, Claude Cloud, Ollama Lokal). 

*   **Siklus Cepat Adapter (`<leader>aT`)**: 
    Tekan `<leader>aT` untuk berpindah adapter secara instan: Claude 3.7 Sonnet (Cloud) ➔ GitHub Copilot (Cloud) ➔ Ollama Qwen 7B (Lokal) ➔ Hermes Agent (ACP Local :9119).
*   **Menu Pemilihan Model Copilot (`<leader>am`)**: 
    Jika Anda sedang menggunakan adapter `copilot`, tekan `<leader>am` untuk memunculkan menu visual (Telescope / `vim.ui.select`) berisi pilihan model yang tersedia:
    *   GPT-4o (OpenAI)
    *   Claude 3.5 Sonnet (Anthropic)
    *   Gemini 2.5 Pro (Google)
    *   GPT-4o Mini
    *   o3-mini (Reasoning)
*   **Rotasi Model Copilot (`<leader>aM`)**: 
    Tekan `<leader>aM` untuk berpindah secara sekuensial antar model Copilot tanpa memicu menu pop-up.
*   **Mengedit Settings Header (YAML)**:
    Jika Anda mengaktifkan opsi `show_settings = true` di [codecompanion.lua](file:///home/x/.config/nvim/lua/plugins/codecompanion.lua#L187), akan muncul header YAML di baris teratas buffer chat. Anda bisa langsung mengubah model atau opsi konfigurasi secara manual pada teks tersebut sebelum mengirim pesan.

---

### 2. Cara Mengirim Konteks Kode ke AI
Agar AI memberikan saran yang akurat, Anda harus mengirimkan file atau potongan kode yang relevan sebagai konteks.

#### A. Mengirim Satu File Penuh
*   **Melalui Chat Sidebar:**
    1. Buka file yang ingin ditanyakan.
    2. Tekan **`<leader>ab`** (*Add Buffer to Chat*). Jendela chat sidebar akan otomatis terbuka dan seluruh isi file tersebut dimasukkan sebagai konteks.
    3. Ketik instruksi Anda (misal: *"Tolong optimasikan fungsi utama di file ini"*).
*   **Melalui Variabel Autocomplete (`#{buffer}`)**:
    Di dalam jendela chat buffer, ketik tombol **`#`** untuk memicu dropdown autocomplete. Pilih **`#{buffer}`** untuk melampirkan buffer aktif saat ini sebagai konteks chat. *(Catatan: Pastikan menulis dengan huruf 'f' ganda: `buffer`, bukan `bufer`)*.

#### B. Mengirim Baris Kode Spesifik (Visual Selection)
*   **Melalui Chat Sidebar:**
    1. Buka file, masuk ke Visual Mode (`v` atau `V`), lalu pilih baris-baris kode yang ingin dianalisis.
    2. Tekan **`<leader>ac`** (*Toggle Chat Sidebar*). AI chat akan terbuka di sebelah kanan dan baris kode pilihan Anda otomatis terlampir di sana.
    3. Ketik pertanyaan atau permintaan Anda di bawahnya.
*   **Melalui Inline Edit:**
    1. Seleksi baris kode secara visual.
    2. Tekan **`<leader>ai`** (*Inline Edit*).
    3. Ketik instruksi Anda secara spesifik di baris input prompt (misal: *"Optimasi perulangan ini"*).

#### C. Mengirim Seluruh Direktori / Folder
Jika perubahan kode menyentuh banyak berkas sekaligus, Anda bisa melampirkan seluruh folder:
1. Buka sidebar chat dengan **`<leader>ac`**.
2. Tekan **`<leader>aD`** (*Add Directory to Chat*).
3. Masukkan path folder pada prompt di bawah (contoh: `lua/plugins`). Tambahkan tanda seru `!` di akhir path untuk pencarian rekursif ke dalam sub-folder (contoh: `lua/plugins!`).
4. Semua file teks dalam folder tersebut akan otomatis disalin ke dalam chat buffer sebagai lampiran konteks.

---

### 3. Menerapkan Rekomendasi Kode AI Secara Otomatis
Setelah AI memberikan usulan perbaikan kode, Anda tidak perlu melakukan copy-paste manual. Gunakan metode berikut untuk memperbarui berkas kode Anda:

#### Metode A: Inline Edit & Diff System (Sangat Direkomendasikan)
Ini adalah alur kerja terbaik karena menerapkan kode langsung dengan visualisasi perbedaan (diff):
1. Seleksi kode atau buka file yang ingin diperbaiki, lalu tekan **`<leader>ai`** (Inline Edit).
2. Tulis instruksi Anda dan tekan `<CR>`.
3. AI akan mulai menulis kode perubahan secara langsung di dalam file Anda dengan format git diff (hijau untuk kode baru, merah untuk kode lama).
4. Tekan keymap berikut untuk mengeksekusi aksi:
    *   **`ga`** (*Accept change*): Menyetujui saran AI dan langsung menerapkan perubahan tersebut ke berkas Anda secara permanen.
    *   **`gr`** (*Reject change*): Menolak saran AI dan langsung membatalkan perubahan, mengembalikan kode Anda seperti semula.

#### Metode B: Menyalin Blok Kode dari Chat Sidebar (`gy`)
Jika Anda berdiskusi panjang di sidebar chat (`<leader>ac`) dan AI memberikan rekomendasi dalam sebuah blok kode markdown:
1. Pindahkan kursor Anda ke dalam blok kode yang disarankan di jendela chat.
2. Tekan **`gy`** (*Yank Codeblock*). Blok kode tersebut akan otomatis tersalin ke clipboard sistem.
3. Pindah fokus kembali ke file kode Anda (`Ctrl+h` atau `Ctrl+l`), pilih baris yang akan diganti, lalu lakukan paste (`p`).

#### Metode C: Menggunakan Agentic Tools (`@editor`)
Di dalam chat buffer, Anda dapat memberikan instruksi langsung kepada AI agent untuk memodifikasi file dengan mengetik simbol **`@`** lalu memilih tool **`@editor`** atau **`@cmd_runner`**. AI agent akan menulis/merefactor kode di latar belakang menggunakan tool tersebut atas izin Anda.

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
        ├── copilot.lua            -- zbirenbaum/copilot.lua (GitHub Copilot ghost text auto-completion)
        └── codecompanion.lua      -- codecompanion.nvim (AI chat & inline edit via Claude, Copilot, & Ollama)
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
| codecompanion.nvim | ✅ Aktif | `codecompanion.lua`, AI chat sidebar + inline edit via Claude 3.7, GitHub Copilot, & Ollama lokal |
| copilot.lua | ✅ Aktif | `copilot.lua`, GitHub Copilot ghost text auto-completion di buffer saat mengetik |
| toggleterm.nvim | ✅ Aktif | `terminal.lua`, terminal terintegrasi dengan toggle shortcut mirip VSCode (`Ctrl+\``) |
| nvim-cmp | ✅ Aktif | `completion.lua`, autocomplete engine untuk LSP, buffer, path, dan perintah AI chat |

Yang ditandai "Opsional" sengaja dibuat sebagai alternatif berdampingan (bukan
dijalankan bersamaan), karena fungsinya tumpang tindih dengan plugin lain yang sudah
aktif (dua file explorer / dua indent-guide sekaligus biasanya cuma bikin bentrok
keymap & visual). Tinggal aktifkan salah satu.

## Mengganti Style & Colorscheme

Secara default template ini menggunakan **[vscode.nvim](https://github.com/Mofiqul/vscode.nvim)** (VS Code theme). Anda bisa mengonfigurasinya di [colorscheme.lua](file:///home/x/.config/nvim/lua/plugins/colorscheme.lua).

Untuk berganti antara mode **VS Code Dark** dan **VS Code Light**, tekan shortcut **`<leader>ts`** secara langsung di dalam Neovim.

Jika ingin kembali menggunakan **onedark.nvim**, cukup buka [colorscheme.lua](file:///home/x/.config/nvim/lua/plugins/colorscheme.lua), ubah `lazy = true` pada `vscode.nvim` dan `lazy = false` pada `onedark.nvim`, lalu aktifkan pemanggilan `require("onedark").load()` di konfigurasinya.

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
| `Leader + ts` | Theme toggle | Berpindah antara tema VS Code Dark dan Light |
| `Tab` | `>gv` (Visual Mode) | Indent block kode (geser kanan) & pertahankan seleksi |
| `Shift + Tab` | `<gv` (Visual Mode) | Outdent block kode (geser kiri) & pertahankan seleksi |

#### File Explorer & Fuzzy Finder (Telescope)
| Shortcut | Plugin | Deskripsi |
|---|---|---|
| `Leader + e` | NvimTree | Toggle sidebar file explorer |
| `Leader + E` | Neo-tree | Toggle Neo-tree (alternatif opsional) |
| `Leader + ff` | Telescope | Cari file berdasarkan nama (`find_files`) |
| `Leader + fg` | Telescope | Cari kata/teks di seluruh project (`live_grep`) |
| `Leader + fb` | Telescope | Cari daftar buffer yang sedang terbuka |
| `Leader + fh` | Telescope | Cari dokumentasi help tags |

> **Navigasi & Operasi Berkas di Dalam File Explorer (`NvimTree` / `<leader>e`):**
> Tekan `<leader>e` untuk membuka sidebar, lalu gunakan tombol berikut saat kursor berada di file explorer:
> - **Memindahkan File (`file.php` ke folder lain)**:
>   - **Cara 1 (Rename/Move)**: Tekan **`r`** pada file `file.php` $\rightarrow$ ubah lokasi menjadi `directory/file.php` $\rightarrow$ tekan `Enter`.
>   - **Cara 2 (Cut & Paste)**: Tekan **`x`** pada file $\rightarrow$ pindah kursor ke folder tujuan $\rightarrow$ tekan **`p`**.
>
> | Shortcut (di NvimTree) | Aksi / Deskripsi |
> |---|---|
> | `r` | **Rename / Move** — Ubah nama atau ketik folder tujuan (misal `directory/file.php`) |
> | `x` | **Cut** — Potong file/folder untuk dipindahkan |
> | `c` | **Copy** — Salin file/folder |
> | `p` | **Paste** — Tempel file/folder hasil Cut/Copy ke folder terpilih |
> | `a` | **Add** — Buat file baru (akhiri dengan `/` untuk membuat folder baru) |
> | `d` | **Delete** — Hapus file/folder (dengan konfirmasi `y/n`) |
> | `Enter` / `o` | Buka file atau toggle direktori |
> | `q` | Tutup sidebar file explorer |

#### LSP (Language Server Protocol)
| Shortcut | Perintah | Deskripsi |
|---|---|---|
| `gd` | `vim.lsp.buf.definition` | Lompat ke lokasi definisi fungsi/variabel |
| `K` | `vim.lsp.buf.hover` | Tampilkan pop-up dokumentasi/tipe di bawah kursor |
| `Leader + rn` | `vim.lsp.buf.rename` | Rename nama simbol di seluruh project |
| `Leader + ca` | `vim.lsp.buf.code_action` | Tampilkan menu saran perbaikan (code action) |
| `Leader + cf` | `vim.lsp.buf.format` | Format file / kode terpilih (LSP auto-spacing & styling) |
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
| `Leader + tt` | Normal | **Toggle terminal di bawah** — panel horizontal mirip VSCode |
| `Leader + tz` | Normal | Toggle terminal floating (popup di tengah layar) |
| `Leader + tv` | Normal | Buka terminal vertikal (sidebar kanan) |
| `Leader + tg` | Normal | Buka **Lazygit** di floating terminal |

> `Ctrl+t` tidak dipakai karena terminal emulator (GNOME Terminal, Tilix, dll) mencurinya untuk membuka tab baru sebelum Neovim sempat menerimanya.

**Di dalam terminal:**
| Shortcut | Deskripsi |
|---|---|
| `Esc` + `Esc` | Masuk Normal mode |
| `Alt + h/j/k/l` | Pindah ke window Neovim lain tanpa keluar terminal (`Ctrl+h` dihindari karena menyamai tombol Backspace) |

#### AI Coding Assistant & Autocomplete (codecompanion.nvim + GitHub Copilot, Ollama, & Hermes)

> Plugin: [`codecompanion.nvim`](https://github.com/olimorris/codecompanion.nvim) (Chat & Inline Edit) & [`copilot.lua`](https://github.com/zbirenbaum/copilot.lua) (Ghost Text Autocomplete).
> **Pilihan Adapter Chat / Inline Edit:**
> - **GitHub Copilot (Cloud) [DEFAULT]**: Model utama bawaan (`gpt-4o` / Copilot API). Cukup jalankan `:Copilot auth` untuk login.
> - **Claude 3.7 (Anthropic)**: Model opsional dengan kemampuan penalaran & agentic tool calling. Perlu `export ANTHROPIC_API_KEY="sk-ant-..."`.
> - **Ollama (Lokal)**: Model `qwen2.5-coder:7b` lokal (`http://192.168.0.100:11434`).
> - **Hermes Agent (ACP)**: Agent local via ACP host `http://localhost:9119`.
>
> *Tekan `<leader>aT` untuk beralih instan antar adapter (GitHub Copilot → Ollama 7B → Hermes Agent → Claude 3.7).*
> *Untuk login/autentikasi GitHub Copilot pertama kali, jalankan `:Copilot auth` di Neovim.*

**Chat & General (Input Context & Setup)**
| Shortcut | Mode | Deskripsi |
|---|---|---|
| `Leader + ac` | Normal / Visual | **Toggle chat sidebar** — buka/tutup panel chat AI di sebelah kanan |
| `Leader + an` | Normal / Visual | **Chat Baru (New Chat)** — buka sesi/ruang percakapan AI baru yang kosong |
| `Leader + aa` | Normal / Visual | Actions palette — daftar semua aksi AI yang tersedia |
| `Leader + ai` | Normal / Visual | Inline edit — minta AI tulis/edit langsung di buffer |
| `Leader + ah` | Normal / Visual | **Chat History** — buka daftar riwayat percakapan AI sebelumnya |
| `Leader + aT` | Normal / Visual | Toggle adapter antara Claude (Anthropic) / Copilot (GitHub) / Ollama (Lokal) / Hermes (ACP) secara instan |
| `Leader + am` | Normal / Visual | **Menu Pilih Model Copilot** — tampilkan daftar pilihan model Copilot (`gpt-4o`, `claude-3.5-sonnet`, `gemini-2.5-pro`, dll) |
| `Leader + aM` | Normal / Visual | **Toggle Model Copilot Instan** — berganti cepat antar model Copilot (`gpt-4o` → `claude-3.5-sonnet` → `gemini-2.5-pro` → `gpt-4o-mini` → `o3-mini` → `auto`) |
| `Leader + ab` | Normal / Visual | Tambah buffer file aktif sebagai context ke chat |
| `Leader + aD` | Normal / Visual | Tambah semua file dalam direktori ke chat (akhiri dengan `!` untuk rekursif) |
| `Leader + ag` | Normal / Visual | Tambah laporan arsitektur Graphify (`GRAPH_REPORT.md`) ke chat |

**GitHub Copilot Ghost Text (copilot.lua — Saran Kode Samar Saat Mengetik)**
| Shortcut | Mode | Deskripsi |
|---|---|---|
| `Alt + l` | Insert | **Accept** seluruh saran kode samar (*ghost text*) |
| `Alt + w` | Insert | **Accept 1 kata** berikutnya dari saran |
| `Alt + a` | Insert | **Accept 1 baris** berikutnya dari saran |
| `Alt + ]` | Insert | Lihat saran alternatif **berikutnya** |
| `Alt + [` | Insert | Lihat saran alternatif **sebelumnya** |
| `Ctrl + ]` | Insert | Batalkan/tutup saran samar |

**Shortcut Aksi Koding (Bekerja pada seluruh file aktif atau kode terseleksi)**
| Shortcut | Mode | Deskripsi |
|---|---|---|
| `Leader + ar` | Normal / Visual | Review code — analisis bug, performa, keamanan (tampil di chat) |
| `Leader + af` | Normal / Visual | Fix bugs — perbaiki error (langsung menimpa/replace kode) |
| `Leader + ae` | Normal / Visual | Explain code — jelaskan kode langkah demi langkah (tampil di chat) |
| `Leader + ad` | Normal / Visual | Add documentation — tambahkan komentar/dokumentasi (langsung replace) |
| `Leader + at` | Normal / Visual | Generate tests — buat unit test untuk kode (tampil di chat) |
| `Leader + ao` | Normal / Visual | Refactor code — optimasi readability & performa (langsung replace) |
| `Leader + ay` | Normal / Visual | Beautify code — rapikan spacing, indentasi, & tata letak kode (langsung replace) |

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
| `gh` | Normal | **Browse Chat History** — buka daftar riwayat percakapan yang tersimpan |
| `sc` | Normal | **Save Chat** — simpan sesi chat aktif secara manual |
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
| Shortcut / Command | Jenis | Deskripsi |
|---|---|---|
| `/pattern` | Pencarian | Cari teks/pattern (`n` untuk hasil berikutnya, `N` untuk hasil sebelumnya) |
| `*` / `#` | Pencarian | Cari kata di bawah kursor ke arah depan / belakang |
| `:%s/old/new/g` | Ganti (Buffer) | **Replace All** — Ganti semua kata `old` menjadi `new` di file aktif saat ini |
| `:%s/old/new/gc` | Ganti (Buffer) | **Replace with Confirmation** — Ganti kata `old` menjadi `new` dengan konfirmasi satu per satu (`y` / `n`) |
| `:'<,'>s/old/new/g` | Ganti (Seleksi) | Ganti kata `old` menjadi `new` hanya pada baris yang diseleksi (Visual Mode) |
| `Leader + rn` | Ganti (Project) | **LSP Rename** — Rename nama variabel/fungsi secara aman di seluruh file project sekaligus |

> **Cara Melakukan Replace All di Seluruh File Project (Global Replace):**
> 1. Cari kata yang ingin diganti lewat Telescope: tekan **`<leader>fg`** (live_grep) lalu ketik kata tersebut.
> 2. Kirim hasil pencarian ke panel daftar perbaikan (Quickfix list): tekan **`Ctrl + q`** di Telescope.
> 3. Jalankan perintah penggantian massal berikut:
>    ```vim
>    :cdo %s/kata_lama/kata_baru/g | update
>    ```
>    *(Tekan `Enter`. Semua kecocokan kata di seluruh file proyek akan diganti dan disimpan secara otomatis).*

#### Manajemen Window & Split
| Shortcut | Fungsi |
|---|---|
| `:sp` / `:vsp` | Split window secara horizontal / vertikal |
| `Ctrl + w` lalu `w` | Pindah fokus ke window berikutnya |
| `Ctrl + w` lalu `c` | Tutup window yang sedang aktif |
| `Ctrl + w` lalu `o` | Tutup semua window lain (Close Others) |
| `Ctrl + w` lalu `=` | Ratakan ukuran seluruh split window |
