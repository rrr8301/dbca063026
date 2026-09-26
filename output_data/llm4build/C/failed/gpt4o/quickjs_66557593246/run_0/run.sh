#!/bin/bash

# Set environment variables
export CC=clang
export CXX=clang++

# Configure the build
meson setup build-debug --buildtype=debug -Dtests=enabled

# Compile the project
meson compile -C build-debug

# Run tests
meson test -C build-debug --timeout-multiplier 5 --print-errorlogs
meson test --benchmark -C build-debug --timeout-multiplier 5 --print-errorlogs