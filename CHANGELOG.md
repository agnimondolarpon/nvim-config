# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-11-02

### Added
- Modular configuration split into `lua/config` (core) and `lua/plugins` (one file per plugin).
- Formatting with conform.nvim: Google C++ style for both C and C++ (clang-format), plus
  Python, web, Lua, shell, Go and Rust formatters. Format on save with `:FormatToggle`.
- Git integration (gitsigns), automatic bracket pairing (nvim-autopairs),
  key hints (which-key) and session restore (persistence.nvim).
- Language servers for C/C++, Python, JavaScript/TypeScript, HTML, CSS, JSON, Lua,
  Bash, YAML, Go and Rust. A server is enabled only when its program is installed.
- `install.sh` for Termux and Linux (apt, dnf, pacman, zypper) with `--dry-run`,
  automatic backup of an existing config and `--uninstall`.
- Insert mode only with `i` (`:InsertGuard` toggles it).
- VS Code style file icons (nvim-web-devicons).

### Changed
- Swap file and write backup are enabled so unsaved work survives when Android kills Termux.
- C and C++ use 2-space indentation (Google style).
