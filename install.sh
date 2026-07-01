#!/bin/bash
# Installs the paste-to-tmux clipboard/file relay tools into ~/bin.
#
# Two ways to run it:
#
#   1. From a clone (recommended for open source):
#        git clone https://github.com/kentaccn/paste-to-tmux
#        cd paste-to-tmux && ./install.sh
#      Copies the scripts sitting next to this installer.
#
#   2. Piped from a host you control (no clone):
#        curl -fsSL https://YOUR-HOST/install.sh | bash
#      Set PASTE_INSTALL_BASE to the URL the scripts are served from. Prefer
#      HTTPS: over plain HTTP a network attacker can swap the downloaded script,
#      so only ever pipe-to-bash over HTTP on a trusted private network.
set -e

DEST="${PASTE_INSTALL_DEST:-$HOME/bin}"
FILES="paste-to-tmux"

# DEST is written into your shell rc; validate it so a hostile value can't
# inject command substitution there or point the install at a weird path.
case "$DEST" in
  /*) ;;
  *) echo "PASTE_INSTALL_DEST must be an absolute path (got: $DEST)" >&2; exit 1 ;;
esac
case "$DEST" in
  *[\$\`\"\']* | *[[:cntrl:]]*) echo "PASTE_INSTALL_DEST contains unsafe characters" >&2; exit 1 ;;
esac

# Directory this script lives in (empty when piped through a pipe, e.g. curl|bash).
SRC_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

echo "Installing paste-to-tmux tools into $DEST"
mkdir -p -- "$DEST"

for f in $FILES; do
  dst="$DEST/$f"
  # Never write through a symlink (could be pointed at ~/.zshrc etc.).
  if [ -L "$dst" ]; then echo "refusing to install over a symlink: $dst" >&2; exit 1; fi
  if [ -f "$dst" ]; then cp -- "$dst" "$dst.bak.$(date +%s)"; fi
  # Unpredictable temp name so an attacker can't pre-plant a symlink at it.
  tmp=$(mktemp "$DEST/.paste-to-tmux.XXXXXX") || { echo "cannot create a temp file in $DEST" >&2; exit 1; }
  if [ -n "$SRC_DIR" ] && [ -f "$SRC_DIR/$f" ]; then
    cp -- "$SRC_DIR/$f" "$tmp"            # local clone: copy
  else
    BASE="${PASTE_INSTALL_BASE:?set PASTE_INSTALL_BASE to the URL serving the scripts, or run this from a clone}"
    case "$BASE" in
      https://*) ;;
      http://*) echo "WARNING: downloading over plain HTTP ($BASE). A network attacker can swap the payload — only do this on a trusted network." >&2 ;;
      *) echo "PASTE_INSTALL_BASE must be an http(s) URL (got: $BASE)" >&2; exit 1 ;;
    esac
    curl -fsSL -- "$BASE/$f" -o "$tmp"    # remote: download to a temp file first
  fi
  chmod +x "$tmp"
  mv -f -- "$tmp" "$dst"                  # atomic replace
  echo "  installed $f"
done

echo
# --- environment checks (warnings only, never fail the install) ---
if ! command -v pngpaste >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/pngpaste ]; then
  echo "WARNING: pngpaste not found (needed for clipboard-image paste). Install with:  brew install pngpaste"
fi

case ":$PATH:" in
  *":$DEST:"*) ;;
  *)
    # Auto-add DEST to PATH via the user's LOGIN shell rc, idempotently.
    case "${SHELL:-}" in
      *bash) RC="$HOME/.bashrc" ;;
      *)     RC="$HOME/.zshrc" ;;   # macOS default login shell is zsh
    esac
    LINE="export PATH=\"$DEST:\$PATH\""
    if ! grep -qF "$LINE" "$RC" 2>/dev/null; then
      printf '\n# added by paste-to-tmux install\n%s\n' "$LINE" >> "$RC"
      echo "Added $DEST to PATH in $RC"
    fi
    echo "NOTE: open a new terminal, or run:  export PATH=\"$DEST:\$PATH\""
    ;;
esac

echo
echo "Done. Usage:"
echo "  paste-to-tmux <host>            # clipboard image -> active pane; else prompts to drag a file"
echo "  paste-to-tmux <host> -f FILE    # send a specific file/folder"
echo "  paste-to-tmux <host> -l         # list attached panes on <host>"
echo
echo "Tip: run 'paste-to-tmux setup <host>' to create a one-word shortcut for a host."
