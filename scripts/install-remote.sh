#!/bin/zsh
emulate -LR zsh
set -euo pipefail

ROOT_DIR="${0:A:h:h}"
SSH_TARGET=""
REMOTE_APP_PATH='Desktop/Copy to Primary Mac.app'

while (( $# > 0 )); do
  case "$1" in
    --ssh)
      SSH_TARGET="${2:?--ssh requires a remote SSH target}"
      shift 2
      ;;
    --remote-app-path)
      REMOTE_APP_PATH="${2:?--remote-app-path requires a path relative to remote home}"
      shift 2
      ;;
    *)
      echo "Usage: $0 --ssh REMOTE_SSH_TARGET [--remote-app-path 'Desktop/Copy to Primary Mac.app']" >&2
      exit 64
      ;;
  esac
done

"$ROOT_DIR/scripts/build-reverse-app.sh" "$ROOT_DIR/build/Copy to Primary Mac.app"

if [[ -z "$SSH_TARGET" ]]; then
  echo "Built reverse app only. Pass --ssh REMOTE_SSH_TARGET to install it on a remote Mac."
  exit 0
fi

REMOTE_CONFIG_DIR='Library/Application Support/Open Remote Desktop/config'
REMOTE_CONFIG_FILE="${REMOTE_CONFIG_DIR}/remote.conf"
REMOTE_BACKUP_DIR='Library/Application Support/Open Remote Desktop/backups'
TMP_REMOTE_EXAMPLE="/tmp/open-remote-desktop-remote.conf.example.$$"
REMOTE_TEMP_APP_PATH="${REMOTE_APP_PATH}.installing.$$"
REMOTE_BACKUP_PATH="${REMOTE_BACKUP_DIR}/${REMOTE_APP_PATH:t}.backup.$(/bin/date +%Y%m%d-%H%M%S)"

/usr/bin/ssh "$SSH_TARGET" "/bin/mkdir -p ~/bin $(printf '%q' "$REMOTE_CONFIG_DIR") $(printf '%q' "$REMOTE_BACKUP_DIR") ~/Desktop"
/usr/bin/scp "$ROOT_DIR/config/remote.conf.example" "${SSH_TARGET}:${TMP_REMOTE_EXAMPLE}"
/usr/bin/ssh "$SSH_TARGET" "if [ ! -f $(printf '%q' "$REMOTE_CONFIG_FILE") ]; then /bin/cp $(printf '%q' "$TMP_REMOTE_EXAMPLE") $(printf '%q' "$REMOTE_CONFIG_FILE") && /bin/chmod 600 $(printf '%q' "$REMOTE_CONFIG_FILE"); echo 'Created remote config: ~/${REMOTE_CONFIG_FILE}'; else echo 'Preserved existing remote config: ~/${REMOTE_CONFIG_FILE}'; fi; /bin/rm -f $(printf '%q' "$TMP_REMOTE_EXAMPLE")"
/usr/bin/scp "$ROOT_DIR/bin/receive-local-mic-to-blackhole" "${SSH_TARGET}:bin/receive-local-mic-to-blackhole"
/usr/bin/ssh "$SSH_TARGET" "/bin/chmod 755 ~/bin/receive-local-mic-to-blackhole"

/usr/bin/ssh "$SSH_TARGET" "/bin/rm -rf $(printf '%q' "$REMOTE_TEMP_APP_PATH")"
/usr/bin/rsync -aE --delete "$ROOT_DIR/build/Copy to Primary Mac.app/" "${SSH_TARGET}:$(printf '%q' "$REMOTE_TEMP_APP_PATH")/"
/usr/bin/ssh "$SSH_TARGET" "/usr/bin/codesign --force --deep --sign - ~/${REMOTE_TEMP_APP_PATH:q} >/dev/null && /usr/bin/codesign --verify --deep --strict --verbose=2 ~/${REMOTE_TEMP_APP_PATH:q}"
/usr/bin/ssh "$SSH_TARGET" "set -e; if [ -e $(printf '%q' "$REMOTE_APP_PATH") ]; then /bin/mv $(printf '%q' "$REMOTE_APP_PATH") $(printf '%q' "$REMOTE_BACKUP_PATH"); echo 'Backed up existing remote app to: ~/${REMOTE_BACKUP_PATH}'; fi; if ! /bin/mv $(printf '%q' "$REMOTE_TEMP_APP_PATH") $(printf '%q' "$REMOTE_APP_PATH"); then if [ -e $(printf '%q' "$REMOTE_BACKUP_PATH") ] && [ ! -e $(printf '%q' "$REMOTE_APP_PATH") ]; then /bin/mv $(printf '%q' "$REMOTE_BACKUP_PATH") $(printf '%q' "$REMOTE_APP_PATH") || true; fi; exit 1; fi"

echo "Installed remote app on ${SSH_TARGET}:~/${REMOTE_APP_PATH}"
