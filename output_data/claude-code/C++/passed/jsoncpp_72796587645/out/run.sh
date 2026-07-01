#!/usr/bin/env bash
set -e

cd /app

# Meson setup
meson setup builddir

# Meson build
meson compile -C builddir

# Meson test
meson test -C builddir

echo "FINAL_STATUS = SUCCESS"
