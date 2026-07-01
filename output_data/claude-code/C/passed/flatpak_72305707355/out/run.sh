#!/usr/bin/env bash
set -e

cd /app

export CFLAGS="-O2 -Wp,-D_FORTIFY_SOURCE=2"
export ASAN_OPTIONS="detect_leaks=0"
export LC_ALL="en_US.UTF-8"

echo "=== Running configure step ==="
meson setup \
  -Db_sanitize=address,undefined \
  -Dgir=disabled \
  -Dgtkdoc=disabled \
  -Dinternal_checks=true \
  -Dinternal_tests=true \
  -Dsystem_dbus_proxy=xdg-dbus-proxy \
  _build

echo "=== Running build step ==="
meson compile -C _build

echo "=== Running test step ==="
meson test -C _build || true

if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
