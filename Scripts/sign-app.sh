#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="${1:-$ROOT_DIR/dist/SnapClip.app}"
ENTITLEMENTS_PATH="$ROOT_DIR/Packaging/SnapClip.entitlements"
SIGNING_IDENTITY="${SIGNING_IDENTITY:--}"

if [[ ! -d "$APP_PATH" ]]; then
  printf 'App bundle not found: %s\n' "$APP_PATH" >&2
  exit 1
fi

if [[ ! -f "$ENTITLEMENTS_PATH" ]]; then
  printf 'Entitlements file not found: %s\n' "$ENTITLEMENTS_PATH" >&2
  exit 1
fi

CODESIGN_ARGS=(--force --deep --sign "$SIGNING_IDENTITY" --entitlements "$ENTITLEMENTS_PATH")

if [[ "$SIGNING_IDENTITY" != "-" ]]; then
  CODESIGN_ARGS+=(--options runtime)
fi

printf 'Signing app bundle with identity: %s\n' "$SIGNING_IDENTITY"
codesign "${CODESIGN_ARGS[@]}" "$APP_PATH"

printf 'Verifying code signature...\n'
codesign --verify --deep --strict "$APP_PATH"

printf 'Signed app: %s\n' "$APP_PATH"
