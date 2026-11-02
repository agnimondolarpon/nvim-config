#!/usr/bin/env bash
# ------------------------------------------------------------------
# Neovim config installer for Termux (Android) and Linux.
#
#   ./install.sh                 install everything (asks before big steps)
#   ./install.sh --yes           no questions
#   ./install.sh --dry-run       show what would happen, change nothing
#   ./install.sh --help          all options
#
# What it does:
#   1. installs the packages this config needs (per package, so one
#      missing package never stops the rest)
#   2. makes sure Neovim is new enough (>= 0.11)
#   3. optionally installs language servers / formatters via npm
#   4. optionally installs a Nerd Font (file icons)
#   5. links this folder to ~/.config/nvim (old config is backed up)
#   6. downloads all plugins
# ------------------------------------------------------------------
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_TARGET="$CONFIG_HOME/nvim"
MIN_NVIM="0.11"
MIN_TS_CLI="0.26.1"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

ASSUME_YES=0
DRY_RUN=0
WITH_DEPS=1
WITH_NPM=1
WITH_FONT=1
WITH_EXTRA=0
DO_UNINSTALL=0

PLATFORM=""
PM=""
SUDO=""
SKIPPED=()

# ---------- output helpers ----------
if [[ -t 1 ]]; then
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'; C_BOLD=$'\033[1m'; C_OFF=$'\033[0m'
else
  C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_BOLD=""; C_OFF=""
fi

info() { printf '%s==>%s %s\n' "$C_BLUE$C_BOLD" "$C_OFF" "$*"; }
ok()   { printf '%s ok%s  %s\n' "$C_GREEN" "$C_OFF" "$*"; }
warn() { printf '%swarn%s %s\n' "$C_YELLOW" "$C_OFF" "$*" >&2; }
die()  { printf '%serror%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit 1; }

trap 'printf "%serror%s unexpected failure near line %s\n" "$C_RED" "$C_OFF" "$LINENO" >&2' ERR

usage() {
  cat <<USAGE
Usage: ./install.sh [options]

Options:
  -y, --yes         answer "yes" to every question
  -n, --dry-run     print the commands instead of running them
      --no-deps     do not install system packages
      --no-npm      do not install language servers / formatters (npm)
      --no-font     do not install a Nerd Font
      --extra       also install Go, Rust and Java toolchains
      --uninstall   remove the link and restore the newest backup
  -h, --help        show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes)      ASSUME_YES=1 ;;
    -n|--dry-run)  DRY_RUN=1 ;;
    --no-deps)     WITH_DEPS=0 ;;
    --no-npm)      WITH_NPM=0 ;;
    --no-font)     WITH_FONT=0 ;;
    --extra)       WITH_EXTRA=1 ;;
    --uninstall)   DO_UNINSTALL=1 ;;
    -h|--help)     usage; exit 0 ;;
    *)             usage; die "unknown option: $1" ;;
  esac
  shift
done

# ---------- generic helpers ----------
have() { command -v "$1" >/dev/null 2>&1; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '  + %s\n' "$*"
    return 0
  fi
  "$@"
}

# ask "question" default(y|n)
ask() {
  local question="$1" default="${2:-y}" reply
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    return 0
  fi
  if [[ ! -t 0 ]]; then
    [[ "$default" == "y" ]]
    return
  fi
  if [[ "$default" == "y" ]]; then
    read -r -p "$question [Y/n] " reply
    [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
  else
    read -r -p "$question [y/N] " reply
    [[ "$reply" =~ ^[Yy] ]]
  fi
}

# version_ge A B  ->  true when A >= B
version_ge() {
  [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

# ---------- platform detection ----------
detect_platform() {
  if [[ -n "${TERMUX_VERSION:-}" || "${PREFIX:-}" == *"com.termux"* ]]; then
    PLATFORM="termux"
    PM="pkg"
    return
  fi

  [[ "$(uname -s)" == "Linux" ]] || die "Only Termux and Linux are supported (found: $(uname -s))."
  PLATFORM="linux"

  if have apt-get; then PM="apt"
  elif have dnf; then PM="dnf"
  elif have pacman; then PM="pacman"
  elif have zypper; then PM="zypper"
  else PM=""
  fi

  if [[ "$EUID" -ne 0 ]]; then
    if have sudo; then
      SUDO="sudo"
    else
      SUDO=""
    fi
  fi
}

# ---------- package lists ----------
CORE=(); DEV=(); EXTRA=()

set_package_lists() {
  case "$PM" in
    pkg)
      CORE=(neovim git curl tar unzip make clang ripgrep fd)
      DEV=(nodejs python tree-sitter lua-language-server stylua shfmt termux-api)
      EXTRA=(golang rust rust-analyzer openjdk-17)
      ;;
    apt)
      CORE=(neovim git curl tar unzip make clang ripgrep fd-find)
      DEV=(nodejs npm python3 clangd clang-format shfmt lua-language-server)
      EXTRA=(golang-go rustc cargo rust-analyzer default-jdk-headless)
      ;;
    dnf)
      CORE=(neovim git curl tar unzip make clang clang-tools-extra ripgrep fd-find)
      DEV=(nodejs npm python3 shfmt lua-language-server)
      EXTRA=(golang rust cargo rust-analyzer java-latest-openjdk-devel)
      ;;
    pacman)
      CORE=(neovim git curl tar unzip make clang ripgrep fd)
      DEV=(nodejs npm python tree-sitter-cli lua-language-server stylua shfmt)
      EXTRA=(go rust rust-analyzer jdk-openjdk)
      ;;
    zypper)
      CORE=(neovim git curl tar unzip make clang clang-tools ripgrep fd)
      DEV=(nodejs npm python3 shfmt)
      EXTRA=(go rust rust-analyzer java-17-openjdk-devel)
      ;;
  esac
}

pm_refresh() {
  case "$PM" in
    pkg)    run pkg update -y || warn "pkg update failed (continuing)" ;;
    apt)    run $SUDO apt-get update || warn "apt-get update failed (continuing)" ;;
  esac
}

pm_install_one() {
  case "$PM" in
    pkg)    run pkg install -y "$1" ;;
    apt)    run $SUDO apt-get install -y "$1" ;;
    dnf)    run $SUDO dnf install -y "$1" ;;
    pacman) run $SUDO pacman -S --needed --noconfirm "$1" ;;
    zypper) run $SUDO zypper --non-interactive install "$1" ;;
  esac
}

# Installs one package at a time, so an unknown package only skips itself.
install_packages() {
  local pkg
  for pkg in "$@"; do
    if pm_install_one "$pkg"; then
      ok "$pkg"
    else
      warn "could not install: $pkg (skipped)"
      SKIPPED+=("$pkg")
    fi
  done
}

# ---------- Neovim ----------
nvim_version() {
  have nvim || { echo "0"; return; }
  nvim --version | head -n1 | sed -E 's/^NVIM v?([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/'
}

ensure_nvim() {
  local current
  current="$(nvim_version)"

  if version_ge "$current" "$MIN_NVIM"; then
    ok "Neovim $current"
    return
  fi

  warn "Neovim $MIN_NVIM or newer is required (found: $current)"

  if [[ "$PLATFORM" == "termux" ]]; then
    warn "Run: pkg update && pkg upgrade -y && pkg install neovim"
    return
  fi

  local arch
  case "$(uname -m)" in
    x86_64)          arch="x86_64" ;;
    aarch64|arm64)   arch="arm64" ;;
    *)
      warn "No prebuilt Neovim for $(uname -m). Install a newer Neovim yourself."
      return
      ;;
  esac

  if ! ask "Download the latest official Neovim into ~/.local/opt?" y; then
    warn "Skipped. Install Neovim >= $MIN_NVIM yourself."
    return
  fi

  local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.tar.gz"
  local tmp="/tmp/nvim-linux-$arch.tar.gz"

  run mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  run curl -fL "$url" -o "$tmp"
  run tar -xzf "$tmp" -C "$HOME/.local/opt"
  run ln -sfn "$HOME/.local/opt/nvim-linux-$arch/bin/nvim" "$HOME/.local/bin/nvim"
  ok "Neovim installed to ~/.local/opt/nvim-linux-$arch"
  warn "Make sure ~/.local/bin comes first in your PATH."
}

# ---------- language servers / formatters (npm) ----------
NPM_PACKAGES=(
  typescript
  typescript-language-server
  vscode-langservers-extracted
  bash-language-server
  yaml-language-server
  pyright
  prettier
)

npm_global() {
  if [[ "$PLATFORM" == "termux" ]]; then
    run npm install -g "$@"
  else
    run npm install -g --prefix "$HOME/.local" "$@"
  fi
}

install_npm_tools() {
  if ! have npm; then
    warn "npm not found, skipping language servers (install nodejs first)"
    return
  fi

  info "Installing language servers and prettier via npm"

  if npm_global "${NPM_PACKAGES[@]}"; then
    ok "npm tools installed"
    return
  fi

  warn "batch install failed, trying one by one"
  local pkg
  for pkg in "${NPM_PACKAGES[@]}"; do
    if npm_global "$pkg"; then
      ok "$pkg"
    else
      warn "could not install: $pkg (skipped)"
      SKIPPED+=("npm:$pkg")
    fi
  done
}

# ---------- treesitter CLI ----------
ensure_tree_sitter() {
  if ! have tree-sitter && [[ "$PLATFORM" == "linux" && "$WITH_NPM" -eq 1 ]] && have npm; then
    info "Installing tree-sitter CLI via npm"
    run npm install -g --prefix "$HOME/.local" tree-sitter-cli \
      || warn "could not install tree-sitter-cli"
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    return
  fi

  if ! have tree-sitter; then
    warn "tree-sitter CLI not found. Syntax highlighting parsers (:TSInstallMine) will not install."
    return
  fi

  local ver
  ver="$(tree-sitter --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)"

  if [[ -n "$ver" ]] && version_ge "$ver" "$MIN_TS_CLI"; then
    ok "tree-sitter CLI $ver"
  else
    warn "tree-sitter CLI ${ver:-unknown} is older than $MIN_TS_CLI. :TSInstallMine will refuse to run."
  fi
}

# ---------- Nerd Font ----------
install_font() {
  info "Nerd Font (needed for file icons)"

  if ! have curl || ! have unzip; then
    warn "curl and unzip are required for the font download, skipping"
    return
  fi

  if ! ask "Install JetBrainsMono Nerd Font?" y; then
    return
  fi

  local tmp="/tmp/nvim-config-font"
  run rm -rf "$tmp"
  run mkdir -p "$tmp"
  run curl -fL "$FONT_URL" -o "$tmp/font.zip"
  run unzip -oq "$tmp/font.zip" -d "$tmp/files"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    return
  fi

  if [[ "$PLATFORM" == "termux" ]]; then
    local font
    font="$(find "$tmp/files" -name 'JetBrainsMonoNerdFontMono-Regular.ttf' | head -n1)"
    [[ -n "$font" ]] || font="$(find "$tmp/files" -name '*NerdFont-Regular.ttf' | head -n1)"
    [[ -n "$font" ]] || { warn "font file not found in the archive"; return; }

    mkdir -p "$HOME/.termux"
    cp "$font" "$HOME/.termux/font.ttf"
    have termux-reload-settings && termux-reload-settings
    ok "font installed (~/.termux/font.ttf). Restart Termux if icons look wrong."
  else
    mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    find "$tmp/files" -name '*.ttf' -exec cp {} "$HOME/.local/share/fonts/JetBrainsMonoNerdFont/" \;
    have fc-cache && fc-cache -f >/dev/null 2>&1
    ok "font installed. Select 'JetBrainsMono Nerd Font' in your terminal settings."
  fi
}

# ---------- link config ----------
link_config() {
  info "Linking $REPO_DIR -> $NVIM_TARGET"

  run mkdir -p "$CONFIG_HOME"

  if [[ -L "$NVIM_TARGET" && "$(readlink -f "$NVIM_TARGET")" == "$REPO_DIR" ]]; then
    ok "already linked"
    return
  fi

  if [[ -e "$NVIM_TARGET" || -L "$NVIM_TARGET" ]]; then
    local backup="$NVIM_TARGET.bak.$(date +%Y%m%d%H%M%S)"
    warn "existing config found, moving it to $backup"
    run mv "$NVIM_TARGET" "$backup"
  fi

  run ln -s "$REPO_DIR" "$NVIM_TARGET"
  ok "linked"
}

sync_plugins() {
  info "Downloading plugins (first run, this can take a few minutes)"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '  + nvim --headless "+Lazy! install" +qa\n'
    return
  fi

  have nvim || { warn "nvim not found, skipping plugin download"; return; }

  local timeout_cmd=()
  have timeout && timeout_cmd=(timeout 900)

  if "${timeout_cmd[@]+"${timeout_cmd[@]}"}" nvim --headless "+Lazy! install" +qa; then
    ok "plugins installed"
  else
    warn "plugin download did not finish. Open nvim and run :Lazy to retry."
  fi
}

# ---------- uninstall ----------
do_uninstall() {
  info "Uninstalling"

  if [[ -L "$NVIM_TARGET" && "$(readlink -f "$NVIM_TARGET")" == "$REPO_DIR" ]]; then
    run rm "$NVIM_TARGET"
    ok "link removed"
  else
    warn "$NVIM_TARGET is not linked to this repository, leaving it alone"
  fi

  local latest
  latest="$(ls -d "$NVIM_TARGET".bak.* 2>/dev/null | sort | tail -n1 || true)"

  if [[ -n "$latest" && ! -e "$NVIM_TARGET" ]]; then
    run mv "$latest" "$NVIM_TARGET"
    ok "restored $latest"
  fi

  info "Plugins and caches were kept. Remove them with:"
  printf '  rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim\n'
}

# ---------- main ----------
main() {
  detect_platform

  if [[ "$DO_UNINSTALL" -eq 1 ]]; then
    do_uninstall
    exit 0
  fi

  info "Platform: $PLATFORM${PM:+ (package manager: $PM)}"
  [[ "$DRY_RUN" -eq 1 ]] && warn "dry run: nothing will be changed"

  if [[ "$WITH_DEPS" -eq 1 ]]; then
    if [[ -z "$PM" ]]; then
      warn "no supported package manager found, skipping packages"
    elif [[ "$PLATFORM" == "linux" && "$EUID" -ne 0 && -z "$SUDO" ]]; then
      warn "need root or sudo to install packages, skipping packages"
    else
      set_package_lists
      info "Refreshing package index"
      pm_refresh
      info "Installing core packages"
      install_packages "${CORE[@]}"
      info "Installing development tools"
      install_packages "${DEV[@]}"

      if [[ "$WITH_EXTRA" -eq 1 ]]; then
        info "Installing Go / Rust / Java toolchains"
        install_packages "${EXTRA[@]}"
      fi
    fi
  fi

  ensure_nvim

  if [[ "$WITH_NPM" -eq 1 ]]; then
    install_npm_tools
  fi

  ensure_tree_sitter

  if [[ "$WITH_FONT" -eq 1 ]]; then
    install_font
  fi

  link_config
  sync_plugins

  echo
  info "Done."

  if [[ "${#SKIPPED[@]}" -gt 0 ]]; then
    warn "skipped packages: ${SKIPPED[*]}"
    warn "they are optional; install them by hand later if you need them"
  fi

  if [[ "$PLATFORM" == "linux" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    warn "add this to your shell profile:  export PATH=\"\$HOME/.local/bin:\$PATH\""
  fi

  cat <<NEXT

Next steps:
  1. open nvim
  2. :checkhealth      (check for problems)
  3. :LspServers       (see which language servers are active)
  4. :TSInstallMine    (install syntax parsers, needs tree-sitter CLI >= $MIN_TS_CLI)
NEXT

  if [[ "$PLATFORM" == "termux" ]]; then
    echo "  5. clipboard: install the Termux:API app too (the termux-api package is already installed)"
  fi
}

main "$@"
