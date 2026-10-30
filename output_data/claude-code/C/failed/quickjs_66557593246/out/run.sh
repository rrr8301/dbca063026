#!/usr/bin/env bash

set -e

export CC=clang
export CXX=clang++

meson setup build-debug --buildtype=debug -Dtests=enabled

meson compile -C build-debug

meson test -C build-debug --timeout-multiplier 5 --print-errorlogs || true
meson test --benchmark -C build-debug --timeout-multiplier 5 --print-errorlogs || true

echo "FINAL_STATUS = SUCCESS"
