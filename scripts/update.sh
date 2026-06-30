#!/bin/zsh
emulate -LR zsh
set -euo pipefail

ROOT_DIR="${0:A:h:h}"
SKIP_PULL=0
GIT="${GIT:-}"

if [[ -z "$GIT" ]]; then
  if [[ -x /opt/homebrew/bin/git ]]; then
    GIT=/opt/homebrew/bin/git
  elif command -v git >/dev/null 2>&1; then
    GIT="$(command -v git)"
  else
    echo "git was not found." >&2
    exit 127
  fi
fi

notify_user() {
  local title="$1" message="$2"
  /usr/bin/osascript - "$title" "$message" <<'APPLESCRIPT' >/dev/null 2>&1 || true
on run argv
	display notification (item 2 of argv) with title (item 1 of argv)
end run
APPLESCRIPT
}

while (( $# > 0 )); do
  case "$1" in
    --skip-pull)
      SKIP_PULL=1
      shift
      ;;
    *)
      break
      ;;
  esac
done

if [[ ! -d "$ROOT_DIR/.git" ]]; then
  echo "This updater expects a git checkout at: $ROOT_DIR" >&2
  exit 66
fi

if (( SKIP_PULL == 0 )); then
  if [[ -n "$("$GIT" -C "$ROOT_DIR" status --porcelain)" ]]; then
    echo "Refusing to update with local repo changes present. Commit/stash them first." >&2
    exit 65
  fi
  "$GIT" -C "$ROOT_DIR" fetch --prune origin
  "$GIT" -C "$ROOT_DIR" pull --ff-only
fi

"$ROOT_DIR/scripts/install-local.sh" "$@"
notify_user "Open Remote Desktop" "Updated from GitHub without overwriting your config."
echo "Update complete. Existing config files were preserved."
