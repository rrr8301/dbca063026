#!/bin/bash

set -e

# Update system package info
apt-get update

# Install system deps for proxygen and patchelf
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Query paths for dependencies
PATHS_OUTPUT=$(python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. proxygen)

# Extract individual path variables from output
eval "$PATHS_OUTPUT"

# Fetch c-ares if needed
if [ -n "$c_ares_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests c-ares
fi

# Fetch fast_float if needed
if [ -n "$fast_float_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float
fi

# Fetch fmt if needed
if [ -n "$fmt_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt
fi

# Fetch glog if needed
if [ -n "$glog_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog
fi

# Fetch googletest if needed
if [ -n "$googletest_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests googletest
fi

# Fetch liboqs if needed
if [ -n "$liboqs_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs
fi

# Fetch gperf if needed
if [ -n "$gperf_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests gperf
fi

# Fetch libunwind if needed
if [ -n "$libunwind_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind
fi

# Fetch xz if needed
if [ -n "$xz_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz
fi

# Fetch folly if needed
if [ -n "$folly_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly
fi

# Fetch fizz if needed
if [ -n "$fizz_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz
fi

# Fetch mvfst if needed
if [ -n "$mvfst_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests mvfst
fi

# Fetch wangle if needed
if [ -n "$wangle_SOURCE" ]; then
    python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests wangle
fi

# Build proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. proxygen --project-install-prefix proxygen:/usr/local

# Copy artifacts
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. proxygen _artifacts/linux --project-install-prefix proxygen:/usr/local --final-install-prefix /usr/local

# Test proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. proxygen --project-install-prefix proxygen:/usr/local