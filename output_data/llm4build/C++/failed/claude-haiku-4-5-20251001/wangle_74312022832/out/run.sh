#!/bin/bash
set -e

cd /workspace

# Update system package info
sudo --preserve-env=http_proxy apt-get update

# Install system deps for wangle and patchelf
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Query paths
PATHS_OUTPUT=$(python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. wangle)

# Extract path variables from output
eval "$PATHS_OUTPUT"

# Fetch dependencies (conditionally based on paths output)
if [ -n "$fast_float_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float
fi

if [ -n "$fmt_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt
fi

if [ -n "$glog_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog
fi

if [ -n "$googletest_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests googletest
fi

if [ -n "$liboqs_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs
fi

if [ -n "$libunwind_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind
fi

if [ -n "$xz_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz
fi

if [ -n "$folly_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly
fi

if [ -n "$fizz_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz
fi

# Build wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. wangle --project-install-prefix wangle:/usr/local

# Copy artifacts
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. wangle _artifacts/linux --project-install-prefix wangle:/usr/local --final-install-prefix /usr/local

# Test wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. wangle --project-install-prefix wangle:/usr/local