#!/bin/bash
set -e

# Build with meson
echo "=== Building with meson ==="
./ci/build-tumbleweed.sh -Db_ndebug=true
BUILD_STATUS=$?

if [ $BUILD_STATUS -ne 0 ]; then
    echo "=== Build failed, printing meson log ==="
    if [ -f ./build/meson-logs/meson-log.txt ]; then
        cat ./build/meson-logs/meson-log.txt
    fi
    exit $BUILD_STATUS
fi

# Run meson tests
echo "=== Running meson tests ==="
meson test -C build
TESTS_STATUS=$?

if [ $TESTS_STATUS -ne 0 ]; then
    echo "=== Tests failed, printing meson test log ==="
    if [ -f ./build/meson-logs/testlog.txt ]; then
        cat ./build/meson-logs/testlog.txt
    fi
    exit $TESTS_STATUS
fi

echo "=== All tests passed ==="
exit 0