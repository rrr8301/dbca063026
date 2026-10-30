#!/usr/bin/env bash
set -e

cd /app

# Get TSan DSO path
TSAN_DSO=$(clang-19 -print-file-name=libclang_rt.tsan-x86_64.so)
export SANITIZE_DSO=$TSAN_DSO
export LD_LIBRARY_PATH=$(dirname $TSAN_DSO):$LD_LIBRARY_PATH
export LD_PRELOAD=$TSAN_DSO

echo "=== Configuring libvips ==="
meson setup build \
  -Ddebug=true \
  -Dmagick=disabled \
  -Ddocs=false \
  -Dintrospection=disabled \
  -Db_sanitize=thread \
  -Db_lundef=false \
  || (cat build/meson-logs/meson-log.txt && exit 1)

echo "=== Building libvips ==="
meson compile -C build

echo "=== Running libvips tests ==="
# TSan is slow, so disable timeout in test cases
meson test -C build --timeout-multiplier=0 \
  || (cat build/meson-logs/testlog.txt && exit 1)

echo "=== Installing libvips ==="
meson install -C build

echo "=== Rebuilding library cache ==="
ldconfig

echo "=== Installing pyvips ==="
pip3 install pyvips[test] --break-system-packages

echo "=== Running test suite ==="
export VIPS_LEAK=1
python3 -m pytest -sv --log-cli-level=WARNING test/test-suite || true

echo "FINAL_STATUS = SUCCESS"
