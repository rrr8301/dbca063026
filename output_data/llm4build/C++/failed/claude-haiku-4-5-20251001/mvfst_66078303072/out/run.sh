#!/bin/bash
set -e

# Update system package info
sudo --preserve-env=http_proxy apt-get update

# Install system deps for mvfst and patchelf
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive mvfst
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Query paths and store output
PATHS_OUTPUT=$(python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. mvfst)

# Extract individual path variables from output
# The output format is KEY=VALUE, so we source it
eval "$PATHS_OUTPUT"

# Fetch dependencies conditionally based on paths output
if [ -n "$fast_float_SOURCE" ]; then
    echo "Fetching fast_float..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float
fi

if [ -n "$fmt_SOURCE" ]; then
    echo "Fetching fmt..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt
fi

if [ -n "$glog_SOURCE" ]; then
    echo "Fetching glog..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog
fi

if [ -n "$googletest_SOURCE" ]; then
    echo "Fetching googletest..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests googletest
fi

if [ -n "$liboqs_SOURCE" ]; then
    echo "Fetching liboqs..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs
fi

if [ -n "$libunwind_SOURCE" ]; then
    echo "Fetching libunwind..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind
fi

if [ -n "$xz_SOURCE" ]; then
    echo "Fetching xz..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz
fi

if [ -n "$folly_SOURCE" ]; then
    echo "Fetching folly..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly
fi

if [ -n "$fizz_SOURCE" ]; then
    echo "Fetching fizz..."
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz
fi

# Build mvfst
echo "Building mvfst..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. mvfst --project-install-prefix mvfst:/usr/local

# Copy artifacts (optional, for local inspection)
echo "Copying artifacts..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. mvfst _artifacts/linux --project-install-prefix mvfst:/usr/local --final-install-prefix /usr/local

# Test mvfst
echo "Testing mvfst..."
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. mvfst --project-install-prefix mvfst:/usr/local

echo "Build and test completed successfully!"