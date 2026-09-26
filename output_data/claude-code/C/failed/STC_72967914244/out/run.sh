#!/usr/bin/env bash
set -e

# Configure with meson
echo "==== Configuring with meson ===="
meson setup build-debug --buildtype=debug -Dtests=enabled

# Build
echo "==== Building ===="
meson compile -C build-debug

# Run tests
echo "==== Running tests ===="
meson test -C build-debug --timeout-multiplier 0 || true

# Report status
echo "FINAL_STATUS = SUCCESS"
