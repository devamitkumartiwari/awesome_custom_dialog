#!/usr/bin/env bash
# Assembles the PNG frame sequences captured by integration_test/*_capture_test.dart
# (see example/build/gif_frames/<feature>/) into optimized GIFs under doc/gifs/,
# via a two-pass palette-based ffmpeg encode for small file size at good quality.
#
# Usage: run from the `example/` directory after running the capture tests and
# copying their sandboxed output into build/gif_frames/<feature>/ (see README
# in this file's directory, or the plan this was generated from, for the
# sandbox-container copy step each capture currently requires on macOS).
set -euo pipefail

FRAMES_DIR="build/gif_frames"
OUT_DIR="../doc/gifs"
FPS=12
WIDTH=360

mkdir -p "$OUT_DIR"

for dir in "$FRAMES_DIR"/*/; do
  name="$(basename "$dir")"
  echo "Encoding $name..."
  ffmpeg -y -framerate "$FPS" -i "${dir}frame_%04d.png" \
    -vf "fps=${FPS},scale=${WIDTH}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
    -loop 0 "$OUT_DIR/$name.gif"
done

echo "Done. Output:"
ls -la "$OUT_DIR"
