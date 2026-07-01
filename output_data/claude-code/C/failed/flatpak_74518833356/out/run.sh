#!/usr/bin/env bash
set -e

cd /app

# Create logs dir
mkdir -p test-logs

# Configure with meson
export CFLAGS="-O2 -Wp,-D_FORTIFY_SOURCE=2"
export ASAN_OPTIONS="detect_leaks=0"
export LC_ALL="en_US.UTF-8"

meson setup \
  -Db_sanitize=address,undefined \
  -Dgir=disabled \
  -Dgtkdoc=disabled \
  -Dinternal_checks=true \
  -Dinternal_tests=true \
  -Dsystem_dbus_proxy=xdg-dbus-proxy \
  _build

# Build flatpak
meson compile -C _build

# Run tests
meson test -C _build || true

# Collect logs
mv _build/meson-logs/* test-logs/ || true

echo "FINAL_STATUS = SUCCESS"
