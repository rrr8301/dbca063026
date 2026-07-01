#!/bin/bash

set -e

# Enable error handling: continue on test failures but track them
TEST_FAILED=0

echo "=== Starting Folly Build and Test ==="

# Show initial disk space
echo "=== Disk space at start ==="
df -h

# Free up disk space (if running in a constrained environment)
echo "=== Freeing up disk space ==="
if [ -d "/usr/local/lib/android" ]; then
    sudo rm -rf /usr/local/lib/android || true
fi

echo "=== Disk space after freeing up ==="
df -h

# Update system package info
echo "=== Updating system package info ==="
sudo --preserve-env=http_proxy apt-get update || true

# Install system dependencies for folly and patchelf
echo "=== Installing system dependencies ==="
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive folly || true
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf || true

# Query paths
echo "=== Querying paths ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. folly || true

# Fetch dependencies
echo "=== Fetching dependencies ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests boost
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libaio
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests ninja
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests cmake
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests double-conversion
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests gflags
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests googletest
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libdwarf
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libevent
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests zlib
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests lz4
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests snappy
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests zstd
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests autoconf
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests automake
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libtool
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libiberty
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libsodium
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz

# Build folly
echo "=== Building folly ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. folly --project-install-prefix folly:/usr/local

# Copy artifacts
echo "=== Copying artifacts ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. folly _artifacts/linux --project-install-prefix folly:/usr/local --final-install-prefix /usr/local

# Test folly
echo "=== Testing folly ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. folly --project-install-prefix folly:/usr/local || TEST_FAILED=1

# Show final disk space
echo "=== Disk space at end ==="
df -h

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "=== Tests failed ==="
    exit 1
else
    echo "=== All tests passed ==="
    exit 0
fi