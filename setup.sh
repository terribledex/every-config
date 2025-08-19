#!/usr/bin/env bash
set -euo pipefail

# Minimal dotfiles setup: backup and install configs (copy by default, or symlink with --link)
# Usage examples:
#   ./setup.sh --all           # install zsh, tmux, nvim configs (copy)
#   ./setup.sh --zsh --tmux    # install selected configs (copy)
#   ./setup.sh --all --link    # install all using symlinks

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
MODE="copy"  # or "link"

INSTALL_ZSH=false
INSTALL_TMUX=false
INSTALL_NVIM=false

info()  { printf "[setup] %s\n" "$*"; }
warn()  { printf "[setup][warn] %s\n" "$*"; }
err()   { printf "[setup][error] %s\n" "$*" 1>&2; }

backup() {
  local path="$1"
  [[ -e "$path" || -L "$path" ]] || return 0
  mkdir -p "$BACKUP_DIR"
  cp -a "$path" "$BACKUP_DIR/" 2>/dev/null || true
  info "Backed up $(basename "$path") to $BACKUP_DIR"
}

install_file() {
  local src="$1" dest="$2"
  if [[ ! -e "$src" ]]; then
    err "Source not found: $src"; return 1
  fi
  backup "$dest"
  mkdir -p "$(dirname "$dest")"
  if [[ "$MODE" == "link" ]]; then
    ln -snf "$src" "$dest"
    info "Symlinked $dest -> $src"
  else
    cp -f "$src" "$dest"
    info "Copied $src -> $dest"
  fi
}

main() {
  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)   INSTALL_ZSH=true; INSTALL_TMUX=true; INSTALL_NVIM=true ;;
      --zsh)   INSTALL_ZSH=true ;;
      --tmux)  INSTALL_TMUX=true ;;
      --nvim)  INSTALL_NVIM=true ;;
      --link)  MODE="link" ;;
      --help|-h)
        cat <<EOF
Minimal dotfiles installer

Options:
  --all           Install zsh, tmux, nvim configs
  --zsh           Install zsh config
  --tmux          Install tmux config
  --nvim          Install nvim config
  --link          Use symlinks instead of copying
  -h, --help      Show this help

Notes:
- This script does NOT install packages or plugins.
- If you use the provided .zshrc, you likely need Oh My Zsh in ~/.oh-my-zsh.
EOF
        exit 0
        ;;
      *) err "Unknown option: $1"; exit 1 ;;
    esac
    shift
  done

  if ! $INSTALL_ZSH && ! $INSTALL_TMUX && ! $INSTALL_NVIM; then
    err "Nothing to do. Pass --all or components like --zsh --tmux --nvim"
    exit 1
  fi

  # Zsh
  if $INSTALL_ZSH; then
    install_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    [[ -d "$HOME/.oh-my-zsh" ]] || warn "Oh My Zsh not found at ~/.oh-my-zsh (the .zshrc expects it)"
  fi

  # Tmux
  if $INSTALL_TMUX; then
    install_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
  fi

  # Neovim
  if $INSTALL_NVIM; then
    install_file "$DOTFILES_DIR/nvim/.nvim.conf" "$HOME/.config/nvim/init.lua"
  fi

  info "Done. Backup (if any) is at: $BACKUP_DIR"
}

main "$@"
