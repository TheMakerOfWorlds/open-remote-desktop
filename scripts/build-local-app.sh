#!/bin/zsh
emulate -LR zsh
set -euo pipefail

ROOT_DIR="${0:A:h:h}"
OUT_PATH="${1:-$HOME/Desktop/Open Remote Desktop.app}"
APP_SRC="$ROOT_DIR/apps/local"

/bin/rm -rf "$OUT_PATH"
/usr/bin/osacompile -o "$OUT_PATH" "$APP_SRC/main.applescript"
/bin/cp "$APP_SRC/Info.plist" "$OUT_PATH/Contents/Info.plist"
/bin/cp "$APP_SRC/PkgInfo" "$OUT_PATH/Contents/PkgInfo"
/bin/cp "$APP_SRC/Open Remote Desktop" "$OUT_PATH/Contents/MacOS/Open Remote Desktop"
/bin/chmod 755 "$OUT_PATH/Contents/MacOS/Open Remote Desktop"
/bin/cp "$ROOT_DIR/apps/shared/transfer-progress.jxa" "$OUT_PATH/Contents/Resources/transfer-progress.jxa"
/bin/cp "$ROOT_DIR/assets/icons/OpenRemoteDesktop.icns" "$OUT_PATH/Contents/Resources/OpenRemoteDesktop.icns"
/usr/bin/touch "$OUT_PATH"
/usr/bin/codesign --force --deep --sign - "$OUT_PATH" >/dev/null
/usr/bin/codesign --verify --deep --strict --verbose=2 "$OUT_PATH"

printf 'Built %s\n' "$OUT_PATH"
