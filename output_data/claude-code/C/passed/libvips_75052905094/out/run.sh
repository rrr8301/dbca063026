#!/usr/bin/env bash
set -e

echo "=== Configuring libvips ==="
meson setup build \
  -Ddebug=true \
  -Ddeprecated=false \
  -Dmagick=disabled \
  -Ddocs=true \
  -Dintrospection=enabled \
  -Db_sanitize=none \
  -Db_lundef=true \
  || (cat build/meson-logs/meson-log.txt && exit 1)

echo "=== Building libvips ==="
meson compile -C build

echo "=== Running libvips tests ==="
meson test -C build --timeout-multiplier=1 \
  || (cat build/meson-logs/testlog.txt && exit 1)

echo "=== Installing libvips ==="
meson install -C build

echo "=== Rebuilding shared library cache ==="
ldconfig

echo "=== Installing pyvips ==="
pip3 install pyvips[test] --break-system-packages

echo "=== Running pyvips test suite ==="
python3 -m pytest -sv --log-cli-level=WARNING test/test-suite

echo "FINAL_STATUS = SUCCESS"
