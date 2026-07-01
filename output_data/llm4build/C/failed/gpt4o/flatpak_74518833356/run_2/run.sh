#!/bin/bash

# Create logs directory
mkdir -p test-logs

# Configure the build
meson setup \
  -Db_sanitize=address,undefined \
  -Dgir=disabled \
  -Dgtkdoc=disabled \
  -Dinternal_checks=true \
  -Dinternal_tests=true \
  -Dsystem_dbus_proxy=xdg-dbus-proxy \
  _build

# Build the project
meson compile -C _build

# Run tests
meson test -C _build || true

# Collect logs on failure
if [ $? -ne 0 ]; then
  mv _build/meson-logs/* test-logs/ || true
fi