# Lightweight & High-Performance Neovim Config for ThinkPad X220

A modern, full-featured, yet lightweight Neovim configuration built for senior full-stack development on older hardware (Intel Core i7 2nd Gen, 8GB RAM, SSD) running **Arch Linux**.

---

##  Key Features & Performance Details

- **Sub-25ms Startup Time:** Loads only **2 out of 18 plugins** (`lazy.nvim` and a compiled version of the `Catppuccin` theme) on initial launch. All other integrations are loaded on-demand.
- **`fzf-lua` over Telescope:** Interfaces with the native, compiled `fzf` binary. File searches and workspace greps are virtually instantaneous and consume very little RAM.
- **Hybrid File Explorer Setup:** Provides both **`oil.nvim`** (buffer-style explorer mapped to `-` for quick edits) and **`neo-tree.nvim`** (classic sidebar explorer on the left mapped to `<Space> + e`). Both are lazy-loaded to keep startup fast.
- **CPU Safeguards:** 
  - Real-time syntax highlighting (Treesitter) automatically disables itself on files larger than **100KB** or **5,000 lines**.
  - Autocomplete (`nvim-cmp`) debounces keystrokes by **100ms** and limits list results to **10 items** to prevent key stutter.
  - Lints and diagnostic calculations are paused during active typing (`update_in_insert = false`).

---

##  Quick Installation

### 1. Install System Dependencies
Since this configuration delegates search and compilations to optimized system tools (written in C, Go, and Rust), install them via Arch's package manager first:

```bash
sudo pacman -S git ripgrep fd fzf make gcc npm python-pip
```

### 2. Symlink the Configuration
Link this repository to your Neovim config directory:

```bash
# Backup your existing config if you have one
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null

# Clone or symlink this directory
ln -s /home/x/Documents/programming/neovim ~/.config/nvim
```

Upon launching Neovim (`nvim`), `lazy.nvim` will automatically clone and install the remaining plugins.

---

##  Keyboard Shortcuts Cheat Sheet

All custom commands use **`<Space>`** as the leader key.

### General Navigation & Pane Management
| Keybinding | Mode | Action |
|:---|:---:|:---|
| **`<Ctrl> + h / j / k / l`** | Normal | Move cursor to Left / Down / Up / Right window split |
| **`<Ctrl> + Arrows`** | Normal | Resize window boundaries (Up, Down, Left, Right) |
| **`<Shift> + h`** | Normal | Go to **previous** buffer (tab left) |
| **`<Shift> + l`** | Normal | Go to **next** buffer (tab right) |
| **`<Space> + w`** | Normal | Save current file (`:w`) |
| **`<Space> + q`** | Normal | Close current window (`:q`) |
| **`<Space> + c`** | Normal | Close current buffer/file (`:bd`) |
| **`<Esc><Esc>`** | Terminal | Switch to Normal mode inside the built-in terminal |

### File Search & Exploration
| Keybinding | Mode | Action |
|:---|:---:|:---|
| **`<Space> + e`** | Normal | Toggle **Neo-tree** (classic sidebar directory explorer) |
| **`-`** | Normal | Open parent directory in **Oil.nvim** (text-buffer mode) |
| **`<Space> + ff`** | Normal | Fuzzy search files by name (using `fd`) |
| **`<Space> + fg`** | Normal | Fuzzy search text inside all files (using `ripgrep`) |
| **`<Space> + fb`** | Normal | Search currently open buffers |
| **`<Space> + fs`** | Normal | Search workspace for the word currently under cursor |
| **`<Space> + fr`** | Normal | Resume the last `fzf-lua` search |
| **`<Space> + h`** or **`<Esc>`** | Normal | Clear highlighting of search matches |

### Text Editing Utilities
| Keybinding | Mode | Action |
|:---|:---:|:---|
| **`J`** | Visual | Move selected lines/blocks **down** |
| **`K`** | Visual | Move selected lines/blocks **up** |
| **`<`** | Visual | Shift text left (keeps selection active for multiple indents) |
| **`>`** | Visual | Shift text right (keeps selection active) |
| **`<Ctrl> + d`** | Normal | Scroll page down (keeps cursor centered `zz`) |
| **`<Ctrl> + u`** | Normal | Scroll page up (keeps cursor centered `zz`) |

### Autocomplete (`nvim-cmp`)
| Keybinding | Mode | Action |
|:---|:---:|:---|
| **`<Ctrl> + j / k`** | Insert | Navigate down / up autocomplete popup menu |
| **`<Ctrl> + Space`** | Insert | Manually trigger autocomplete suggestions |
| **`<Ctrl> + e`** | Insert | Close completion menu |
| **`<CR>` (Enter)** | Insert | Confirm suggestion |
| **`<Tab>`** | Insert/Select | Next item or jump forward in Snippet template |
| **`<Shift> + Tab`** | Insert/Select | Previous item or jump backward in Snippet template |

### LSP & Full-Stack Development
These keymaps attach dynamically only when a language server is running in your current buffer.

| Keybinding | Mode | Action |
|:---|:---:|:---|
| **`K`** | Normal | Show documentation / type signatures on hover |
| **`gd`** | Normal | Jump to symbol definition |
| **`gD`** | Normal | Jump to symbol declaration |
| **`gi`** | Normal | Jump to implementation |
| **`gr`** | Normal | Find all references of symbol |
| **`<Space> + rn`** | Normal | Rename symbol workspace-wide |
| **`<Space> + ca`** | Normal/Visual | Trigger code actions / quick-fixes |
| **`<Space> + d`** | Normal | Show diagnostics (errors/warnings) under cursor in a float |
| **`[d` / `]d`** | Normal | Go to previous / next diagnostic error |

---

##  Managing Language Servers (LSPs) & Tooling

This setup utilizes **Mason** to manage servers automatically. To add support for JS/TS, Python, HTML, Go, etc.:

1. Type `:Mason` inside Neovim.
2. Search for the tool or server you need (e.g., `typescript-language-server`, `pyright`, `tailwindcss-language-server`).
3. Press `i` to install it.
4. Once installed, it is configured to auto-start and map shortcuts dynamically.
