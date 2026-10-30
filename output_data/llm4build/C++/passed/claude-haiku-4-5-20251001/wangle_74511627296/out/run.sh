#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Update system package info
sudo --preserve-env=http_proxy apt-get update

# Install system dependencies for wangle and patchelf
# This will build glog, liboqs, fmt and other dependencies from source
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive wangle
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Fetch all dependencies (they go to getdeps' internal temp directory)
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests boost
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests googletest
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz

# Build dependencies from source (without --src-dir=. so getdeps uses its internal paths)
python3 build/fbcode_builder/getdeps.py --allow-system-packages build fmt
python3 build/fbcode_builder/getdeps.py --allow-system-packages build glog
python3 build/fbcode_builder/getdeps.py --allow-system-packages build liboqs
python3 build/fbcode_builder/getdeps.py --allow-system-packages build folly
python3 build/fbcode_builder/getdeps.py --allow-system-packages build fizz

# Build wangle with --src-dir=. to use the workspace as the source
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. wangle --project-install-prefix wangle:/usr/local

# Test wangle with --src-dir=. to use the workspace as the source
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. wangle --project-install-prefix wangle:/usr/local

echo "Build and test completed successfully!"