#!/bin/zsh
emulate -LR zsh
set -euo pipefail

ROOT_DIR="${0:A:h:h}"

if rg -n --glob '!**/check-no-secrets.sh' \
  'jacksons|Jacksons|100\.81\.|MacTop|dittodub|72953903|TheMakerOfWorlds' "$ROOT_DIR"; then
  echo "Potential private strings found." >&2
  exit 1
fi

echo "No known private strings found."
