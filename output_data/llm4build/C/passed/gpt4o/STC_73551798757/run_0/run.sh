#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone <repository-url> /app
cd /app

# Configure the build with meson
export CC=clang
export CXX=clang++
meson setup build-debug --buildtype=debug -Dtests=enabled

# Compile the code
meson compile -C build-debug

# Run tests
meson test -C build-debug --timeout-multiplier 0