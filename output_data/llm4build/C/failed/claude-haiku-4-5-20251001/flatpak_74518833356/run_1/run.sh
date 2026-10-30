#!/bin/bash
set -e

# Initialize git submodules
git submodule update --init --recursive

# Configure with meson
meson setup \
  -Db_sanitize=address,undefined \
  -Dgir=disabled \
  -Dgtkdoc=disabled \
  -Dinternal_checks=true \
  -Dinternal_tests=true \
  -Dsystem_dbus_proxy=xdg-dbus-proxy \
  _build

# Build flatpak
export ASAN_OPTIONS=detect_leaks=0
export CFLAGS="-O2 -Wp,-D_FORTIFY_SOURCE=2"
meson compile -C _build

# Run tests
export LC_ALL=en_US.UTF-8
meson test -C _build || TEST_FAILED=1

# Collect logs on failure
if [ -n "$TEST_FAILED" ]; then
  mv _build/meson-logs/* test-logs/ || true
  exit 1
fi

exit 0