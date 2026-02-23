#!/bin/sh
# test.sh - Build and test devwork images locally, mirroring CI behaviour
# Usage:
#   ./test.sh           - Build and test all Node versions (22, 24, lts)
#   ./test.sh 24        - Build and test a specific version
#   ./test.sh 22 24     - Build and test multiple versions

set -e

VERSIONS="${*:-22 24 lts}"
PASS=0
FAIL=0

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { printf "${GREEN}[✔]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[!]${NC} %s\n" "$1"; }
err() { printf "${RED}[✘]${NC} %s\n" "$1"; }

# --- Shellcheck ---
printf "\n${YELLOW}==> Linting shell scripts${NC}\n"
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck devwork-versions .profile && log "shellcheck passed" || warn "shellcheck reported issues"
else
  warn "shellcheck not installed, skipping lint"
fi

# --- Build & test each version ---
for VERSION in $VERSIONS; do
  printf "\n${YELLOW}==> Node.js $VERSION${NC}\n"
  TAG="devwork:$VERSION-node"

  # Build
  printf "Building $TAG...\n"
  if docker build --build-arg NODE_VERSION="$VERSION" -t "$TAG" .; then
    log "Build succeeded"
  else
    err "Build failed for Node $VERSION"
    FAIL=$((FAIL + 1))
    continue
  fi

  # Test
  printf "Testing $TAG...\n"
  if docker run --rm "$TAG" devwork-versions; then
    log "Tests passed"
    PASS=$((PASS + 1))
  else
    err "Tests failed for Node $VERSION"
    FAIL=$((FAIL + 1))
  fi

  # Size report
  SIZE=$(docker images --format "{{.Size}}" "$TAG" | head -1)
  log "Image size: $SIZE"
done

# --- Summary ---
printf "\n${YELLOW}==> Summary${NC}\n"
printf "Passed: ${GREEN}$PASS${NC}  Failed: ${RED}$FAIL${NC}\n\n"

[ "$FAIL" -eq 0 ]
