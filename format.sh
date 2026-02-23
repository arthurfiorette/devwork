#!/bin/sh
# format.sh - Format shell scripts using shfmt
# Requires: docker (uses mvdan/shfmt container image)
#
# Usage:
#   ./format.sh        Format all shell scripts
#   ./format.sh -s     Format only staged files and re-stage them (git hook)
#   ./format.sh -c     Check formatting without writing (CI)

set -e

ALL_SHELL_FILES=".profile devwork-versions test.sh format.sh"
CHECK=false
STAGED_ONLY=false

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { printf "${GREEN}[✔]${NC} %s\n" "$1"; }
err() { printf "${RED}[✘]${NC} %s\n" "$1"; }

while getopts "cs" opt; do
  case $opt in
    c) CHECK=true ;;
    s) STAGED_ONLY=true ;;
    *) printf "Usage: %s [-c] [-s]\n" "$0" && exit 1 ;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  err "docker not found"
  exit 1
fi

if $STAGED_ONLY; then
  STAGED=$(git diff --cached --name-only)
  FILES=""
  for f in $ALL_SHELL_FILES; do
    echo "$STAGED" | grep -qx "$f" && FILES="$FILES $f"
  done
else
  FILES=$ALL_SHELL_FILES
fi

if $CHECK; then
  printf "\n${YELLOW}==> Checking shell script formatting (shfmt)${NC}\n"
  SHFMT_FLAGS="-l"
else
  printf "\n${YELLOW}==> Formatting shell scripts (shfmt)${NC}\n"
  SHFMT_FLAGS="-w"
fi

for f in $FILES; do
  [ -f "$f" ] || continue
  # shellcheck disable=SC2086
  docker run --rm -u "$(id -u):$(id -g)" -v "$PWD:/mnt" -w /mnt mvdan/shfmt:v3 $SHFMT_FLAGS -i 2 -ci "$f"
  $STAGED_ONLY && git add "$f"
  log "$f"
done
