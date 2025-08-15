#!/usr/bin/env bash
# Build the RogueOS live ISO using Debian live-build.
# This script installs live-build if missing, regenerates package lists,
# configures live-build via auto/config and builds the ISO.
set -e

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
CONFIG_DIR="$ROOT_DIR/config/livebuild"
PACKAGES_DIR="$ROOT_DIR/config/packages.d"
OUT_DIR="$ROOT_DIR/out"

# Ensure live-build is installed
if ! command -v lb >/dev/null 2>&1; then
  echo "Installing live-build..."
  sudo apt-get update
  sudo apt-get install -y live-build
fi

# Regenerate combined package list for live-build
find "$PACKAGES_DIR" -name '*.list' -type f -print0 | xargs -0 cat > "$CONFIG_DIR/package-lists/rogueos.list.chroot"

# Generate MOTD with build date
TEMPLATE="$ROOT_DIR/config/includes.chroot/etc/motd.template"
if [ -f "$TEMPLATE" ]; then
  sed "s/BUILD_DATE/$(date +%Y-%m-%d)/" "$TEMPLATE" > "$ROOT_DIR/config/includes.chroot/etc/motd"
fi

# Run live-build
cd "$CONFIG_DIR"
# clean previous build artifacts
lb clean --purge

# configure and build
./auto/config
lb build

# Move ISO to out/ with dated name
mkdir -p "$OUT_DIR"
ISO_SRC="$CONFIG_DIR"/live-image-amd64.hybrid.iso
ISO_DEST="$OUT_DIR/rogueos-amd64-$(date +%Y%m%d).iso"
if [ -f "$ISO_SRC" ]; then
  mv "$ISO_SRC" "$ISO_DEST"
  echo "ISO generated at $ISO_DEST"
else
  echo "ISO build failed: $ISO_SRC not found" >&2
  exit 1
fi
