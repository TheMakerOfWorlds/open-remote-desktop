#!/bin/zsh
emulate -LR zsh
set -euo pipefail

ROOT_DIR="${0:A:h:h}"
APP_PATH="$HOME/Desktop/Open Remote Desktop.app"
SUPPORT_DIR="$HOME/Library/Application Support/Open Remote Desktop"
CONFIG_DIR="$SUPPORT_DIR/config"
CONFIG_FILE="$CONFIG_DIR/local.conf"
BACKUP_DIR="$SUPPORT_DIR/backups"
BIN_DIR="$HOME/bin"
FORCE_CONFIG=0

while (( $# > 0 )); do
  case "$1" in
    --app-path)
      APP_PATH="${2:?--app-path requires a path}"
      shift 2
      ;;
    --force-config)
      FORCE_CONFIG=1
      shift
      ;;
    *)
      echo "Usage: $0 [--app-path PATH] [--force-config]" >&2
      exit 64
      ;;
  esac
done

umask 077
/bin/mkdir -p "$CONFIG_DIR" "$BACKUP_DIR" "$BIN_DIR"

if [[ ! -f "$CONFIG_FILE" || "$FORCE_CONFIG" == "1" ]]; then
  if [[ -f "$CONFIG_FILE" && "$FORCE_CONFIG" == "1" ]]; then
    /bin/cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(/bin/date +%Y%m%d-%H%M%S)"
  fi
  /bin/cp "$ROOT_DIR/config/local.conf.example" "$CONFIG_FILE"
  /bin/chmod 600 "$CONFIG_FILE"
  echo "Created config: $CONFIG_FILE"
  echo "Edit it before launching the app."
else
  echo "Preserved existing config: $CONFIG_FILE"
fi

/bin/cp "$ROOT_DIR/bin/remote-mic-control" "$BIN_DIR/remote-mic-control"
/bin/chmod 755 "$BIN_DIR/remote-mic-control"

TEMP_APP_PATH="${APP_PATH}.installing.$$.app"
BACKUP_PATH=""

cleanup_temp_app() {
  /bin/rm -rf "$TEMP_APP_PATH" >/dev/null 2>&1 || true
}
trap cleanup_temp_app EXIT

"$ROOT_DIR/scripts/build-local-app.sh" "$TEMP_APP_PATH"

if [[ -e "$APP_PATH" ]]; then
  BACKUP_PATH="$BACKUP_DIR/${APP_PATH:t}.backup.$(/bin/date +%Y%m%d-%H%M%S)"
  /bin/mv "$APP_PATH" "$BACKUP_PATH"
  echo "Backed up existing app to: $BACKUP_PATH"
fi

if ! /bin/mv "$TEMP_APP_PATH" "$APP_PATH"; then
  if [[ -n "$BACKUP_PATH" && -e "$BACKUP_PATH" && ! -e "$APP_PATH" ]]; then
    /bin/mv "$BACKUP_PATH" "$APP_PATH" || true
  fi
  echo "Install failed while moving the new app into place." >&2
  exit 1
fi
trap - EXIT

cat > "$BIN_DIR/open-remote-desktop-update" <<EOF
#!/bin/zsh
exec "$(printf '%q' "$ROOT_DIR")/scripts/update.sh" "\$@"
EOF
/bin/chmod 755 "$BIN_DIR/open-remote-desktop-update"

echo "Installed local app: $APP_PATH"
echo "Installed updater: $BIN_DIR/open-remote-desktop-update"
