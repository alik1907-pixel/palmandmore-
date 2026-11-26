#!/usr/bin/env bash
# capture.sh <out_dir> <frames> <fps> <godot user args...>
# Renders the game under a virtual display at native 720x1280 into PNG frames + WAV.
set -uo pipefail
OUT=$1; FR=$2; FPS=$3; shift 3
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$OUT"; rm -f "$OUT"/f*.png "$OUT"/f.wav
cd "$ROOT/game"
timeout 1200 xvfb-run -a -s "-screen 0 1400x2200x24" godot --path . --rendering-driver opengl3 \
  --resolution 720x1280 --write-movie "$OUT/f.png" --fixed-fps "$FPS" --quit-after "$FR" -- "$@" \
  < /dev/null > "$OUT/log.txt" 2>&1
grep -E "SCRIPT ERROR" "$OUT/log.txt" | head -3
ls "$OUT"/f*.png | wc -l
