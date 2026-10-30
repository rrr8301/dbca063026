#!/bin/bash

set -e

# Change to workspace directory
cd /workspace

echo "=== Starting Folly Build and Test ==="

# Show disk space at start
echo "=== Disk space at start ==="
df -h

# Update system package info
echo "=== Updating system package info ==="
apt-get update

# Install system dependencies for folly and patchelf
echo "=== Installing system dependencies ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive folly || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf || true

# Query paths
echo "=== Querying paths ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. folly || true

# Fetch dependencies
echo "=== Fetching dependencies ==="
for dep in boost libaio ninja cmake double-conversion fast_float fmt gflags glog googletest libdwarf libevent zlib lz4 snappy zstd autoconf automake libtool libiberty libsodium libunwind xz openssl; do
    echo "Fetching $dep..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests $dep || true
done

# Build and cache dependencies
echo "=== Building dependencies ==="
for dep in boost libaio ninja cmake double-conversion fast_float fmt gflags glog googletest libdwarf libevent zlib lz4 snappy zstd autoconf automake libtool libiberty libsodium libunwind xz openssl; do
    echo "Building $dep..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages build --free-up-disk --no-tests $dep || true
done

# Build folly
echo "=== Building folly ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. folly --project-install-prefix folly:/usr/local

# Copy artifacts
echo "=== Copying artifacts ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. folly _artifacts/linux --project-install-prefix folly:/usr/local --final-install-prefix /usr/local || true

# Test folly
echo "=== Testing folly ==="
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. folly --project-install-prefix folly:/usr/local

# Show disk space at end
echo "=== Disk space at end ==="
df -h

echo "=== Build and test completed successfully ==="