#!/bin/bash
set -e

cd /workspace

# Update system package info
sudo --preserve-env=http_proxy apt-get update

# Install system deps
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive proxygen
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Query paths
python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. proxygen

# Fetch dependencies
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests c-ares || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests googletest || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests gperf || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests mvfst || true
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests wangle || true

# Build proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. proxygen --project-install-prefix proxygen:/usr/local

# Copy artifacts
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. proxygen _artifacts/linux --project-install-prefix proxygen:/usr/local --final-install-prefix /usr/local

# Test proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. proxygen --project-install-prefix proxygen:/usr/local

echo "Build and test completed successfully!"