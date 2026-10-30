#!/usr/bin/env bash
set -e

cd /app

# Setup meson
meson setup build-debug --buildtype=debug -Dtests=enabled

# Building
meson compile -C build-debug

# Running tests
meson test -C build-debug --timeout-multiplier 5 --print-errorlogs
meson test --benchmark -C build-debug --timeout-multiplier 5 --print-errorlogs

echo "FINAL_STATUS = SUCCESS"
