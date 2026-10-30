#!/usr/bin/env bash
set -e

export CC=clang
export CXX=clang++

echo "=== Configuring ==="
meson setup build-debug --buildtype=debug -Dtests=enabled

echo "=== Building ==="
meson compile -C build-debug

echo "=== Running tests ==="
meson test -C build-debug --timeout-multiplier 0

echo "FINAL_STATUS = SUCCESS"
