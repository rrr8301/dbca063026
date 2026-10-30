#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Update system package info
sudo --preserve-env=http_proxy apt-get update

# Install system dependencies for wangle and patchelf
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive wangle
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Query paths to determine which dependencies need to be fetched
PATHS_OUTPUT=$(python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. wangle)

# Extract individual path variables
BOOST_SOURCE=$(echo "$PATHS_OUTPUT" | grep "^boost_SOURCE=" | cut -d'=' -f2)
FAST_FLOAT_SOURCE=$(echo "$PATHS_OUTPUT" | grep "^fast_float_SOURCE=" | cut -d'=' -f2)
FMT_SOURCE=$(echo "$PATHS_OUTPUT" | grep "^fmt_SOURCE=" | cut -d'=' -f2)
GLOG_SOURCE=$(echo "$PATHS_OUTPUT" | grep "^glog_SOURCE=" | cut -d'=' -f2)
GOOGLETEST_SOURCE=$(echo "$PATHS_OUTPUT" | grep "^googletest_SOURCE=" | cut -d'=' -f2)
LIBOQS_SOURCE=$(echo "$PATHS_OUTPUT" | grep "^liboqs_SOURCE=" | cut -d'=' -f2)
LIBUNWIND_SOURCE=$(echo "$PATHS_OUTPUT" | grep "^libunwind_SOURCE=" | cut -d'=' -f2)
XZ_SOURCE=$(echo "$PATHS_OUTPUT" | grep "^xz_SOURCE=" | cut -d'=' -f2)
FOLLY_SOURCE=$(echo "$PATHS_OUTPUT" | grep "^folly_SOURCE=" | cut -d'=' -f2)
FIZZ_SOURCE=$(echo "$PATHS_OUTPUT" | grep "^fizz_SOURCE=" | cut -d'=' -f2)

# Fetch dependencies conditionally
[ -n "$BOOST_SOURCE" ] && python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests boost
[ -n "$FAST_FLOAT_SOURCE" ] && python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float
[ -n "$FMT_SOURCE" ] && python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt
[ -n "$GLOG_SOURCE" ] && python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog
[ -n "$GOOGLETEST_SOURCE" ] && python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests googletest
[ -n "$LIBOQS_SOURCE" ] && python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs
[ -n "$LIBUNWIND_SOURCE" ] && python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind
[ -n "$XZ_SOURCE" ] && python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz
[ -n "$FOLLY_SOURCE" ] && python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly
[ -n "$FIZZ_SOURCE" ] && python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz

# Build wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. wangle --project-install-prefix wangle:/usr/local

# Test wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. wangle --project-install-prefix wangle:/usr/local

echo "Build and test completed successfully!"