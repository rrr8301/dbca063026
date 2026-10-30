#!/bin/bash

# Navigate to the app directory
cd /app

# Configure the build
export CC=clang
export CXX=clang++
meson setup build-debug --buildtype=debug -Dtests=enabled

# Compile the project
meson compile -C build-debug

# Run tests
meson test -C build-debug --timeout-multiplier 0