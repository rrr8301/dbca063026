#!/bin/bash
set -e

# Build with meson
echo "=== Building with meson ==="
./ci/build-tumbleweed.sh -Db_ndebug=true

# Run meson tests
echo "=== Running meson tests ==="
meson test -C build || {
    echo "=== Meson tests failed, printing test log ==="
    if [ -f ./build/meson-logs/testlog.txt ]; then
        cat ./build/meson-logs/testlog.txt
    fi
    exit 1
}

echo "=== All tests passed ==="