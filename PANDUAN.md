# Panduan Cepat — Neovim ala VSCode + AI (Claude / Gemini / Copilot)

Panduan ini berorientasi **"mau melakukan apa → tekan apa"**. Daftar lengkap semua shortcut ada di
[README.md](README.md). Tombol **Leader = `Space`**. Tekan `Space` lalu tunggu sebentar: menu
**which-key** menampilkan semua pilihan lanjutan, jadi Anda tidak perlu menghafal.

> Notasi: `Space f f` artinya tekan Space, lalu f, lalu f (berurutan, bukan bersamaan).
> `Ctrl+p` artinya tahan Ctrl sambil menekan p.

---

## 1. Setup sekali saja (±5 menit)

| # | Langkah | Cara |
|---|---|---|
| 1 | Buka nvim, tunggu plugin & server bahasa ter-install | `nvim` (biarkan sampai selesai, cek dengan `:Mason` dan `:Lazy`) |
| 2 | Login GitHub Copilot | Di nvim: `:LspCopilotSignIn`, ikuti kode di browser |
| 3 | Login Gemini | Di terminal: `gemini` (sekali, ikuti login Google) |
| 4 | Login Claude | Di terminal: `claude` (sekali, jika belum) |
| 5 | Isi pengaturan pribadi (opsional: Ollama/Hermes) | `cp lua/ai/local.example.lua lua/ai/local.lua` lalu edit |
| 6 | Cek kesehatan | `:checkhealth sidekick` dan `:checkhealth vim.lsp` |

Prasyarat tool (sudah terpasang di mesin ini): `claude`, `gemini`, `tmux`, `lsof`, `rg`, `fd`, `lazygit`.

---

## 2. Cheat sheet satu halaman

### Harian
| Mau… | Tekan |
|---|---|
| Simpan | `Ctrl+s` |
| Buka file cepat (fuzzy) | `Ctrl+p` |
| Cari teks di seluruh project | `Space f g` |
| Cari kata di bawah kursor | `Space f w` |
| File terakhir dibuka | `Space f r` |
| Command palette | `Space p` |
| Pindah project | `Space f p` |
| Sidebar file (tree) | `Space e` |
| File manager gaya "edit teks" | `Space E` atau `-` |
| Pindah tab buffer | `Shift+l` / `Shift+h` |
| Tutup tab | `Space b d` |
| Terminal bawah | `Space t t` |
| Lazygit | `Space t g` |
| Komentar baris | `Ctrl+/` (atau `gcc`) |
| Pindah baris naik/turun | `Alt+k` / `Alt+j` |

### Koding (LSP)
| Mau… | Tekan |
|---|---|
| Ke definisi | `gd` atau `F12` |
| Lihat semua pemakaian | `gr` |
| Dokumentasi / tipe | `K` |
| Rename simbol | `F2` |
| Perbaikan cepat / code action | `Space c a` |
| Daftar simbol di file | `Space c s` |
| Error berikutnya / sebelumnya | `]d` / `[d` |
| Panel semua error (Problems) | `Space x x` |
| Format | otomatis saat simpan, atau `Space c f` |
| Outline | `Space o` |

### AI
| Mau… | Tekan |
|---|---|
| **Claude Code** (agent utama, terhubung ke editor) | `Space C c` |
| Gemini | `Space G g` |
| Pilih CLI AI lain | `Space G s` |
| Kirim kode terseleksi ke AI CLI | `Space G t` (visual) |
| Chat AI sidebar (Copilot/Claude/Ollama/…) | `Space a c` |
| Edit kode lewat AI langsung di buffer | `Space a i` |
| Terima / tolak edit AI | `ga` / `gr` |
| Terima saran Copilot (abu-abu) | `Alt+l` |
| Terapkan "Next Edit Suggestion" | `Tab` |

---

## 3. Alur kerja (langkah demi langkah)

### A. Mulai bekerja di sebuah project
1. `cd ~/project && nvim` (atau di dalam nvim: `Space f p` untuk pindah project).
2. `Ctrl+p` → ketik sebagian nama file → `Enter`.
3. Ingin kembali ke sesi kemarin (buffer yang terbuka)? `Space q s`.

### B. Mencari & mengganti di seluruh project
1. `Space s r` membuka panel **Search & Replace**.
2. Isi kolom *Search* (boleh regex) dan *Replace*; hasil ter-preview langsung.
3. Tekan `Space r` (di panel itu) untuk menerapkan semua. Tutup panel dengan `:q`.
4. Hanya ingin mengganti kata di bawah kursor? `Space s w`.

### C. Memahami & mengubah kode
- **Lompat**: `gd` ke definisi, `Ctrl+o` kembali, `gr` daftar pemakaian, `gi` implementasi.
- **Rename aman** ke seluruh project: kursor di nama → `F2` → ketik nama baru → `Enter`.
- **Lihat error**: `]d` loncat ke error berikutnya; `Space c d` tampilkan pesan lengkap; `Space x x` daftar semuanya.
- **Perbaiki otomatis**: kursor di error → `Space c a` → pilih perbaikan.
- **Lipat kode**: `zc` lipat, `zo` buka, `zR` buka semua, `zM` lipat semua.
- **Nama fungsi hilang dari layar karena scroll?** Header fungsi/class otomatis menempel di atas (sticky); `[C` lompat ke sana.

### D. Edit banyak tempat sekaligus (multi-cursor)
1. Taruh kursor di sebuah kata → `Ctrl+n` (memilih kata itu).
2. `Ctrl+n` lagi untuk menambah kemunculan berikutnya (seperti `Ctrl+D` di VSCode).
3. `n`/`N` ke berikutnya/sebelumnya, `q` lewati satu, `Q` hapus kursor terakhir.
4. Ketik penggantinya, lalu `Esc` untuk selesai.

### E. Git
- Lihat perubahan di margin kiri (garis hijau/biru/merah). Blame tampil di ujung baris.
- `]h` / `[h` loncat antar perubahan (hunk). `Space h p` pratinjau, `Space h s` stage, `Space h r` batalkan hunk.
- `Space g d` lihat diff seluruh project, `Space g h` riwayat file, `Space t g` Lazygit (commit, rebase, dll).
- `Space g b` / `g c` ganti branch / lihat commit via Telescope.

### F. Debug (seperti VSCode)
1. Taruh breakpoint di baris: `F9`.
2. `F5` mulai/lanjut. Pilih konfigurasi bila ditanya (jika ada `.vscode/launch.json`, otomatis dipakai).
3. `F10` step over, `F11` masuk fungsi, `Shift+F11` keluar. Panel variabel terbuka otomatis.
4. `Space d e` evaluasi ekspresi/seleksi. `F5` lagi untuk lanjut, `Shift+F5` berhenti.
5. Python: dipasang `debugpy` otomatis. JS/TS: `js-debug-adapter`.

### G. Menjalankan test
`Space t n` test terdekat · `Space t f` semua test di file · `Space t o` output · `Space t S` ringkasan.
(Perlu adapter bahasa: lihat komentar di `lua/plugins/neotest.lua`.)

---

## 4. AI: pakai yang mana, kapan, dan caranya

Ada 4 alat AI. Aturan praktisnya:

| Situasi | Pakai | Kunci utama |
|---|---|---|
| Tugas besar / multi-file / jalankan test / "kerjakan fitur ini" | **Claude Code** | `Space C c` |
| Pertanyaan cepat, ingin pilihan model lain, atau second opinion | **Gemini** (atau CLI lain) via sidekick | `Space G g` |
| Edit kecil di kode terpilih, hasilnya langsung terlihat sebagai diff | **CodeCompanion** (inline) | `Space a i` |
| Mengetik kode dan ingin dilengkapi | **Copilot** (ghost text + NES) | `Alt+l`, `Tab` |

### 4.1 Claude Code (terintegrasi ke editor, seperti ekstensi VSCode)
**Cara pakai**
1. Buka file di project, tekan `Space C c` → panel Claude terbuka di kanan dan **otomatis terhubung** ke nvim.
2. Ketik permintaan, mis. *"tambahkan validasi email di fungsi ini"*. Claude tahu file & baris yang sedang Anda buka.
3. **Kirim konteks lebih spesifik**
   - Seleksi kode (`v`) lalu `Space C s` → seleksi dikirim ke Claude.
   - `Space C b` → tambahkan file aktif sebagai konteks.
   - Di file tree (`Space e`) arahkan ke file, `Space C s` → tambahkan file itu.
4. **Review edit Claude**: perubahan dibuka sebagai tampilan diff di nvim.
   `Space C a` = terima, `Space C d` = tolak.
5. Lanjutkan sesi lama: `Space C C` (sesi terakhir) atau `Space C r` (pilih dari daftar). Ganti model: `Space C m`.
6. Pindah kembali ke jendela kode dari panel Claude: `Ctrl+\` lalu `Ctrl+n`, kemudian `Ctrl+h`. Tutup panel: `Space C c` lagi.

> File yang diubah Claude otomatis dimuat ulang di nvim. Jika terlihat tidak berubah, jalankan `:checktime`.

**Claude yang sudah berjalan di terminal/tmux lain?** Di dalam Claude ketik `/ide`, pilih instance Neovim.
Syaratnya dibuka dari folder project yang sama.

### 4.2 Gemini / CLI AI lain (sidekick.nvim) + tmux
**Cara pakai**
1. `Space G g` → Gemini terbuka di kanan (pertama kali butuh login, lihat bagian 1).
   Ingin Claude di sini juga? `Space G c`. Ingin memilih dari semua CLI terpasang? `Space G s`.
2. **Kirim konteks tanpa copy-paste** (Gemini/Claude menerimanya langsung di prompt):
   | Tombol | Yang dikirim |
   |---|---|
   | `Space G t` | Posisi kursor, atau seleksi bila di visual mode |
   | `Space G f` | Seluruh file |
   | `Space G v` | Seleksi saja (visual) |
   | `Space G x` | Daftar error/diagnostics file ini |
   | `Space G p` | Pilih prompt siap pakai (explain, fix, review, tests, …) |
3. Pindah fokus ke panel AI dari mana saja (termasuk saat mengetik): `Ctrl+.`.
4. Tutup panel: `Space G g` lagi. Sesi **tidak mati** — lihat bagian tmux di bawah.

**Kenapa tmux?** Sesi AI dijalankan di dalam tmux. Artinya:
- Menutup panel atau keluar dari nvim **tidak menghentikan** AI yang sedang bekerja.
- Buka nvim lagi → `Space G g` → tersambung kembali ke sesi yang sama (riwayat percakapan utuh).
- Lihat sesi dari terminal biasa: `tmux ls`; masuk langsung: `tmux attach -t <nama>`.
- Menghentikan sesi sepenuhnya: `Space G d` (detach) atau `tmux kill-session -t <nama>`.
- `lsof` dipakai sidekick untuk menemukan sesi yang sudah berjalan.

> Jika nvim sendiri dijalankan di dalam tmux dan `Ctrl+h/j/k/l` terasa bentrok, beri tahu — bisa ditambahkan `vim-tmux-navigator`.

### 4.3 CodeCompanion (chat sidebar & edit inline)
**Chat**
1. `Space a c` buka chat (kanan). Ketik pesan, `Enter` (mode Normal) atau `Ctrl+s` (mode Insert) untuk kirim.
2. Tambah konteks: `Space a b` (file ini), `Space a D` (satu folder), atau di chat ketik `#` lalu pilih `#{buffer}`.
3. Ganti AI: `Space a s` (menu: Claude Code ACP, Gemini ACP, Hermes, Copilot, Claude API, Ollama), `Space a T` putar cepat.
4. Riwayat chat: `Space a h`. Chat baru: `Space a n`.

**Edit inline (paling nyaman untuk perubahan kecil)**
1. Seleksi kode (`V`) → `Space a i` → tulis instruksi → `Enter`.
2. AI menulis perubahan sebagai diff di buffer. **`ga` terima · `gr` tolak.**

**Aksi cepat (seleksi kode lalu tekan)**
`Space a r` review · `a f` perbaiki bug · `a e` jelaskan · `a d` tambah dokumentasi · `a t` buat test · `a o` refactor · `a y` rapikan.

### 4.4 Copilot (saat mengetik)
- **Ghost text** (teks abu-abu): `Alt+l` terima · `Alt+]` / `Alt+[` saran lain · `Ctrl+]` tutup.
- **Next Edit Suggestion (NES)**: Copilot menyarankan perubahan di *tempat lain* di file (mis. mengganti nama yang sama
  di bawah). Muncul sebagai diff kecil; tekan **`Tab`** untuk lompat/terapkan. `Space K n` untuk menyalakan/mematikan.
- Autocomplete biasa (LSP/snippet): menu muncul sendiri; `Tab` / `Shift+Tab` pilih, `Enter` terima, `Ctrl+Space` panggil manual.

---

## 5. Manajemen file dengan oil.nvim
`Space E` membuka direktori sebagai **teks yang bisa diedit**:
- Ganti nama: edit nama baris → simpan (`:w`) → konfirmasi.
- Buat file/folder: tambah baris baru (akhiri `/` untuk folder) → `:w`.
- Hapus: hapus barisnya (`dd`) → `:w` (masuk Trash, tidak permanen).
- Pindah file: potong baris (`dd`), buka direktori tujuan, tempel (`p`), `:w`.
- `-` naik ke direktori induk, `Enter` buka, `g?` bantuan, `q` tutup.

(Sidebar klasik tetap ada: `Space e`, dengan `a` buat, `r` rename, `x`/`c`/`p` potong/salin/tempel, `d` hapus.)

---

## 6. Troubleshooting

| Gejala | Penyebab / solusi |
|---|---|
| Tidak ada autocomplete / LSP | `:LspInfo`, `:Mason` (pastikan server terpasang), `:checkhealth vim.lsp` |
| Ghost text Copilot tidak muncul | Login dulu: `:LspCopilotSignIn`. Cek `:checkhealth sidekick` |
| `Space C c` tidak terhubung ke Claude | Pastikan `claude` ada di PATH (`which claude`); untuk Claude di terminal lain pakai `/ide` |
| Gemini "not installed" | `which gemini` harus menunjuk `~/.local/bin/gemini`; pastikan `~/.local/bin` di PATH |
| Panel AI tidak mau tersambung lagi | `tmux ls` lalu `tmux kill-session -t <nama>`; buka ulang dengan `Space G g` |
| File tidak ter-update setelah AI mengedit | `:checktime` |
| Format saat simpan mengganggu | `:FormatToggle` (nyala/mati) |
| Tombol `Shift+F5`/`Shift+F11`/`Shift+F12` tidak bereaksi | Terminal tidak mengirimnya. Pakai `:DapTerminate` (stop), `:DapStepOut` (keluar fungsi), `gr` (references) |
| Ikon berupa kotak | Pasang Nerd Font dan set di terminal |
| Plugin rusak setelah update | `:Lazy restore` (kembali ke versi di `lazy-lock.json`) |
| Lupa sebuah shortcut | Tekan `Space` lalu tunggu (which-key), atau `Space f k` (cari semua keymap) |

---

## 7. Mengubah konfigurasi
- Satu file = satu plugin/tema di `lua/plugins/`. Contoh: AI CLI → `sidekick.lua`, `ai-cli.lua`; fitur VSCode → `vscode-like.lua`; LSP → `lsp.lua`.
- Tambah bahasa baru: tambahkan satu baris di tabel `servers` pada `lsp.lua` (mis. `clangd = {}`).
- Tambah formatter: `formatters_by_ft` di `vscode-like.lua`.
- Pengaturan pribadi (host/IP/key): `lua/ai/local.lua` — tidak ikut git.
