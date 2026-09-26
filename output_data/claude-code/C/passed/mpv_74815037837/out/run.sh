#!/usr/bin/env bash
set -e

export CC="gcc"
export CXX="g++"

cd /app

# Build with meson using the tumbleweed build script
./ci/build-tumbleweed.sh -Db_ndebug=true

# Run meson tests
if meson test -C build; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
