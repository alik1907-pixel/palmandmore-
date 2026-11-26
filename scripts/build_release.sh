#!/usr/bin/env bash
# Signed release AAB for Google Play. Reads the upload key from secrets/keystore.properties (never committed).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source <(grep -E '^(KEYSTORE|ALIAS|PASSWORD)=' "$ROOT/secrets/keystore.properties")
export ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$ROOT/secrets/$KEYSTORE"
export GODOT_ANDROID_KEYSTORE_RELEASE_USER="$ALIAS"
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="$PASSWORD"
mkdir -p "$ROOT/build/android"
cd "$ROOT/game"
timeout 600 godot --headless --path . --import < /dev/null > /dev/null 2>&1 || true
timeout 1800 godot --headless --path . --export-release "Android AAB" "$ROOT/build/android/sis-release.aab" < /dev/null
ls -la "$ROOT/build/android/sis-release.aab"
