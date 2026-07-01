#!/bin/bash
set -e

# Clone the repository with submodules
git clone --recurse-submodules https://github.com/flatpak/flatpak.git /workspace/flatpak
cd /workspace/flatpak

# Create logs directory
mkdir -p test-logs

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
export CFLAGS="-O2 -Wp,-D_FORTIFY_SOURCE=2"
export ASAN_OPTIONS="detect_leaks=0"
meson compile -C _build

# Run tests
export LC_ALL="en_US.UTF-8"
meson test -C _build