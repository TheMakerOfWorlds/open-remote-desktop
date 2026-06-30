#!/bin/zsh
emulate -LR zsh
set -euo pipefail

ROOT_DIR="${0:A:h:h}"
OUT_PATH="${1:-$ROOT_DIR/build/Copy to Primary Mac.app}"
APP_SRC="$ROOT_DIR/apps/reverse"

/bin/mkdir -p "${OUT_PATH:h}"
/bin/rm -rf "$OUT_PATH"
/usr/bin/osacompile -o "$OUT_PATH" "$APP_SRC/main.applescript"
/bin/cp "$APP_SRC/Info.plist" "$OUT_PATH/Contents/Info.plist"
/bin/cp "$APP_SRC/PkgInfo" "$OUT_PATH/Contents/PkgInfo"
/bin/cp "$APP_SRC/Copy to Primary Mac" "$OUT_PATH/Contents/MacOS/Copy to Primary Mac"
/bin/cp "$ROOT_DIR/apps/shared/transfer-progress.jxa" "$OUT_PATH/Contents/Resources/transfer-progress.jxa"
/bin/cp "$ROOT_DIR/assets/icons/CopyToPrimaryMac.icns" "$OUT_PATH/Contents/Resources/CopyToPrimaryMac.icns"
/usr/bin/find "$OUT_PATH" -type d -exec /bin/chmod 755 {} +
/usr/bin/find "$OUT_PATH" -type f -exec /bin/chmod 644 {} +
/bin/chmod 755 "$OUT_PATH/Contents/MacOS/droplet" "$OUT_PATH/Contents/MacOS/Copy to Primary Mac"
/usr/bin/touch "$OUT_PATH"
/usr/bin/codesign --force --deep --sign - "$OUT_PATH" >/dev/null
/usr/bin/codesign --verify --deep --strict --verbose=2 "$OUT_PATH"

printf 'Built %s\n' "$OUT_PATH"
