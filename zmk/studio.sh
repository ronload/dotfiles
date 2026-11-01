#!/bin/bash
# Usage: zmk/studio.sh dump|check|apply <keymap.json>
#
# Runs the ZMK Studio client in zmk/studio-cli against the keyboard named in
# the keymap file, building it first when its sources changed. macOS grants
# Bluetooth only to an app that declares a usage description and is its own
# responsible process, so the client is an app bundle started through `open`.
# `open` passes back neither output nor exit status: output goes through temp
# files, and the client's final "RESULT: OK" line sets the exit status.
set -euo pipefail

ZMK_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="${ZMK_DIR}/studio-cli"
APP="${ZMK_DIR}/build/ZMKStudioCLI.app"
BIN="${APP}/Contents/MacOS/zmk-studio-cli"

if [[ $# -ne 2 ]]; then
  echo "usage: $0 dump|check|apply <keymap.json>" >&2
  exit 2
fi
action="$1"
# The app starts in /, so it needs an absolute path.
keymap="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"

# Each build gets a new ad-hoc signature, and macOS then asks for Bluetooth
# access again, so only rebuild when the sources are newer than the binary.
if [[ ! -x "${BIN}" || "${SRC_DIR}/main.swift" -nt "${BIN}" || "${SRC_DIR}/Info.plist" -nt "${BIN}" ]]; then
  echo "Building ZMK Studio CLI..."
  rm -rf "${APP}"
  mkdir -p "${APP}/Contents/MacOS"
  cp "${SRC_DIR}/Info.plist" "${APP}/Contents/Info.plist"
  swiftc -O -o "${BIN}" "${SRC_DIR}/main.swift"
  codesign --force --sign - "${APP}"
fi

tmp="$(mktemp -d -t zmk-studio)"
trap 'rm -rf "${tmp}"' EXIT
echo "Talking to the keyboard over Bluetooth..."
open -W -n --stdout "${tmp}/out" --stderr "${tmp}/err" "${APP}" --args "${action}" "${keymap}"
cat "${tmp}/out" "${tmp}/err" 2>/dev/null || true
[[ "$(tail -n 1 "${tmp}/out" 2>/dev/null)" == "RESULT: OK" ]]
