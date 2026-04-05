#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="SnapClip"
EXECUTABLE_NAME="snapclip"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
DMG_STAGING_DIR="$DIST_DIR/dmg-root"
DMG_PATH="$DIST_DIR/$APP_NAME-sandbox.dmg"
INFO_PLIST_SOURCE="$ROOT_DIR/Packaging/Info.plist"
SIGN_SCRIPT="$ROOT_DIR/Scripts/sign-app.sh"
APP_ICON_SOURCE="$ROOT_DIR/Packaging/AppIcon.icns"

printf 'Building release binary...\n'
RELEASE_DIR="$(swift build -c release --package-path "$ROOT_DIR" --show-bin-path)"
EXECUTABLE_SOURCE="$RELEASE_DIR/$EXECUTABLE_NAME"
RESOURCE_BUNDLE_SOURCE="$RELEASE_DIR/KeyboardShortcuts_KeyboardShortcuts.bundle"

if [[ ! -f "$EXECUTABLE_SOURCE" ]]; then
  printf 'Release executable not found: %s\n' "$EXECUTABLE_SOURCE" >&2
  exit 1
fi

if [[ ! -f "$INFO_PLIST_SOURCE" ]]; then
  printf 'Missing Info.plist template: %s\n' "$INFO_PLIST_SOURCE" >&2
  exit 1
fi

printf 'Preparing bundle directories...\n'
rm -rf "$APP_DIR" "$DMG_STAGING_DIR" "$DMG_PATH"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$DMG_STAGING_DIR"

printf 'Copying app metadata and executable...\n'
cp "$INFO_PLIST_SOURCE" "$CONTENTS_DIR/Info.plist"
cp "$EXECUTABLE_SOURCE" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

if [[ -f "$APP_ICON_SOURCE" ]]; then
  printf 'Copying app icon...\n'
  cp "$APP_ICON_SOURCE" "$RESOURCES_DIR/AppIcon.icns"
fi

if [[ -d "$RESOURCE_BUNDLE_SOURCE" ]]; then
  printf 'Copying KeyboardShortcuts resource bundle...\n'
  cp -R "$RESOURCE_BUNDLE_SOURCE" "$RESOURCES_DIR/"
fi

if [[ -x "$SIGN_SCRIPT" ]]; then
  printf 'Signing sandbox app bundle...\n'
  "$SIGN_SCRIPT" "$APP_DIR"
fi

printf 'Preparing DMG staging area...\n'
cp -R "$APP_DIR" "$DMG_STAGING_DIR/"
ln -s /Applications "$DMG_STAGING_DIR/Applications"

printf 'Creating DMG...\n'
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

printf '\nDone.\n'
printf 'App bundle: %s\n' "$APP_DIR"
printf 'DMG: %s\n' "$DMG_PATH"
