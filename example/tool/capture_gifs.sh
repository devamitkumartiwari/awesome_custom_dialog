#!/usr/bin/env bash
# Renders every README GIF / screenshot frame on this computer (no phone
# needed), in dark mode, as full 360x720 app frames.
#
# Usage (from example/):   bash tool/capture_gifs.sh [test files...]
# Then encode:             python tool/encode_gifs.py build/gif_frames ../doc/gifs
#
# Frames land in example/build/gif_frames/<name>/frame_%04d.png. Real fonts
# (Roboto, Material and Cupertino icons) are loaded by the capture harness
# from the paths passed below.
set -euo pipefail

FLUTTER_ROOT="$(dirname "$(dirname "$(command -v flutter)")")"
PUB_CACHE_DIR="${PUB_CACHE:-${LOCALAPPDATA:-$HOME}/Pub/Cache}"
if [ ! -d "$PUB_CACHE_DIR/hosted" ]; then PUB_CACHE_DIR="$HOME/.pub-cache"; fi
CUPERTINO_ICONS="$(ls -d "$PUB_CACHE_DIR"/hosted/pub.dev/cupertino_icons-* | sort -V | tail -1)/assets/CupertinoIcons.ttf"

if command -v cygpath >/dev/null 2>&1; then # Git Bash on Windows
  FLUTTER_ROOT="$(cygpath -m "$FLUTTER_ROOT")"
  CUPERTINO_ICONS="$(cygpath -m "$CUPERTINO_ICONS")"
fi

if [ "$#" -eq 0 ]; then set -- integration_test; fi

flutter test "$@" -d flutter-tester \
  --dart-define=ACD_MATERIAL_FONTS="$FLUTTER_ROOT/bin/cache/artifacts/material_fonts" \
  --dart-define=ACD_CUPERTINO_ICONS="$CUPERTINO_ICONS"
