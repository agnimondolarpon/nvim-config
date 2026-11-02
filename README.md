# nvim-config

A fast, stable and modular **Neovim 0.11+** configuration for **Termux (Android)** and **Linux**.
Tokyo Night theme, LSP for 11 languages, Google-style C/C++ formatting, file explorer with
VS Code style icons, fuzzy finder, git integration and a safe one-command installer.

> Built for working on a phone: touch-keyboard friendly, light on memory, and nothing breaks
> when an optional tool is missing.

## Features

- **Modular** - one small file per concern (`lua/config`) and per plugin (`lua/plugins`).
- **Safe by design** - a broken module or a missing tool is reported, never fatal.
- **LSP** for C/C++, Python, JavaScript/TypeScript, HTML, CSS, JSON, Lua, Bash, YAML, Go and
  Rust. A server is enabled only when its program is installed (`:LspServers` shows the status).
- **Formatting** with [conform.nvim](https://github.com/stevearc/conform.nvim), on save:
  C and C++ share the **Google C++ style** (clang-format), plus Python, web, Lua, shell,
  Go and Rust.
- **Completion** ([nvim-cmp](https://github.com/hrsh7th/nvim-cmp)), **file explorer**
  ([nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)) with per-language icons,
  **fuzzy finder** ([telescope](https://github.com/nvim-telescope/telescope.nvim)),
  **treesitter** highlighting, **git signs**, **auto pairs**, **key hints** and **sessions**.
- **Insert mode only with `i`** - `a`, `o`, `s`, `c`... are disabled so accidental key
  combinations on a touch keyboard never start typing (`:InsertGuard` turns it off).
- **Run files with `<F5>`** - C, C++, Python, JS/TS, Lua, Shell, Go, Rust, Java, Ruby, PHP, Perl.
- **Crash-safe** - swap files stay on, so work survives when Android kills Termux.

## Requirements

| Tool | Why |
|------|-----|
| Neovim **0.11 or newer** | the config uses the built-in LSP API |
| `git` | plugin manager |
| `curl`, `tar`, `unzip` | downloads |
| C compiler (`clang`) | treesitter parsers, running C/C++ with `<F5>` |
| `ripgrep`, `fd` | Telescope search |
| A [Nerd Font](https://www.nerdfonts.com/) | file icons |

`install.sh` installs all of these and more (see below).

## Install

```sh
git clone https://github.com/YOUR_USERNAME/nvim-config.git
cd nvim-config
./install.sh
```

The installer works on **Termux** and on **Debian/Ubuntu (apt), Fedora (dnf), Arch (pacman)
and openSUSE (zypper)**. It:

1. installs the packages (one by one - an unknown package is skipped, not fatal),
2. makes sure Neovim is new enough (downloads the official build on Linux if needed),
3. installs language servers and prettier through npm,
4. installs a Nerd Font (Termux: `~/.termux/font.ttf`),
5. links the repository to `~/.config/nvim` (**an existing config is backed up** to
   `~/.config/nvim.bak.<date>`),
6. downloads all plugins.

Useful options:

```text
./install.sh --dry-run    show what would happen, change nothing
./install.sh --yes        no questions
./install.sh --extra      also install Go, Rust and Java toolchains
./install.sh --no-font    skip the font
./install.sh --no-npm     skip language servers installed with npm
./install.sh --no-deps    skip system packages
./install.sh --uninstall  remove the link and restore your old config
```

Because the config is **linked**, `git pull` inside the repository updates it.

### Manual install

```sh
git clone https://github.com/YOUR_USERNAME/nvim-config.git ~/.config/nvim
nvim
```

### First start

1. Wait while the plugins download.
2. `:checkhealth` - look for problems.
3. `:LspServers` - see which language servers are active.
4. `:TSInstallMine` - compile the treesitter parsers (needs `tree-sitter` CLI >= 0.26.1;
   takes a few minutes on a phone).
5. Commit the generated `lazy-lock.json` (see [Updating](#updating-plugins)).

## Key bindings

`<leader>` is the **Space** key.

### General

| Key | Action |
|-----|--------|
| `<C-s>` | Save (normal, insert, visual) |
| `<C-q>` | Quit |
| `<C-x>` | Save and quit |
| `<C-n>` | **Quit without saving** |
| `<C-d>` | **Delete all text in the file** |
| `<C-a>` | Select all |
| `<leader>q` / `<leader>wq` | Quit / save and quit |
| `<Esc>` | Clear search highlight |
| `<C-h/j/k/l>` | Move between windows |
| `J` / `K` (visual) | Move selected lines down / up |
| `<F5>` | Run the current file |
| `<Esc>` (terminal) | Leave terminal mode |

> **Careful:** `<C-n>` and `<C-d>` can destroy work. Remove or change them in
> `lua/config/keymaps.lua` if you press them by accident.

### Insert mode

| Key | Action |
|-----|--------|
| `i` | The **only** key that starts insert mode |
| `:InsertGuard` | Turn the protection off / on |

Because `c` is disabled, change text with `d` and then `i`.

### Files and search

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>E` | Show the current file in the explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Search text in all files |
| `<leader>fb` | Open buffers |
| `<leader>fr` | Recent files |
| `<leader>fd` | Diagnostics |
| `<leader>fh` | Help pages |

In the explorer: `<CR>` open, `a` new file (end with `/` for a folder), `d` delete,
`r` rename, `c` copy, `x` cut, `p` paste, `?` all keys.
In Telescope: `<C-n>`/`<C-p>` move, `<CR>` open, `<C-v>`/`<C-x>` open in a split, `<Esc>` close.

### Code

| Key | Action |
|-----|--------|
| `K` | Documentation under the cursor |
| `gd` | Go to definition |
| `gr` | Find references |
| `<leader>r` | Rename symbol |
| `<leader>d` | Show diagnostic |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>=` | Format buffer (or selection in visual mode) |
| `gcc` / `gc` | Comment line / selection (built into Neovim) |

Completion (insert mode): `<Tab>`/`<S-Tab>` or `<C-n>`/`<C-p>` select, `<CR>` confirm,
`<C-Space>` open, `<C-e>` close.

### Git

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / previous changed hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk |
| `<leader>hb` | Blame line |
| `<leader>hB` | Toggle inline blame |
| `<leader>hd` | Diff this file |

### Sessions

| Key | Action |
|-----|--------|
| `<leader>ss` | Restore the session of the current folder |
| `<leader>sl` | Restore the last session |
| `<leader>sd` | Do not save this session |

Press `<leader>` and wait a moment: **which-key** lists everything that is available.

## Commands

| Command | Action |
|---------|--------|
| `:LspServers` | Language servers: enabled / not installed |
| `:TSInstallMine` | Install treesitter parsers |
| `:FormatToggle` | Format on save on / off |
| `:ConformInfo` | Formatter status for the current file |
| `:InsertGuard` | Insert-only-with-`i` on / off |
| `:Lazy` | Plugin manager |

## Languages

| Language | Server | Formatter | `<F5>` | Indent |
|----------|--------|-----------|--------|--------|
| C | clangd | clang-format (Google) | clang | 2 |
| C++ | clangd | clang-format (Google) | clang++ | 2 |
| Python | pyright | ruff or black | python | 4 |
| JavaScript / TypeScript | typescript-language-server | prettier | node | 2 |
| HTML / CSS / JSON | vscode-langservers-extracted | prettier | - | 2 |
| YAML | yaml-language-server | prettier | - | 2 |
| Lua | lua-language-server | stylua | nvim -l | 2 |
| Bash | bash-language-server | shfmt | bash | 4 |
| Go | gopls | gofmt | go run | tabs |
| Rust | rust-analyzer | rustfmt | rustc | 4 |
| Java / Ruby / PHP / Perl | - | - | yes | - |

### Google C++ style for C and C++

Google has no separate C style guide, so C files use the same clang-format style as C++.
If a project has its own `.clang-format`, that file wins. Without one, Google style is used.
To pin Google style inside a project:

```sh
clang-format --style=Google -dump-config > .clang-format
```

## Project layout

```text
nvim-config/
├── init.lua                 entry point
├── install.sh               installer (Termux + Linux)
├── lua/
│   ├── config/              core settings
│   │   ├── init.lua         loads every module (with error isolation)
│   │   ├── options.lua      editor options
│   │   ├── lazy.lua         plugin manager bootstrap
│   │   ├── colors.lua       highlight tweaks
│   │   ├── autocmds.lua     indentation rules and helpers
│   │   ├── keymaps.lua      global keymaps
│   │   ├── insert_guard.lua insert mode only with "i"
│   │   ├── diagnostics.lua  diagnostic display
│   │   ├── statusline.lua   statusline with error counters
│   │   ├── lsp.lua          language servers and LSP keys
│   │   └── run.lua          <F5> runner
│   └── plugins/             one file per plugin (loaded by lazy.nvim)
├── .editorconfig
├── .stylua.toml
├── CHANGELOG.md
└── LICENSE
```

## Customize

- **Add a language server:** add `name = "program"` to the `servers` table in
  `lua/config/lsp.lua`.
- **Add a formatter:** add the filetype to `formatters_by_ft` in `lua/plugins/formatting.lua`.
- **Add a plugin:** create `lua/plugins/<name>.lua` that returns a lazy.nvim spec.
- **Change indentation:** edit `lua/config/autocmds.lua`.
- **Run another language with `<F5>`:** add an entry to `runners` in `lua/config/run.lua`.

## Updating plugins

```vim
:Lazy update     " update everything
:Lazy restore    " go back to the versions in lazy-lock.json
```

`lazy-lock.json` pins every plugin to an exact commit. Commit it, and run `:Lazy restore`
if an update ever breaks something.

## Termux notes

- **Icons show as boxes:** the terminal needs a Nerd Font. `install.sh` installs one; restart
  Termux afterwards. Manual way: copy a `*NerdFont*-Regular.ttf` to `~/.termux/font.ttf`
  and run `termux-reload-settings`.
- **Clipboard:** install the *Termux:API* app and `pkg install termux-api`.
- **Treesitter parsers do not install:** `tree-sitter --version` must be 0.26.1 or newer.
  Everything else still works without it (regex highlighting).
- **Termux was killed and you lost your place:** open the file again and choose **R**ecover
  at the swap file prompt, then restore your files with `<leader>sl`.
- **`<leader>` keys feel too fast:** raise `timeoutlen` in `lua/config/options.lua`
  (for example `700`).
- **Mason is not used:** most of its downloads are built for glibc and do not run on Termux.
  Install tools with `pkg` or `npm` instead (the installer does it for you).

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Something looks wrong | `:checkhealth`, then `:messages` |
| A plugin broke after an update | `:Lazy restore` |
| No completion or hover for a language | `:LspServers`, install the missing server |
| Format on save does nothing | `:ConformInfo`, install the formatter |
| Want to start fresh | `rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim` |

## Uninstall

```sh
./install.sh --uninstall
```

removes the link and restores the newest backup of your previous config.

## License

[MIT](LICENSE)
