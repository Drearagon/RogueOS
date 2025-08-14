#!/usr/bin/env bash
# Remove build artifacts and temporary files.
set -e

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
CONFIG_DIR="$ROOT_DIR/config/livebuild"
OUT_DIR="$ROOT_DIR/out"

cd "$CONFIG_DIR" && lb clean --purge || true
rm -rf "$CONFIG_DIR/auto"/saved.cache "$CONFIG_DIR/live-image-amd64.hybrid.iso" 2>/dev/null || true
rm -rf "$OUT_DIR"/*.iso
