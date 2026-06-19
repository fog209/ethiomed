#!/bin/bash
# fdb-watch.sh — filtered logcat for WardReady
# Usage:
#   bash scripts/fdb-watch.sh            normal flutter errors
#   bash scripts/fdb-watch.sh release    release APK crash filter
#   bash scripts/fdb-watch.sh full       everything (noisy)

DEVICE="SOAYYD7HEE65QKY5"
MODE="${1:-default}"

echo "=== WardReady logcat | mode=$MODE | device=$DEVICE ==="
echo "=== Ctrl+C to stop ==="
echo ""

case "$MODE" in
  release)
    fdb -d "$DEVICE" logcat \
      | grep -E "FATAL|AndroidRuntime|flutter|WardReady|E/|crash|signal 11|signal 6"
    ;;
  full)
    fdb -d "$DEVICE" logcat
    ;;
  *)
    fdb -d "$DEVICE" logcat \
      | grep -iE "flutter|WardReady|E/flutter|DioException|PostgrestException|Unhandled|Exception|Error:"
    ;;
esac