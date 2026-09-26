#!/bin/bash
set -e

echo "=== Starting mvfst build and test ==="

# Set environment variable to allow pip operations (PEP 668 workaround)
export PIP_BREAK_SYSTEM_PACKAGES=1

# Update system package info
echo "Updating system packages..."
apt-get update

# Install system dependencies for mvfst and patchelf
echo "Installing system dependencies..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive mvfst
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Query paths for dependencies
echo "Querying dependency paths..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. mvfst > /tmp/paths.txt
cat /tmp/paths.txt

# Fetch all dependencies
echo "Fetching boost..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests boost

echo "Fetching fast_float..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float

echo "Fetching fmt..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt

echo "Fetching glog..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog

echo "Fetching liboqs..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs

echo "Fetching libunwind..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind

echo "Fetching xz..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz

echo "Fetching folly..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly

echo "Fetching fizz..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz

# Build folly
echo "Building folly..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --build-type RelWithDebInfo --no-tests folly

# Build fizz
echo "Building fizz..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --build-type RelWithDebInfo --no-tests fizz

# Build mvfst
echo "Building mvfst..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --build-type RelWithDebInfo --src-dir=. mvfst --project-install-prefix mvfst:/usr/local

# Copy artifacts
echo "Copying artifacts..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. mvfst _artifacts/linux --project-install-prefix mvfst:/usr/local --final-install-prefix /usr/local

# Test mvfst
echo "Testing mvfst..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --build-type RelWithDebInfo --src-dir=. mvfst --project-install-prefix mvfst:/usr/local

echo "=== Build and test completed successfully ==="