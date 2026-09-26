#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app

# Activate MSVC and Configure (simulated)
meson setup build-debug --buildtype=debug -Dtests=enabled --vsenv

# Building
meson compile -C build-debug

# Running tests
meson test -C build-debug --timeout-multiplier 5 --print-errorlogs
meson test --benchmark -C build-debug --timeout-multiplier 5 --print-errorlogs