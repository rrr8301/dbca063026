#!/usr/bin/env bash
set -e

cd /app

# Build with meson
echo "=== Building with meson ==="
./ci/build-tumbleweed.sh -Db_ndebug=true

# Run meson tests
echo "=== Running meson tests ==="
meson test -C build

echo "FINAL_STATUS = SUCCESS"
