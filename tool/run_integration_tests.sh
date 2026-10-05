#!/usr/bin/env bash
# Runs integration tests against the host stub server.
#
#   tool/run_integration_tests.sh <device-id> [test path]
#
# Device ids come from `flutter devices` (e.g. emulator-5554 or a simulator UDID).
set -euo pipefail

DEVICE="${1:?Usage: tool/run_integration_tests.sh <device-id> [test path]}"
TARGET="${2:-integration_test}"
PORT=8089
GENERATED_XCCONFIG=ios/Flutter/Generated.xcconfig
cd "$(dirname "$0")/.."

fail() {
  echo "$1" >&2
  exit 1
}

ADB="$(command -v adb || true)"
if [ -z "$ADB" ]; then
  for sdk in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk"; do
    if [ -n "$sdk" ] && [ -x "$sdk/platform-tools/adb" ]; then ADB="$sdk/platform-tools/adb"; break; fi
  done
fi

ANDROID=false
if [ -n "$ADB" ] && "$ADB" -s "$DEVICE" get-state >/dev/null 2>&1; then
  ANDROID=true
elif [ -z "$ADB" ] && ! [[ "$DEVICE" =~ ^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$ ]]; then
  fail "adb not found and '$DEVICE' is not an iOS simulator id; set ANDROID_HOME or add platform-tools to PATH."
fi

# iOS builds need full Xcode; use it when xcode-select still points at the Command Line Tools.
if ! $ANDROID && [ -z "${DEVELOPER_DIR:-}" ] && [[ "$(xcode-select -p 2>/dev/null)" == *CommandLineTools* ]] \
  && [ -d /Applications/Xcode.app ]; then
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

if curl -s "http://127.0.0.1:$PORT" >/dev/null; then
  fail "Port $PORT is already in use, probably by a stub server left from an earlier run: lsof -nP -iTCP:$PORT -sTCP:LISTEN"
fi

XCCONFIG_BACKUP=""
if ! $ANDROID && [ -f "$GENERATED_XCCONFIG" ]; then
  XCCONFIG_BACKUP="$(mktemp)"
  cp "$GENERATED_XCCONFIG" "$XCCONFIG_BACKUP"
fi

dart run tool/stub_server.dart "$PORT" &
SERVER_PID=$!
disown "$SERVER_PID"

cleanup() {
  kill "$SERVER_PID" 2>/dev/null || true
  if $ANDROID; then "$ADB" -s "$DEVICE" reverse --remove "tcp:$PORT" >/dev/null 2>&1 || true; fi
  # flutter test leaves the test dart-defines in Generated.xcconfig; a later Xcode run would keep using the stub.
  if [ -n "$XCCONFIG_BACKUP" ]; then mv "$XCCONFIG_BACKUP" "$GENERATED_XCCONFIG"; fi
}
trap cleanup EXIT

for _ in $(seq 1 50); do
  curl -s "http://127.0.0.1:$PORT/__stub/requests" >/dev/null && break
  sleep 0.2
done
kill -0 "$SERVER_PID" 2>/dev/null && curl -s "http://127.0.0.1:$PORT/__stub/requests" >/dev/null \
  || fail "Stub server did not start on port $PORT."

if $ANDROID; then
  "$ADB" -s "$DEVICE" reverse "tcp:$PORT" "tcp:$PORT" >/dev/null
fi

flutter test "$TARGET" -d "$DEVICE" \
  --dart-define=NETMERA_TEST_BASE_URL="http://127.0.0.1:$PORT"
