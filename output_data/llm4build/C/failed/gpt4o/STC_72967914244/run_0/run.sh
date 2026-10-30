#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app

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