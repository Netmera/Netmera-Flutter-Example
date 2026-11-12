#!/usr/bin/env bash
# Runs integration tests against the host stub server.
#
#   tool/run_integration_tests.sh <device-id> [test path]
#
# Paths under patrol_test/ run with `patrol test`, one run per file (needs
# patrol_cli on PATH). Paths under host_test/ build the app and run
# tests that drive it from the host (install, launch, kill, permissions).
#
# Device ids come from `flutter devices` (e.g. emulator-5554 or a simulator UDID).
set -euo pipefail

DEVICE="${1:?Usage: tool/run_integration_tests.sh <device-id> [test path]}"
TARGET="${2:-integration_test}"
# The seed files (patrol_test/*.stub.json) use this port too.
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

if $ANDROID; then
  dart run tool/stub_server.dart "$PORT" &
else
  # The stub delivers the tests' pushes to the simulator.
  dart run tool/stub_server.dart "$PORT" "$DEVICE" &
fi
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

DART_DEFINE="--dart-define=NETMERA_TEST_BASE_URL=http://127.0.0.1:$PORT"
if [[ "$TARGET" == patrol_test* ]]; then
  # One Patrol run per file: each run reinstalls the app, so every file starts
  # with fresh permissions (iOS keeps them between tests of a single run).
  # The app starts before the test can stub responses, so a file's launch-time
  # responses come from <file>.stub.json ({"pathContains": ..., "body": ...}).
  STATUS=0
  for file in $(find "$TARGET" -name '*_test.dart' | sort); do
    curl -sf -X POST "http://127.0.0.1:$PORT/__stub/reset" >/dev/null
    seed="${file%.dart}.stub.json"
    if [ -f "$seed" ]; then
      curl -sf -X POST -H 'Content-Type: application/json' --data @"$seed" \
        "http://127.0.0.1:$PORT/__stub/responses" >/dev/null
    fi
    patrol test --target "$file" --device "$DEVICE" "$DART_DEFINE" || STATUS=1
  done
  exit $STATUS
elif [[ "$TARGET" == host_test* ]]; then
  # Host-side tests that install, launch and kill a prebuilt app themselves.
  if $ANDROID; then
    flutter build apk --debug "$DART_DEFINE"
    APP=build/app/outputs/flutter-apk/app-debug.apk
  else
    flutter build ios --simulator --debug "$DART_DEFINE"
    APP=build/ios/iphonesimulator/Runner.app
  fi
  # The files share one device and stub server, so they run one at a time.
  flutter test "$TARGET" --concurrency=1 \
    --dart-define=HOST_TEST_DEVICE="$DEVICE" --dart-define=HOST_TEST_APP="$APP" \
    --dart-define=HOST_TEST_ADB="$ADB"
else
  flutter test "$TARGET" -d "$DEVICE" "$DART_DEFINE"
fi
