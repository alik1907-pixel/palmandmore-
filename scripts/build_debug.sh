#!/usr/bin/env bash
# Debug APK üretir ve (varsa) bağlı cihaza/emülatöre kurar.
# DURUM: Android SDK platform/build-tools kurulumu yapımcı onayı bekliyor → DOĞRULANMADI.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
OUT="$ROOT/build/android"
mkdir -p "$OUT"
cd "$ROOT/game"
timeout 600 godot --headless --path . --import < /dev/null
timeout 900 godot --headless --path . --export-debug "Android" "$OUT/game-debug.apk" < /dev/null
ls -la "$OUT/game-debug.apk"
if command -v adb >/dev/null && adb get-state >/dev/null 2>&1; then
  adb install -r "$OUT/game-debug.apk"
  adb shell monkey -p com.studio.prototypes -c android.intent.category.LAUNCHER 1
  sleep 3
  adb exec-out screencap -p > "$OUT/launch.png"
  echo "Açılış görüntüsü: $OUT/launch.png"
else
  echo "Bağlı cihaz yok: APK üretildi, kurulum atlandı."
fi
